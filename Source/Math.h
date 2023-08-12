#ifndef SOL_MATH_H
#define SOL_MATH_H
#include "Defines.h"
#include <math.h>

typedef struct Sol_Vec2
{
    union { Real x, r;};
    union { Real y, g;};
} Sol_Vec2;

typedef struct Sol_Isometry2D
{
    Sol_Vec2 translation;
    Real rotation[2];
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

#endif // SOL_MATH_H