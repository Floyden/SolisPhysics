#pragma once
#include "IShape.hh"
#include <stdexcept>

namespace Solis::Physics
{
    
class Sphere : public IShape {
public: 
    Sphere(float radius) : radius(radius) {};
    virtual ~Sphere() = default;

    AABB ComputeLocalAABB() const override { 
        return AABB {
            .posMin = Vec2(-radius),
            .posMax = Vec2(radius),
        };
    }

    float radius;
};

} // namespace Solis
