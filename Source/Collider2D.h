#ifndef SOL_COLLIDER_2D
#define SOL_COLLIDER_2D
#include "CollisionShapes2D.h"
#include <stddef.h>

typedef struct Sol_Collider2D 
{
    Sol_CollisionShape2DType collisionType;
    Sol_CollisionShape2D collisionShape;
    Sol_Isometry2D transform;
} Sol_Collider2D;

typedef struct {
    size_t i, j;
    Sol_CollisionContactInfo2D contactInfo;
} CollisionIter;

CollisionIter Sol_CollisionIterCreate();
int Sol_DetectNextCollisions(Sol_Collider2D const *colliders, size_t count, CollisionIter *iter);


#endif // SOL_COLLIDER_2D
