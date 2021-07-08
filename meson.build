project('dpdk-nfv', ['c', 'cpp'], default_options: ['buildtype=release', 'cpp_std=c++20'],)
add_global_arguments(['-Wall', '-Wextra', '-pedantic'], language : ['c', 'cpp'])

sources = []
subdir('src')


dependencies = [
    dependency('libdpdk'),
    dependency('absl_container'),
    dependency('boost'),
]


executable('kmercounter', sources, dependencies: dependencies)
