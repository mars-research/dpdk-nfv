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

# Propagate meson flags to compilers. 
# burst_size = get_option('burst_size')
# assert(burst_size % 4 == 0, '''
#     Some drivers using vector instructions require that *nb_pkts* is
#     divisible by 4 or 8, depending on the driver implementation.
#     https://github.com/DPDK/dpdk/blob/02e077f35dbc9821dfcb32714ad1096a3ee58d08/lib/ethdev/rte_ethdev.h#L4954-L4956
# ''')
# cpp_args += [
#     '-DBURST_SIZE=' + get_option('burst_size').to_string()
# ]


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

    rust_target = ['--target', rust_src_path + '/x86_64-unknown-linux-gnu-nosimd.json', '-Zbuild-std']
endif

# Load subdirectories.
sources = []
subdir('src')

# Build librust_nfv.
cargo = find_program('cargo')
rust_nfv_lib = custom_target(
  'rust_nfv',
  output: 'librust_nfv.a',
  build_always_stale: true,
  command: ['env', 'RUSTFLAGS=-C target-cpu=native', 'cargo', 'build'] + rust_target + ['--manifest-path', rust_src_path + '/Cargo.toml', '--release', '--out-dir', '.', '-Z', 'unstable-options'],
)

# Find common dependencies.
cpp = meson.get_compiler('cpp')
dependencies = [
    cpp.find_library('pthread'),
    cpp.find_library('dl'),
    dependency('libdpdk'),
    #dependency('papi'),
]
rust_dependencies = dependencies

# Find cpp dependencies.
cpp_dependencies = dependencies + [
    dependency('boost'),
]

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
foreach burst_size : ['1', '4', '8', '16', '32']
    cpp_args = ['-DBURST_SIZE=' + burst_size]
    executable('nfv-notrampoline-' + burst_size,
        sources,
        dependencies: cpp_dependencies,
        include_directories: include_directories,
        link_with: cpp_link_with + [
            libtrampoline_no_trampoline,
        ],
        cpp_args: cpp_args + ['-DNAME=notrampoline' + name_postfix]
    )
    executable('nfv-nofxsave-' + burst_size,
        sources,
        dependencies: cpp_dependencies,
        include_directories: include_directories,
        link_with: cpp_link_with + [
            libtrampoline_no_fxsave,
        ],
        cpp_args: cpp_args + ['-DNAME=nofxsave' + name_postfix]
    )
    executable('nfv-fxsave-' + burst_size,
        sources,
        dependencies: cpp_dependencies,
        include_directories: include_directories,
        link_with: cpp_link_with + [
            libtrampoline_fxsave,
        ],
        cpp_args: cpp_args + ['-DNAME=fxsave' + name_postfix]
    )
    executable('nfv-rust-' + burst_size,
        sources,
        include_directories: include_directories,
        dependencies: rust_dependencies,
        link_with: rust_nfv_lib,
        cpp_args: cpp_args + ['-DNAME=rust' + name_postfix]
    )
endforeach