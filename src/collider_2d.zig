const Vec2 = @import("vec2.zig").Vec2;
const CollisionShapes = @import("collision_shapes_2d.zig");
const CollisionShape = CollisionShapes.CollisionShape;
const CollisionInfo = CollisionShapes.CollisionInfo;
const Transform = @import("transform.zig").Transform2D;
const std = @import("std");

pub const Collider2D = struct { shape: CollisionShape, transform: Transform, mass: f32 };

pub const CollisionDetector2D = struct {
    colliders: []const Collider2D,
    index1: usize,
    index2: usize,

    pub fn new(colliders: []const Collider2D) CollisionDetector2D {
        return CollisionDetector2D{ .colliders = colliders, .index1 = 0, .index2 = 0 };
    }

    pub fn nextCollision(self: *CollisionDetector2D) ?CollisionInfo {
        var res: ?CollisionInfo = null;
        var index1 = self.index1;
        var index2 = self.index2;

        outer: while (index1 < self.colliders.len) {
            while (index2 < self.colliders.len) {
                defer index2 += 1;
                if (index1 == index2)
                    continue;
                const collider1 = self.colliders[index1];
                const collider2 = self.colliders[index2];

                var offset = collider1.transform;
                offset.translation.subtract(collider2.transform.translation);
                offset.translation.rotate(collider2.transform.rotation.scaled(-1.0));
                res = CollisionShapes.checkCollisions(collider1.shape, collider2.shape, offset);
                if (res != null) break :outer;
            }
            index1 += 1;
            index2 = 0;
        }

        self.index1 = index1;
        self.index2 = index2;
        return res;
    }
};
