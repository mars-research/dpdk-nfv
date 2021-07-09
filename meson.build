project('dpdk-nfv', ['c', 'cpp'], default_options: ['buildtype=release', 'cpp_std=c++20'],)
add_project_arguments(['-Wall', '-Wextra'], language : ['c', 'cpp'])

sources = []
subdir('src')


dependencies = [
    dependency('libdpdk'),
    dependency('absl_container'),
    dependency('boost'),
]


executable('nfv', sources, dependencies: dependencies)
