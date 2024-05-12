const Vec2 = @import("vec2.zig").Vec2;

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

pub const Line = struct { length: f32 };

pub const CollisionShape = union(enum) {
    capsule: Capsule,
    convexPolygon: ConvexPolygon,
    line: Line,
    rectangle: Rectangle,
    sphere: Sphere,

    pub fn newLine(length: f32) @This() {
        return @This(){ .line = Line{ .length = length } };
    }

    pub fn newSphere(radius: f32) @This() {
        return @This(){ .sphere = Sphere{ .radius = radius } };
    }

    pub fn newRectangle(halfWidth: f32, halfHeight: f32) @This() {
        return @This(){ .rectangle = Rectangle.new(halfWidth, halfHeight) };
    }
};
