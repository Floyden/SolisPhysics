#include "Collision/ContactSphereSphere.hh"
#include "PhysicsWorld.hh"
#include "Shape/CompositeShape.hh"
#include "Shape/Cuboid.hh"
#include "Shape/Sphere.hh"

int main()
{
    using namespace Solis::Physics;
    World world;

    auto *sphere = world.CreateShape<Sphere>(0.5);
    auto *composite = world.CreateShape<CompositeShape>();
    composite->AddShape(Solis::Isometry{}, sphere);

    auto *body = world.CreateRigidBody(Solis::Isometry{}, composite);
}