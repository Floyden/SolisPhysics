#include "Collider2D.h"
#include "Source/CollisionShapes2D.h"
#include "Source/Math.h"

CollisionIter Sol_CollisionIterCreate()
{
    return (CollisionIter) { 
        .i = 0, 
        .j = 1, 
        (Sol_CollisionContactInfo2D){} 
    };
}

int _HandleRectangleCollision(Sol_Collider2D const *colliderA, Sol_Collider2D const *colliderB, Sol_Isometry2D *difference, Sol_CollisionContactInfo2D *contactInfo)
{
    switch (colliderB->collisionType) {
    case SOL_COLLISION_SHAPE_2D_CAPSULE:
        // [TODO]
        return 0;
    case SOL_COLLISION_SHAPE_2D_CONVEX_POLYGON:
        // [TODO]
        return 0;
    case SOL_COLLISION_SHAPE_2D_RECTANGLE:
        return Sol_CollisionCheckRectangleRectangle((Sol_ShapeRectangle2D*)&colliderA->collisionShape, (Sol_ShapeRectangle2D*)&colliderA->collisionShape, difference, contactInfo);
    case SOL_COLLISION_SHAPE_2D_SEGMENT:
        // [TODO]
        return 0;
        //return Sol_CollisionCheckRectangleSegment((Sol_ShapeRectangle2D*)&colliderA->collisionShape, (Sol_ShapeSegment2D*)&colliderA->collisionShape, difference, contactInfo);
    case SOL_COLLISION_SHAPE_2D_SPHERE:
        // [TODO]
        return 0;
        //return Sol_CollisionCheckRectangleSphere((Sol_ShapeRectangle2D*)&colliderA->collisionShape, (Sol_ShapeSphere2D*)&colliderA->collisionShape, difference, contactInfo);
    }
    return 0;
}

int _HandleCollision(Sol_Collider2D const *colliderA, Sol_Collider2D const *colliderB, Sol_Isometry2D *difference, Sol_CollisionContactInfo2D *contactInfo)
{
    switch (colliderA->collisionType) {
    case SOL_COLLISION_SHAPE_2D_CAPSULE:
        // [TODO]
        break;
    case SOL_COLLISION_SHAPE_2D_CONVEX_POLYGON:
        // [TODO]
        break;
    case SOL_COLLISION_SHAPE_2D_RECTANGLE:
        return _HandleRectangleCollision(colliderA, colliderB, difference, contactInfo);
    case SOL_COLLISION_SHAPE_2D_SEGMENT:
        // [TODO]
        break;
    case SOL_COLLISION_SHAPE_2D_SPHERE:
        // [TODO]
        break;
    }
    return 0;
}

int DetectNextCollisions(Sol_Collider2D const *colliders, size_t count, CollisionIter *iter)
{
    while(iter->i < count - 1) {
        while(iter->j < count) {
            Sol_Isometry2D difference = colliders[iter->i].transform;
            Sol_Isometry2DSub(&difference, &colliders[iter->j].transform); 
            
            int res = _HandleCollision(&colliders[iter->i], &colliders[iter->j], &difference, &iter->contactInfo);

            ++iter->j;
            if(res) return 1;
        }
        ++iter->i;
        iter->j = iter->i + 1;
    }
    return 0;
}
