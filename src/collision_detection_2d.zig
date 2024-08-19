const CollisionShapes = @import("collision_shapes_2d.zig");
const Isometry2D = @import("isometry.zig").Isometry2D;
const Vec2 = @import("vec2.zig").Vec2;
const std = @import("std");

const CollisionShape = CollisionShapes.CollisionShape;
pub const CollisionContactInfo2D = struct {
    points: [2]Vec2,
    normals: [2]Vec2,
    depth: f32,

    fn swapped(self: CollisionContactInfo2D) CollisionContactInfo2D {
        return CollisionContactInfo2D{ .points = .{ self.points[1], self.points[0] }, .normals = .{ self.normals[1], self.normals[0] }, .depth = self.depth };
    }
};

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

fn getLineLineIntersection(a: Vec2, b: Vec2, c: Vec2, d: Vec2) ?Vec2 {
    const ab = a.sub(b);
    const ac = a.sub(c);
    const cd = c.sub(d);

    const denom = ab.x * cd.y - ab.y * cd.x;
    if (denom == 0) return null;
    // [TODO] Check if 0 <= t <= 1 without dividing first, same for u
    const t = (ac.x * cd.y - ac.y * cd.x) / denom;
    if (!(0 <= t and t <= 1)) return null;

    const u = -(ab.x * ac.y - ab.y * ac.x) / denom;
    if (!(0 <= u and u <= 1)) return null;

    return a.add(b.sub(a).scale(t));
}

pub fn checkRectangleRectangleCollision(rect1: CollisionShapes.Rectangle, rect2: CollisionShapes.Rectangle, difference: Isometry2D) ?CollisionContactInfo2D {
    const rects = [2]CollisionShapes.Rectangle{ rect1, rect2 };
    const transforms = [2]Isometry2D{ difference, difference.inverse() };

    const closest1 = checkRectangleRectangleCollisionAxis(rects[0], rects[1], transforms[0]) orelse return null;
    const closest2 = checkRectangleRectangleCollisionAxis(rects[1], rects[0], transforms[1]) orelse return null;

    var points = [2]Vec2{
        Vec2.new(std.math.copysign(rects[0].halfWidth, transforms[1].translation.x), std.math.copysign(rects[0].halfHeight, transforms[1].translation.y)),
        Vec2.new(std.math.copysign(rects[1].halfWidth, transforms[0].translation.x), std.math.copysign(rects[1].halfHeight, transforms[0].translation.y)),
    };
    var normals = [2]Vec2{
        Vec2.zero(),
        Vec2.zero(),
    };

    // Corner of rects[1-idx] should be colliding with the edge of rects[idx]
    const idx: usize = if (closest1 >= closest2) 1 else 0;
    var orthoCorner = Vec2.new(points[idx].x, -points[idx].y);
    const pointT = transforms[idx].transform(points[idx]);

    const e1 = transforms[idx].transform(orthoCorner);
    const e2 = transforms[idx].transform(orthoCorner.scale(-1.0));
    orthoCorner = if (e1.len2() > e2.len2()) e2 else e1;

    // Get intersection point
    const intersectionOpt = getLineLineIntersection(pointT, orthoCorner, points[1 - idx], Vec2.zero());
    if (intersectionOpt) |intersection|
        points[idx] = transforms[1 - idx].transform(intersection);

    // [TODO] Check if this is correct
    const tolerance = comptime @sqrt(std.math.floatEps(f32));
    normals[idx].x = if (std.math.approxEqRel(f32, @abs(points[idx].x), rects[idx].halfWidth, tolerance)) std.math.copysign(@as(f32, 1.0), points[idx].x) else 0.0;
    normals[idx].y = if (std.math.approxEqRel(f32, @abs(points[idx].y), rects[idx].halfHeight, tolerance)) std.math.copysign(@as(f32, 1.0), points[idx].y) else 0.0;
    if (normals[idx].len2() > 1.0) normals[idx].normalizeMut();
    normals[1 - idx] = transforms[idx].rotate(normals[idx].scale(-1.0));

    const depth = points[1].sub(transforms[0].transform(points[0])).len();
    return CollisionContactInfo2D{ .points = .{ points[0], points[1] }, .normals = .{ normals[0], normals[1] }, .depth = depth };
}

pub fn checkRectangleSphereCollision(rect: CollisionShapes.Rectangle, sphere: CollisionShapes.Sphere, difference: Isometry2D) ?CollisionContactInfo2D {
    // [TODO] Deep penetration seems to be buggy
    var corner = Vec2.new(std.math.copysign(rect.halfWidth, difference.translation.x), std.math.copysign(rect.halfHeight, difference.translation.y));
    const absDiff = Vec2.new(@abs(difference.translation.x), @abs(difference.translation.y));

    var normalRect = Vec2.zero();

    if (absDiff.x - sphere.radius <= rect.halfWidth and absDiff.y < rect.halfHeight) {
        corner.y = difference.translation.y;
        normalRect.x = std.math.copysign(@as(f32, 1.0), difference.translation.x);
    } else if (absDiff.y - sphere.radius <= rect.halfHeight and absDiff.x < rect.halfWidth) {
        corner.x = difference.translation.x;
        normalRect.y = std.math.copysign(@as(f32, 1.0), difference.translation.y);
    } else if (difference.translation.sub(corner).len2() >= sphere.radius * sphere.radius) {
        return null;
    } else {
        normalRect = corner.normalize();
    }

    var diff = difference.translation.sub(corner);
    if (diff.x == 0 and diff.y == 0)
        diff = difference.translation;

    var invRota = difference.rotation;
    invRota.y *= -1.0;
    const normal = diff.normalize().rotate(invRota);
    const point = normal.scale(-sphere.radius);
    const depth = difference.transform(point).sub(corner).len();

    return CollisionContactInfo2D{ .points = .{ corner, point }, .normals = .{ normalRect, normal.scale(-1.0) }, .depth = depth };
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
    const start2 = Vec2.new(-line2.length / 2, 0);
    const end2 = Vec2.new(line2.length / 2, 0);

    const start1 = difference.transform(Vec2.new(-line1.length / 2, 0));
    const end1 = difference.transform(Vec2.new(line1.length / 2, 0));

    const point2 = getLineLineIntersection(start1, end1, start2, end2) orelse return null;
    const invDiff = difference.inverse();

    const point1 = invDiff.transform(point2);
    return CollisionContactInfo2D{ .points = .{ point1, point2 }, .normals = .{ point1.normalize(), point2.normalize() }, .depth = 0.0 };
}

fn checkSphereSphereCollision(sphere1: CollisionShapes.Sphere, sphere2: CollisionShapes.Sphere, difference: Isometry2D) ?CollisionContactInfo2D {
    const radiusSum = sphere1.radius + sphere2.radius;
    const diff = radiusSum * radiusSum - difference.translation.len2();
    if (diff < 0) return null;
    // Special case if two spheres share the same origin
    if (difference.translation.len2() == 0)
        return CollisionContactInfo2D{ .points = .{ Vec2.zero(), Vec2.zero() }, .normals = .{ Vec2.up(), Vec2.up() }, .depth = @max(sphere1.radius, sphere2.radius) };

    var norm = difference;
    norm.translation.normalizeMut();
    const point1 = norm.translation.scale(sphere1.radius);
    const invDiff = norm.inverse();
    const point2 = invDiff.translation.scale(sphere2.radius);
    const depth = radiusSum - difference.translation.len();

    return CollisionContactInfo2D{ .points = .{ point1, point2 }, .normals = .{ point1.normalize(), point2.normalize() }, .depth = depth };
}

inline fn checkCollisionsRectangleShape(rectangle: CollisionShapes.Rectangle, shape: CollisionShape, transform: Isometry2D) ?CollisionContactInfo2D {
    switch (shape) {
        CollisionShape.rectangle => |rectangle2| return checkRectangleRectangleCollision(rectangle, rectangle2, transform),
        CollisionShape.sphere => |sphere| return checkRectangleSphereCollision(rectangle, sphere, transform.inverse()),
        CollisionShape.line => |line| return checkLineRectangleCollision(line, rectangle, transform.inverse()),
        else => return null,
    }
    return null;
}

inline fn checkCollisionsLineShape(line: CollisionShapes.Line, shape: CollisionShape, transform: Isometry2D) ?CollisionContactInfo2D {
    switch (shape) {
        CollisionShape.line => |line2| return checkLineLineCollision(line, line2, transform),
        else => return null,
    }
    return null;
}

inline fn checkCollisionsSphereShape(sphere: CollisionShapes.Sphere, shape: CollisionShape, transform: Isometry2D) ?CollisionContactInfo2D {
    switch (shape) {
        CollisionShape.sphere => |sphere2| return checkSphereSphereCollision(sphere, sphere2, transform.inverse()),
        CollisionShape.rectangle => |rectangle| return if (checkRectangleSphereCollision(rectangle, sphere, transform)) |info| info.swapped() else null,
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
