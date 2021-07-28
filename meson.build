project('dpdk-nfv', ['cpp'], default_options: [
    'buildtype=release',
    'optimization=3',
    'debug=true',
    #'b_lto=true',
    'cpp_std=gnu++20',
    'warning_level=3',
    ],
)
rust_src_path = meson.source_root() + '/rust-nfv/'

cpp_args = [
    '-ggdb',
    '-g3',
    '-fno-omit-frame-pointer',
    '-mtune=native',
    '-march=native',
    '-Wno-pedantic',
    '-Wno-error=pedantic',
    '-Wno-deprecated-declarations'
]
rust_target = []
if not get_option('simd')
    simd_disabling_args = [
        '-mno-mmx',
        '-mno-sse',
        '-mno-sse2',
        '-mno-sse3',
        '-mno-ssse3',
        '-mno-sse4',
        '-mno-sse4a',
        '-mno-sse4.1',
        '-mno-sse4.2',
        '-mno-avx',
        '-mno-avx2',
        '-mno-avx512f',
        '-mno-avx512pf',
        '-mno-avx512er',
        '-mno-avx512cd',
        '-mno-avx512vl',
        '-mno-avx512bw',
        '-mno-avx512dq',
        '-mno-avx512ifma',
        '-mno-avx512vbmi',
        '-msoft-float',
        '-lsoft-fp']
    cpp_args += simd_disabling_args
    # We don't add it to the entire project. Main uses STD, which uses SIMD.
    #add_project_arguments(simd_disabling_args, language: 'cpp')

    rust_target = ['--target', rust_src_path + '/x86_64-unknown-linux-gnu-nosimd.json', '-Zbuild-std']
endif

sources = []
subdir('src')

cpp = meson.get_compiler('cpp')

dependencies = [
    cpp.find_library('pthread'),
    cpp.find_library('dl'),
    dependency('libdpdk'),
    #dependency('papi'),
]

cargo = find_program('cargo')
rust_nfv_lib = custom_target(
  'rust_nfv',
  output: 'librust_nfv.a',
  build_always_stale: true,
  command: ['env', 'RUSTFLAGS=-C target-cpu=native', 'cargo', 'build'] + rust_target + ['--manifest-path', rust_src_path + '/Cargo.toml', '--release', '--out-dir', '.', '-Z', 'unstable-options'],
)
rust_dependencies = dependencies

cpp_dependencies = dependencies + [
    dependency('boost'),
]

include_directories = [
    libnfv_inc,
]
link_with = []

executable('nfv-notrampoline',
    sources + no_trampoline_objects,
    dependencies: cpp_dependencies,
    include_directories: include_directories,
    link_with: link_with + [
        libnfv_no_trampoline,
    ]
)
executable('nfv-nofxsave',
    sources + no_fxsave_objects,
    dependencies: cpp_dependencies,
    include_directories: include_directories,
    link_with: link_with + [
        libnfv_no_fxsave,
    ]
)
executable('nfv-fxsave',
    sources + fxsave_objects,
    dependencies: cpp_dependencies,
    include_directories: include_directories,
    link_with: link_with + [
        libnfv_fxsave,
    ]
)
executable('nfv-rust',
    sources,
    include_directories: include_directories,
    dependencies: rust_dependencies,
    link_with: rust_nfv_lib,
)
