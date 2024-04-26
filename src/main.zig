const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const CollisionShapes = @import("collision_shapes_2d.zig");
const CollisionShape = CollisionShapes.CollisionShape;
const Transform = @import("transform.zig").Transform2D;
const Collider = @import("collider_2d.zig");
const PhysicsWorld = @import("physics_world.zig").PhysicsWorld;
const RigidBody = @import("physics_world.zig").RigidBody;
const ray = @cImport({
    @cInclude("raylib.h");
});

fn drawPhysicsRectangle(collider: *Collider.Collider2D, color: ray.Color) void {
    const rExtent = collider.shape.rectangle;
    const rPos = collider.transform.translation;
    ray.DrawRectangle(@intFromFloat(rPos.x - rExtent.halfWidth), @intFromFloat(rPos.y - rExtent.halfHeight), @intFromFloat(2.0 * rExtent.halfWidth), @intFromFloat(2.0 * rExtent.halfHeight), color);
}

pub fn main() !void {
    ray.InitWindow(600, 480, "Test");
    defer ray.CloseWindow();

    var world = PhysicsWorld.new();
    defer world.deinit();

    const rect1Shape = CollisionShape{ .rectangle = CollisionShapes.Rectangle.new(50.0, 50.0) };
    const rect2Shape = CollisionShape{ .rectangle = CollisionShapes.Rectangle.new(50.0, 50.0) };
    const rect3Shape = CollisionShape{ .rectangle = CollisionShapes.Rectangle.new(60.0, 40.0) };
    // const rect2Shape = CollisionShape{ .sphere = CollisionShapes.Sphere{ .radius = 50.0 } };
    const transform = Transform.fromTranslation(Vec2.new(200.0, 100.0));
    const transform2 = Transform.fromTranslation(Vec2.new(300.0, 200.0));

    var colliderArray = std.ArrayList(Collider.Collider2D).init(std.heap.page_allocator);
    defer colliderArray.deinit();

    const c1 = world.addCollider(Collider.Collider2D{ .shape = rect1Shape, .transform = Transform.identity(), .mass = 1.0 });
    const c2 = world.addCollider(Collider.Collider2D{ .shape = rect2Shape, .transform = transform, .mass = 1.0 });
    const c3 = world.addCollider(Collider.Collider2D{ .shape = rect3Shape, .transform = transform2, .mass = 1.0 });

    _ = world.addRigidBody(RigidBody{ .colliderId = c1, .velocity = Vec2.zero(), .forces = Vec2.zero(), .mass = 1.0 });
    _ = world.addRigidBody(RigidBody{ .colliderId = c2, .velocity = Vec2.zero(), .forces = Vec2.zero(), .mass = 1.0 });

    while (!ray.WindowShouldClose()) {
        ray.ClearBackground(ray.Color{ .r = 0, .g = 0, .b = 0, .a = 0 });
        ray.BeginDrawing();

        const mouseX: f32 = @floatFromInt(ray.GetMouseX());
        const mouseY: f32 = @floatFromInt(ray.GetMouseY());

        if (ray.IsMouseButtonDown(0)) {
            world.getCollider(c2).transform.translation.x = mouseX;
            world.getCollider(c2).transform.translation.y = mouseY;
        }
        if (ray.IsMouseButtonDown(1)) {
            world.getCollider(c1).transform.translation.x = mouseX;
            world.getCollider(c1).transform.translation.y = mouseY;
        }
        try world.step(16.0);

        const r = world.getCollider(c1);
        const s = world.getCollider(c2);
        const t = world.getCollider(c3);
        // ray.DrawCircle(@intFromFloat(s.*.transform.translation.x), @intFromFloat(s.*.transform.translation.y), s.*.shape.sphere.radius, ray.MAROON);
        drawPhysicsRectangle(r, ray.GREEN);
        drawPhysicsRectangle(s, ray.MAROON);
        drawPhysicsRectangle(t, ray.MAROON);
        for (world.collisionList.items) |collisions| {
            var point1 = collisions.contactInfo.point1;
            point1.add(collisions.colliders[0].transform.translation);
            ray.DrawCircle(@intFromFloat(point1.x), @intFromFloat(point1.y), 10.0, ray.YELLOW);

            var point2 = collisions.contactInfo.point2;
            point2.add(collisions.colliders[1].transform.translation);
            ray.DrawCircle(@intFromFloat(point2.x), @intFromFloat(point2.y), 10.0, ray.YELLOW);
        }

        ray.EndDrawing();
    }
}
