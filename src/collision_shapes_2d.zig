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

pub fn checkRectangleRectangleCollision(rect1: Rectangle, rect2: Rectangle, transform: Transform) ?CollisionInfo {
    _ = rect1;
    _ = rect2;
    _ = transform;
    return CollisionInfo{ .value = "Rect" };
}

pub fn checkRectangleSphereCollision(rect: Rectangle, sphere: Sphere, transform: Transform) ?CollisionInfo {
    _ = rect;
    _ = sphere;
    _ = transform;
    return CollisionInfo{ .value = "Sphere" };
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
