#include <stdio.h>
#include "CollisionShapes2D.h"

int main()
{
    Sol_ShapeRectangle2D rect1 = {5.0, 5.0};
    Sol_ShapeRectangle2D rect2 = {2.0, 4.0};
    Sol_Isometry2D isometry1 = Sol_ISOMETRY2D_IDENTITY;
    Sol_Isometry2D isometry2 = Sol_ISOMETRY2D_IDENTITY;
    isometry2.translation = (Sol_Vec2){3.0, 2.0};
    isometry2.rotation.x = sqrt(2.0) / 2.0;
    isometry2.rotation.y = sqrt(2.0) / 2.0;
    Sol_CollisionContactInfo2D colInfo;
    Sol_CollisionCheckRectangleRectangle(&rect1, &rect2, &isometry2, &colInfo);
}