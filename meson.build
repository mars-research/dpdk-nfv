project('dpdk-nfv', ['cpp'], default_options: [
    'buildtype=release',
    'optimization=3',
    'debug=true',
    #'b_lto=true',
    'cpp_std=gnu++20',
    'warning_level=3',
    ],
)

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
    add_project_arguments(simd_disabling_args, language: 'cpp')
endif

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
    #dependency('papi'),
]

rust_src_path = meson.source_root() + '/src/rust-nfv/'
cargo = find_program('cargo')
rust_nfv_lib = custom_target(
  'rust_nfv',
  output: 'librust_nfv.a',
  build_always_stale: true,
  command: ['env', 'RUSTFLAGS=-C target-cpu=native', 'cargo', 'build', '--manifest-path', rust_src_path + '/Cargo.toml', '--release', '--out-dir', '.', '-Z', 'unstable-options'],
)
rust_nfv_no_simd_lib = custom_target(
  'rust_nfv_no_simd',
  output: 'librust_nfv_no_simd.a',
  build_always_stale: true,
  command: ['bash', '-c', 'env RUSTFLAGS="-C target-cpu=native" cargo build --target ' + rust_src_path + '/x86_64-unknown-linux-gnu-nosimd.json -Zbuild-std --manifest-path ' + rust_src_path + '/Cargo.toml --release --out-dir ./no_simd -Z unstable-options && cp ./no_simd/librust_nfv.a ./librust_nfv_no_simd.a'],
)
rust_dependencies = dependencies

cpp_dependencies = dependencies + [
    dependency('absl_container', default_options: ['werror=false', 'cpp_args=' + ' '.join(cpp_args), 'warning_level=1', 'debug=true']),
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
    link_with: rust_nfv_lib,
)
executable('nfv-rust-no-simd',
    sources,
    dependencies: rust_dependencies,
    link_with: rust_nfv_no_simd_lib,
)
