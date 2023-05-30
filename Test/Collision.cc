#include "Collision/ContactSphereSphere.hh"
#include <iostream>

void TestNoCollisionTwoSpheres()
{
    using namespace Solis::Physics;

    Sphere s1{1.0};
    Sphere s2{2.0};
    Solis::Isometry transform{.translation = glm::vec2{3.5, 0.}, .rotation = glm::vec2{1.0, 0.}};

    auto collisionInfo = ComputeSphereSphereContact(&s1, &s2, transform);

    assert(!collisionInfo.has_value());
}

void TestCollisionTwoSpheres()
{
    using namespace Solis::Physics;

    Sphere s1{1.0};
    Sphere s2{2.0};
    Solis::Isometry transform{.translation = glm::vec2{2.5, 0.}, .rotation = glm::vec2{-1.0, 0.}};

    auto collisionInfo = ComputeSphereSphereContact(&s1, &s2, transform);

    assert(collisionInfo.has_value());
    assert(std::abs(collisionInfo->distance + 0.5) < 0.01);
    assert(std::abs(collisionInfo->point1.x - 1.0) < 0.01);
    assert(std::abs(collisionInfo->point2.x + 2.0) < 0.01);
    assert(std::abs(collisionInfo->normal1.x - 1.0) < 0.01);
    assert(std::abs(collisionInfo->normal2.x + 1.0) < 0.01);
}

int main()
{
    TestNoCollisionTwoSpheres();
    TestCollisionTwoSpheres();

    return 0;
}