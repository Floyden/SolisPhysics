#include "Collider2D.h"
#include <stdlib.h>

typedef struct Sol_ColliderSet_T {
    Sol_Collider2D* colliders;
    size_t size;
    size_t allocatedSize;
} Sol_ColliderSet_T;

void Sol_ColliderSetCreate(Sol_ColliderSet* set)
{
    static const DEFAULT_ALLOCATION_COUNT = 16;
    *set =(Sol_ColliderSet_T*) malloc(sizeof(Sol_ColliderSet_T));
    (*set)->colliders = (Sol_Collider2D*) malloc(sizeof(Sol_Collider2D) * DEFAULT_ALLOCATION_COUNT);
    (*set)->allocatedSize = DEFAULT_ALLOCATION_COUNT;
    (*set)->size = 0;
}

void Sol_ColliderSetDestroy(Sol_ColliderSet set)
{
    free(set->colliders);
    free(set);
}

Sol_ColliderIndex Sol_ColliderSetAddCollider(Sol_ColliderSet set, Sol_Collider2D collider)
{
    if (set->size >= set->allocatedSize)
    {
        set->colliders = (Sol_Collider2D*) realloc(set->colliders, sizeof(Sol_Collider2D) * (set->allocatedSize * 2));
        set->allocatedSize *= 2;
    }

    set->colliders[set->size++] = collider;
    return set->size;
}


