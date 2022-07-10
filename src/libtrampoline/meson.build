# Declare sources
libtrampoline_sources = files(
  '../../user-trampoline/rt.c',
  '../../user-trampoline/buddy.c',
)
libtrampoline_inc = include_directories(
  '.',
  '../../user-trampoline/',
)

# Declare dependencies
libtrampoline_dependencies = []

# Find nasm compiler
nasm = find_program('nasm', required: false)
if not nasm.found()
  error('MESON_SKIP_TEST: nasm not available')
endif

# Construct compiler arguments.
no_trampoline_asm_args = []
no_fxsave_asm_args = no_trampoline_asm_args + ['-DUSE_TRAMPOLINE', '-DUSE_REGWIPE', 
'-DUSE_ATOMIC', '-DUSE_PASSING_BUFFER', '-DUSE_WRPKRU','-DUSE_CHECK_CALLER','-DUSE_CHECK_RAX']
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


include_directories = []

link_with = []

# Define libraries.
libtrampoline_no_trampoline = static_library('trampoline_no_trampoline',
	no_trampoline_objects + libtrampoline_sources,
  include_directories: include_directories,
	dependencies: libtrampoline_dependencies,
  link_with: link_with,
)

libtrampoline_no_fxsave = static_library('trampoline_no_fxsave',
	no_fxsave_objects + libtrampoline_sources,
  include_directories: include_directories,
	dependencies: libtrampoline_dependencies,
  link_with: link_with,
)

libtrampoline_fxsave = static_library('trampoline_fxsave',
	fxsave_objects + libtrampoline_sources,
  include_directories: include_directories,
	dependencies: libtrampoline_dependencies,
  link_with: link_with,
)

