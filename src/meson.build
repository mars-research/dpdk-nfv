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

no_trampoline_asm_args = []
no_fxsave_asm_args = no_trampoline_asm_args + ['-DUSE_TRAMPOLINE']
fxsave_asm_args = no_fxsave_asm_args + ['-DUSE_FXSAVE']

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


no_trampoline_objects += [
  no_trampoline_asm_gen.process('trampolines.S')
]
no_fxsave_objects += [
  no_fxsave_asm_gen.process('trampolines.S')
]
fxsave_objects += [
  fxsave_asm_gen.process('trampolines.S')
]
