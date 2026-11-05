; 1. add, sub, inc, dec, neg
;   add rax, 2     ; rax = rax + 2      -> 42
;   sub rax, 8     ; rax = rax - 8
;   inc rax        ; rax + 1
;   dec rax        ; rax - 1
;   neg rax        ; 0 - rax            -> -42

; 2. Multiplication has three forms
;   imul rax, rbx         ; rax = rax * rbx             6*7   -> 42
;   imul rax, rbx, 10     ; rax = rbx * 10              7*10  -> 70
;   mul  rbx              ; rdx:rax = rax * rbx         (unsigned, full result)

; A 64-bit times a 64-bit number can need 128 bits. imul keeps only the low 64, which is what you want most of the time and works for negative numbers (-6*7 gave -42). One-operand mul keeps the whole answer: 2^62 * 4 = 2^64 gave high half 1 (in rdx) and low half 0 (in rax).

; 3. Division (recap)
;   idiv divides rdx:rax by its operand, so cqo has to fill rdx first. The quotient lands in rax, the remainder in rdx.
;   17 / 5 gave quotient 3 and remainder 2.
;   -17 / 5 gave quotient -3 and remainder -2. It rounds toward zero, and the remainder takes the sign of the dividend.

; 4. Shifts: fast powers of two
;   shl rax, 3  ; multiply by 2^3      5<<3   -> 40
;   shr rax, 1  ; unsigned divide by 2 100>>1 -> 50
;   sar rax, 1  ; signed divide by 2   -7>>1  -> -4
; For negative numbers, sar and idiv disagree. sar rounds down (-7 → -4) while idiv rounds toward zero (-7/2 → -3). Neither is wrong, but you need to know which one you’re using. A compiler can swap a division for a shift only after correcting for that.

; 5. lea: arithmetic that doesn’t touch the flags
;   lea rax, [rbx + rcx*4 + 10] ; 7 + 5*4 + 10 = 37
;   lea rax, [rbx + rbx*4]      ; x * 5 = 35
;   lea (“load effective address”) computes the address expression but doesn’t read memory. It was designed for pointer maths, but it’s also a quick way to do small multiplications and sums in one instruction. The scale can be 1, 2, 4 or 8.

; 6. Bitwise operations
; Instruction	Result for 1100 and 1010	Rule
;   and	1000	1 only where both have 1
;   or	1110	1 where either has 1
;   xor	0110	1 where they differ
;   not	flips all bits	not 0 is -1

; read notes/Arithmetic.txt for more on overflow

global _start

section .bss
buf: resb 20

section .data:
num1: dq 100
num2: dq 25

sum: db " + "
sub: db " - "
mul: db " * "
_div: db " / "
eql: db " = "

nl: db 10

section .text
_start:
  ; addition
  mov R8, [num1]
  mov rsi, [num2]
  add R8, rsi    ; R8 += rsi

  mov rdi, [num1]
  call pnum
  call sumf

  mov rdi, [num2]
  call pnum
  call eqlf

  mov rdi, R8
  call pnum
  call nlf

  ; subtraction
  ; R10 = R8 - R9
  mov rdx, R8
  mov R9, 75
  sub rdx, R9   ; rdx -= R9
  mov R10, rdx

  mov rdi, R8
  call pnum
  call subf

  mov rdi, R9
  call pnum
  call eqlf

  mov rdi, R10
  call pnum
  call nlf

  ; multiplication
  ; R8 = R10 * R9
  mov R9, 3
  mov rdi, R10
  imul rdi, R9  ; rdi *= R9
  mov R8, rdi

  mov rdi, R10
  call pnum
  call mulf

  mov rdi, R9
  call pnum
  call eqlf

  mov rdi, R8
  call pnum,
  call nlf

  ; division
  ; R9 = R8 / R10
  xor rdx, rdx  ; must be cleared
  mov rax, R8
  mov R10, 25
  div R10     ; rax /= R10 && rdx %= R10 
  mov R9, rax

  mov rdi, R8
  call pnum
  call divf

  mov rdi, R10
  call pnum
  call eqlf

  mov rdi, R9
  call pnum
  call nlf

  ; exit
  mov rax, 60
  mov rdi, 0
  syscall

sumf:
  mov rax, 1
  mov rdi, 1
  mov rsi, sum
  mov rdx, 3
  syscall
  ret

subf:
  mov rax, 1
  mov rdi, 1
  mov rsi, sub
  mov rdx, 3
  syscall
  ret

mulf:
  mov rax, 1
  mov rdi, 1
  mov rsi, mul
  mov rdx, 3
  syscall
  ret

divf:
  mov rax, 1
  mov rdi, 1
  mov rsi, _div
  mov rdx, 3
  syscall
  ret

eqlf:
  mov rax, 1
  mov rdi, 1
  mov rsi, eql
  mov rdx, 3
  syscall
  ret

nlf:
  mov rax, 1
  mov rdi, 1
  mov rsi, nl
  mov rdx, 1
  syscall
  ret

; (rdi)
pnum:
  mov rax, rdi
  mov rcx, buf
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
  mov rbx, buf
  add rbx, 20
  sub rbx, rcx  ; length in rbx

  mov rax, 1
  mov rdi, 1
  mov rsi, rcx
  mov rdx, rbx
  syscall

  ret

