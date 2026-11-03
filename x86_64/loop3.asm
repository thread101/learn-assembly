
global _start

section .bss
buf: resb 20

section .data
fmt: db "Factorial of "
fmt_len: equ $ - fmt
num: dq 1000

section .text
_start:
  mov rdi, [num]
  call factorial
  
  mov rdi, [num]
  mov rsi, rax
  call format

  mov rax, 60
  mov rdi, 0
  syscall

format:
  mov R8, rdi
  mov R9, rsi

  mov rax, 1
  mov rdi, 1
  mov rsi, fmt
  mov rdx, fmt_len
  syscall

  mov rdi, R8
  call print_num
  
  mov byte [rsi], ' '
  call print_char

  mov byte [rsi], 'i'
  call print_char

  mov byte [rsi], 's'
  call print_char

  mov byte [rsi], ' '
  call print_char

  mov rdi, R9
  call print_num

  mov byte [rsi], 10
  call print_char

  ret

print_num:
  mov rax, rdi
  mov rdi, buf
  add rdi, 20
  mov rsi, 10
  .next_digit
    xor rdx, rdx
    div rsi
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz .next_digit

  ; get len
  mov rsi, buf
  add rsi, 20
  sub rsi, rdi

  mov rax, 1    ; write operation
  mov rdx, rsi  ; length
  mov rsi, rdi  ; buf
  mov rdi, 1    ; fd
  syscall

  ret

print_char:
  mov rax, 1
  mov rdi, 1
  mov rdx, 1
  syscall

  ret

factorial:
  xor rax, rax
  .loop:
    add rax, rdi
    dec rdi
    test rdi, rdi
    jnz .loop

  ret

