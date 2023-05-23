#pragma once
#include "Defines.hh"
#include "IShape.hh"

namespace Solis::Physics
{

class CompositeShape: public IShape {
public:
    void AddShape(Isometry isometry, IShape* shape) {
        children.emplace_back(isometry, shape);
    }

    AABB ComputeLocalAABB() const { throw std::logic_error("Not Yet Implemented"); }

    Vector<Pair<Isometry, IShape*>> children;
};
} // namespace Solis::Physics
