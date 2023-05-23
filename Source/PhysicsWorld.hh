#pragma once
#include "Defines.hh"
#include "Shape/IShape.hh"
#include <type_traits>

namespace Solis::Physics
{
class World {
public:
    template<class Shape, class... Args>
    Shape* CreateShape(Args&&... args) {
        static_assert(std::is_convertible<Shape*, IShape*>::value, "Class Shape must inherit from IShape");
        
        mShapes.emplace_back(UPtr<IShape>(new Shape(std::forward<Args>(args)...)));
        return reinterpret_cast<Shape*>(mShapes.back().get());
    }

    void Destroy() {
        mShapes.clear();
    }

private:
    Vector<UPtr<IShape>> mShapes;
};
    
} // namespace Solis::Physics
