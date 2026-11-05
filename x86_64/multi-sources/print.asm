
section .data
newline: db 10

section .text
global print
global println

; (rdi: str, rsi: len)
print:
  push rax
  push rdx
  push rcx
  push r11

  mov rax, 1
  mov rdx, rsi
  mov rsi, rdi
  mov rdi, 1
  syscall

  pop r11     ; Pop the last one pushed first
  pop rcx
  pop rdx
  pop rax
  ret

println:
  call print
  push rax
  push rdx
  push rcx
  push r11

  mov rax, 1
  mov rdi, 1
  mov rsi, newline
  mov rdx, 1
  syscall

  pop r11     ; Pop the last one pushed first
  pop rcx
  pop rdx
  pop rax
  ret

