pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub inline fn zero() Vec2 {
        return Vec2{ .x = 0.0, .y = 0.0 };
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

    pub inline fn dot(self: Vec2, other: *const Vec2) f32 {
        return self.x * other.*.x + self.y * other.*.y;
    }

    pub inline fn normalize(self: *Vec2) void {
        var _len = self.len();
        self.*.x /= _len;
        self.*.y /= _len;
    }

    pub inline fn scale(self: *Vec2, scalar: f32) void {
        self.*.x *= scalar;
        self.*.y *= scalar;
    }

    pub inline fn scaled(self: *const Vec2, scalar: f32) Vec2 {
        var res = self.*;
        res.scale(scalar);
        return res;
    }

    pub inline fn rotate(self: *Vec2, other: *const Vec2) void {
        const tX = self.*.x;
        const tY = self.*.y;
        self.*.x = tX * other.*.x - tY * other.*.y;
        self.*.y = tX * other.*.y + tY * other.*.x;
    }

    pub inline fn rotateRad(self: *Vec2, ang: f32) void {
        const tX = self.*.x;
        const tY = self.*.y;
        self.*.x = tX * @cos(ang) - tY * @sin(ang);
        self.*.y = tX * @sin(ang) + tY * @cos(ang);
    }
};
