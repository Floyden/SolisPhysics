project('Solis', 'c',
    default_options : ['c_std=c17'])
    
source = [
    'Source/Math.c',
    'Source/Collider2D.c',
    'Source/CollisionShapes2D.c',
]

lib = library('solis_physics', source, c_args : ['-ffast-math', '-O3'], link_args : ['-lm', '-lraylib'])
executable('demo', 'Source/Main.c', c_args : ['-ffast-math', '-O0'], link_args : ['-lm', '-lraylib'], link_with : lib)
