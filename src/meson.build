sources += files(
  'main.c',
  'packettool.cpp',
  'nf1.cpp',
  'nf2.cpp',
  'nf3.cpp',
  'nf4.cpp',
  '../user-trampoline/rt.c',
)


nasm = find_program('nasm', required: false)


if not nasm.found()
  error('MESON_SKIP_TEST: nasm not available')
endif

asm_args = []

if get_option('trampoline') == 'fxsave'
  asm_args += ['-DUSE_TRAMPOLINE', '-DUSE_FXSAVE']
elif get_option('trampoline') == 'no-fxsave'
  asm_args += ['-DUSE_TRAMPOLINE']
endif

asm_gen = generator(nasm,
  output : '@BASENAME@.o',
  arguments : [
    '-f', 'elf64',
    '@INPUT@',
    '-o', '@OUTPUT@'] + asm_args)

trampolines = asm_gen.process('trampolines.S')

objects += [
  trampolines,
]