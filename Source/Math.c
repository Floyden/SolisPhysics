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

void Sol_Vec2Add(Sol_Vec2* a, Sol_Vec2 const* b)
{
    a->x += b->x;
    a->y += b->y;
}

void Sol_Vec2Sub(Sol_Vec2* a, Sol_Vec2 const* b)
{
    a->x -= b->x;
    a->y -= b->y;
}

void Sol_Vec2MulAdd(Sol_Vec2* a, Sol_Vec2 const* b, Real x)
{
    a->x += b->x * x;
    a->y += b->y * x;
}

Real Sol_Vec2Dot(Sol_Vec2 const* a, Sol_Vec2 const* b)
{
    return a->x * b->x + a->y * b->y;
}

Real Sol_Min(Real a, Real b)
{
    return a < b ? a : b;
}

Real Sol_Max(Real a, Real b)
{
    return a > b ? a : b;
}