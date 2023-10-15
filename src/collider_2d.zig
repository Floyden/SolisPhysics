const Vec2 = @import("vec2.zig").Vec2;
const CollisionShapes = @import("collision_shapes_2d.zig");
const CollisionShape = CollisionShapes.CollisionShape;
const CollisionInfo = CollisionShapes.CollisionInfo;
const Transform = @import("transform.zig").Transform2D;
const std = @import("std");

pub const Collider2D = struct { shape: CollisionShape, transform: Transform, mass: f32 };

pub fn detectCollisions(colliders: std.ArrayList(Collider2D)) std.ArrayList(CollisionInfo) {
    var colliderArray = std.ArrayList(CollisionInfo).init(std.heap.page_allocator);

    for (colliders.items) |collider1| {
        for (colliders.items) |collider2| {
            if (std.meta.eql(collider1, collider2))
                continue;

            var offset = collider1.transform;
            offset.translation.subtract(collider2.transform.translation);
            offset.translation.rotate(collider2.transform.rotation.scaled(-1.0));
            const res = CollisionShapes.checkCollisions(collider1.shape, collider2.shape, offset);
            if (res != null)
                colliderArray.append(res.?) catch unreachable;
        }
    }
    return colliderArray;
}
