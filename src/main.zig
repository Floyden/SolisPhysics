const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const CollisionShapes = @import("collision_shapes_2d.zig");
const CollisionShape = CollisionShapes.CollisionShape;
const Transform = @import("transform.zig").Transform2D;
const Collider = @import("collider_2d.zig");
const PhysicsWorld = @import("physics_world.zig").PhysicsWorld;
const RigidBody = @import("physics_world.zig").RigidBody;

pub fn main() !void {
    var world = PhysicsWorld.new();
    defer world.deinit();

    const rect1Shape = CollisionShape{ .rectangle = CollisionShapes.Rectangle.new(1.0, 1.0) };
    const rect2Shape = CollisionShape{ .sphere = CollisionShapes.Sphere{ .radius = 1.0 } };
    const transform = Transform.fromTranslation(Vec2.new(2.0, 0.0));

    var colliderArray = std.ArrayList(Collider.Collider2D).init(std.heap.page_allocator);
    defer colliderArray.deinit();

    const c1 = world.addCollider(Collider.Collider2D{ .shape = rect1Shape, .transform = Transform.identity(), .mass = 1.0 });
    const c2 = world.addCollider(Collider.Collider2D{ .shape = rect2Shape, .transform = transform, .mass = 1.0 });

    _ = world.addRigidBody(RigidBody{ .colliderId = c1, .velocity = Vec2.zero(), .forces = Vec2.zero(), .mass = 1.0 });
    _ = world.addRigidBody(RigidBody{ .colliderId = c2, .velocity = Vec2.zero(), .forces = Vec2.zero(), .mass = 1.0 });

    const res = Collider.detectCollisions(world.colliderList);
    defer res.deinit();
    if (res.items.len != 0) {
        std.debug.print("CollisionInfo {}\n", .{res});
    } else {
        std.debug.print("No Collision\n", .{});
    }
}
