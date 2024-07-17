const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const CollisionShapes = @import("collision_shapes_2d.zig");
const CollisionShape = CollisionShapes.CollisionShape;
const Isometry2D = @import("isometry.zig").Isometry2D;
const Collider2D = @import("collider_2d.zig").Collider2D;
const PhysicsWorld = @import("physics_world.zig").PhysicsWorld;
const RigidBody = @import("physics_world.zig").RigidBody;
const ray = @cImport({
    @cInclude("raylib.h");
});

fn drawPhysicsRectangle(collider: *Collider2D, color: ray.Color) void {
    const rExtent = collider.shape.rectangle;
    const rPos = collider.transform.translation;
    const rect = ray.Rectangle{ .x = rPos.x, .y = rPos.y, .width = (2.0 * rExtent.halfWidth), .height = (2.0 * rExtent.halfHeight) };
    const rotation = std.math.atan2(collider.transform.rotation.y, collider.transform.rotation.x) / std.math.pi * 180.0;
    ray.DrawRectanglePro(rect, ray.Vector2{ .x = rect.width / 2, .y = rect.height / 2 }, rotation, color);
}

fn drawPhysicsLine(collider: *Collider2D, color: ray.Color) void {
    const start = collider.transform.transform(Vec2.new(-collider.shape.line.length / 2.0, 0.0));
    const end = collider.transform.transform(Vec2.new(collider.shape.line.length / 2.0, 0.0));
    ray.DrawLineEx(ray.Vector2{ .x = start.x, .y = start.y }, ray.Vector2{ .x = end.x, .y = end.y }, 1.0, color);
}
fn drawPhysicsSphere(collider: *Collider2D, color: ray.Color) void {
    const x: c_int = @intFromFloat(collider.transform.translation.x);
    const y: c_int = @intFromFloat(collider.transform.translation.y);
    ray.DrawCircle(x, y, collider.shape.sphere.radius, color);
}

fn drawPhysicsObject(collider: *Collider2D, color: ray.Color) void {
    switch (collider.shape) {
        CollisionShape.rectangle => drawPhysicsRectangle(collider, color),
        CollisionShape.line => drawPhysicsLine(collider, color),
        CollisionShape.sphere => drawPhysicsSphere(collider, color),
        else => {},
    }
}

pub fn main() !void {
    ray.InitWindow(600, 480, "Test");
    defer ray.CloseWindow();

    var world = PhysicsWorld.new(std.heap.page_allocator);
    defer world.deinit();

    const shape1 = CollisionShape.newRectangle(50.0, 50.0);
    const shape2 = CollisionShape.newRectangle(50.0, 50.0);
    const shape3 = CollisionShape.newRectangle(600, 50);
    // const shape1 = CollisionShape.newLine(100);
    // const shape2 = CollisionShape.newLine(100);
    // const shape3 = CollisionShape{ .sphere = CollisionShapes.Sphere{ .radius = 50.0 } };
    const transform = Isometry2D.new(Vec2.new(350.0, 240.0), Vec2.new(0, 1.0));
    const transform2 = Isometry2D.new(Vec2.new(200.0, 200.0), Vec2.new(1.0 / @sqrt(2.0), -1.0 / @sqrt(2.0)));
    const transform3 = Isometry2D.fromTranslation(Vec2.new(300.0, 400.0));

    const c1 = world.addCollider(Collider2D.new(shape1, transform));
    const c2 = world.addCollider(Collider2D.new(shape2, transform2));
    const c3 = world.addCollider(Collider2D.new(shape3, transform3));

    _ = world.addRigidBody(RigidBody.new(c1, 1.0));
    _ = world.addRigidBody(RigidBody.new(c2, 1.0));
    _ = world.addRigidBody(RigidBody.new(c3, 0.0));

    ray.SetTargetFPS(30);
    while (!ray.WindowShouldClose()) {
        ray.ClearBackground(ray.Color{ .r = 0, .g = 0, .b = 0, .a = 0 });
        ray.BeginDrawing();

        const mouseX: f32 = @floatFromInt(ray.GetMouseX());
        const mouseY: f32 = @floatFromInt(ray.GetMouseY());

        const keyRotation: f32 = if (ray.IsKeyDown(ray.KEY_UP)) 0.1 else if (ray.IsKeyDown(ray.KEY_DOWN)) -0.1 else 0.0;
        if (ray.IsMouseButtonDown(0)) {
            const rotation = ray.GetMouseWheelMove() * 0.1 + keyRotation;
            var iso = &world.getCollider(c1).transform;
            iso.translation.x = mouseX;
            iso.translation.y = mouseY;
            iso.rotation.rotateRad(rotation);
        }
        if (ray.IsMouseButtonDown(1)) {
            const rotation = ray.GetMouseWheelMove() * 0.1 + keyRotation;
            var iso = &world.getCollider(c2).transform;
            iso.translation.x = mouseX;
            iso.translation.y = mouseY;
            iso.rotation.rotateRad(rotation);
        }

        const r = world.getCollider(c1);
        const s = world.getCollider(c2);
        const t = world.getCollider(c3);
        drawPhysicsObject(r, ray.GREEN);
        drawPhysicsObject(s, ray.MAROON);
        drawPhysicsObject(t, ray.MAROON);

        try world.step(0.0);
        for (world.collisionList.items) |collisions| {
            const point1 = collisions.colliders[0].transform.transform(collisions.contactInfo.points[0]);
            ray.DrawCircle(@intFromFloat(point1.x), @intFromFloat(point1.y), 10.0, ray.YELLOW);

            const point2 = collisions.colliders[1].transform.transform(collisions.contactInfo.points[1]);
            ray.DrawCircle(@intFromFloat(point2.x), @intFromFloat(point2.y), 10.0, ray.YELLOW);
        }

        ray.EndDrawing();
    }
}
