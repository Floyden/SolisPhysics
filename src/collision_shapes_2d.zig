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

    pub fn calculateInertia(self: CollisionShape, mass: f32) f32 {
        switch (self) {
            CollisionShape.line => |line| {
                return mass * line.length * line.length / 12.0;
            },
            CollisionShape.rectangle => |rect| {
                // m(w^2 + h^2) / 12 = m((2*halfWidth)^2 + (2*halfHeight)^2) / 12
                return mass * (rect.halfWidth * rect.halfWidth + rect.halfHeight * rect.halfHeight) / 3.0;
            },
            CollisionShape.sphere => |sphere| {
                // m(w^2 + h^2) / 12 = m((2*halfWidth)^2 + (2*halfHeight)^2) / 12
                return 0.5 * mass * sphere.radius * sphere.radius;
            },
            CollisionShape.capsule => |capsule| {
                const rr = capsule.radius * capsule.radius;
                const hh = capsule.height * capsule.height;
                const circleInertia = 0.5 * (rr + hh);
                const rectInertia = (4.0 * rr + hh) / 12.0;
                return mass * (circleInertia + rectInertia);
            },
            else => {
                return 1.0;
            },
        }
        return 1.0;
    }
};
