#pragma once
#include "IShape.hh"

namespace Solis::Physics
{
    
class Sphere : public IShape {
public: 
    Sphere(float radius) : radius(radius) {};
    virtual ~Sphere() = default;

    AABB GetLocalAABB() const override { 
        return AABB {
            .posMin = Vec2(-radius),
            .posMax = Vec2(radius),
        };
    }

    AABB GetAABB(const Isometry& isometry) const override { 
        // Rotating a sphere does not change anything
        return AABB {
            .posMin = Vec2(-radius) + isometry.translation,
            .posMax = Vec2(radius) + isometry.translation,
        };
    }

    float radius;
};

} // namespace Solis
