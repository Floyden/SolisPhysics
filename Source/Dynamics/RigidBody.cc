#include "RigidBody.hh"

namespace Solis::Phyiscs
{
    
void RigidBody::AddForce(Vec2 force) {
    this->mTotalForces += force;
}

} // namespace Solis::Phyiscs
