; To simulate a function call, assembly uses two foundational instructions that automatically manipulate the Instruction Pointer / Program Counter (IP or PC) and the stack:
; • CALL <label>:
; 	1. Pushes the return address (the address of the next instruction after the CALL) onto the stack.
; 	2. Jumps to the memory address defined by the label.
; • RET:
; 	1. Pops the top value off the stack.
; 	2. Jumps back to that address, resuming execution in the caller function.


global _start

section .data
msg: db "Hello mate!", 10
len: equ $ - msg

section .text
_start:
  call print_no_arg ; push the return address, jump to print_no_arg

  mov rax, 60
  mov rdi, 0
  syscall

print_no_arg:
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, len
  syscall
  ret     ; pop the return address into rip, i.e. jump back

; ---------------------------------------------------------------------
; Function: sum_two_nums
; Inputs:
;   RDI - First Integer (passed by caller)
;   RSI - Second Integer (passed by caller)
; Output:
;   RAX - The sum of RDI and RSI
; ---------------------------------------------------------------------
