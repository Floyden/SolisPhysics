#pragma once
#include "Defines.hh"
#include "Shape/IShape.hh"
#include "Dynamics/RigidBody.hh"
#include <type_traits>

namespace Solis::Physics
{
class World {
public:
    template<Derived<IShape> Shape, class... Args>
    Shape* CreateShape(Args&&... args) {
        auto* shape = mShapes.emplace_back(UPtr<IShape>(new Shape(std::forward<Args>(args)...))).get();
        return reinterpret_cast<Shape*>(shape);
    }

    RigidBody* CreateRigidBody(const Isometry& transform, IShape* shape) {
        return mRigidBodies.emplace_back(UPtr<RigidBody>(new RigidBody(transform, shape))).get();
    }

    void Destroy() {
        mShapes.clear();
        mRigidBodies.clear();
    }

private:
    Vector<UPtr<IShape>> mShapes;
    Vector<UPtr<RigidBody>> mRigidBodies;
};
    
} // namespace Solis::Physics
