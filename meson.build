project('Solis', 'c',
    default_options : 'c_std=c17')
    
source = [
    'Source/Math.c',
    'Source/CollisionShapes2D.c',
]

lib = library('solis_physics', source, link_args : '-lm')
executable('demo', 'Source/Main.c', link_args : '-lm', link_with : lib)