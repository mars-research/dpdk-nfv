project('dpdk-nfv', ['cpp'], default_options: [
    'buildtype=release',
    'optimization=3',
    #'b_lto=true',
    'cpp_std=gnu++20',
    'warning_level=3',
    'werror=true',
    ],)

add_project_arguments('-Wno-deprecated-declarations', language: 'cpp')
add_project_arguments('-Wno-error=pedantic', language: 'cpp')
add_project_arguments('-Wno-pedantic', language: 'cpp')

no_trampoline_objects = []
no_fxsave_objects = []
fxsave_objects = []
cpp_sources = []
sources = []
subdir('src')

cpp = meson.get_compiler('cpp')

dependencies = [
    cpp.find_library('pthread'),
    cpp.find_library('dl'),
    dependency('libdpdk'),
]

cargo = find_program('cargo')
rust_nfv_lib = custom_target(
  'rust_nfv',
  output: 'librust_nfv.a',
  build_always_stale: true,
  command: ['cargo', 'build', '--manifest-path', meson.source_root() + '/src/rust-nfv/Cargo.toml', '--release', '--out-path', '.', '-Z', 'unstable-options'],
)
rust_dependencies = dependencies + [
    #cpp.find_library('rust_nfv', dirs: meson.current_source_dir() + '/src/rust-nfv/target/release'),
]

cpp_dependencies = dependencies + [
    dependency('absl_container', default_options: ['werror=false', 'cpp_args=-Wno-pedantic', 'warning_level=1']),
    dependency('boost'),
]

libsashstore = subproject('libsashstore')

executable('nfv-notrampoline',
    sources + cpp_sources + no_trampoline_objects,
    dependencies: cpp_dependencies,
    include_directories: libsashstore.get_variable('libsashstore_inc'),
    link_with: libsashstore.get_variable('libsashstore'),
)
executable('nfv-nofxsave',
    sources + cpp_sources + no_fxsave_objects,
    dependencies: cpp_dependencies,
    include_directories: libsashstore.get_variable('libsashstore_inc'),
    link_with: libsashstore.get_variable('libsashstore'),
)
executable('nfv-fxsave',
    sources + cpp_sources + fxsave_objects,
    dependencies: cpp_dependencies,
    include_directories: libsashstore.get_variable('libsashstore_inc'),
    link_with: libsashstore.get_variable('libsashstore'),
)
executable('nfv-rust',
    sources,
    dependencies: rust_dependencies,
    link_with: rust_nfvlib,
)
