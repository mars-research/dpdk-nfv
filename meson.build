project('dpdk-nfv', ['cpp'], default_options: [
    'buildtype=release',
    'optimization=3',
    'b_lto=true',
    'cpp_std=c++17',
    'warning_level=3',
    'werror=true',
    ],)

 add_project_arguments('-Wno-deprecated-declarations', language: 'cpp')

no_trampoline_objects = []
no_fxsave_objects = []
fxsave_objects = []
sources = []
subdir('src')

dependencies = [
    dependency('libdpdk'),
    dependency('absl_container'),
    dependency('boost'),
]

libsashstore = subproject('libsashstore')

executable('nfv-notrampoline',
    sources + no_trampoline_objects,
    dependencies: dependencies,
    include_directories: libsashstore.get_variable('libsashstore_inc'),
    link_with: libsashstore.get_variable('libsashstore'),
)
executable('nfv-nofxsave',
    sources + no_fxsave_objects,
    dependencies: dependencies,
    include_directories: libsashstore.get_variable('libsashstore_inc'),
    link_with: libsashstore.get_variable('libsashstore'),
)
executable('nfv-fxsave',
    sources + fxsave_objects,
    dependencies: dependencies,
    include_directories: libsashstore.get_variable('libsashstore_inc'),
    link_with: libsashstore.get_variable('libsashstore'),
)
