	.text
	.file	"maglev.c"
	.globl	swap_mac                        # -- Begin function swap_mac
	.p2align	4, 0x90
	.type	swap_mac,@function
swap_mac:                               # @swap_mac
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %rbp, -16
	movq	%rdi, %rbx
	leaq	6(%rdi), %r14
	movl	$8, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %bpl
	movl	$8, %esi
	movq	%rbx, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %r12b
	movl	$1, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	%r12b, (%rax)
	movl	$1, %esi
	movq	%rbx, %rdi
	callq	sxfi_check_deref@PLT
	movb	%bpl, (%rax)
	leaq	7(%rbx), %r14
	movl	$8, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %bpl
	leaq	1(%rbx), %r12
	movl	$8, %esi
	movq	%r12, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %r13b
	movl	$1, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	%r13b, (%rax)
	movl	$1, %esi
	movq	%r12, %rdi
	callq	sxfi_check_deref@PLT
	movb	%bpl, (%rax)
	leaq	8(%rbx), %r14
	movl	$8, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %bpl
	leaq	2(%rbx), %r12
	movl	$8, %esi
	movq	%r12, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %r13b
	movl	$1, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	%r13b, (%rax)
	movl	$1, %esi
	movq	%r12, %rdi
	callq	sxfi_check_deref@PLT
	movb	%bpl, (%rax)
	leaq	9(%rbx), %r14
	movl	$8, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %bpl
	leaq	3(%rbx), %r12
	movl	$8, %esi
	movq	%r12, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %r13b
	movl	$1, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	%r13b, (%rax)
	movl	$1, %esi
	movq	%r12, %rdi
	callq	sxfi_check_deref@PLT
	movb	%bpl, (%rax)
	leaq	10(%rbx), %r14
	movl	$8, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %bpl
	leaq	4(%rbx), %r12
	movl	$8, %esi
	movq	%r12, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %r13b
	movl	$1, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	%r13b, (%rax)
	movl	$1, %esi
	movq	%r12, %rdi
	callq	sxfi_check_deref@PLT
	movb	%bpl, (%rax)
	leaq	11(%rbx), %r14
	movl	$8, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %bpl
	addq	$5, %rbx
	movl	$8, %esi
	movq	%rbx, %rdi
	callq	sxfi_check_deref@PLT
	movb	(%rax), %r12b
	movl	$1, %esi
	movq	%r14, %rdi
	callq	sxfi_check_deref@PLT
	movb	%r12b, (%rax)
	movl	$1, %esi
	movq	%rbx, %rdi
	callq	sxfi_check_deref@PLT
	movb	%bpl, (%rax)
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	popq	%r9
	jmpq	*%r9
	retq
	retq
.Lfunc_end0:
	.size	swap_mac, .Lfunc_end0-swap_mac
	.cfi_endproc
                                        # -- End function
	.globl	populate_lut                    # -- Begin function populate_lut
	.p2align	4, 0x90
	.type	populate_lut,@function
populate_lut:                           # @populate_lut
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$64, %rsp
	.cfi_def_cfa_offset 112
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %rbp, -16
	movq	%rdi, %rbp
	movl	$65537, %edx                    # imm = 0x10001
	movl	$255, %esi
	callq	memset@PLT
	leaq	79957(%rbp), %rax
	movq	%rax, 56(%rsp)                  # 8-byte Spill
	leaq	51383(%rbp), %rax
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	leaq	103622(%rbp), %rax
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	xorl	%r14d, %r14d
	xorl	%ebx, %ebx
	xorl	%r13d, %r13d
	xorl	%eax, %eax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	movq	%rbp, 32(%rsp)                  # 8-byte Spill
	jmp	.LBB1_1
	.p2align	4, 0x90
.LBB1_15:                               #   in Loop: Header=BB1_1 Depth=1
	movq	16(%rsp), %r13                  # 8-byte Reload
	movq	8(%rsp), %rbx                   # 8-byte Reload
	movq	%rbp, %rdi
.LBB1_19:                               # %while.end.2
                                        #   in Loop: Header=BB1_1 Depth=1
	addq	$1, %r14
	addq	$1, %rbx
	movq	32(%rsp), %rbp                  # 8-byte Reload
	addq	%rbp, %rdi
	movl	$1, %esi
	callq	sxfi_check_deref@PLT
	movb	$2, (%rax)
	addq	$1, %r13
	movq	24(%rsp), %rcx                  # 8-byte Reload
	addq	$3, %rcx
	movq	%rcx, %rax
	movq	%rcx, 24(%rsp)                  # 8-byte Spill
	cmpq	$65537, %rcx                    # imm = 0x10001
	je	.LBB1_9
.LBB1_1:                                # %for.cond1
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_6 Depth 2
                                        #     Child Loop BB1_11 Depth 2
                                        #     Child Loop BB1_17 Depth 2
	movq	%rbx, 8(%rsp)                   # 8-byte Spill
	movq	%r13, 16(%rsp)                  # 8-byte Spill
	imulq	$27606, %r14, %rbx              # imm = 0x6BD6
	movq	%rbp, %r13
	leaq	52351(%rbx), %r12
	movq	%r12, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%r12, %rbp
	subq	%rax, %rbp
	movq	%r13, %rdi
	addq	%rbp, %rdi
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	cmpb	$0, (%rax)
	js	.LBB1_2
# %bb.5:                                # %while.body.preheader
                                        #   in Loop: Header=BB1_1 Depth=1
	movabsq	$-281470681808895, %rbp         # imm = 0xFFFF0000FFFF0001
	movq	56(%rsp), %rax                  # 8-byte Reload
	leaq	(%rax,%rbx), %r13
	addq	$79957, %rbx                    # imm = 0x13855
	.p2align	4, 0x90
.LBB1_6:                                # %while.body
                                        #   Parent Loop BB1_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%rbx, %rax
	mulq	%rbp
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%r13, %rdi
	subq	%rax, %rdi
	addq	$1, %r14
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	addq	$27606, %r12                    # imm = 0x6BD6
	addq	$27606, %r13                    # imm = 0x6BD6
	addq	$27606, %rbx                    # imm = 0x6BD6
	cmpb	$0, (%rax)
	jns	.LBB1_6
# %bb.7:                                # %while.end.loopexit
                                        #   in Loop: Header=BB1_1 Depth=1
	movq	%r12, %rax
	mulq	%rbp
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	subq	%rax, %r12
	movq	%r12, %rdi
	movq	32(%rsp), %r13                  # 8-byte Reload
	movq	8(%rsp), %r12                   # 8-byte Reload
	jmp	.LBB1_8
	.p2align	4, 0x90
.LBB1_2:                                #   in Loop: Header=BB1_1 Depth=1
	movq	8(%rsp), %r12                   # 8-byte Reload
	movq	%rbp, %rdi
.LBB1_8:                                # %while.end
                                        #   in Loop: Header=BB1_1 Depth=1
	addq	%r13, %rdi
	movl	$1, %esi
	callq	sxfi_check_deref@PLT
	movb	$0, (%rax)
	cmpq	$65536, 24(%rsp)                # 8-byte Folded Reload
                                        # imm = 0x10000
	je	.LBB1_9
# %bb.3:                                # %for.cond3
                                        #   in Loop: Header=BB1_1 Depth=1
	movq	%r13, %rbp
	imulq	$47859, %r12, %rbx              # imm = 0xBAF3
	leaq	3524(%rbx), %r12
	movq	%r12, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%r12, %r13
	subq	%rax, %r13
	movq	%rbp, %rdi
	addq	%r13, %rdi
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	cmpb	$0, (%rax)
	js	.LBB1_4
# %bb.10:                               # %while.body.1.preheader
                                        #   in Loop: Header=BB1_1 Depth=1
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	8(%rsp), %r13                   # 8-byte Reload
	leaq	(%rax,%rbx), %rbp
	addq	$51383, %rbx                    # imm = 0xC8B7
	.p2align	4, 0x90
.LBB1_11:                               # %while.body.1
                                        #   Parent Loop BB1_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%rbx, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%rbp, %rdi
	subq	%rax, %rdi
	addq	$1, %r13
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	addq	$47859, %r12                    # imm = 0xBAF3
	addq	$47859, %rbp                    # imm = 0xBAF3
	addq	$47859, %rbx                    # imm = 0xBAF3
	cmpb	$0, (%rax)
	jns	.LBB1_11
# %bb.12:                               # %while.end.1.loopexit
                                        #   in Loop: Header=BB1_1 Depth=1
	movq	%r12, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	subq	%rax, %r12
	movq	%r12, %rdi
	movq	%r13, %rbx
	movq	16(%rsp), %r12                  # 8-byte Reload
	movq	32(%rsp), %rbp                  # 8-byte Reload
	jmp	.LBB1_13
	.p2align	4, 0x90
.LBB1_4:                                #   in Loop: Header=BB1_1 Depth=1
	movq	16(%rsp), %r12                  # 8-byte Reload
	movq	8(%rsp), %rbx                   # 8-byte Reload
	movq	%r13, %rdi
.LBB1_13:                               # %while.end.1
                                        #   in Loop: Header=BB1_1 Depth=1
	addq	%rbp, %rdi
	movl	$1, %esi
	callq	sxfi_check_deref@PLT
	movb	$1, (%rax)
	cmpq	$65535, 24(%rsp)                # 8-byte Folded Reload
                                        # imm = 0xFFFF
	je	.LBB1_9
# %bb.14:                               # %for.cond3.1
                                        #   in Loop: Header=BB1_1 Depth=1
	movq	%rbp, %rsi
	movq	%rbx, 8(%rsp)                   # 8-byte Spill
	movq	%r12, %rbx
	imulq	$59205, %r12, %rbx              # imm = 0xE745
	leaq	44417(%rbx), %r12
	movq	%r12, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%r12, %rbp
	subq	%rax, %rbp
	leaq	(%rsi,%rbp), %rdi
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	cmpb	$0, (%rax)
	js	.LBB1_15
# %bb.16:                               # %while.body.2.preheader
                                        #   in Loop: Header=BB1_1 Depth=1
	movq	40(%rsp), %rax                  # 8-byte Reload
	leaq	(%rax,%rbx), %rbp
	addq	$103622, %rbx                   # imm = 0x194C6
	movq	16(%rsp), %r13                  # 8-byte Reload
	.p2align	4, 0x90
.LBB1_17:                               # %while.body.2
                                        #   Parent Loop BB1_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%rbx, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%rbp, %rdi
	subq	%rax, %rdi
	addq	$1, %r13
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	addq	$59205, %r12                    # imm = 0xE745
	addq	$59205, %rbp                    # imm = 0xE745
	addq	$59205, %rbx                    # imm = 0xE745
	cmpb	$0, (%rax)
	jns	.LBB1_17
# %bb.18:                               # %while.end.2.loopexit
                                        #   in Loop: Header=BB1_1 Depth=1
	movq	%r12, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	subq	%rax, %r12
	movq	%r12, %rdi
	movq	8(%rsp), %rbx                   # 8-byte Reload
	jmp	.LBB1_19
.LBB1_9:                                # %cleanup29
	addq	$64, %rsp
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	popq	%r9
	jmpq	*%r9
	retq
	retq
.Lfunc_end1:
	.size	populate_lut, .Lfunc_end1-populate_lut
	.cfi_endproc
                                        # -- End function
	.globl	maglev_hashmap_insert           # -- Begin function maglev_hashmap_insert
	.p2align	4, 0x90
	.type	maglev_hashmap_insert,@function
maglev_hashmap_insert:                  # @maglev_hashmap_insert
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$16, %rsp
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %rbp, -16
	movq	%rsi, 8(%rsp)                   # 8-byte Spill
	movq	%rdi, %r12
	movsbq	%r12b, %rax
	movabsq	$-5808590958014384161, %rcx     # imm = 0xAF63BD4C8601B7DF
	xorq	%rax, %rcx
	movabsq	$1099511628211, %rax            # imm = 0x100000001B3
	imulq	%rax, %rcx
	movq	%rdi, %rdx
	shrq	$8, %rdx
	movsbq	%dl, %rdx
	xorq	%rcx, %rdx
	imulq	%rax, %rdx
	movq	%rdi, %rcx
	shrq	$16, %rcx
	movsbq	%cl, %rcx
	xorq	%rdx, %rcx
	imulq	%rax, %rcx
	movq	%rdi, %rdx
	shrq	$24, %rdx
	movsbq	%dl, %rdx
	xorq	%rcx, %rdx
	imulq	%rax, %rdx
	movq	%rdi, %rcx
	shrq	$32, %rcx
	movsbq	%cl, %rcx
	xorq	%rdx, %rcx
	imulq	%rax, %rcx
	movq	%rdi, %rdx
	shrq	$40, %rdx
	movsbq	%dl, %rdx
	xorq	%rcx, %rdx
	imulq	%rax, %rdx
	movq	%rdi, %rcx
	shrq	$48, %rcx
	movsbq	%cl, %rcx
	xorq	%rdx, %rcx
	imulq	%rax, %rcx
	movq	%rdi, %r13
	sarq	$56, %r13
	xorq	%rcx, %r13
	xorl	%ebp, %ebp
	.p2align	4, 0x90
.LBB2_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
	leal	(%r13,%rbp), %r14d
	andl	$16777215, %r14d                # imm = 0xFFFFFF
	shlq	$4, %r14
	leaq	maglev_kv_pairs(%r14), %rbx
	movl	$8, %esi
	movq	%rbx, %rdi
	callq	sxfi_check_deref@PLT
	movq	(%rax), %rax
	cmpq	%r12, %rax
	je	.LBB2_4
# %bb.3:                                # %for.body
                                        #   in Loop: Header=BB2_2 Depth=1
	testq	%rax, %rax
	je	.LBB2_4
# %bb.1:                                # %for.cond
                                        #   in Loop: Header=BB2_2 Depth=1
	addq	$1, %rbp
	cmpq	$16777216, %rbp                 # imm = 0x1000000
	jne	.LBB2_2
	jmp	.LBB2_5
.LBB2_4:                                # %if.then
	movl	$8, %esi
	movq	%rbx, %rdi
	callq	sxfi_check_deref@PLT
	movq	%r12, (%rax)
	leaq	maglev_kv_pairs+8(%r14), %rdi
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	movq	8(%rsp), %rcx                   # 8-byte Reload
	movq	%rcx, (%rax)
.LBB2_5:                                # %cleanup8
	addq	$16, %rsp
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	popq	%r9
	jmpq	*%r9
	retq
	retq
.Lfunc_end2:
	.size	maglev_hashmap_insert, .Lfunc_end2-maglev_hashmap_insert
	.cfi_endproc
                                        # -- End function
	.globl	maglev_hashmap_get              # -- Begin function maglev_hashmap_get
	.p2align	4, 0x90
	.type	maglev_hashmap_get,@function
maglev_hashmap_get:                     # @maglev_hashmap_get
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%r14
	.cfi_def_cfa_offset 16
	pushq	%r13
	.cfi_def_cfa_offset 24
	pushq	%r12
	.cfi_def_cfa_offset 32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r12, -32
	.cfi_offset %r13, -24
	.cfi_offset %r14, -16
	movq	%rdi, %r14
	movsbq	%r14b, %rax
	movabsq	$-5808590958014384161, %rcx     # imm = 0xAF63BD4C8601B7DF
	xorq	%rax, %rcx
	movabsq	$1099511628211, %rax            # imm = 0x100000001B3
	imulq	%rax, %rcx
	movq	%rdi, %rdx
	shrq	$8, %rdx
	movsbq	%dl, %rdx
	xorq	%rcx, %rdx
	imulq	%rax, %rdx
	movq	%rdi, %rcx
	shrq	$16, %rcx
	movsbq	%cl, %rcx
	xorq	%rdx, %rcx
	imulq	%rax, %rcx
	movq	%rdi, %rdx
	shrq	$24, %rdx
	movsbq	%dl, %rdx
	xorq	%rcx, %rdx
	imulq	%rax, %rdx
	movq	%rdi, %rcx
	shrq	$32, %rcx
	movsbq	%cl, %rcx
	xorq	%rdx, %rcx
	imulq	%rax, %rcx
	movq	%rdi, %rdx
	shrq	$40, %rdx
	movsbq	%dl, %rdx
	xorq	%rcx, %rdx
	imulq	%rax, %rdx
	movq	%rdi, %rcx
	shrq	$48, %rcx
	movsbq	%cl, %rcx
	xorq	%rdx, %rcx
	imulq	%rax, %rcx
	movq	%rdi, %r12
	sarq	$56, %r12
	xorq	%rcx, %r12
	xorl	%ebx, %ebx
	.p2align	4, 0x90
.LBB3_1:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
	leal	(%r12,%rbx), %eax
	andl	$16777215, %eax                 # imm = 0xFFFFFF
	shlq	$4, %rax
	leaq	maglev_kv_pairs(%rax), %r13
	movl	$8, %esi
	movq	%r13, %rdi
	callq	sxfi_check_deref@PLT
	movq	(%rax), %rax
	testq	%rax, %rax
	je	.LBB3_5
# %bb.2:                                # %cleanup
                                        #   in Loop: Header=BB3_1 Depth=1
	cmpq	%r14, %rax
	je	.LBB3_6
# %bb.3:                                # %for.cond
                                        #   in Loop: Header=BB3_1 Depth=1
	addq	$1, %rbx
	cmpq	$16777216, %rbx                 # imm = 0x1000000
	jne	.LBB3_1
.LBB3_5:
	xorl	%r13d, %r13d
.LBB3_6:                                # %cleanup8
	movq	%r13, %rax
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r12
	.cfi_def_cfa_offset 24
	popq	%r13
	.cfi_def_cfa_offset 16
	popq	%r14
	.cfi_def_cfa_offset 8
	popq	%r9
	jmpq	*%r9
	retq
	retq
.Lfunc_end3:
	.size	maglev_hashmap_get, .Lfunc_end3-maglev_hashmap_get
	.cfi_endproc
                                        # -- End function
	.globl	maglev_process_frame            # -- Begin function maglev_process_frame
	.p2align	4, 0x90
	.type	maglev_process_frame,@function
maglev_process_frame:                   # @maglev_process_frame
	.cfi_startproc
# %bb.0:                                # %entry
	movq	$-1, %rax
	popq	%r9
	jmpq	*%r9
	retq
	retq
.Lfunc_end4:
	.size	maglev_process_frame, .Lfunc_end4-maglev_process_frame
	.cfi_endproc
                                        # -- End function
	.globl	maglev_init                     # -- Begin function maglev_init
	.p2align	4, 0x90
	.type	maglev_init,@function
maglev_init:                            # @maglev_init
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%r13
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	subq	$32, %rsp
	.cfi_def_cfa_offset 80
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r13, -32
	.cfi_offset %r14, -24
	.cfi_offset %rbp, -16
	movl	$maglev_lookup, %edi
	movl	$65537, %edx                    # imm = 0x10001
	movl	$255, %esi
	callq	memset@PLT
	xorl	%ebx, %ebx
	movabsq	$-281470681808895, %r13         # imm = 0xFFFF0000FFFF0001
	xorl	%r12d, %r12d
	xorl	%eax, %eax
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	xorl	%eax, %eax
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	jmp	.LBB5_1
	.p2align	4, 0x90
.LBB5_11:                               #   in Loop: Header=BB5_1 Depth=1
	movq	8(%rsp), %r13                   # 8-byte Reload
.LBB5_15:                               # %while.end.2.i
                                        #   in Loop: Header=BB5_1 Depth=1
	movq	16(%rsp), %rbx                  # 8-byte Reload
	addq	$1, %rbx
	addq	$1, %r12
	leaq	maglev_lookup(%rbp), %rdi
	movl	$1, %esi
	callq	sxfi_check_deref@PLT
	movb	$2, (%rax)
	addq	$1, %r13
	movq	%r13, 8(%rsp)                   # 8-byte Spill
	addq	$3, 24(%rsp)                    # 8-byte Folded Spill
	movabsq	$-281470681808895, %r13         # imm = 0xFFFF0000FFFF0001
.LBB5_1:                                # %for.cond1.i
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB5_3 Depth 2
                                        #     Child Loop BB5_7 Depth 2
                                        #     Child Loop BB5_13 Depth 2
	movq	%rbx, 16(%rsp)                  # 8-byte Spill
	imulq	$27606, %rbx, %rbx              # imm = 0x6BD6
	leaq	52351(%rbx), %r14
	movq	%r14, %rax
	mulq	%r13
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%r14, %rbp
	subq	%rax, %rbp
	leaq	maglev_lookup(%rbp), %rdi
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	cmpb	$0, (%rax)
	js	.LBB5_5
# %bb.2:                                # %while.body.i.preheader
                                        #   in Loop: Header=BB5_1 Depth=1
	leaq	maglev_lookup+79957(%rbx), %r13
	addq	$79957, %rbx                    # imm = 0x13855
	movq	16(%rsp), %rbp                  # 8-byte Reload
	.p2align	4, 0x90
.LBB5_3:                                # %while.body.i
                                        #   Parent Loop BB5_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%rbx, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%r13, %rdi
	subq	%rax, %rdi
	addq	$1, %rbp
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	addq	$27606, %r14                    # imm = 0x6BD6
	addq	$27606, %r13                    # imm = 0x6BD6
	addq	$27606, %rbx                    # imm = 0x6BD6
	cmpb	$0, (%rax)
	jns	.LBB5_3
# %bb.4:                                # %for.cond3.i.loopexit
                                        #   in Loop: Header=BB5_1 Depth=1
	movq	%rbp, 16(%rsp)                  # 8-byte Spill
	movq	%r14, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	subq	%rax, %r14
	movq	%r14, %rbp
	movq	%rcx, %r13
.LBB5_5:                                # %for.cond3.i
                                        #   in Loop: Header=BB5_1 Depth=1
	leaq	maglev_lookup(%rbp), %rdi
	movl	$1, %esi
	callq	sxfi_check_deref@PLT
	movb	$0, (%rax)
	imulq	$47859, %r12, %rbx              # imm = 0xBAF3
	leaq	3524(%rbx), %r14
	movq	%r14, %rax
	mulq	%r13
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%r14, %rbp
	subq	%rax, %rbp
	leaq	maglev_lookup(%rbp), %rdi
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	cmpb	$0, (%rax)
	js	.LBB5_9
# %bb.6:                                # %while.body.1.i.preheader
                                        #   in Loop: Header=BB5_1 Depth=1
	leaq	maglev_lookup+51383(%rbx), %rbp
	addq	$51383, %rbx                    # imm = 0xC8B7
	.p2align	4, 0x90
.LBB5_7:                                # %while.body.1.i
                                        #   Parent Loop BB5_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%rbx, %rax
	mulq	%r13
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%rbp, %rdi
	subq	%rax, %rdi
	addq	$1, %r12
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	addq	$47859, %r14                    # imm = 0xBAF3
	addq	$47859, %rbp                    # imm = 0xBAF3
	addq	$47859, %rbx                    # imm = 0xBAF3
	cmpb	$0, (%rax)
	jns	.LBB5_7
# %bb.8:                                # %while.end.1.i.loopexit
                                        #   in Loop: Header=BB5_1 Depth=1
	movq	%r14, %rax
	mulq	%r13
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	subq	%rax, %r14
	movq	%r14, %rbp
.LBB5_9:                                # %while.end.1.i
                                        #   in Loop: Header=BB5_1 Depth=1
	movq	8(%rsp), %rbx                   # 8-byte Reload
	leaq	maglev_lookup(%rbp), %rdi
	movl	$1, %esi
	callq	sxfi_check_deref@PLT
	movb	$1, (%rax)
	cmpq	$65535, 24(%rsp)                # 8-byte Folded Reload
                                        # imm = 0xFFFF
	je	.LBB5_16
# %bb.10:                               # %for.cond3.1.i
                                        #   in Loop: Header=BB5_1 Depth=1
	imulq	$59205, %rbx, %rbx              # imm = 0xE745
	leaq	44417(%rbx), %r14
	movq	%r14, %rax
	mulq	%r13
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%r14, %rbp
	subq	%rax, %rbp
	leaq	maglev_lookup(%rbp), %rdi
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	cmpb	$0, (%rax)
	js	.LBB5_11
# %bb.12:                               # %while.body.2.i.preheader
                                        #   in Loop: Header=BB5_1 Depth=1
	leaq	maglev_lookup+103622(%rbx), %rbp
	addq	$103622, %rbx                   # imm = 0x194C6
	movq	8(%rsp), %r13                   # 8-byte Reload
	.p2align	4, 0x90
.LBB5_13:                               # %while.body.2.i
                                        #   Parent Loop BB5_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movq	%rbx, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	movq	%rbp, %rdi
	subq	%rax, %rdi
	addq	$1, %r13
	movl	$8, %esi
	callq	sxfi_check_deref@PLT
	addq	$59205, %r14                    # imm = 0xE745
	addq	$59205, %rbp                    # imm = 0xE745
	addq	$59205, %rbx                    # imm = 0xE745
	cmpb	$0, (%rax)
	jns	.LBB5_13
# %bb.14:                               # %while.end.2.i.loopexit
                                        #   in Loop: Header=BB5_1 Depth=1
	movq	%r14, %rax
	movabsq	$-281470681808895, %rcx         # imm = 0xFFFF0000FFFF0001
	mulq	%rcx
	shrq	$16, %rdx
	movq	%rdx, %rax
	shlq	$16, %rax
	addq	%rdx, %rax
	subq	%rax, %r14
	movq	%r14, %rbp
	jmp	.LBB5_15
.LBB5_16:                               # %populate_lut.exit
	addq	$32, %rsp
	.cfi_def_cfa_offset 48
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	popq	%r9
	jmpq	*%r9
	retq
	retq
.Lfunc_end5:
	.size	maglev_init, .Lfunc_end5-maglev_init
	.cfi_endproc
                                        # -- End function
	.type	ETH_HEADER_LEN,@object          # @ETH_HEADER_LEN
	.section	.rodata,"a",@progbits
	.globl	ETH_HEADER_LEN
	.p2align	3
ETH_HEADER_LEN:
	.quad	14                              # 0xe
	.size	ETH_HEADER_LEN, 8

	.type	UDP_HEADER_LEN,@object          # @UDP_HEADER_LEN
	.globl	UDP_HEADER_LEN
	.p2align	3
UDP_HEADER_LEN:
	.quad	8                               # 0x8
	.size	UDP_HEADER_LEN, 8

	.type	IPV4_PROTO_OFFSET,@object       # @IPV4_PROTO_OFFSET
	.globl	IPV4_PROTO_OFFSET
	.p2align	3
IPV4_PROTO_OFFSET:
	.quad	9                               # 0x9
	.size	IPV4_PROTO_OFFSET, 8

	.type	IPV4_LENGTH_OFFSET,@object      # @IPV4_LENGTH_OFFSET
	.globl	IPV4_LENGTH_OFFSET
	.p2align	3
IPV4_LENGTH_OFFSET:
	.quad	2                               # 0x2
	.size	IPV4_LENGTH_OFFSET, 8

	.type	IPV4_CHECKSUM_OFFSET,@object    # @IPV4_CHECKSUM_OFFSET
	.globl	IPV4_CHECKSUM_OFFSET
	.p2align	3
IPV4_CHECKSUM_OFFSET:
	.quad	10                              # 0xa
	.size	IPV4_CHECKSUM_OFFSET, 8

	.type	IPV4_SRCDST_OFFSET,@object      # @IPV4_SRCDST_OFFSET
	.globl	IPV4_SRCDST_OFFSET
	.p2align	3
IPV4_SRCDST_OFFSET:
	.quad	12                              # 0xc
	.size	IPV4_SRCDST_OFFSET, 8

	.type	IPV4_SRCDST_LEN,@object         # @IPV4_SRCDST_LEN
	.globl	IPV4_SRCDST_LEN
	.p2align	3
IPV4_SRCDST_LEN:
	.quad	8                               # 0x8
	.size	IPV4_SRCDST_LEN, 8

	.type	UDP_LENGTH_OFFSET,@object       # @UDP_LENGTH_OFFSET
	.globl	UDP_LENGTH_OFFSET
	.p2align	3
UDP_LENGTH_OFFSET:
	.quad	4                               # 0x4
	.size	UDP_LENGTH_OFFSET, 8

	.type	UDP_CHECKSUM_OFFSET,@object     # @UDP_CHECKSUM_OFFSET
	.globl	UDP_CHECKSUM_OFFSET
	.p2align	3
UDP_CHECKSUM_OFFSET:
	.quad	6                               # 0x6
	.size	UDP_CHECKSUM_OFFSET, 8

	.type	FNV_BASIS,@object               # @FNV_BASIS
	.globl	FNV_BASIS
	.p2align	3
FNV_BASIS:
	.quad	-3750763034362895579            # 0xcbf29ce484222325
	.size	FNV_BASIS, 8

	.type	FNV_PRIME,@object               # @FNV_PRIME
	.globl	FNV_PRIME
	.p2align	3
FNV_PRIME:
	.quad	1099511628211                   # 0x100000001b3
	.size	FNV_PRIME, 8

	.type	packets,@object                 # @packets
	.bss
	.globl	packets
	.p2align	2
packets:
	.long	0                               # 0x0
	.size	packets, 4

	.type	maglev_lookup,@object           # @maglev_lookup
	.local	maglev_lookup
	.comm	maglev_lookup,65537,16
	.type	maglev_kv_pairs,@object         # @maglev_kv_pairs
	.globl	maglev_kv_pairs
	.p2align	4
maglev_kv_pairs:
	.zero	16
	.size	maglev_kv_pairs, 16

	.ident	"clang version 13.0.0 (git@github.com:mars-research/llvm-project-13.x.git 1eec89b0ab27617a059c1277b6ac86e573f81315)"
	.section	".note.GNU-stack","",@progbits
