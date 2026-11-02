; To simulate a function call, assembly uses two foundational instructions that automatically manipulate the Instruction Pointer / Program Counter (IP or PC) and the stack:
; • CALL <label>:
; 	1. Pushes the return address (the address of the next instruction after the CALL) onto the stack.
; 	2. Jumps to the memory address defined by the label.
; • RET:
; 	1. Pops the top value off the stack.
; 	2. Jumps back to that address, resuming execution in the caller function.

; dl is the lowest byte of rdx. Each of the big registers can be used in smaller slices:
; 64-bit	low 32	low 16	low 8	  bits 8-15
; rdx	    edx	    dx	    dl	    dh
; rax	    eax	    ax	    al	    ah
; rbx	    ebx	    bx	    bl	    bh
; rcx	    ecx	    cx	    cl	    ch
; They are the same storage. Changing dl changes the bottom 8 bits of rdx and leaves the other 56 bits alone

; How Parameters and Return Values Work
; Because assembly has no function signature arguments, data must be placed where both the caller and callee can see it. Depending on the CPU architecture, this is done in one of two ways:

; Option A: Passing by Registers (Fast)
; Modern architectures like x86-64 or ARM pass the first few parameters directly inside specific general-purpose registers.
; • x86-64 Standard: Arguments 1 through 6 are placed in RDI, RSI, RDX, RCX, R8, and R9 respectively. The return value is stored in RAX.
; • ARM Standard: Arguments 1 through 4 go in R0 through R3. The return value is placed back into R0

; Option B: Passing via Stack (Legacy/Overflow)
; Older architectures (like 32-bit x86) or functions with too many parameters push arguments onto the stack right before calling the function. The function then uses positive offsets relative to the Base Pointer (EBP) to read them.

global _start

section .bss
num_buf: resb 20

; The data directives (d for “define”) from nasm
; Directive	Stands for	Size
; db	define byte	1 byte
; dw	define word	2 bytes
; dd	define double word	4 bytes
; dq	define quad word	8 bytes
; dt	define ten bytes	10 bytes (floating point)

section .data
fmt1: db "sum of "
fmt1_len: equ $ - fmt1

fmt2: db " and "
fmt2_len: equ $ - fmt2

fmt3: db " is "
fmt3_len: equ $ - fmt3

num1: dq 25
num2: dq 75

section .text
_start:
  mov rdi, [num1]         ; 1st argument
  mov rsi, [num2]         ; 2nd argument
  call add_two
  
  mov rdx, rax            ; result
  mov rdi, [num1]         ; 1st argument
  mov rsi, [num2]         ; 2nd argument
  call print_sum          ; push the return address, jump to print

  mov rax, 60
  mov rdi, 0
  syscall


print_sum:
  mov rbx, rdi
  mov R8, rsi
  mov R9, rdx
  
  mov rax, 1
  mov rdi, 1
  mov rsi, fmt1
  mov rdx, fmt1_len
  syscall

  ; print arg 1
  mov rdi, rbx
  call print_num

  mov rax, 1
  mov rdi, 1
  mov rsi, fmt2
  mov rdx, fmt2_len
  syscall

  ; print arg 2
  mov rdi, R8
  call print_num

  mov rax, 1
  mov rdi, 1
  mov rsi, fmt3
  mov rdx, fmt3_len
  syscall

  ; print arg 3
  mov rdi, R9
  call print_num

  ; print \n
  mov rax, 1
  mov rdi, 1
  mov byte [rsi], 10
  mov rdx, 1
  syscall

  ret     ; pop the return address into rip, i.e. jump back

print_num:
  mov rax, rdi
  mov rcx, num_buf
  add rcx, 20
  mov rbx, 10
  .next_digit:
    xor rdx, rdx
    div rbx
    add dl, '0'   ; same as add bl, 48
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .next_digit

  ; length
  mov rbx, num_buf
  add rbx, 20
  sub rbx, rcx  ; length in rbx

  mov rax, 1
  mov rdi, 1
  mov rsi, rcx
  mov rdx, rbx
  syscall

  ret

add_two:
  mov rax, rdi
  add rax, rsi
  ret

