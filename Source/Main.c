#include <stdio.h>
#include "CollisionShapes2D.h"

int main()
{
    Sol_ShapeRectangle2D rect1 = {5.0, 5.0};
    Sol_ShapeRectangle2D rect2 = {2.0, 2.0};
    Sol_Isometry2D isometry1 = Sol_ISOMETRY2D_IDENTITY;
    Sol_Isometry2D isometry2 = Sol_ISOMETRY2D_IDENTITY;
    isometry2.translation.x = 5.0;
    printf("Hi\n");
}