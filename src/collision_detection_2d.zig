const CollisionShapes = @import("collision_shapes_2d.zig");
const Isometry2D = @import("isometry.zig").Isometry2D;
const Vec2 = @import("vec2.zig").Vec2;
const std = @import("std");

const CollisionShape = CollisionShapes.CollisionShape;
pub const CollisionContactInfo2D = struct { point1: Vec2, point2: Vec2, depth: f32 };

fn checkRectangleRectangleCollisionAxis(rect1: CollisionShapes.Rectangle, rect2: CollisionShapes.Rectangle, transform: Isometry2D) ?Vec2 {
    const up = Vec2.up().rotate(transform.rotation);
    const right = Vec2.right().rotate(transform.rotation);

    const t1 = @abs(transform.translation.dot(right));
    const t2 = @abs(transform.translation.dot(up));
    const t3 = @abs(transform.translation.dot(Vec2.right()));
    const t4 = @abs(transform.translation.dot(Vec2.up()));

    if (t1 > rect1.halfWidth + @abs(right.dot(Vec2.right()) * rect2.halfWidth) + @abs(up.dot(Vec2.right()) * rect2.halfHeight)) return null;
    if (t2 > rect1.halfHeight + @abs(right.dot(Vec2.up()) * rect2.halfWidth) + @abs(up.dot(Vec2.up()) * rect2.halfHeight)) return null;
    if (t3 > rect2.halfWidth + @abs(right.dot(Vec2.right()) * rect1.halfWidth) + @abs(right.dot(Vec2.up()) * rect1.halfHeight)) return null;
    if (t4 > rect2.halfHeight + @abs(up.dot(Vec2.right()) * rect1.halfWidth) + @abs(up.dot(Vec2.up()) * rect1.halfHeight)) return null;

    return Vec2.zero();
}

pub fn checkRectangleRectangleCollision(rect1: CollisionShapes.Rectangle, rect2: CollisionShapes.Rectangle, difference: Isometry2D) ?CollisionContactInfo2D {
    const closest = checkRectangleRectangleCollisionAxis(rect1, rect2, difference);
    if (closest == null)
        return null;

    // [TODO] Calculate closest penetrating corner
    return CollisionContactInfo2D{ .point1 = Vec2.zero(), .point2 = Vec2.zero(), .depth = 0.0 };
}

pub fn checkRectangleSphereCollision(rect: CollisionShapes.Rectangle, sphere: CollisionShapes.Sphere, difference: Isometry2D) ?CollisionContactInfo2D {
    _ = rect;
    _ = sphere;
    _ = difference;
    return null;
}

fn checkLineRectangleCollision(line: CollisionShapes.Line, rectangle: CollisionShapes.Rectangle, difference: Isometry2D) ?CollisionContactInfo2D {
    _ = line;
    _ = rectangle;
    _ = difference;
    return null;
}

fn isLeft(a: Vec2, b: Vec2, c: Vec2) bool {
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x) > 0;
}

fn checkLineLineCollision(line1: CollisionShapes.Line, line2: CollisionShapes.Line, difference: Isometry2D) ?CollisionContactInfo2D {
    const start2 = difference.transform(Vec2.new(-line2.length / 2, 0));
    const end2 = difference.transform(Vec2.new(line2.length / 2, 0));

    const start1 = Vec2.new(-line1.length / 2, 0);
    const end1 = Vec2.new(line1.length / 2, 0);
    if (isLeft(start1, end1, start2) == isLeft(start1, end1, end2) or isLeft(start2, end2, start1) == isLeft(start2, end2, end1)) return null;

    // [TODO] Implement return
    return CollisionContactInfo2D{ .point1 = Vec2.zero(), .point2 = Vec2.zero(), .depth = 0.0 };
}

inline fn checkCollisionsRectangleShape(rectangle: CollisionShapes.Rectangle, shape: CollisionShape, transform: Isometry2D) ?CollisionContactInfo2D {
    switch (shape) {
        CollisionShape.rectangle => |rectangle2| return checkRectangleRectangleCollision(rectangle, rectangle2, transform),
        CollisionShape.sphere => |sphere| return checkRectangleSphereCollision(rectangle, sphere, transform),
        CollisionShape.line => |line| return checkLineRectangleCollision(line, rectangle, transform.inverse()),
        else => return null,
    }
    return null;
}

inline fn checkCollisionsLineShape(line: CollisionShapes.Line, shape: CollisionShape, transform: Isometry2D) ?CollisionContactInfo2D {
    switch (shape) {
        CollisionShape.line => |line2| return checkLineLineCollision(line, line2, transform.inverse()),
        else => return null,
    }
    return null;
}

pub fn checkCollisions(shape1: CollisionShape, shape2: CollisionShape, transform: Isometry2D) ?CollisionContactInfo2D {
    switch (shape1) {
        CollisionShape.rectangle => |rectangle| return checkCollisionsRectangleShape(rectangle, shape2, transform),
        CollisionShape.line => |line| return checkCollisionsLineShape(line, shape2, transform),
        else => return null,
    }
}
