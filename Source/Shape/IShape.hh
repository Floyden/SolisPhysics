#pragma once
#include "Math.hh"

namespace Solis::Physics
{   
//TODO: Move this somewhere appropriate
struct Aabb {
    Vec2 posMin;
    Vec2 posMax;
};

class IShape {
public:
    virtual ~IShape() = default;
    virtual Aabb GetLocalAabb() const = 0;
    virtual Aabb GetAabb(const Isometry& isometry) const = 0;
};
} // namespace Solis::Physics
