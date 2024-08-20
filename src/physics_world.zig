const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const Colliders = @import("collider_2d.zig");
const Isometry2D = @import("isometry.zig").Isometry2D;

pub const RigidBody = struct {
    colliderId: u64,
    velocity: Vec2,
    forces: Vec2,
    angularVelocity: f32,
    torque: f32,
    mass: f32,

    pub fn new(collider: u64, mass: f32) RigidBody {
        return RigidBody{
            .colliderId = collider,
            .velocity = Vec2.zero(),
            .angularVelocity = 0.0,
            .forces = Vec2.zero(),
            .torque = 0,
            .mass = mass,
        };
    }

    pub inline fn applyForce(self: *RigidBody, force: Vec2, point: Vec2) void {
        self.forces.addMut(force);
        self.torque += force.y * point.x - force.x * point.y;
    }

    pub inline fn resetForces(self: *RigidBody) void {
        self.forces = Vec2.zero();
        self.torque = 0;
    }
};

pub const PhysicsWorld = struct {
    colliderList: std.ArrayList(Colliders.Collider2D),
    rigidBodyList: std.ArrayList(RigidBody),
    collisionList: std.ArrayList(Colliders.CollisionInfo2D),
    predictions: std.ArrayList(Isometry2D),
    gravity: Vec2,

    pub fn new(allocator: std.mem.Allocator) PhysicsWorld {
        return PhysicsWorld{
            .colliderList = std.ArrayList(Colliders.Collider2D).init(allocator),
            .rigidBodyList = std.ArrayList(RigidBody).init(allocator),
            .predictions = std.ArrayList(Isometry2D).init(allocator),
            .collisionList = std.ArrayList(Colliders.CollisionInfo2D).init(allocator),
            .gravity = Vec2.new(0.0, 9.81),
        };
    }

    pub fn deinit(self: *PhysicsWorld) void {
        self.rigidBodyList.deinit();
        self.colliderList.deinit();
        self.collisionList.deinit();
    }

    pub fn addCollider(self: *PhysicsWorld, collider: Colliders.Collider2D) u64 {
        self.colliderList.append(collider) catch unreachable;
        return self.colliderList.items.len - 1;
    }

    pub fn getCollider(self: *PhysicsWorld, id: u64) *Colliders.Collider2D {
        return &self.colliderList.items[id];
    }

    pub fn addRigidBody(self: *PhysicsWorld, collider: RigidBody) u64 {
        self.rigidBodyList.append(collider) catch unreachable;
        return self.rigidBodyList.items.len - 1;
    }

    pub fn getRigidBody(self: *PhysicsWorld, rid: u64) *RigidBody {
        return &self.rigidBodyList.items[rid];
    }

    pub fn getRigidBodyOfCollider(self: *PhysicsWorld, cid: u64) ?*RigidBody {
        for (self.rigidBodyList.items) |*rb| {
            if (rb.colliderId == cid) {
                return rb;
            }
        }
        return null;
    }

    pub fn resetForces(self: *PhysicsWorld) void {
        for (self.rigidBodyList.items) |*rb| {
            rb.resetForces();
        }
    }

    pub fn applyGravity(self: *PhysicsWorld) void {
        for (self.rigidBodyList.items) |*rb| {
            if (rb.mass == 0.0) continue;
            rb.applyForce(self.gravity, Vec2.zero());
        }
    }

    pub fn predictMidpointMethod(self: *PhysicsWorld, dt: f32) void {
        for (self.rigidBodyList.items, self.predictions.items) |rb, *pred| {
            if (rb.mass == 0.0) continue;
            var transform = &self.colliderList.items[rb.colliderId].transform;
            const v_next = rb.velocity.add(rb.forces.scale(dt / rb.mass));
            const _pred = transform.translation.add(v_next.add(rb.velocity).scale(0.5 * dt));

            pred.translation = _pred;
        }
    }

    pub fn applyMidpointMethod(self: *PhysicsWorld, dt: f32) void {
        for (self.rigidBodyList.items) |*rb| {
            if (rb.mass == 0.0) continue;
            var transform = &self.colliderList.items[rb.colliderId].transform;
            const v_next = rb.velocity.add(rb.forces.scale(dt / rb.mass));
            transform.translation.addMut(v_next.add(rb.velocity).scale(0.5 * dt));
            rb.velocity = v_next;
        }
    }

    pub fn handleCollisions(self: *PhysicsWorld, dt: f32) !void {
        var detector = Colliders.CollisionDetector2D.new(&self.colliderList.items);
        self.collisionList.clearRetainingCapacity();
        while (detector.nextCollision()) |collision| {
            try self.collisionList.append(collision);
            if (dt != 0.0) {
                const rb1 = self.getRigidBodyOfCollider(collision.colliderIds[0]).?;
                const rb2 = self.getRigidBodyOfCollider(collision.colliderIds[1]).?;

                if (rb1.mass + rb2.mass == 0.0) continue; // Both bodies are static

                const v1 = rb1.velocity;
                const v2 = rb2.velocity;

                const invMass = 1.0 / (rb1.mass + rb2.mass);

                const normal1 = collision.colliders[0].transform.rotate(collision.contactInfo.normals[0]);
                const normal2 = collision.colliders[1].transform.rotate(collision.contactInfo.normals[1]);

                if (rb1.mass != 0.0) {
                    rb1.velocity = v2.scale(rb2.mass * invMass).sub(v1).reflect(normal2);

                    const correction = normal2.scale(collision.contactInfo.depth * rb1.mass * invMass);
                    var collider = &self.colliderList.items[collision.colliderIds[0]];
                    collider.transform.translation.addMut(correction);
                }

                if (rb2.mass != 0.0) {
                    rb2.velocity = v1.scale(2 * rb1.mass / rb2.mass).add(v2.scale(1.0 - rb1.mass / invMass)).reflect(normal1);

                    const correction = normal1.scale(collision.contactInfo.depth * rb2.mass * invMass);
                    var collider = &self.colliderList.items[collision.colliderIds[1]];
                    collider.transform.translation.addMut(correction);
                }
            }
        }
    }

    pub fn step(self: *PhysicsWorld, dt: f32) !void {
        // Assert same size
        self.predictions.resize(self.rigidBodyList.items.len) catch unreachable;
        if (dt != 0.0) {
            self.resetForces();
            self.applyGravity();

            self.predictMidpointMethod(dt);
        }

        try self.handleCollisions(dt);

        if (dt != 0.0) {
            self.applyMidpointMethod(dt);
        }
    }
};
