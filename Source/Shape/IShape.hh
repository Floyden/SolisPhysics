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
    virtual AABB ComputeLocalAABB() const = 0;
};
} // namespace Solis::Physics
