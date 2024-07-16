const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const Isometry2 = @import("isometry.zig").Isometry2D;
const PhysicsWorld = @import("physics_world.zig").PhysicsWorld;
const RigidBody = @import("physics_world.zig").RigidBody;
const Collider2 = @import("collider_2d.zig").Collider2D;
const CollisionShapes = @import("collision_shapes_2d.zig").CollisionShape;

export fn Vec2_add(a: Vec2, b: Vec2) callconv(.C) Vec2 {
    return a.add(b);
}

export fn Vec2_addMut(a: *Vec2, b: Vec2) callconv(.C) void {
    return a.addMut(b);
}

export fn PhysicsWorld_Create() callconv(.C) *PhysicsWorld {
    const world = std.heap.page_allocator.create(PhysicsWorld) catch unreachable;
    world.* = PhysicsWorld.new();

    return world;
}

export fn PhysicsWorld_Destroy(world: *PhysicsWorld) callconv(.C) void {
    world.deinit();
    std.heap.page_allocator.destroy(world);
}

export fn PhysicsWorld_Step(world: *PhysicsWorld, dt: f32) callconv(.C) void {
    world.step(dt) catch unreachable;
}

export fn PhysicsWorld_CreateRectangleCollider(world: *PhysicsWorld, width: f32, height: f32, isometry: Isometry2) callconv(.C) u64 {
    return world.addCollider(Collider2.new(CollisionShapes.newRectangle(width, height), isometry));
}

export fn Colliders_GetIsometry(world: *PhysicsWorld, collider: u64) callconv(.C) *Isometry2 {
    return &world.getCollider(collider).transform;
}

export fn PhysicsWorld_CreateRigidBody(world: *PhysicsWorld, collider: u64, mass: f32) callconv(.C) u64 {
    return world.addRigidBody(RigidBody.new(collider, mass));
}
