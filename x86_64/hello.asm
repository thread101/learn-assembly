global _start

; .data hold text
section .data
msg:  db "Hello assembly!", 10  ; newline = 10
len:  equ $ - msg               ; $ (current location) - msg = length 

; .text holds instructions
section .text
_start:
  mov rax, 1    ; syscall 1 = write
  mov rdi, 1    ; fd 1 = stdout
  mov rsi, msg  ; address of msg
  mov rdx, len  ; length of message
  syscall

  mov rax, 60
  mov rdi, 0
  ; xor rdi, rdi  ; xor 1 with 1 = 0
  syscall

