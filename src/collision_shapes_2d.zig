const Vec2 = @import("vec2.zig").Vec2;
const Transform = @import("transform.zig").Transform2D;

pub const Capsule = struct {
    height: f32,
    radius: f32,
};

pub const ConvexPolygon = struct {
    points: [*]f32,
};

pub const Rectangle = struct {
    halfWidth: f32,
    halfHeight: f32,

    pub inline fn new(halfWidth: f32, halfHeight: f32) Rectangle {
        return Rectangle{ .halfWidth = halfWidth, .halfHeight = halfHeight };
    }

    pub inline fn fromVec(halfExtent: Vec2) Rectangle {
        return Rectangle{ .halfWidth = halfExtent.x, .halfHeight = halfExtent.y };
    }
};

pub const Sphere = struct {
    radius: f32,
};

pub const CollisionShape = union(enum) {
    capsule: Capsule,
    convexPolygon: ConvexPolygon,
    rectangle: Rectangle,
    sphere: Sphere,
};

pub const CollisionInfo = struct {
    value: []const u8,
};

fn checkRectangleRectangleCollisionAxis(rect1: Rectangle, rect2: Rectangle, transform: Transform) ?Vec2 {
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

pub fn checkRectangleRectangleCollision(rect1: Rectangle, rect2: Rectangle, difference: Transform) ?CollisionInfo {
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

    return CollisionInfo{ .value = "Rectangle" };
}

pub fn checkRectangleSphereCollision(rect: Rectangle, sphere: Sphere, transform: Transform) ?CollisionInfo {
    _ = rect;
    _ = sphere;
    _ = transform;
    // return CollisionInfo{ .value = "Sphere" };
    return null;
}

inline fn checkCollisionsRectangleShape(rectangle: Rectangle, shape: CollisionShape, transform: Transform) ?CollisionInfo {
    switch (shape) {
        CollisionShape.rectangle => |rectangle2| return checkRectangleRectangleCollision(rectangle, rectangle2, transform),
        CollisionShape.sphere => |sphere| return checkRectangleSphereCollision(rectangle, sphere, transform),
        else => return null,
    }
}

pub fn checkCollisions(shape1: CollisionShape, shape2: CollisionShape, transform: Transform) ?CollisionInfo {
    switch (shape1) {
        CollisionShape.rectangle => |rectangle| return checkCollisionsRectangleShape(rectangle, shape2, transform),
        else => return null,
    }
}
