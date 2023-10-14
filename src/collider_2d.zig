const Vec2 = @import("vec2.zig").Vec2;
const CollisionShape = @import("collision_shapes_2d.zig").CollisionShape;
const CollisionInfo = @import("collision_shapes_2d.zig").CollisionInfo;
const Transform = @import("transform.zig").Transform2D;
const std = @import("std");

pub const Collider2D = struct {
    shape: CollisionShape,
    transform: Transform,
};

pub fn detectCollisions(colliders: std.ArrayList(Collider2D)) std.ArrayList(CollisionInfo) {
    _ = colliders;
    var colliderArray = std.ArrayList(CollisionInfo).init(std.heap.page_allocator);
    return colliderArray;
}
