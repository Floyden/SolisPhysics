#pragma once
#include "Math.hh"
#include "IShape.hh"
#include <stdexcept>

namespace Solis::Physics
{

class Cuboid : public IShape {
public: 
    Cuboid(Vec2 halfExtends) : halfExtends(halfExtends) {};
    Cuboid(float halfExtend) : halfExtends(Vec2(halfExtend)) {};

    virtual AABB ComputeLocalAABB() const { 
        return AABB {
            .posMin = -halfExtends,
            .posMax = halfExtends
        };
    }

    Vec2 halfExtends;
};
    
} // namespace Solis
