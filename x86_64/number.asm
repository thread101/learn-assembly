global _start

section .data
answer: dq 1234567            ; a 64-bit number stored in memory

section .bss
buffer: resb 21               ; scratch space for the digits (20 digits + newline)

section .text
_start:
  ; 1. put a number straight into a register
  mov rax, 42
  call print_number

  ; 2. read a number from memory
  mov rax, [answer]
  call print_number

  ; 3. change the number in memory, then read it again
  mov qword [answer], 99
  mov rax, [answer]
  call print_number

  ; 4. count from 1 to 5 (rbx is safe from syscall)
  mov rbx, 1
.count:
  mov rax, rbx
  call print_number
  inc rbx
  cmp rbx, 5
  jbe .count                ; jump if below or equal

  mov rax, 60
  xor rdi, rdi
  syscall

; ---------------------------------------------------------------
; print_number: prints the unsigned number in rax, then a newline.
; Uses (clobbers): rax, rcx, rdx, rsi, rdi, r11
; ---------------------------------------------------------------
print_number:
  mov rdi, buffer + 20      ; start at the END of the buffer
  mov byte [rdi], 10        ; newline goes last
  mov rcx, 10               ; we divide by 10
.next_digit:
  xor rdx, rdx              ; div uses rdx:rax, so clear rdx first
  div rcx                   ; rax = rax / 10, rdx = rax % 10
  add dl, '0'               ; turn the digit 0-9 into the character '0'-'9'
  dec rdi                   ; step one place to the left
  mov [rdi], dl             ; store the digit
  test rax, rax             ; anything left to print?
  jnz .next_digit

  mov rsi, rdi              ; rsi = address of the first digit
  mov rdx, buffer + 21
  sub rdx, rsi              ; rdx = length (digits + newline)
  mov rax, 1                ; write
  mov rdi, 1                ; stdout
  syscall
  ret

