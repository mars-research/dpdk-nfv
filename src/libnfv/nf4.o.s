	.text
	.file	"nf4.c"
	.globl	process_frames                  # -- Begin function process_frames
	.p2align	4, 0x90
	.type	process_frames,@function
process_frames:                         # @process_frames
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	pushq	%rax
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -24
	.cfi_offset %r14, -16
	testl	%esi, %esi
	jle	.LBB0_3
# %bb.1:                                # %for.body.preheader
	movq	%rdi, %rbx
	movl	%esi, %r14d
	.p2align	4, 0x90
.LBB0_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
	movl	$8, %esi
	movq	%rbx, %rdi
	callq	sxfi_check_deref@PLT
	movq	(%rax), %rdi
	callq	swap_mac
	addq	$8, %rbx
	addq	$-1, %r14
	jne	.LBB0_2
.LBB0_3:                                # %for.cond.cleanup
	addq	$8, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	popq	%r9
	jmpq	*%r9
	retq
	retq
.Lfunc_end0:
	.size	process_frames, .Lfunc_end0-process_frames
	.cfi_endproc
                                        # -- End function
	.ident	"clang version 13.0.0 (git@github.com:mars-research/llvm-project-13.x.git 1eec89b0ab27617a059c1277b6ac86e573f81315)"
	.section	".note.GNU-stack","",@progbits
