# Declare sources
libnfv_sources = files(
  '../../user-trampoline/rt.c',
  'packettool.cpp',
  'nfv.cpp',
  'nf1.cpp',
  'nf2.cpp',
  'nf3.cpp',
  'nf4.cpp',
)
libnfv_inc = include_directories('./.')

# Declare dependencies
libnfv_dependencies = [
    dependency('libdpdk'),
    dependency('absl_container', default_options: ['werror=false', 'cpp_args=' + ' '.join(cpp_args), 'warning_level=1', 'debug=true']),
]

# Declare default options.
libnfv_default_options =  [
  'debug=true',
  'b_lto=true',
]

# Find nasm compiler
nasm = find_program('nasm', required: false)
if not nasm.found()
  error('MESON_SKIP_TEST: nasm not available')
endif

# Construct compiler arguments.
no_trampoline_asm_args = []
no_fxsave_asm_args = no_trampoline_asm_args + ['-DUSE_TRAMPOLINE', '-DUSE_REGWIPE']
fxsave_asm_args = no_fxsave_asm_args + ['-DUSE_SIMD']

# Configure compiler.
no_trampoline_asm_gen = generator(nasm,
  output : '@BASENAME@.o',
  arguments : [
    '-f', 'elf64',
    '@INPUT@',
    '-o', '@OUTPUT@'] + no_trampoline_asm_args)
no_fxsave_asm_gen = generator(nasm,
  output : '@BASENAME@.o',
  arguments : [
    '-f', 'elf64',
    '@INPUT@',
    '-o', '@OUTPUT@'] + no_fxsave_asm_args)
fxsave_asm_gen = generator(nasm,
  output : '@BASENAME@.o',
  arguments : [
    '-f', 'elf64',
    '@INPUT@',
    '-o', '@OUTPUT@'] + fxsave_asm_args)

# Compile asm to objects.
no_trampoline_objects = [
  no_trampoline_asm_gen.process('trampolines.S')
]
no_fxsave_objects = [
  no_fxsave_asm_gen.process('trampolines.S')
]
fxsave_objects = [
  fxsave_asm_gen.process('trampolines.S')
]

# Load libsashstore
libsashstore = subproject('libsashstore')

include_directories = [
  libsashstore.get_variable('libsashstore_inc'),
]

link_with = [
  libsashstore.get_variable('libsashstore'),
]

# Define libraries.
libnfv_no_trampoline = library('nfv_no_trampoline',
	libnfv_sources + no_trampoline_objects,
  include_directories: include_directories,
	dependencies: libnfv_dependencies,
  link_with: link_with,
	default_options: libnfv_default_options,
)

libnfv_no_fxsave = library('nfv_no_fxsave',
	libnfv_sources + no_fxsave_objects,
  include_directories: include_directories,
	dependencies: libnfv_dependencies,
  link_with: link_with,
	default_options: libnfv_default_options,
)

libnfv_fxsave = library('nfv_fxsave',
	libnfv_sources + fxsave_objects,
  include_directories: include_directories,
	dependencies: libnfv_dependencies,
  link_with: link_with,
	default_options: libnfv_default_options,
)

