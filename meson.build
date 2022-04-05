project('dpdk-nfv', ['c', 'cpp'], default_options: [
    'buildtype=release',
    'optimization=3',
    'debug=true',
    #'b_lto=true',
    'cpp_std=gnu++20',
    'warning_level=3',
    ],
)
rust_src_path = meson.source_root() + '/rust-nfv/'

# Set global flags.
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
if get_option('papi')
    cpp_args += ['-DPAPI']
endif

# Pass args to compiler.
add_project_arguments(cpp_args, language: 'cpp')


# Add SIMD disabling flags if simd is false.
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

    rust_target = ['--target', rust_src_path + '/x86_64-unknown-linux-gnu-nosimd.json']
else
    rust_target = ['--target', rust_src_path + '/x86_64-unknown-linux-gnu.json']
endif

# Load subdirectories.
sources = []
subdir('src')

# Build librust_nfv.
rust_nfv_lib = custom_target(
  'rust_nfv',
  output: 'librust_nfv.a',
  build_always_stale: true,
  command: ['env', 'RUSTFLAGS=-C target-cpu=native', 'cargo', 'build'] + rust_target + ['-Zbuild-std', '--manifest-path', rust_src_path + '/Cargo.toml', '--release', '--out-dir', '.', '-Zunstable-options', '--color', 'always'],
)

# Find common dependencies.
cpp = meson.get_compiler('cpp')
dependencies = [
    cpp.find_library('pthread'),
    cpp.find_library('dl'),
    dependency('libdpdk'),
    dependency('absl_flags', default_options: ['werror=false', 'warning_level=1', 'debug=true']),
]
if get_option('papi')
    dependencies += [dependency('papi')]
endif
rust_dependencies = dependencies

# Find cpp dependencies.
cpp_dependencies = dependencies + []

include_directories = [
    libnfv_inc,
    libtrampoline_inc,
]
cpp_link_with = [
    libnfv,
]

# Declare executables.
if get_option('simd')
    name_postfix = ''
else
    name_postfix = '_no_simd'
endif
foreach batch_size : ['1', '4', '8', '16', '32']
    cpp_args = ['-DBATCH_SIZE=' + batch_size]
    executable('nfv-notrampoline-' + batch_size,
        sources,
        dependencies: cpp_dependencies,
        include_directories: include_directories,
        link_with: cpp_link_with + [
            libtrampoline_no_trampoline,
        ],
        cpp_args: cpp_args + ['-DNAME=notrampoline' + name_postfix],
                link_args: [
        '-T' + meson.source_root() + '/user-trampoline/ls.ld'
        ]
        
    )
    executable('nfv-nofxsave-' + batch_size,
        sources,
        dependencies: cpp_dependencies,
        include_directories: include_directories,
        link_with: cpp_link_with + [
            libtrampoline_no_fxsave,
        ],
        cpp_args: cpp_args + ['-DNAME=nofxsave' + name_postfix],
                link_args: [
        '-T' + meson.source_root() + '/user-trampoline/ls.ld'
        ]
    )
    executable('nfv-fxsave-' + batch_size,
        sources,
        dependencies: cpp_dependencies,
        include_directories: include_directories,
        link_with: cpp_link_with + [
            libtrampoline_fxsave,
        ],
        cpp_args: cpp_args + ['-DNAME=fxsave' + name_postfix],
        link_args: [
        '-T' + meson.source_root() + '/user-trampoline/ls.ld'
        ]
    )
    executable('nfv-rust-' + batch_size,
        sources,
        include_directories: include_directories,
        dependencies: rust_dependencies,
        link_with: rust_nfv_lib,
        cpp_args: cpp_args + ['-DNAME=rust' + name_postfix],
        link_args: [
        '-T' + meson.source_root() + '/user-trampoline/ls.ld'
        ]

    )
endforeach