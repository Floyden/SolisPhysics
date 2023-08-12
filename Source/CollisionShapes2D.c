#include "CollisionShapes2D.h"

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
    Sol_Vec2 inverse_rotation = { difference->rotation[0], -difference->rotation[1] };
    Sol_Vec2Rotate(&contactInfo->normal2, &inverse_rotation);

    contactInfo->point1 = contactInfo->normal1;
    contactInfo->point2 = contactInfo->normal2;
    Sol_Vec2Scale(&contactInfo->point1, radius1);
    Sol_Vec2Scale(&contactInfo->point2, radius2);

    contactInfo->distance = sqrt(distanceSquared - radius1 - radius2);
    return 1;
}

int Sol_CollisionCheckCapsuleCapsule(Sol_ShapeCapsule2D const* c1, Sol_ShapeCapsule2D const* c2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);
int Sol_CollisionCheckCapsuleRectangle(Sol_ShapeCapsule2D const* c, Sol_ShapeRectangle2D const* r, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);
int Sol_CollisionCheckCapsuleSegment(Sol_ShapeCapsule2D const* c, Sol_ShapeSegment2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);
int Sol_CollisionCheckCapsuleSphere(Sol_ShapeCapsule2D const* c, Sol_ShapeSphere2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);

int Sol_CollisionCheckRectangleRectangle(Sol_ShapeRectangle2D const* r1, Sol_ShapeRectangle2D const* r2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);
int Sol_CollisionCheckRectangleSegment(Sol_ShapeRectangle2D const* r, Sol_ShapeSegment2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);
int Sol_CollisionCheckRectangleSphere(Sol_ShapeRectangle2D const* r, Sol_ShapeSphere2D const* s, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);

int Sol_CollisionCheckSegmentSegment(Sol_ShapeSegment2D const* s1, Sol_ShapeSegment2D const* s2, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);
int Sol_CollisionCheckSegmentSphere(Sol_ShapeSegment2D const* segment, Sol_ShapeSphere2D const* sphere, Sol_Isometry2D const* difference, Sol_CollisionContactInfo2D* out_contactInfo);
