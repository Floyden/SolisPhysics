project('SolisPhysics', 'cpp',
    default_options : ['cpp_std=c++20', 'warning_level=3'])

cpp = meson.get_compiler('cpp')

incdir = include_directories('./Source')

libglm = dependency('glm')


source = [
    'Source/Test.cc',
]


executable('demo', source, 
    include_directories : [incdir], 
    dependencies : [libglm])