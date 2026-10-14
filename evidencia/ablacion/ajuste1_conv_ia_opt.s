	.file	"a1.c"
	.text
	.p2align 4
	.type	convolve_ia_opt._omp_fn.0, @function
convolve_ia_opt._omp_fn.0:
.LFB1:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movq	%rdi, %r13
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$232, %rsp
	.cfi_def_cfa_offset 288
	movl	28(%rdi), %ebx
	call	omp_get_num_threads
	movl	%eax, %ebp
	call	omp_get_thread_num
	movl	%eax, %esi
	movl	%ebx, %eax
	cltd
	idivl	%ebp
	cmpl	%edx, %esi
	leal	1(%rax), %ecx
	cmovl	%ecx, %eax
	movl	$0, %ecx
	cmovl	%ecx, %edx
	imull	%eax, %esi
	leal	(%rsi,%rdx), %r12d
	leal	(%rax,%r12), %r9d
	cmpl	%r9d, %r12d
	jge	.L1
	movl	32(%r13), %eax
	movslq	24(%r13), %rdi
	leaq	160(%rsp), %r15
	movl	36(%r13), %r14d
	movq	0(%r13), %rcx
	movl	%eax, 88(%rsp)
	movq	16(%r13), %rax
	movl	%edi, 4(%rsp)
	movq	8(%r13), %rbp
	movl	%r14d, %r13d
	movq	%rax, 64(%rsp)
	movslq	%r12d, %rax
	negl	%r13d
	movq	%rdi, 56(%rsp)
	imulq	%rax, %rdi
	movslq	%r14d, %rax
	movq	%rcx, 8(%rsp)
	movq	%rax, 72(%rsp)
.L7:
	cmpl	%r14d, %r12d
	movl	%r14d, %eax
	leal	(%r12,%r14), %edx
	movl	4(%rsp), %ecx
	cmovs	%r12d, %eax
	movl	%eax, 120(%rsp)
	leal	-1(%rbx), %eax
	subl	%r12d, %eax
	cmpl	%edx, %ebx
	cmovg	%r14d, %eax
	movl	%eax, %r11d
	testl	%ecx, %ecx
	jle	.L66
	movl	120(%rsp), %eax
	movl	%ebx, 144(%rsp)
	leaq	0(%rbp,%rdi,4), %r8
	pxor	%xmm3, %xmm3
	movq	$0, 16(%rsp)
	movl	%eax, %ecx
	addl	%r14d, %eax
	movq	%rbp, 136(%rsp)
	imull	88(%rsp), %eax
	negl	%ecx
	movq	%rdi, 152(%rsp)
	movl	%ecx, 124(%rsp)
	movslq	%r13d, %rcx
	movq	%rcx, 80(%rsp)
	leaq	0(%rbp,%rdi,4), %rcx
	movl	%eax, 128(%rsp)
	leal	1(%r12), %eax
	movl	%eax, 92(%rsp)
	leal	16(%r14), %eax
	movl	%eax, 132(%rsp)
	movl	%r9d, 148(%rsp)
	movl	%r11d, %r9d
.L11:
	movq	16(%rsp), %rax
	movl	80(%rsp), %edx
	movaps	%xmm3, 160(%rsp)
	movaps	%xmm3, 176(%rsp)
	leal	16(%rax), %ebx
	movl	%eax, 36(%rsp)
	movl	%eax, %ebp
	movl	4(%rsp), %eax
	movaps	%xmm3, 192(%rsp)
	cmpl	%eax, %ebx
	movaps	%xmm3, 208(%rsp)
	cmovg	%eax, %ebx
	testl	%edx, %edx
	js	.L67
	xorl	%r11d, %r11d
	movl	132(%rsp), %eax
	addl	16(%rsp), %eax
	cmpl	%eax, 4(%rsp)
	setge	%r11b
.L36:
	movl	92(%rsp), %eax
	movl	%r12d, %edi
	movl	128(%rsp), %edx
	subl	120(%rsp), %edi
	leal	(%rax,%r9), %r10d
	cmpl	%r9d, 124(%rsp)
	jg	.L21
	movl	%r12d, 96(%rsp)
	movl	%r11d, 52(%rsp)
	movl	%r9d, 100(%rsp)
	movq	%r8, 104(%rsp)
	movl	%edi, 32(%rsp)
	movl	%edx, 44(%rsp)
	movl	%r10d, 48(%rsp)
	movq	%rcx, 112(%rsp)
	movl	%r13d, 40(%rsp)
	.p2align 4
	.p2align 3
.L20:
	cmpl	40(%rsp), %r14d
	jl	.L25
	movslq	40(%rsp), %rcx
	movq	72(%rsp), %rax
	movslq	44(%rsp), %rdx
	movq	64(%rsp), %rdi
	subq	%rcx, %rax
	movslq	32(%rsp), %r12
	imulq	56(%rsp), %r12
	addq	%rdx, %rax
	leaq	(%rdi,%rax,4), %r8
	movl	52(%rsp), %eax
	movss	(%r8), %xmm1
	testl	%eax, %eax
	jne	.L22
	movq	8(%rsp), %rax
	leaq	(%rax,%r12,4), %rax
	movq	%rax, 24(%rsp)
	movl	%ecx, %eax
	.p2align 4
	.p2align 3
.L23:
	movl	%eax, %edx
	movl	4(%rsp), %esi
	negl	%edx
	cmpl	%ebp, %edx
	cmovl	%ebp, %edx
	subl	%eax, %esi
	cmpl	%ebx, %esi
	cmovg	%ebx, %esi
	cmpl	%esi, %edx
	jge	.L32
	movl	%esi, %r10d
	movq	%r15, %r13
	subl	%edx, %r10d
	leal	-1(%r10), %eax
	cmpl	$2, %eax
	jbe	.L28
	movslq	%edx, %rax
	leaq	(%r12,%rcx), %r9
	movaps	%xmm1, %xmm2
	addq	%rax, %r9
	movq	%rax, %rdi
	movq	8(%rsp), %rax
	subq	16(%rsp), %rdi
	leaq	(%r15,%rdi,4), %rdi
	shufps	$0, %xmm2, %xmm2
	leaq	(%rax,%r9,4), %r11
	movl	%r10d, %r9d
	xorl	%eax, %eax
	shrl	$2, %r9d
	salq	$4, %r9
.L29:
	movups	(%r11,%rax), %xmm0
	movups	(%rdi,%rax), %xmm4
	mulps	%xmm2, %xmm0
	addps	%xmm4, %xmm0
	movups	%xmm0, (%rdi,%rax)
	addq	$16, %rax
	cmpq	%r9, %rax
	jne	.L29
	testb	$3, %r10b
	je	.L32
	andl	$-4, %r10d
	addl	%r10d, %edx
.L28:
	movq	24(%rsp), %rdi
	movslq	%edx, %rax
	subl	36(%rsp), %edx
	movslq	%edx, %rdx
	leaq	0(%r13,%rdx,4), %rdx
	leaq	(%rdi,%rcx,4), %rdi
.L33:
	movss	(%rdi,%rax,4), %xmm0
	addq	$1, %rax
	addq	$4, %rdx
	mulss	%xmm1, %xmm0
	addss	-4(%rdx), %xmm0
	movss	%xmm0, -4(%rdx)
	cmpl	%eax, %esi
	jg	.L33
.L32:
	addq	$1, %rcx
	cmpl	%ecx, %r14d
	jl	.L25
	subq	$4, %r8
	movl	%ecx, %eax
	movss	(%r8), %xmm1
	jmp	.L23
	.p2align 4,,10
	.p2align 3
.L25:
	addl	$1, 32(%rsp)
	movl	88(%rsp), %esi
	movl	32(%rsp), %eax
	subl	%esi, 44(%rsp)
	cmpl	48(%rsp), %eax
	jne	.L20
	movl	96(%rsp), %r12d
	movl	100(%rsp), %r9d
	movq	104(%rsp), %r8
	movq	112(%rsp), %rcx
	movl	40(%rsp), %r13d
.L21:
	cmpl	16(%rsp), %ebx
	jle	.L16
	movl	%ebx, %edx
	subl	36(%rsp), %edx
	movq	%r15, %rdi
	leal	-1(%rdx), %eax
	cmpl	$2, %eax
	jbe	.L13
	movl	%edx, %esi
	xorl	%eax, %eax
	shrl	$2, %esi
	salq	$4, %rsi
.L14:
	movups	(%rcx,%rax), %xmm0
	addps	(%r15,%rax), %xmm0
	movups	%xmm0, (%rcx,%rax)
	addq	$16, %rax
	cmpq	%rsi, %rax
	jne	.L14
	testb	$3, %dl
	je	.L16
	andl	$-4, %edx
	addl	%edx, %ebp
.L13:
	movslq	%ebp, %rax
	subl	36(%rsp), %ebp
	movslq	%ebp, %rbp
	subq	%rax, %rbp
	leaq	(%rdi,%rbp,4), %rdx
.L18:
	movss	(%r8,%rax,4), %xmm0
	addss	(%rdx,%rax,4), %xmm0
	movss	%xmm0, (%r8,%rax,4)
	addq	$1, %rax
	cmpl	%eax, %ebx
	jg	.L18
.L16:
	addq	$16, 16(%rsp)
	addq	$64, %rcx
	movq	16(%rsp), %rax
	addq	$16, 80(%rsp)
	cmpl	%eax, 4(%rsp)
	jg	.L11
	movl	144(%rsp), %ebx
	movq	136(%rsp), %rbp
	movl	148(%rsp), %r9d
	movq	152(%rsp), %rdi
.L12:
	movl	92(%rsp), %r12d
	addq	56(%rsp), %rdi
	cmpl	%r12d, %r9d
	jne	.L7
.L1:
	addq	$232, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L22:
	.cfi_restore_state
	movq	8(%rsp), %rax
	addq	80(%rsp), %r12
	leaq	(%rax,%r12,4), %rdx
	.p2align 4
	.p2align 3
.L24:
	xorl	%eax, %eax
	shufps	$0, %xmm1, %xmm1
.L34:
	movups	(%rdx,%rax), %xmm0
	mulps	%xmm1, %xmm0
	addps	(%r15,%rax), %xmm0
	movaps	%xmm0, (%r15,%rax)
	addq	$16, %rax
	cmpq	$64, %rax
	jne	.L34
	addq	$1, %rcx
	cmpl	%ecx, %r14d
	jl	.L25
	subq	$4, %r8
	addq	$4, %rdx
	movss	(%r8), %xmm1
	jmp	.L24
.L67:
	xorl	%r11d, %r11d
	jmp	.L36
.L66:
	leal	1(%r12), %eax
	movl	%eax, 92(%rsp)
	jmp	.L12
	.cfi_endproc
.LFE1:
	.size	convolve_ia_opt._omp_fn.0, .-convolve_ia_opt._omp_fn.0
	.p2align 4
	.globl	convolve_ia_opt
	.type	convolve_ia_opt, @function
convolve_ia_opt:
.LFB0:
	.cfi_startproc
	movl	%r9d, %eax
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	shrl	$31, %eax
	movl	%edx, 24(%rsp)
	movl	64(%rsp), %edx
	addl	%r9d, %eax
	movl	%ecx, 28(%rsp)
	movl	$4, %ecx
	movq	%rsi, 8(%rsp)
	sarl	%eax
	movq	%rsp, %rsi
	movq	%rdi, (%rsp)
	movl	$convolve_ia_opt._omp_fn.0, %edi
	movl	%eax, 36(%rsp)
	movl	%r9d, 32(%rsp)
	movq	%r8, 16(%rsp)
	call	GOMP_parallel
	addq	$56, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	convolve_ia_opt, .-convolve_ia_opt
	.ident	"GCC: (GNU) 15.3.1 20260722 (Red Hat 15.3.1-1)"
	.section	.note.GNU-stack,"",@progbits
