global _start

section .bss
sum: resd 1     ; reserve 4 bytes for int
buf: resb 20    ; print int buffer

section .data
sym_add: db " + "
sym_eql: db " = "
nl: db 10

section .text
_start:
  mov rax, 108
  mov rdx, 202
  mov rcx, rax
  add rcx, rdx
  mov [sum], rcx    ; store int value into memory

  mov rdi, rax
  call pnum

  mov rdi, sym_add
  call psymbol

  mov rdi, rdx
  call pnum
  mov rdi, sym_eql
  call psymbol

  mov rdi, [sum]      ; load int value from memory
  call pnum

  mov rax, 1
  mov rdi, 1
  mov rsi, nl
  mov rdx, 1
  syscall

  mov rax, 60
  mov rdi, 0
  syscall

psymbol:
  ; push to stack
  push rax
  push rsi
  push rdx
  push rcx
  push r11

  mov rax, 1
  mov rsi, rdi
  mov rdi, 1
  mov rdx, 3
  syscall

  ; pop from stack
  pop r11
  pop rcx
  pop rdx
  pop rsi
  pop rax
  ret

; (rdi)
pnum:
  ; push to stack
  push rax
  push rsi
  push rdx
  push rcx
  push r11

  mov rax, rdi
  mov rcx, buf
  add rcx, 20
  mov rbx, 10
  .nxt:
    xor rdx, rdx
    div rbx
    add dl, '0'   ; same as add bl, 48
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .nxt

  ; length
  mov rbx, buf
  add rbx, 20
  sub rbx, rcx  ; length in rbx

  mov rax, 1
  mov rdi, 1
  mov rsi, rcx
  mov rdx, rbx
  syscall

  ; pop from stack
  pop r11
  pop rcx
  pop rdx
  pop rsi
  pop rax
  ret

