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

typedef struct Sol_ColliderSet_T* Sol_ColliderSet;
typedef size_t Sol_ColliderIndex;

void Sol_ColliderSetCreate(Sol_ColliderSet* set);
void Sol_ColliderSetDestroy(Sol_ColliderSet set);
Sol_ColliderIndex Sol_ColliderSetAddCollider(Sol_ColliderSet set, Sol_Collider2D collider);

#endif // SOL_COLLIDER_2D
