#include "RigidBody.hh"

namespace Solis::Phyiscs
{

void RigidBody::AddForce(Vec2 force)
{
    this->mTotalForces += force;
}

void RigidBody::IntegrateVelocity(float timeStep)
{
    this->mVelocity += mTotalForces * mInverseMass * timeStep;
}
} // namespace Solis::Phyiscs
