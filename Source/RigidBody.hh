#pragma once
#include "Shape/IShape.hh"

namespace Solis::Physics
{

class RigidBody {
public:
    RigidBody (const Isometry& transform, IShape* collisionShape) : 
        mTransform(transform), mCollisionShape(collisionShape) {};
private:
    Isometry mTransform;
    IShape* mCollisionShape;
};
    
} // namespace Solis::Phyiscs
