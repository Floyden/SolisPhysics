#pragma once
#include "Shape/Sphere.hh"
#include "Contact.hh"
#include "Defines.hh"

namespace Solis::Physics
{

Optional<ContactInfo> ComputeSphereSphereContact(const Sphere* sphere1, const Sphere* sphere2, Isometry diff)
{
    auto radius1 = sphere1->radius;
    auto radius2 = sphere2->radius;
    auto distanceSquared = glm::length2(diff.translation);
    
    if(distanceSquared > radius1 * radius1 + radius2 * radius2)
        return {};
        
    auto normal1 = glm::normalize(diff.translation);
    auto rotationMatrix = Matrix2(diff.rotation.x, -diff.rotation.y, diff.rotation.y, diff.rotation.x);
    auto normal2 = glm::inverse(rotationMatrix) * normal1;
    return ContactInfo {
        .point1 = radius1 * normal1,
        .point2 = radius2 * normal2,
        .normal1 = normal1,
        .normal2 = normal2,
        .distance = glm::sqrt(distanceSquared) - radius1 - radius2
    };
    
}

} // namespace Solis::Physics
