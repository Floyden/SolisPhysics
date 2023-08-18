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
void Sol_Vec2Normalize(Sol_Vec2* v);
/* Rotate the Vec2 around rotation r */
void Sol_Vec2Rotate(Sol_Vec2* v, Sol_Vec2 const* rotation);
/* Scale the Vec2 by scalar */
void Sol_Vec2Scale(Sol_Vec2* v, Real scalar);
/* Return the dot product between the two vectors a and b */
Real Sol_Vec2Dot(Sol_Vec2 const* a, Sol_Vec2 const* b);

/* Add two vectors and write the result in a */
void Sol_Vec2Add(Sol_Vec2* a, Sol_Vec2 const* b);
/* Subtract two vectors and write the result in a */
void Sol_Vec2Sub(Sol_Vec2* a, Sol_Vec2 const* b);
/* Fused multiply add, calculate a + bx and save the result in a*/
void Sol_Vec2MulAdd(Sol_Vec2* a, Sol_Vec2 const* b, Real x);

Real Sol_Min(Real a, Real b);
Real Sol_Max(Real a, Real b);

#endif // SOL_MATH_H