const Vec2 = @import("vec2.zig").Vec2;
const std = @import("std");

pub const Isometry2D = struct {
    translation: Vec2,
    rotation: Vec2,

    pub fn identity() Isometry2D {
        return Isometry2D{ .translation = Vec2.zero(), .rotation = Vec2.new(1, 0) };
    }

    pub fn new(translation: Vec2, rotation: Vec2) Isometry2D {
        return Isometry2D{ .translation = translation, .rotation = rotation };
    }

    pub fn fromRotation(rotation: Vec2) Isometry2D {
        return Isometry2D{ .translation = Vec2.zero(), .rotation = rotation };
    }

    pub fn fromTranslation(translation: Vec2) Isometry2D {
        return Isometry2D{ .translation = translation, .rotation = Vec2.new(1, 0) };
    }

    pub fn mulMut(self: *Isometry2D, other: Isometry2D) void {
        var shift = other.translation;
        shift.rotateMut(self.rotation);
        self.translation.addMut(shift);
        self.rotation.rotateMut(other.rotation);
    }

    pub fn mul(self: *const Isometry2D, other: Isometry2D) Isometry2D {
        var iso = self.*;
        iso.mulMut(other);
        return iso;
    }

    pub fn transform(self: *const Isometry2D, _pt: Vec2) Vec2 {
        var pt = _pt;
        pt.rotateMut(self.rotation);
        pt.addMut(self.translation);
        return pt;
    }

    pub fn inverseMut(self: *Isometry2D) void {
        self.rotation.y *= -1.0;
        self.translation.scaleMut(-1.0);
        self.translation.rotateMut(self.rotation);
    }

    pub fn inverse(self: *const Isometry2D) Isometry2D {
        var iso = self.*;
        iso.inverseMut();
        return iso;
    }

    // Calculate self.inverse() * other
    pub fn invMul(self: *const Isometry2D, other: Isometry2D) Isometry2D {
        var rotation = self.rotation;
        rotation.y *= -1.0;
        var translation = other.translation;
        translation.subMut(self.translation);
        translation.rotateMut(rotation);
        rotation.rotateMut(other.rotation);
        return Isometry2D.new(translation, rotation);
    }
};

test "identity" {
    const iso = Isometry2D.identity();
    const pt = Vec2.new(1, 2);

    try std.testing.expectEqual(iso.transform(pt), pt);
}

test "mul" {
    const iso1 = Isometry2D.identity();
    const iso2 = Isometry2D.new(Vec2.new(1, 2), Vec2.new(1.0 / @sqrt(2.0), 1.0 / @sqrt(2.0)));

    try std.testing.expectEqual(iso2.mul(iso1), iso2);
}

test "inverse" {
    const iso = Isometry2D.new(Vec2.new(1, 2), Vec2.new(1.0 / @sqrt(2.0), 1.0 / @sqrt(2.0)));
    const pt = Vec2.new(1, 2);
    const tPt = iso.transform(pt);
    const inverse = iso.inverse();
    const iPt = inverse.transform(tPt);

    try std.testing.expectApproxEqAbs(pt.x, iPt.x, 0.0001);
    try std.testing.expectApproxEqAbs(pt.y, iPt.y, 0.0001);
}

test "invMul" {
    const iso1 = Isometry2D.new(Vec2.new(1, 2), Vec2.new(1.0 / @sqrt(2.0), 1.0 / @sqrt(2.0)));
    const iso2 = Isometry2D.new(Vec2.new(10, 20), Vec2.new(1.0 / @sqrt(2.0), -1.0 / @sqrt(2.0)));

    const res1 = iso1.invMul(iso2);
    const res2 = iso1.inverse().mul(iso2);
    try std.testing.expectApproxEqAbs(res1.translation.x, res2.translation.x, 0.0001);
    try std.testing.expectApproxEqAbs(res1.translation.y, res2.translation.y, 0.0001);
    try std.testing.expectApproxEqAbs(res1.rotation.x, res2.rotation.x, 0.0001);
    try std.testing.expectApproxEqAbs(res1.rotation.y, res2.rotation.y, 0.0001);
}
