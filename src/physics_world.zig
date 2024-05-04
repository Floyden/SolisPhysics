const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const Colliders = @import("collider_2d.zig");

pub const RigidBody = struct {
    colliderId: u64,
    velocity: Vec2,
    forces: Vec2,
    mass: f32,

    pub inline fn applyForce(self: *RigidBody, force: Vec2) void {
        self.forces.addMut(force);
    }

    pub inline fn resetForces(self: *RigidBody) void {
        self.forces = Vec2.zero();
    }
};

pub const PhysicsWorld = struct {
    colliderList: std.ArrayList(Colliders.Collider2D),
    rigidBodyList: std.ArrayList(RigidBody),
    collisionList: std.ArrayList(Colliders.CollisionInfo2D),
    gravity: Vec2,

    pub fn new() PhysicsWorld {
        return PhysicsWorld{
            .colliderList = std.ArrayList(Colliders.Collider2D).init(std.heap.page_allocator),
            .rigidBodyList = std.ArrayList(RigidBody).init(std.heap.page_allocator),
            .collisionList = std.ArrayList(Colliders.CollisionInfo2D).init(std.heap.page_allocator),
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

    pub fn resetForces(self: *PhysicsWorld) void {
        for (self.rigidBodyList.items) |*rb| {
            rb.resetForces();
        }
    }

    pub fn applyGravity(self: *PhysicsWorld) void {
        for (self.rigidBodyList.items) |*rb| {
            if (rb.mass == 0.0) continue;
            rb.applyForce(self.gravity);
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

    pub fn step(self: *PhysicsWorld, dt: f32) !void {
        if (dt != 0.0) {
            self.resetForces();
            self.applyGravity();

            self.applyMidpointMethod(dt);
        }

        var detector = Colliders.CollisionDetector2D.new(&self.colliderList.items);
        self.collisionList.clearRetainingCapacity();
        while (detector.nextCollision()) |collision| {
            try self.collisionList.append(collision);
        }
    }
};
