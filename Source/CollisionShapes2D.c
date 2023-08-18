#include "CollisionShapes2D.h"
#include <math.h>
#include <stdio.h>

int Sol_CollisionCheckSphereSphere(Sol_ShapeSphere2D const* s1, Sol_ShapeSphere2D const* s2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo)
{
    Real radius1 = s1->radius;
    Real radius2 = s2->radius;
    Real distanceSquared = difference->translation.x * difference->translation.x + 
        difference->translation.y + difference->translation.y;

    if (distanceSquared > (radius1 + radius2) * (radius2 + radius2))
        return 0;

    contactInfo->normal1 = difference->translation;
    Sol_Vec2Normalize(&contactInfo->normal1);
    
    contactInfo->normal2 = contactInfo->normal1;
    Sol_Vec2 inverse_rotation = difference->rotation;
    inverse_rotation.y *= -1.0;
    Sol_Vec2Rotate(&contactInfo->normal2, &inverse_rotation);

    contactInfo->point1 = contactInfo->normal1;
    contactInfo->point2 = contactInfo->normal2;
    Sol_Vec2Scale(&contactInfo->point1, radius1);
    Sol_Vec2Scale(&contactInfo->point2, radius2);

    contactInfo->distance = sqrt(distanceSquared - radius1 - radius2);
    return 1;
}

int Sol_CollisionCheckCapsuleCapsule(Sol_ShapeCapsule2D const* c1, Sol_ShapeCapsule2D const* c2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckCapsuleRectangle(Sol_ShapeCapsule2D const* c, Sol_ShapeRectangle2D const* r, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckCapsuleSegment(Sol_ShapeCapsule2D const* c, Sol_ShapeSegment2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckCapsuleSphere(Sol_ShapeCapsule2D const* c, Sol_ShapeSphere2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);

void Sol_SwapIf(Sol_Vec2* a, Sol_Vec2* b, int condition)
{
    if (!condition)
        return;
    Sol_Vec2 tmp = *a;
    *a = *b;
    *b = tmp;
}

/**
 * Projects r2 onto the two spanning axis of r1. 
 * Returns 0 if there is a seperating axis and 1 if there is none. 
 * Also writes the colliding corner into closestCorner, if that corner collides.
*/
int Sol_CheckRectangleRectangleCollisionAxis(Sol_ShapeRectangle2D const* r1, Sol_ShapeRectangle2D const* r2, Sol_Isometry2D const* difference, Sol_Vec2* closestCorner)
{
    Real const halfHeight1 = r1->height / 2.0;
    Real const halfWidth1 = r1->width / 2.0;
    Real const halfHeight2 = r2->height / 2.0;
    Real const halfWidth2 = r2->width / 2.0;

    Sol_Vec2 dir1 = {1.0, 0.0};
    Sol_Vec2 dir2 = {0.0, 1.0};
    Sol_Vec2Rotate(&dir1, &difference->rotation);
    Sol_Vec2Rotate(&dir2, &difference->rotation);
    Sol_Vec2Scale(&dir1, halfWidth2);
    Sol_Vec2Scale(&dir2, halfHeight2);

    // Calculate the coordinates of the corners of r2
    Sol_Vec2 corners2[4] = {dir1, dir1, dir1, dir1};
    Sol_Vec2Add(&corners2[0], &dir2);
    Sol_Vec2Sub(&corners2[1], &dir2);
    Sol_Vec2Add(&corners2[2], &dir2);
    Sol_Vec2Scale(&corners2[2], -1.0);
    Sol_Vec2Scale(&corners2[3], -1.0);
    Sol_Vec2Add(&corners2[3], &dir2);

    Sol_Vec2Add(&corners2[0], &difference->translation);
    Sol_Vec2Add(&corners2[1], &difference->translation);
    Sol_Vec2Add(&corners2[2], &difference->translation);
    Sol_Vec2Add(&corners2[3], &difference->translation);

    Sol_SwapIf(&corners2[0], &corners2[1], corners2[0].x <  corners2[1].x);
    Sol_SwapIf(&corners2[0], &corners2[2], corners2[0].x <  corners2[2].x);
    Sol_SwapIf(&corners2[0], &corners2[3], corners2[0].x <  corners2[3].x);
    Sol_SwapIf(&corners2[1], &corners2[2], corners2[1].x >  corners2[2].x);
    Sol_SwapIf(&corners2[1], &corners2[3], corners2[1].x >  corners2[3].x);
    Sol_SwapIf(&corners2[2], &corners2[3], corners2[2].y <  corners2[3].y);

    if (corners2[0].x < -halfWidth1 || corners2[1].x > halfWidth1 || corners2[2].y < -halfHeight1 || corners2[3].y > halfHeight1)
        return 0;

    if (corners2[0].x <= halfWidth1 && corners2[0].y >= -halfHeight1 && corners2[0].y <= halfHeight1) 
        *closestCorner = corners2[0];
    else if (corners2[1].x >= -halfWidth1 && corners2[1].y >= -halfHeight1 && corners2[1].y <= halfHeight1)
        *closestCorner = corners2[1];
    else if (corners2[2].y <= halfHeight1 && corners2[2].x >= -halfWidth1 && corners2[2].x <= halfWidth1) 
        *closestCorner = corners2[2];
    else if (corners2[3].y >= -halfHeight1 && corners2[3].x >= -halfWidth1 && corners2[3].x <= halfWidth1) 
        *closestCorner = corners2[3];

    return 1;
}

int Sol_CollisionCheckRectangleRectangle(Sol_ShapeRectangle2D const* r1, Sol_ShapeRectangle2D const* r2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo)
{
    Sol_Vec2 corner1 = {0.0, 0.0};
    if (!Sol_CheckRectangleRectangleCollisionAxis(r1, r2, difference, &corner1))
        return 0;

    Sol_Isometry2D inverseDifference = *difference;
    Sol_Vec2Scale(&inverseDifference.translation, -1.0);
    inverseDifference.rotation.y *= -1.0;

    Sol_Vec2 corner2 = {0.0, 0.0};
    if (!Sol_CheckRectangleRectangleCollisionAxis(r2, r1, &inverseDifference, &corner2))
        return 0;

    return 1;
}

int Sol_CollisionCheckRectangleSegment(Sol_ShapeRectangle2D const* r, Sol_ShapeSegment2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckRectangleSphere(Sol_ShapeRectangle2D const* r, Sol_ShapeSphere2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);

int Sol_CollisionCheckSegmentSegment(Sol_ShapeSegment2D const* s1, Sol_ShapeSegment2D const* s2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckSegmentSphere(Sol_ShapeSegment2D const* segment, Sol_ShapeSphere2D const* sphere, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
