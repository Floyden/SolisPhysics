const Vec2 = @import("vec2.zig").Vec2;
const CollisionShapes = @import("collision_shapes_2d.zig");
const CollisionShape = CollisionShapes.CollisionShape;
const Isometry2D = @import("isometry.zig").Isometry2D;
const std = @import("std");
const CollisionDetection = @import("collision_detection_2d.zig");

pub const Collider2D = struct {
    pub fn new(shape: CollisionShape, transform: Isometry2D) Collider2D {
        return Collider2D{ .shape = shape, .transform = transform };
    }

    shape: CollisionShape,
    transform: Isometry2D,
};
pub const CollisionInfo2D = struct { colliders: [2]*const Collider2D, contactInfo: CollisionDetection.CollisionContactInfo2D };

pub const CollisionDetector2D = struct {
    colliders: *[]const Collider2D,
    index1: usize,
    index2: usize,

    pub fn new(colliders: *[]const Collider2D) CollisionDetector2D {
        return CollisionDetector2D{ .colliders = colliders, .index1 = 0, .index2 = 1 };
    }

    pub fn nextCollision(self: *CollisionDetector2D) ?CollisionInfo2D {
        var res: ?CollisionInfo2D = null;
        var index1 = self.index1;
        var index2 = self.index2;

        outer: while (index1 < self.colliders.len) {
            while (index2 < self.colliders.len) {
                defer index2 += 1;
                const collider1: *const Collider2D = &self.colliders.*[index1];
                const collider2: *const Collider2D = &self.colliders.*[index2];

                const offset = collider2.transform.invMul(collider1.transform);
                const contactInfo = CollisionDetection.checkCollisions(collider1.shape, collider2.shape, offset);
                if (contactInfo != null) {
                    res = CollisionInfo2D{ .colliders = .{ collider1, collider2 }, .contactInfo = contactInfo.? };
                    break :outer;
                }
            }
            index1 += 1;
            index2 = index1 + 1;
        }

        self.index1 = index1;
        self.index2 = index2;
        return res;
    }
};
