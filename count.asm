; Copyright (c) Satvik Reddy <reddy.satvik@gmail.com>

section .text
	global	_start

println:					; prints number in rdi
	push	rbp
	mov	rbp, rsp

	sub	rsp, 37				; make room for variables
	mov	QWORD [rbp-8], rdi		; move num argument onto stack
	call	find_len_u64			; find string length of num
	mov	QWORD [rbp-16], rax		; move len onto stack

	mov	rdi, rbp			; move rbp into seperate register so we can do pointer math on it
	sub	rdi, 37				; point rdi to the bottom of the string buffer
	mov	rsi, QWORD [rbp-8]		; move num into rsi
	mov	rdx, QWORD [rbp-16]		; move len into rdx
	call 	u64_to_string			; convert number to string

	mov	rax, rbp			; locate end of string in rax
	sub	rax, 37				; point rax at the bottom of the buffer
	add	rax, QWORD [rbp-16]		; point rax to the end of the string
	mov	BYTE [rax], 10			; add a newline to the string


	mov	rax, 1				; set syscall to write
	mov	rdi, 1				; set fd to stdout
	mov	rsi, rbp			; set buf to our string buffer
	sub	rsi, 37				; move the pointer to the correct positition
	mov	rdx, QWORD [rbp-16]		; set length to len variable
	add	rdx, 1				; add 1 byte for the null terminator
	syscall

	mov	rsp, rbp
	pop	rbp
	ret


find_len_u64:					; Finds the string length of an unsigned 64 bit integer in rdi
	push	rbp
	mov	rbp, rsp

	sub	rsp, 32				; make room for variables
	mov	QWORD [rbp-8], 20		; move len variable onto the stack
	add	QWORD [rbp-8], 1		; add 1 to len
	mov	rax, 10000000000000000000	; move divisor variable into rax because of its size
	mov	QWORD [rbp-16], rax		; move divisor variable onto stack
	mov 	QWORD [rbp-24], 0		; move quotient variable onto stack
	mov	QWORD [rbp-32], rdi		; move num variable (first argument) onto stack
	jmp	.find_len_u64_L2		; begin loop

.find_len_u64_L1:				; Loop body
	mov	rax, QWORD[rbp-32]		; move num into rax to be divided
	mov	edx, 0				; prepare for division instruction and prevent overflow
	div	QWORD [rbp-16]			; divide num by divisor
	mov	QWORD [rbp-24], rax		; move result into quotient

	mov	rax, QWORD[rbp-16]		; move divisor variable into rax to be divided
	mov	edx, 0				; prepare for division instruction and prevent overflow
	mov	rsi, 10				; move 10 into rsi to be divided by
	div	rsi				; divide divisor by 10
	mov	QWORD [rbp-16], rax		; move result into divisor variable

	sub	QWORD [rbp-8], 1		; subtract 0 from len
.find_len_u64_L2:				; Loop condition: continue only when quotient == 0 and len > 1
	cmp	QWORD [rbp-24], 0		; compare quotient to 0
	jne	.find_len_u64_L3		; exit loop if quotient != 0
	cmp	QWORD [rbp-8], 1		; compare len to 1
	ja	.find_len_u64_L1		; continue looping if len > 1

.find_len_u64_L3:
	mov	rax, QWORD [rbp-8]		; move len variable into rax to be returned

	mov	rsp, rbp
	pop	rbp
	ret


u64_to_string:					; convert u64 integer into a string
						; rdi: buffer, rsi: num, rdx: len (use find_len_u64)
	push	rbp
	mov	rbp, rsp

	sub	rsp, 48				; make space for variables
	mov	QWORD [rbp-8], rdi		; move buffer argument onto stack
	mov	QWORD [rbp-16], rsi		; move num argument onto stack
	mov	QWORD [rbp-24], rdx		; move len argument onto stack
	mov	rax, QWORD [rbp-8]		; move buffer argument to rax
	mov	QWORD [rbp-32], rax		; intialize ptr variable with buffer
	mov	rax, QWORD [rbp-24]		; move len argument to rax
	add	QWORD [rbp-32], rax		; add length to ptr
	sub	QWORD [rbp-32], 1		; subtract 1 from ptr
	mov	QWORD [rbp-40], 0		; move 0 into i (iterator)
						; [rbp-48] will hold the current digit
	jmp .u64_to_string_L2			; begin loop

.u64_to_string_L1:				; Loop body
	mov	rax, QWORD [rbp-16]		; move num to rax to be divided
	mov	edx, 0				; prepare for division instruction and prevent overflow
	mov	rsi, 10				; move 10 to a register to be divided by
	div	rsi				; divide num by 10
	mov	QWORD [rbp-48], rdx		; move remainder to digit variable

	mov	rax, QWORD [rbp-32]		; move ptr address into rax
	mov	rdx, QWORD [rbp-48]		; move digit into rdx register
	mov	BYTE [rax], dl			; move digit into the buffer
	add	BYTE [rax], 48			; add '0' to the digit in the buffer

	mov	rax, QWORD [rbp-16]		; move num to rax to be divided
	mov	edx, 0				; prepare for division instruction and prevent overflow
	mov	rsi, 10				; move 10 into register to be divided by
	div 	rsi				; divide num by 10
	mov	QWORD [rbp-16], rax		; move result back into num

	sub	QWORD [rbp-32], 1		; decrease ptr by 1

	add	QWORD [rbp-40], 1		; increment interator
.u64_to_string_L2:				; Loop condition
	mov	rax, QWORD [rbp-24]		; move len into rax
	cmp	QWORD [rbp-40], rax		; compare i to len
	jb	.u64_to_string_L1		; continue looping if i < len

	mov	rsp, rbp
	pop	rbp
	ret

main:
	push	rbp
	mov	rbp, rsp

	sub	rsp, 8			; make space for a counter variable
	mov	QWORD [rbp-8], 0	; move 0 into the counter
	jmp	.main.L2		; begin loop
.main.L1:
	mov	rdi, QWORD [rbp-8]	; move counter into rdi register
	add	rdi, 1			; add one to counter
	call	println			; print counter
	inc	QWORD [rbp-8]		; increment counter
.main.L2:
	cmp	QWORD [rbp-8], 10	; compare counter to 10
	jb	.main.L1		; continue loop if counter < 10

	mov	rsp, rbp
	pop	rbp
	ret

_start:
	call main

	mov	rax, 60			; exit
	mov	rdi, 0			; exit code 0
	syscall
