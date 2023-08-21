#ifndef SOL_MATH_H
#define SOL_MATH_H
#include "Defines.h"
#include <math.h>

typedef struct Sol_Vec2
{
    Real x;
    Real y;
} Sol_Vec2;

typedef struct Sol_Isometry2D
{
    Sol_Vec2 translation;
    Sol_Vec2 rotation;
} Sol_Isometry2D;

extern const Sol_Isometry2D Sol_ISOMETRY2D_IDENTITY;

/* Calculate the sum of two isometric transformations. Result is written in a */
void Sol_Isometry2DAdd(Sol_Isometry2D* a, Sol_Isometry2D const* b);
/* Calculate the difference of two isometric transformations. Result is written in a */
void Sol_Isometry2DSub(Sol_Isometry2D* a, Sol_Isometry2D const* b);

/* Normalize the given Vec2 */
SOL_INLINE void Sol_Vec2Normalize(Sol_Vec2* v) 
{ 
    Real len = sqrt(v->x * v->x + v->y * v->y); 
    v->x /= len; 
    v->y /= len; 
}

/* Rotate the Vec2 around rotation r */
SOL_INLINE void Sol_Vec2Rotate(Sol_Vec2* v, Sol_Vec2 const* rotation)
{
    Real x = v->x;
    Real y = v->y;
    v->x = x * rotation->x - y * rotation->y;
    v->y = x * rotation->y + y * rotation->x;
}

/* Rotate the Vec2 around angle a in rad */
SOL_INLINE void Sol_Vec2RotateRad(Sol_Vec2* v, Real a)
{
    Sol_Vec2 tmp = *v;
    v->x = tmp.x * cos(a) - tmp.y * sin(a);
    v->y = tmp.x * sin(a) + tmp.y * cos(a);
}

/* Scale the Vec2 by scalar */
SOL_INLINE void Sol_Vec2Scale(Sol_Vec2* v, Real scalar)
{
    v->x *= scalar;
    v->y *= scalar;
}

/* Return the dot product between the two vectors a and b */
SOL_INLINE Real Sol_Vec2Dot(Sol_Vec2 const* a, Sol_Vec2 const* b)
{
    return a->x * b->x + a->y * b->y;
}

/* Add two vectors and write the result in a */
SOL_INLINE void Sol_Vec2Add(Sol_Vec2* a, Sol_Vec2 const* b)
{
    a->x += b->x;
    a->y += b->y;
}

/* Subtract two vectors and write the result in a */
SOL_INLINE void Sol_Vec2Sub(Sol_Vec2* a, Sol_Vec2 const* b)
{
    a->x -= b->x;
    a->y -= b->y;
}

/* Fused multiply add, calculate a + bx and save the result in a*/
SOL_INLINE void Sol_Vec2MulAdd(Sol_Vec2* a, Sol_Vec2 const* b, Real x)
{
    a->x += b->x * x;
    a->y += b->y * x;
}

/* Return the squared length of the vector. */
SOL_INLINE Real Sol_Vec2Length2(Sol_Vec2 const* a)
{
    return a->x * a->x + a->y * a->y;
}

/* Return the length of the vector. */
SOL_INLINE Real Sol_Vec2Length(Sol_Vec2 const* a)
{
    return sqrt(Sol_Vec2Length2(a));
}

SOL_INLINE Real Sol_Min(Real a, Real b)
{
    return a < b ? a : b;
}

SOL_INLINE Real Sol_Max(Real a, Real b)
{
    return a > b ? a : b;
}

#endif // SOL_MATH_H