const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const Collider = @import("collider_2d.zig");

pub const RigidBody = struct {
    colliderId: u64,
    velocity: Vec2,
    forces: Vec2,
    mass: f32,
};

pub const PhysicsWorld = struct {
    colliderList: std.ArrayList(Collider.Collider2D),
    rigidBodyList: std.ArrayList(RigidBody),

    pub fn new() PhysicsWorld {
        return PhysicsWorld{
            .colliderList = std.ArrayList(Collider.Collider2D).init(std.heap.page_allocator),
            .rigidBodyList = std.ArrayList(RigidBody).init(std.heap.page_allocator),
        };
    }

    pub fn deinit(self: *PhysicsWorld) void {
        self.rigidBodyList.deinit();
        self.colliderList.deinit();
    }

    pub fn addCollider(self: *PhysicsWorld, collider: Collider.Collider2D) u64 {
        self.colliderList.append(collider) catch unreachable;
        return self.colliderList.items.len - 1;
    }

    pub fn addRigidBody(self: *PhysicsWorld, collider: RigidBody) u64 {
        self.rigidBodyList.append(collider) catch unreachable;
        return self.rigidBodyList.items.len - 1;
    }
};
