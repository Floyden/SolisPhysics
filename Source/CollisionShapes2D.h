#pragma once
#include "Defines.h"
#include "Math.h"

typedef struct Sol_ShapeCapsule2D
{
    Real radius;
    Real height;
} Sol_ShapeCapsule2D;

typedef struct Sol_ShapeRectangle2D
{
    Real width;
    Real height;
} Sol_ShapeRectangle2D;

typedef struct Sol_ShapeSegment2D
{
    Real a[2];
} Sol_ShapeSegment2D;

typedef struct Sol_ShapeSphere2D
{
    Real radius;
} Sol_ShapeSphere2D;

typedef struct Sol_CollisionContactInfo2D
{
    Real distance;
    Sol_Vec2 point1;
    Sol_Vec2 point2;
    Sol_Vec2 normal1;
    Sol_Vec2 normal2;
} Sol_CollisionContactInfo2D;

/**
 * \brief Check if two spheres collide.
 * \param[in] s1 Shape information of the first shape.
 * \param[in] s2 Shape information of the second shape.
 * \param[in] difference Relative difference between the two shapes.
 * \param[out] contactInfo Information of the collision if a collision occurred. Does not modify contactInfo if no collision happened
 * \return Returns zero if no collision happened, otherwise it returns a positive number.
*/
int Sol_CollisionCheckSphereSphere(Sol_ShapeSphere2D const* s1, Sol_ShapeSphere2D const* s2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);

int Sol_CollisionCheckSegmentSegment(Sol_ShapeSegment2D const* s1, Sol_ShapeSegment2D const* s2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckSegmentSphere(Sol_ShapeSegment2D const* segment, Sol_ShapeSphere2D const* sphere, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);

int Sol_CollisionCheckRectangleRectangle(Sol_ShapeRectangle2D const* r1, Sol_ShapeRectangle2D const* r2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckRectangleSegment(Sol_ShapeRectangle2D const* r, Sol_ShapeSegment2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckRectangleSphere(Sol_ShapeRectangle2D const* r, Sol_ShapeSphere2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);

int Sol_CollisionCheckCapsuleCapsule(Sol_ShapeCapsule2D const* c1, Sol_ShapeCapsule2D const* c2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckCapsuleRectangle(Sol_ShapeCapsule2D const* c, Sol_ShapeRectangle2D const* r, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckCapsuleSegment(Sol_ShapeCapsule2D const* c, Sol_ShapeSegment2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckCapsuleSphere(Sol_ShapeCapsule2D const* c, Sol_ShapeSphere2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);


