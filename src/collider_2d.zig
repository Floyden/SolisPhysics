const Vec2 = @import("vec2.zig").Vec2;
const CollisionShapes = @import("collision_shapes_2d.zig");
const CollisionShape = CollisionShapes.CollisionShape;
const Transform = @import("transform.zig").Transform2D;
const std = @import("std");

pub const Collider2D = struct { shape: CollisionShape, transform: Transform, mass: f32 };

pub const CollisionDetector2D = struct {
    colliders: []const Collider2D,
    index1: usize,
    index2: usize,

    pub fn new(colliders: []const Collider2D) CollisionDetector2D {
        return CollisionDetector2D{ .colliders = colliders, .index1 = 0, .index2 = 1 };
    }

    pub fn nextCollision(self: *CollisionDetector2D) ?CollisionContactInfo2D {
        var res: ?CollisionContactInfo2D = null;
        var index1 = self.index1;
        var index2 = self.index2;

        outer: while (index1 < self.colliders.len) {
            while (index2 < self.colliders.len) {
                defer index2 += 1;
                const collider1 = self.colliders[index1];
                const collider2 = self.colliders[index2];

                var offset = collider1.transform;
                offset.translation.subtract(collider2.transform.translation);
                offset.translation.rotate(collider2.transform.rotation.scaled(-1.0));
                res = checkCollisions(collider1.shape, collider2.shape, offset);
                if (res != null) break :outer;
            }
            index1 += 1;
            index2 = index1 + 1;
        }

        self.index1 = index1;
        self.index2 = index2;
        return res;
    }
};

pub const CollisionContactInfo2D = struct { point1: Vec2, point2: Vec2, depth: f32 };

fn checkRectangleRectangleCollisionAxis(rect1: CollisionShapes.Rectangle, rect2: CollisionShapes.Rectangle, transform: Transform) ?Vec2 {
    var up = Vec2.new(1, 0);
    var right = Vec2.new(0, 1);
    up.rotate(transform.rotation);
    up.scale(rect2.halfWidth);
    right.rotate(transform.rotation);
    right.scale(rect2.halfHeight);

    var corners = [4]Vec2{ up, up, up, up };
    corners[0].add(right);
    corners[1].subtract(right);
    corners[2].add(right);
    corners[2].scale(-1);
    corners[3].scale(-1);
    corners[3].add(right);

    const idx: usize = if (@abs(corners[0].x) > @abs(corners[1].x)) 1 else 0;
    for (&corners) |*corner| corner.add(transform.translation);

    if (corners[1 - idx].x > corners[3 - idx].x and (corners[1 - idx].x < -rect1.halfWidth or corners[3 - idx].x > rect1.halfWidth))
        return null;
    if (corners[1 - idx].x < corners[3 - idx].x and (corners[1 - idx].x > rect1.halfWidth or corners[3 - idx].x < -rect1.halfWidth))
        return null;
    if (corners[0 + idx].y > corners[2 + idx].y and (corners[0 + idx].y < -rect1.halfHeight or corners[2 + idx].y > rect1.halfHeight))
        return null;
    if (corners[0 + idx].y < corners[2 + idx].y and (corners[0 + idx].y > rect1.halfHeight or corners[2 + idx].y < -rect1.halfHeight))
        return null;

    var closest = corners[0];
    for (corners[1..]) |corner| {
        if (corner.len2() > closest.len2()) continue;
        closest = corner;
    }
    return closest;
}

pub fn checkRectangleRectangleCollision(rect1: CollisionShapes.Rectangle, rect2: CollisionShapes.Rectangle, difference: Transform) ?CollisionContactInfo2D {
    var closest = checkRectangleRectangleCollisionAxis(rect1, rect2, difference);
    if (closest == null)
        return null;

    var inverseDifference = difference;
    inverseDifference.translation.scale(-1.0);
    inverseDifference.rotation.y *= -1.0;
    inverseDifference.translation.rotate(inverseDifference.rotation);

    closest = checkRectangleRectangleCollisionAxis(rect2, rect1, inverseDifference);
    if (closest == null)
        return null;

    // [TODO] Calculate closest penetrating corner
    return CollisionContactInfo2D{ .point1 = Vec2.zero(), .point2 = Vec2.zero(), .depth = 0.0 };
}

pub fn checkRectangleSphereCollision(rect: CollisionShapes.Rectangle, sphere: CollisionShapes.Sphere, difference: Transform) ?CollisionContactInfo2D {
    _ = rect;
    _ = sphere;
    _ = difference;
    return null;
}

inline fn checkCollisionsRectangleShape(rectangle: CollisionShapes.Rectangle, shape: CollisionShape, transform: Transform) ?CollisionContactInfo2D {
    switch (shape) {
        CollisionShape.rectangle => |rectangle2| return checkRectangleRectangleCollision(rectangle, rectangle2, transform),
        CollisionShape.sphere => |sphere| return checkRectangleSphereCollision(rectangle, sphere, transform),
        else => return null,
    }
    return null;
}

pub fn checkCollisions(shape1: CollisionShape, shape2: CollisionShape, transform: Transform) ?CollisionContactInfo2D {
    switch (shape1) {
        CollisionShape.rectangle => |rectangle| return checkCollisionsRectangleShape(rectangle, shape2, transform),
        else => return null,
    }
}
