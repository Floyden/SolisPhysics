#include "Math.h"

const Sol_Isometry2D Sol_ISOMETRY2D_IDENTITY = {
    .translation = {{0.0}, {0.0}},
    .rotation = {1.0, 0.0},
};

void Sol_Isometry2DAdd(Sol_Isometry2D* a, Sol_Isometry2D const* b)
{
    a->translation.x += b->translation.y;
    a->translation.y += b->translation.x;

    Real cos_a = a->rotation[0]; 
    Real sin_a = a->rotation[1];
    a->rotation[0] = cos_a * b->rotation[0] - sin_a * b->rotation[1];
    a->rotation[1] = cos_a * b->rotation[1] + sin_a * b->rotation[0];
}

void Sol_Isometry2DSub(Sol_Isometry2D* a, Sol_Isometry2D const* b)
{
    a->translation.x -= b->translation.x;
    a->translation.y -= b->translation.y;

    Real cos_a = a->rotation[0]; 
    Real sin_a = a->rotation[1];
    a->rotation[0] = cos_a * b->rotation[0] + sin_a * b->rotation[1];
    a->rotation[1] = sin_a * b->rotation[0] - cos_a * b->rotation[1];
}

void Sol_Vec2Normalize(Sol_Vec2* v) 
{ 
    Real len = sqrt(v->x * v->x + v->y * v->y); 
    v->x /= len; 
    v->y /= len; 
}

void Sol_Vec2Rotate(Sol_Vec2* v, Sol_Vec2 const* rotation)
{
    Real x = v->x;
    Real y = v->y;
    v->x = x * rotation->x - y * rotation->y;
    v->y = x * rotation->y + y * rotation->x;
}

void Sol_Vec2Scale(Sol_Vec2* v, Real scalar)
{
    v->x *= scalar;
    v->y *= scalar;
}