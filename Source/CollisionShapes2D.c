#include "CollisionShapes2D.h"
#include <math.h>
#include <stdio.h>

// sqrt(2.0f) / 2.0f
static Real const HALF_SQRT_2 = 0.70710678118f;

int Sol_CollisionCheckSphereSphere(Sol_ShapeSphere2D const* s1, Sol_ShapeSphere2D const* s2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo)
{
    Real radius1 = s1->radius;
    Real radius2 = s2->radius;
    Real distanceSquared = difference->translation.x * difference->translation.x + 
        difference->translation.y + difference->translation.y;

    if (distanceSquared > (radius1 + radius2) * (radius1 + radius2))
        return 0;

    contactInfo->normal1 = difference->translation;
    Sol_Vec2Normalize(&contactInfo->normal1);
    
    contactInfo->normal2 = contactInfo->normal1;
    Sol_Vec2 inverse_rotation = difference->rotation;
    inverse_rotation.y *= -1.0f;
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

inline void Sol_SwapIf(Sol_Vec2* a, Sol_Vec2* b, int condition)
{
    if (!condition)
        return;
    Sol_Vec2 tmp = *a;
    *a = *b;
    *b = tmp;
}

inline void _Sol_ReplaceIfCloser(Sol_Vec2* closest, Sol_Vec2 const* corner, Real* closestDistance)
{
    Real distance = Sol_Vec2Length(corner);
    if(distance < *closestDistance)
    {
        *closestDistance = distance;
        *closest = *corner;
    }
}

/**
 * Projects r2 onto the two spanning axis of r1. 
 * Returns 0 if there is a seperating axis and 1 if there is none. 
 * Also writes the colliding corner into closestCorner, if that corner collides.
*/
int Sol_CheckRectangleRectangleCollisionAxis(Sol_ShapeRectangle2D const* r1, Sol_ShapeRectangle2D const* r2, Sol_Isometry2D const* difference, Sol_Vec2* closestCorner)
{
    Real const halfHeight1 = r1->height / 2.0f;
    Real const halfWidth1 = r1->width / 2.0f;
    Real const halfHeight2 = r2->height / 2.0f;
    Real const halfWidth2 = r2->width / 2.0f;

    Sol_Vec2 dir1 = {1.0f, 0.0f};
    Sol_Vec2 dir2 = {0.0f, 1.0f};
    Sol_Vec2Rotate(&dir1, &difference->rotation);
    Sol_Vec2Rotate(&dir2, &difference->rotation);
    Sol_Vec2Scale(&dir1, halfWidth2);
    Sol_Vec2Scale(&dir2, halfHeight2);

    // Calculate the coordinates of the corners of r2
    Sol_Vec2 corners2[4] = {dir1, dir1, dir1, dir1};
    Sol_Vec2Add(&corners2[0], &dir2);
    Sol_Vec2Sub(&corners2[1], &dir2);
    Sol_Vec2Add(&corners2[2], &dir2);
    Sol_Vec2Scale(&corners2[2], -1.0f);
    Sol_Vec2Scale(&corners2[3], -1.0f);
    Sol_Vec2Add(&corners2[3], &dir2);

    int idx = fabs(corners2[0].x) > fabs(corners2[1].x);

    Sol_Vec2Add(&corners2[0], &difference->translation);
    Sol_Vec2Add(&corners2[1], &difference->translation);
    Sol_Vec2Add(&corners2[2], &difference->translation);
    Sol_Vec2Add(&corners2[3], &difference->translation);
    
    if (corners2[1-idx].x > corners2[3-idx].x && (corners2[1-idx].x < -halfWidth1 || corners2[3-idx].x > halfWidth1))
        return 0;
    if (corners2[1-idx].x < corners2[3-idx].x && (corners2[1-idx].x > halfWidth1 || corners2[3-idx].x < -halfWidth1))
        return 0;
    if (corners2[0+idx].y > corners2[2+idx].y && (corners2[0+idx].y < -halfHeight1 || corners2[2+idx].y > halfHeight1))
        return 0;
    if (corners2[0+idx].y < corners2[2+idx].y && (corners2[0+idx].y > halfHeight1 || corners2[2+idx].y < -halfHeight1))
        return 0;

    Real closestDistance = Sol_Vec2Length2(&corners2[0]);
    *closestCorner = corners2[0];

    for (int i = 1; i < 4; i++)
    {
        Real tmpDistance = Sol_Vec2Length2(&corners2[i]);
        if (tmpDistance > closestDistance)
            continue;
        closestDistance = tmpDistance;
        *closestCorner = corners2[i];
    }

    return 1;
}

int Sol_CollisionCheckRectangleRectangle(Sol_ShapeRectangle2D const* r1, Sol_ShapeRectangle2D const* r2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo)
{
    Sol_Vec2 corner2 = {0.0f, 0.0f};
    if (!Sol_CheckRectangleRectangleCollisionAxis(r1, r2, difference, &corner2))
        return 0;

    Sol_Isometry2D inverseDifference = *difference;
    Sol_Vec2Scale(&inverseDifference.translation, -1.0f);
    inverseDifference.rotation.y *= -1.0f;
    Sol_Vec2Rotate(&inverseDifference.translation, &inverseDifference.rotation);

    Sol_Vec2 corner1 = {0.0f, 0.0f};
    if (!Sol_CheckRectangleRectangleCollisionAxis(r2, r1, &inverseDifference, &corner1))
        return 0;
    
    // Inverse transform of the corner if it exists
    if (corner1.x != 0.0f || corner1.y != 0.0f)
    {
        Sol_Vec2Rotate(&corner1, &difference->rotation);
        Sol_Vec2Add(&corner1, &difference->translation);
    }

    Sol_Vec2 diff = difference->translation;
    Sol_Vec2Sub(&diff, &corner1);
    

    if (corner1.x == 0 && corner1.y == 0)
    {
        corner1 = corner2;
        Sol_Vec2 normal = corner1;
        Sol_Vec2Normalize(&normal);
        
        Sol_Vec2 right = {1.0f, 0.0f};
        Sol_Vec2 up = {0.0f, 1.0f};
        Real dotR = Sol_Vec2Dot(&normal, &right);
        Real dotU = Sol_Vec2Dot(&normal, &up);

        if (fabs(dotR) >= HALF_SQRT_2)
            corner1.x = r1->width / 2.0f * (dotR > 0.0f ? 1.0f : -1.0f);
        else if (fabs(dotU) >= HALF_SQRT_2)
            corner1.y = r1->height / 2.0f * (dotU > 0.0f ? 1.0f : -1.0f);
    }
    else if (corner2.x == 0 && corner2.y == 0) 
    {
        Sol_Vec2Rotate(&corner1, &inverseDifference.rotation);
        Sol_Vec2Add(&corner1, &inverseDifference.translation);

        corner2 = corner1;
        Sol_Vec2 normal = corner2;
        Sol_Vec2Normalize(&normal);
        
        Sol_Vec2 right = {1.0f, 0.0f};
        Sol_Vec2 up = {0.0f, 1.0f};
        Real dotR = Sol_Vec2Dot(&normal, &right);
        Real dotU = Sol_Vec2Dot(&normal, &up);

        if (fabs(dotR) >= HALF_SQRT_2)
            corner2.x = r2->width / 2.0f * (dotR > 0.0f ? 1.0f : -1.0f);
        else 
            corner2.y = r2->height / 2.0f * (dotU > 0.0f ? 1.0f : -1.0f);
            
        Sol_Vec2Rotate(&corner1, &difference->rotation);
        Sol_Vec2Add(&corner1, &difference->translation);
        Sol_Vec2Rotate(&corner2, &difference->rotation);
        Sol_Vec2Add(&corner2, &difference->translation);
    }

    contactInfo->point1 = corner1;
    contactInfo->point2 = corner2;

    Sol_Vec2 distance = corner1;
    Sol_Vec2Add(&distance, &corner2);
    contactInfo->distance = Sol_Vec2Length(&distance);

    Sol_Vec2Normalize(&corner1);
    Sol_Vec2Rotate(&corner2, &inverseDifference.rotation);
    Sol_Vec2Add(&corner2, &inverseDifference.translation);
    Sol_Vec2Normalize(&corner2);

    contactInfo->normal1 = corner1;
    contactInfo->normal2 = corner2;

    return 1;
}

int Sol_CollisionCheckRectangleSegment(Sol_ShapeRectangle2D const* r, Sol_ShapeSegment2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckRectangleSphere(Sol_ShapeRectangle2D const* r, Sol_ShapeSphere2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo)
{
    Real const halfWidth = r->width / 2.0f;
    Real const halfHeight = r->height / 2.0f;
    Sol_Vec2 const halfExtends = {halfWidth, halfHeight};

    Real const cornerDistance = Sol_Vec2Length(&halfExtends);

    if(Sol_Vec2Length2(&difference->translation) > (cornerDistance + s->radius) * (cornerDistance + s->radius))
        return 0;
    
    if (difference->translation.x + s->radius < -halfWidth || 
        difference->translation.x - s->radius > halfWidth || 
        difference->translation.y + s->radius < -halfHeight || 
        difference->translation.y - s->radius > halfHeight)
        return 0;
    
    if (difference->translation.x <= halfWidth && difference->translation.x >= -halfWidth)
        contactInfo->point1.x = difference->translation.x;
    else 
        contactInfo->point1.x = halfWidth * (difference->translation.x > 0.0f ? 1.0f : -1.0f);

    if (difference->translation.y <= halfHeight && difference->translation.y >= -halfHeight)
        contactInfo->point1.y = difference->translation.y;
    else 
        contactInfo->point1.y = halfHeight * (difference->translation.y > 0.0f ? 1.0f : -1.0f);

    contactInfo->normal1 = contactInfo->point1;
    Sol_Vec2Normalize(&contactInfo->normal1);

    Sol_Vec2 normal2 = difference->translation;
    Sol_Vec2Sub(&normal2, &contactInfo->point1);
    Sol_Vec2Normalize(&normal2);
    
    contactInfo->point2 = normal2;
    contactInfo->normal2 = normal2;
    Sol_Vec2Scale(&contactInfo->point2, -s->radius);
    Sol_Vec2Add(&contactInfo->point2, &difference->translation);

    Sol_Vec2 diff = contactInfo->point2;
    Sol_Vec2Sub(&diff, &contactInfo->point2);
    contactInfo->distance = Sol_Vec2Length(&diff);

    return 1;
}

int Sol_CollisionCheckSegmentSegment(Sol_ShapeSegment2D const* s1, Sol_ShapeSegment2D const* s2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
int Sol_CollisionCheckSegmentSphere(Sol_ShapeSegment2D const* segment, Sol_ShapeSphere2D const* sphere, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* contactInfo);
