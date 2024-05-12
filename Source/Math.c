#include "Math.h"

const Sol_Isometry2D Sol_ISOMETRY2D_IDENTITY = 
{
    .translation = {0.0, 0.0},
    .rotation = {1.0, 0.0},
};

void Sol_Isometry2DTransform(Sol_Isometry2D const *a, Sol_Vec2 *b)
{
    Sol_Vec2Rotate(b, &a->rotation);
    Sol_Vec2Add(b, &a->translation);
}

void Sol_Isometry2DInverse(Sol_Isometry2D *a) 
{
    a->rotation.y *= -1.0;

    Sol_Vec2Scale(&a->translation, -1.0);
    Sol_Vec2Rotate(&a->translation, &a->rotation);
}

void Sol_Isometry2DMul(Sol_Isometry2D *a, Sol_Isometry2D const *b)
{
    Sol_Vec2 offset = b->translation;
    Sol_Vec2Rotate(&offset, &a->rotation);
    Sol_Vec2Add(&a->translation, &offset);
    Sol_Vec2Rotate(&a->rotation, &b->rotation);
}