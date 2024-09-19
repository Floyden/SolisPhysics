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

pub fn createSimpleScene(world: *PhysicsWorld) void {
    const shape1 = CollisionShape.newRectangle(50.0, 50.0);
    // const shape1 = CollisionShape.newSphere(50);
    const shape2 = CollisionShape.newRectangle(50.0, 50.0);
    const shape3 = CollisionShape.newSphere(100);
    const transform = Isometry2D.new(Vec2.new(250.0, 250.0), Vec2.new(1.0, 0.0)); //Vec2.new(1.0 / @sqrt(2.0), -1.0 / @sqrt(2.0)));
    const transform2 = Isometry2D.new(Vec2.new(200.0, 400.0), Vec2.new(1.0, 0.0)); //Vec2.new(1.0 / @sqrt(2.0), -1.0 / @sqrt(2.0)));
    const transform3 = Isometry2D.fromTranslation(Vec2.new(450.0, 350.0));

    const c1 = world.addCollider(Collider2D.new(shape1, transform));
    const c2 = world.addCollider(Collider2D.new(shape2, transform2));
    const c3 = world.addCollider(Collider2D.new(shape3, transform3));

    _ = world.addRigidBody(RigidBody.new(c1, 1.0, shape1.calculateInertia(1.0)));
    _ = world.addRigidBody(RigidBody.new(c2, 0.0, 0.0));
    _ = world.addRigidBody(RigidBody.new(c3, 0.0, 0.0));
}

pub fn createMassScene(world: *PhysicsWorld) void {
    // const shape = CollisionShape.newSphere(10);
    const shape = CollisionShape.newRectangle(20, 10);
    for (0..1) |i| {
        for (0..3) |k| {
            const x = @as(f32, @floatFromInt(i * 40)) + 300.0;
            const y = @as(f32, @floatFromInt(k * 40)) + 200.0;
            const transform = Isometry2D.new(Vec2.new(x, y), Vec2.right());
            const collider = world.addCollider(Collider2D.new(shape, transform));
            _ = world.addRigidBody(RigidBody.new(collider, 1.0, shape.calculateInertia(1.0)));
        }
    }

    const walls = CollisionShape.newRectangle(220.0, 20.0);
    const bottomT = Isometry2D.new(Vec2.new(300.0, 460.0), Vec2.right());
    const topT = Isometry2D.new(Vec2.new(300.0, 10.0), Vec2.right());
    const leftT = Isometry2D.new(Vec2.new(10.0, 240.0), Vec2.up());
    const rightT = Isometry2D.new(Vec2.new(590.0, 240.0), Vec2.up());

    _ = world.addRigidBody(RigidBody.new(world.addCollider(Collider2D.new(walls, bottomT)), 0.0, 0.0));
    _ = world.addRigidBody(RigidBody.new(world.addCollider(Collider2D.new(walls, topT)), 0.0, 0.0));
    _ = world.addRigidBody(RigidBody.new(world.addCollider(Collider2D.new(walls, leftT)), 0.0, 0.0));
    _ = world.addRigidBody(RigidBody.new(world.addCollider(Collider2D.new(walls, rightT)), 0.0, 0.0));
}

pub fn main() !void {
    ray.InitWindow(600, 480, "Test");
    defer ray.CloseWindow();

    var world = PhysicsWorld.new(std.heap.page_allocator);
    defer world.deinit();

    createMassScene(&world);

    ray.SetTargetFPS(30);
    var timestep: f32 = 0.1;
    while (!ray.WindowShouldClose()) {
        ray.ClearBackground(ray.Color{ .r = 0, .g = 0, .b = 0, .a = 0 });
        ray.BeginDrawing();

        const mouseX: f32 = @floatFromInt(ray.GetMouseX());
        const mouseY: f32 = @floatFromInt(ray.GetMouseY());

        const keyRotation: f32 = if (ray.IsKeyDown(ray.KEY_UP)) 0.1 else if (ray.IsKeyDown(ray.KEY_DOWN)) -0.1 else 0.0;
        if (ray.IsMouseButtonDown(0)) {
            const rotation = ray.GetMouseWheelMove() * 0.1 + keyRotation;
            var iso = &world.getCollider(0).transform;
            iso.translation.x = mouseX;
            iso.translation.y = mouseY;
            iso.rotation.rotateRad(rotation);
            world.getRigidBody(0).resetForces();
            world.getRigidBody(0).velocity = Vec2.zero();
        }
        if (ray.IsMouseButtonDown(1)) {
            const rotation = ray.GetMouseWheelMove() * 0.1 + keyRotation;
            var iso = &world.getCollider(0).transform;
            iso.translation.x = mouseX;
            iso.translation.y = mouseY;
            iso.rotation.rotateRad(rotation);
            world.getRigidBody(0).resetForces();
            world.getRigidBody(0).velocity = Vec2.zero();
        }
        if (ray.IsKeyPressed(ray.KEY_ONE)) {
            world.clear();
            createMassScene(&world);
        } else if (ray.IsKeyPressed(ray.KEY_TWO)) {
            world.clear();
            createSimpleScene(&world);
        }

        if (ray.IsKeyPressed(ray.KEY_P))
            timestep = if (timestep == 0.0) 0.1 else 0.0;

        for (world.colliderList.items) |*c| {
            drawPhysicsObject(c, ray.GREEN);
        }

        if (ray.IsKeyPressed(ray.KEY_S) and !ray.IsKeyPressedRepeat(ray.KEY_S)) {
            try world.step(0.1);
        } else {
            try world.step(timestep);
        }
        for (world.collisionList.items) |collisions| {
            const point1 = collisions.colliders[0].transform.transform(collisions.contactInfo.points[0]);
            const normal1 = collisions.colliders[0].transform.rotate(collisions.contactInfo.normals[0].scale(10.0)).add(point1);
            ray.DrawCircle(@intFromFloat(point1.x), @intFromFloat(point1.y), 10.0, ray.YELLOW);
            ray.DrawLineEx(ray.Vector2{ .x = point1.x, .y = point1.y }, ray.Vector2{ .x = normal1.x, .y = normal1.y }, 1.0, ray.RED);

            const point2 = collisions.colliders[1].transform.transform(collisions.contactInfo.points[1]);
            const normal2 = collisions.colliders[1].transform.rotate(collisions.contactInfo.normals[1].scale(10.0)).add(point2);
            ray.DrawCircle(@intFromFloat(point2.x), @intFromFloat(point2.y), 10.0, ray.YELLOW);
            ray.DrawLineEx(ray.Vector2{ .x = point2.x, .y = point2.y }, ray.Vector2{ .x = normal2.x, .y = normal2.y }, 1.0, ray.RED);
        }

        ray.EndDrawing();
    }
}
