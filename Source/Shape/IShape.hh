#pragma once
#include "Math.hh"

namespace Solis::Physics
{   
//TODO: Move this somewhere appropriate
struct AABB {
    Vec2 posMin;
    Vec2 posMax;
};

class IShape {
public:
    virtual ~IShape() = default;
    virtual AABB GetLocalAABB() const = 0;
    virtual AABB GetAABB(const Isometry& isometry) const = 0;
};
} // namespace Solis::Physics
