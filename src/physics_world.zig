const std = @import("std");
const Collider = @import("collider_2d.zig");

pub const PhysicsWorld = struct {
    colliderList: std.ArrayList(Collider.Collider2D),

    pub fn new() PhysicsWorld {
        return PhysicsWorld{
            .colliderList = std.ArrayList(Collider.Collider2D).init(std.heap.page_allocator),
        };
    }

    pub fn deinit(self: *PhysicsWorld) void {
        self.colliderList.deinit();
    }

    pub fn addCollider(self: *PhysicsWorld, collider: Collider.Collider2D) u64 {
        self.colliderList.append(collider) catch unreachable;
        return self.colliderList.items.len - 1;
    }
};
