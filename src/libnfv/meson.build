# Declare sources
libnfv_sources = files(
  'nfv.c',
)
libnfv_inc = include_directories('./.')

# Declare dependencies
libnfv_dependencies = [
    dependency('libdpdk'),
    dependency('absl_container', default_options: ['werror=false', 'cpp_args=' + ' '.join(cpp_args), 'warning_level=1', 'debug=true']),
]

# Find nasm compiler
nasm = find_program('nasm', required: false)
if not nasm.found()
  error('MESON_SKIP_TEST: nasm not available')
endif

# Load libsashstore
libsashstore = subproject('libsashstore')

include_directories = [
  libsashstore.get_variable('libsashstore_inc'),
]

link_with = [
  libsashstore.get_variable('libsashstore'),
]

# Define libraries.
libnfv = static_library('nfv',
	libnfv_sources,
  include_directories: include_directories,
	dependencies: libnfv_dependencies,
  link_with: link_with,
)
