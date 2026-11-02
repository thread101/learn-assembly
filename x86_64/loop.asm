; The rule to remember: a Linux syscall changes rax (it holds the return value), rcx and r11. Everything else is preserved. That is also why you must set rax to the syscall number again on every pass, as you already did.

global _start

section .data
msg: db "Hi man!", 10
len: equ $ - msg

section .text
_start:
  mov rbx, 5   ; store 10
  ; xor rbx, rbx  ; xor with itself is o

.loop:
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, len
  syscall

  dec rbx
  jnz .loop

  mov rax, 60
  xor rdi, rdi
  syscall

