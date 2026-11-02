; computers only understand how to display text characters. You must convert the numerical value into its ASCII text representation by repeatedly dividing it by 10 and printing the remainders

; add dl, '0' is plain addition, and the “conversion” works because of how the ASCII table is laid out.
; '0' is just the number 48. NASM lets you write a character in quotes, and it replaces it with that character’s ASCII code. These three lines assemble to exactly the same machine code

global _start

section .data
msg: db "Your count is: "
len: equ $ - msg

section .bss
; reserve a small buffer for number string 64bit number = 20 + 1 for \n
buffer: resb 21

section .text
_start:
  mov rbx, 100000000

.loop:
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, len
  syscall

  mov rax, rbx        ; number we wanna display
  mov rdi, buffer     ; address of buffer to rdi
  add rdi, 20         ; move to the end of the buffer
  mov byte [rdi], 10  ; place a new line

  mov rcx, 10         ; the divident
  .num2ascii:
    xor rdx, rdx      ; clear rdi
    div rcx           ; divide rax by rcx, RAX = quotient, RDX = remainder
    add dl, '0'       ; Convert remainder (0-9) to ASCII ('0'-'9')
    dec rdi           ; mov pointer
    mov [rdi], dl     ; store ascii in buffer
    test rax, rax     ; check if quotient is 0
    jnz .num2ascii    ; repeate the cycle till quotient is 0

  ; getting length
  mov rdx, buffer     ; start of the string buffer
  add rdx, 21         ; move to the end
  sub rdx, rdi        ; stop address - start address to get len, RDX = length of the string to print

  mov rax, 1
  mov rsi, rdi
  mov rdi, 1
  ; mov rdx, rdx
  syscall
    
  dec rbx
  jnz .loop

  mov rax, 60
  mov rdi, 0
  syscall

