const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const CollisionShapes = @import("collision_shapes_2d.zig");
const CollisionShape = CollisionShapes.CollisionShape;
const Transform = @import("transform.zig").Transform2D;
const Collider = @import("collider_2d.zig");

pub fn main() !void {
    const rect1 = CollisionShapes.Rectangle.new(1.0, 1.0);
    const rect1Shape = CollisionShape{ .rectangle = rect1 };
    const rect2 = CollisionShapes.Sphere{ .radius = 1.0 };
    const rect2Shape = CollisionShape{ .sphere = rect2 };
    const transform = Transform.fromTranslation(Vec2.new(2.0, 0.0));

    //const res = CollisionShapes.checkCollisions(rect1Shape, rect2Shape, transform);
    var colliderArray = std.ArrayList(Collider.Collider2D).init(std.heap.page_allocator);
    defer colliderArray.deinit();

    try colliderArray.append(Collider.Collider2D{ .shape = rect1Shape, .transform = transform });
    try colliderArray.append(Collider.Collider2D{ .shape = rect2Shape, .transform = transform });

    const res = Collider.detectCollisions(colliderArray);
    defer res.deinit();
    if (res.items.len != 0) {
        std.debug.print("CollisionInfo {}\n", .{res});
    } else {
        std.debug.print("No Collision\n", .{});
    }
}
