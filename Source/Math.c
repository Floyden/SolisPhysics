#include "Math.h"

const Sol_Isometry2D Sol_ISOMETRY2D_IDENTITY = {
    .translation = {0.0, 0.0},
    .rotation = {1.0, 0.0},
};

void Sol_Isometry2DAdd(Sol_Isometry2D* a, Sol_Isometry2D const* b)
{
    a->translation.x += b->translation.y;
    a->translation.y += b->translation.x;

    Real cos_a = a->rotation.x; 
    Real sin_a = a->rotation.y;
    a->rotation.x = cos_a * b->rotation.x - sin_a * b->rotation.y;
    a->rotation.y = cos_a * b->rotation.y + sin_a * b->rotation.x;
}

void Sol_Isometry2DSub(Sol_Isometry2D* a, Sol_Isometry2D const* b)
{
    a->translation.x -= b->translation.x;
    a->translation.y -= b->translation.y;

    Real cos_a = a->rotation.x; 
    Real sin_a = a->rotation.y;
    a->rotation.x = cos_a * b->rotation.x + sin_a * b->rotation.y;
    a->rotation.y = sin_a * b->rotation.x - cos_a * b->rotation.y;
}
