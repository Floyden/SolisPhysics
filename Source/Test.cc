#include "Shape/Cuboid.hh"
#include "Shape/Sphere.hh"
#include "Shape/CompositeShape.hh"
#include "PhysicsWorld.hh"

int main() {
    using namespace Solis::Physics;
    World world;

    auto* sphere = world.CreateShape<Sphere>(0.5);
    auto* composite = world.CreateShape<CompositeShape>();
    composite->AddShape(Solis::Isometry{}, sphere);
}