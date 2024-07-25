pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    pub inline fn zero() Vec2 {
        return Vec2{ .x = 0.0, .y = 0.0 };
    }

    pub inline fn right() Vec2 {
        return Vec2{ .x = 1.0, .y = 0.0 };
    }

    pub inline fn left() Vec2 {
        return Vec2{ .x = -1.0, .y = 0.0 };
    }

    pub inline fn up() Vec2 {
        return Vec2{ .x = 0.0, .y = 1.0 };
    }

    pub inline fn down() Vec2 {
        return Vec2{ .x = 0.0, .y = -1.0 };
    }

    pub inline fn new(x: f32, y: f32) Vec2 {
        return Vec2{ .x = x, .y = y };
    }

    pub inline fn len(self: Vec2) f32 {
        return @sqrt(self.len2());
    }

    pub inline fn len2(self: Vec2) f32 {
        return self.x * self.x + self.y * self.y;
    }

    pub inline fn dot(self: Vec2, other: Vec2) f32 {
        return self.x * other.x + self.y * other.y;
    }

    pub inline fn addMut(self: *Vec2, other: Vec2) void {
        self.x += other.x;
        self.y += other.y;
    }

    pub inline fn add(self: *const Vec2, other: Vec2) Vec2 {
        var res = self.*;
        res.addMut(other);
        return res;
    }

    pub inline fn subMut(self: *Vec2, other: Vec2) void {
        self.x -= other.x;
        self.y -= other.y;
    }

    pub inline fn sub(self: *const Vec2, other: Vec2) Vec2 {
        var res = self.*;
        res.subMut(other);
        return res;
    }

    pub inline fn normalizeMut(self: *Vec2) void {
        const lenInv = 1.0 / self.len();
        self.*.x *= lenInv;
        self.*.y *= lenInv;
    }

    pub inline fn normalize(self: *const Vec2) Vec2 {
        var res = self.*;
        res.normalizeMut();
        return res;
    }

    pub inline fn scaleMut(self: *Vec2, scalar: f32) void {
        self.*.x *= scalar;
        self.*.y *= scalar;
    }

    pub inline fn scale(self: *const Vec2, scalar: f32) Vec2 {
        var res = self.*;
        res.scaleMut(scalar);
        return res;
    }

    pub inline fn rotateMut(self: *Vec2, other: Vec2) void {
        const tX = self.x;
        const tY = self.y;
        self.x = tX * other.x - tY * other.y;
        self.y = tX * other.y + tY * other.x;
    }

    pub inline fn rotate(self: *const Vec2, other: Vec2) Vec2 {
        var res = self.*;
        res.rotateMut(other);
        return res;
    }

    pub inline fn rotateRad(self: *Vec2, ang: f32) void {
        const tX = self.x;
        const tY = self.y;
        self.x = tX * @cos(ang) - tY * @sin(ang);
        self.y = tX * @sin(ang) + tY * @cos(ang);
    }

    pub inline fn reflect(self: *const Vec2, axis: Vec2) Vec2 {
        const d = self.dot(axis);
        const x = 2 * d * axis.x - self.x;
        const y = 2 * d * axis.y - self.y;
        return Vec2.new(x, y);
    }
};

const std = @import("std");
test "rotate" {
    // Rotation by 90 degrees
    var t1 = Vec2.new(1, 0);
    t1.rotate(Vec2.new(0, 1));
    try std.testing.expectEqual(t1, Vec2.new(0, 1));

    // Rotation by 180 degrees
    t1 = Vec2.new(1, 0);
    t1.rotate(Vec2.new(-1, 0));
    try std.testing.expectEqual(t1, Vec2.new(-1, 0));

    // Rotation by 45 degrees
    t1 = Vec2.new(1, 0);
    t1.rotate(Vec2.new(1.0 / @sqrt(2.0), 1.0 / @sqrt(2.0)));
    try std.testing.expectEqual(t1, Vec2.new(1.0 / @sqrt(2.0), 1.0 / @sqrt(2.0)));
}
