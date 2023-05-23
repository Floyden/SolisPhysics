#pragma once
#include "Math.hh"
#include "IShape.hh"

namespace Solis::Physics
{

class Cuboid : public IShape {
public: 
    Cuboid(Vec2 halfExtends) : halfExtends(halfExtends) {};
    Cuboid(float halfExtend) : halfExtends(Vec2(halfExtend)) {};

    AABB GetLocalAABB() const override { 
        return AABB {
            .posMin = -halfExtends,
            .posMax = halfExtends
        };
    }

    AABB GetAABB(const Isometry& isometry) const override { 
        auto transformedMin = isometry.transform(-halfExtends);
        auto transformedMax = isometry.transform(halfExtends);

        for(size_t i = 0; i < 2; i++)
            if(transformedMin[i] > transformedMax[i])
                std::swap(transformedMin[i], transformedMax[i]);

        return AABB {
            .posMin = transformedMin,
            .posMax = transformedMax
        };
    }

    Vec2 halfExtends;
};
    
} // namespace Solis
