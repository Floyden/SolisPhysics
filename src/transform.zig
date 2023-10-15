const Vec2 = @import("vec2.zig").Vec2;

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
};
