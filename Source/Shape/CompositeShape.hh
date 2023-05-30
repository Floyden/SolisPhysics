#pragma once
#include "Defines.hh"
#include "IShape.hh"

namespace Solis::Physics
{

class CompositeShape : public IShape
{
public:
    void AddShape(Isometry isometry, IShape *shape)
    {
        children.emplace_back(isometry, shape);

        auto shapeAabb = shape->GetAabb(isometry);

        for (size_t i = 0; i < 2; i++)
        {
            if (shapeAabb.posMax[i] > this->aabb.posMax[i])
                this->aabb.posMax[i] = shapeAabb.posMax[i];
            if (shapeAabb.posMin[i] < this->aabb.posMin[i])
                this->aabb.posMin[i] = shapeAabb.posMin[i];
        }
    }

    virtual Aabb GetLocalAabb() const override
    {
        return aabb;
    }

    Aabb GetAabb(const Isometry &) const override
    {
        throw std::logic_error("CompositeShape::GetAabb is not implemented");
    }

    Vector<Pair<Isometry, IShape *>> children;
    Aabb aabb;
};
} // namespace Solis::Physics
