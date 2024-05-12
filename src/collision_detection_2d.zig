const CollisionShapes = @import("collision_shapes_2d.zig");
const Isometry2D = @import("isometry.zig").Isometry2D;
const Vec2 = @import("vec2.zig").Vec2;
const std = @import("std");

const CollisionShape = CollisionShapes.CollisionShape;
pub const CollisionContactInfo2D = struct { point1: Vec2, point2: Vec2, depth: f32 };

fn checkRectangleRectangleCollisionAxis(rect1: CollisionShapes.Rectangle, rect2: CollisionShapes.Rectangle, transform: Isometry2D) ?f32 {
    const up = Vec2.up().rotate(transform.rotation);
    const right = Vec2.right().rotate(transform.rotation);

    var t1 = @abs(transform.translation.dot(right));
    var t2 = @abs(transform.translation.dot(up));

    t1 -= rect1.halfWidth + @abs(right.dot(Vec2.right()) * rect2.halfWidth) + @abs(up.dot(Vec2.right()) * rect2.halfHeight);
    t2 -= rect1.halfHeight + @abs(right.dot(Vec2.up()) * rect2.halfWidth) + @abs(up.dot(Vec2.up()) * rect2.halfHeight);
    if (t1 > 0 or t2 > 0) return null;

    return @min(t1, t2);
}

pub fn checkRectangleRectangleCollision(rect1: CollisionShapes.Rectangle, rect2: CollisionShapes.Rectangle, difference: Isometry2D) ?CollisionContactInfo2D {
    const closest1 = checkRectangleRectangleCollisionAxis(rect1, rect2, difference);
    if (closest1 == null)
        return null;

    const invDiff = difference.inverse();
    const closest2 = checkRectangleRectangleCollisionAxis(rect2, rect1, invDiff);
    if (closest2 == null) return null;

    var corner1 = Vec2.zero();
    var corner2 = Vec2.zero();
    if (closest1.? > closest2.?) {
        corner1.x = std.math.copysign(rect1.halfWidth, invDiff.translation.x);
        corner1.y = std.math.copysign(rect1.halfHeight, invDiff.translation.y);
    } else {
        corner2.x = std.math.copysign(rect2.halfWidth, difference.translation.x);
        corner2.y = std.math.copysign(rect2.halfHeight, difference.translation.y);
    }

    // [TODO] Calculate closest penetrating corner
    return CollisionContactInfo2D{ .point1 = corner1, .point2 = corner2, .depth = 0.0 };
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

fn checkSphereSphereCollision(sphere1: CollisionShapes.Sphere, sphere2: CollisionShapes.Sphere, difference: Isometry2D) ?CollisionContactInfo2D {
    const radiusSum = sphere1.radius + sphere2.radius;
    const diff = radiusSum * radiusSum - difference.translation.len2();
    if (diff < 0) return null;
    // Special case if two spheres share the same origin
    if (difference.translation.len2() == 0)
        return CollisionContactInfo2D{ .point1 = Vec2.zero(), .point2 = Vec2.zero(), .depth = radiusSum };

    var norm = difference;
    norm.translation.normalizeMut();
    const point1 = norm.translation.scale(sphere1.radius);
    const invDiff = norm.inverse();
    const point2 = invDiff.translation.scale(sphere2.radius);
    const depth = @sqrt(diff);

    return CollisionContactInfo2D{ .point1 = point1, .point2 = point2, .depth = depth };
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

inline fn checkCollisionsSphereShape(sphere: CollisionShapes.Sphere, shape: CollisionShape, transform: Isometry2D) ?CollisionContactInfo2D {
    switch (shape) {
        CollisionShape.sphere => |sphere2| return checkSphereSphereCollision(sphere, sphere2, transform.inverse()),
        else => return null,
    }
    return null;
}

pub fn checkCollisions(shape1: CollisionShape, shape2: CollisionShape, transform: Isometry2D) ?CollisionContactInfo2D {
    switch (shape1) {
        CollisionShape.rectangle => |rectangle| return checkCollisionsRectangleShape(rectangle, shape2, transform),
        CollisionShape.sphere => |sphere| return checkCollisionsSphereShape(sphere, shape2, transform),
        CollisionShape.line => |line| return checkCollisionsLineShape(line, shape2, transform),
        else => return null,
    }
}
