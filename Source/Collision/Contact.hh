#pragma once
#include "Math.hh"

namespace Solis::Physics
{
struct ContactInfo {
    Vec2 point1;
    Vec2 point2;
    Vec2 normal1;
    Vec2 normal2;
    float distance;
};
}