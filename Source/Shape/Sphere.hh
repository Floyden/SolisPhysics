#pragma once
#include "IShape.hh"

namespace Solis::Physics
{
    
class Sphere : public IShape {
public: 
    Sphere(float radius) : radius(radius) {};
    virtual ~Sphere() = default;

    Aabb GetLocalAabb() const override { 
        return Aabb {
            .posMin = Vec2(-radius),
            .posMax = Vec2(radius),
        };
    }

    Aabb GetAabb(const Isometry& isometry) const override { 
        // Rotating a sphere does not change anything
        return Aabb {
            .posMin = Vec2(-radius) + isometry.translation,
            .posMax = Vec2(radius) + isometry.translation,
        };
    }

    float radius;
};

} // namespace Solis
