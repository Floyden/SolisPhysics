#pragma once
#include "Shape/IShape.hh"

namespace Solis::Physics
{

class RigidBody {
public:
    RigidBody (const Isometry& transform, IShape* collisionShape) : 
        mTransform(transform), mCollisionShape(collisionShape) {};

    void AddForce(Vec2 force);
    void IntegrateVelocity(float timeStep);

    const Isometry& GetTransform() const { return mTransform; }
private:
    Isometry mTransform;
    IShape* mCollisionShape;

    float mInverseMass;
    Vec2 mTotalForces;
    Vec2 mVelocity;
};
    
} // namespace Solis::Phyiscs
