const Vec2 = @import("vec2.zig").Vec2;
const std = @import("std");

pub const Transform2D = struct {
    translation: Vec2,
    rotation: Vec2,

    pub fn identity() Transform2D {
        return Transform2D.new(Vec2.zero(), Vec2.new(1.0, 0.0));
    }

    pub fn new(translation: Vec2, rotation: Vec2) Transform2D {
        return Transform2D{ .translation = translation, .rotation = rotation };
    }

    pub fn fromTranslation(translation: Vec2) Transform2D {
        return Transform2D{ .translation = translation, .rotation = Vec2.new(1.0, 0.0) };
    }

    pub fn inverted(self: *const Transform2D) Transform2D {
        return Transform2D{
            .translation = self.*.translation.scaled(-1.0),
            .rotation = Vec2.new(self.*.rotation.x, -self.*.rotation.y),
        };
    }

    pub fn transform(self: Transform2D, vec: Vec2) Vec2 {
        vec.rotate(self.rotation);
        vec.add(self.translation);
        return vec;
    }

    pub fn add(self: *Transform2D, other: Transform2D) void {
        self.translation.add(other.translation);
        self.rotation.rotate(other.rotation);
    }
};

test "add" {
    var t1 = Transform2D.new(Vec2.new(1, 0), Vec2.new(0.5, @sqrt(3.0) / 2.0));
    const t2 = Transform2D.new(Vec2.new(0, -1), Vec2.new(@sqrt(3.0) / 2.0, 0.5));
    t1.add(t2);

    try std.testing.expectEqual(t1.translation, Vec2.new(1, -1));
    try std.testing.expectEqual(t1.rotation, Vec2.new(0, 1));
}

test "invert" {
    var t1 = Transform2D.new(Vec2.new(1, 1), Vec2.new(0.5, @sqrt(3.0) / 2.0));
    const t2 = t1.inverted();
    t1.add(t2);

    try std.testing.expectEqual(t1, Transform2D.identity());
}
