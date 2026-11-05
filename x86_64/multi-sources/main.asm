
global _start
extern print
extern println

section .data
msg: db "Hello my name is Andre, what about yours?"
msgl: equ $ - msg

msg1: db "My count is: "
msg1l: equ $ - msg1

msg2: db "100 meters"
msg2l: equ $ - msg2

section .text
_start:
  mov rdi, msg
  mov rsi, msgl
  call println

  mov rdi, msg1
  mov rsi, msg1l
  call print

  mov rdi, msg2
  mov rsi, msg2l
  call println

  mov rax, 60
  mov rdi, 0
  syscall

