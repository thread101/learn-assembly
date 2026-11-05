; Every demo puts values in registers, runs the instruction, and prints
; "label: result". Read the code next to the output.
global _start

; show "text": prints  text: <the number in rax>
; rax is kept; rcx, rdx, rsi, rdi, r11 are destroyed (print_number and syscall do that)
%macro show 1
    push rax
    section .data
%%text: db %1, ": "
%%len:  equ $ - %%text
    section .text
    mov rax, 1
    mov rdi, 1
    mov rsi, %%text
    mov rdx, %%len
    syscall
    pop rax
    call print_number
%endmacro

section .bss
buffer: resb 21

section .text
_start:
    ; ===== 1. add, sub, inc, dec, neg ==============================
    mov rax, 40
    add rax, 2                   ; rax = rax + 2
    show "add 40+2"

    mov rax, 50
    sub rax, 8                   ; rax = rax - 8
    show "sub 50-8"

    mov rax, 41
    inc rax                      ; rax = rax + 1
    show "inc 41"

    mov rax, 43
    dec rax                      ; rax = rax - 1
    show "dec 43"

    mov rax, 42
    neg rax                      ; rax = 0 - rax
    show "neg 42"

    ; ===== 2. multiply =============================================
    mov rax, 6
    mov rbx, 7
    imul rax, rbx                ; rax = rax * rbx   (result cut to 64 bits)
    show "imul 6*7"

    mov rbx, 7
    imul rax, rbx, 10            ; rax = rbx * 10    (3 operands: dest, source, constant)
    show "imul 7*10"

    mov rax, -6
    mov rbx, 7
    imul rax, rbx                ; imul understands negative numbers
    show "imul -6*7"

    mov rax, 1 << 62             ; 2^62
    mov rbx, 4
    mul rbx                      ; rdx:rax = rax * rbx, full 128-bit result, unsigned
    mov rbx, rax                 ; save the low half (show destroys rdx)
    mov rax, rdx
    show "mul 2^62*4 high half"
    mov rax, rbx
    show "mul 2^62*4 low half"

    ; ===== 3. divide ===============================================
    mov rax, 17
    cqo                          ; sign-extend rax into rdx (needed before idiv)
    mov rbx, 5
    idiv rbx                     ; rax = quotient, rdx = remainder
    mov rbx, rdx
    show "idiv 17/5 quotient"
    mov rax, rbx
    show "idiv 17/5 remainder"

    mov rax, -17
    cqo
    mov rbx, 5
    idiv rbx                     ; rounds toward zero; remainder takes the sign of the dividend
    mov rbx, rdx
    show "idiv -17/5 quotient"
    mov rax, rbx
    show "idiv -17/5 remainder"

    ; ===== 4. shifts (multiply / divide by powers of two) ==========
    mov rax, 5
    shl rax, 3                   ; shift left 3 = multiply by 2^3
    show "shl 5<<3"

    mov rax, 100
    shr rax, 1                   ; logical shift right = unsigned divide by 2
    show "shr 100>>1"

    mov rax, -7
    sar rax, 1                   ; arithmetic shift right = signed divide by 2, rounds DOWN
    show "sar -7>>1"

    mov rax, -7
    cqo
    mov rbx, 2
    idiv rbx                     ; idiv rounds toward ZERO, so it differs from sar
    show "idiv -7/2"

    ; ===== 5. lea: arithmetic without touching the flags ===========
    mov rbx, 7
    mov rcx, 5
    lea rax, [rbx + rcx*4 + 10]  ; rax = rbx + rcx*4 + 10  (scale can be 1, 2, 4 or 8)
    show "lea 7+5*4+10"

    mov rbx, 7
    lea rax, [rbx + rbx*4]       ; rax = rbx * 5
    show "lea 7*5"

    ; ===== 6. bitwise ==============================================
    mov rax, 0b1101
    and rax, 0b0110              ; 1 only where both have 1
    show "and 1101 and 0110"

    mov rax, 0b1100
    or rax, 0b0011               ; 1 where either has 1
    show "or 1100 or 0011"

    mov rax, 0b1100
    xor rax, 0b1010              ; 1 where they differ
    show "xor 1100 xor 1010"

    xor rax, rax
    not rax                      ; flips every bit
    show "not 0"

    mov rax, 43
    and rax, 1                   ; lowest bit: 1 means odd
    show "43 and 1 (1 = odd)"

    ; ===== 7. wrap-around, carry and overflow ======================
    mov al, 250
    add al, 10                   ; 8-bit add: 260 does not fit in a byte
    setc bl                      ; bl = carry flag
    movzx rax, al
    show "al 250+10 wraps to"
    movzx rax, bl
    show "carry flag"

    mov rax, 9223372036854775807 ; largest signed 64-bit number
    add rax, 1
    seto bl                      ; bl = signed overflow flag
    show "max+1 wraps to"
    movzx rax, bl
    show "overflow flag"

    mov rax, -1                  ; low half: all 64 bits set
    xor rdx, rdx                 ; high half: 0
    add rax, 1                   ; low half wraps to 0 and sets the carry flag
    adc rdx, 0                   ; add with carry: pushes the carry into the high half
    mov rbx, rdx
    show "128-bit add low half"
    mov rax, rbx
    show "128-bit add high half"

    ; ===== 8. register sizes =======================================
    mov rax, -1
    mov eax, 5                   ; writing the 32-bit part CLEARS the upper 32 bits
    show "mov eax,5 after rax=-1"

    mov rax, -1
    mov ax, 5                    ; writing the 16-bit part leaves the rest alone
    show "mov ax,5 after rax=-1"

    mov rax, 60
    xor rdi, rdi
    syscall

; print_number: prints the signed number in rax followed by a newline
print_number:
    mov rdi, buffer + 20
    mov byte [rdi], 10
    mov r8, rax
    test rax, rax
    jns .positive
    neg rax
.positive:
    mov rcx, 10
.next_digit:
    xor rdx, rdx
    div rcx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz .next_digit
    test r8, r8
    jns .write
    dec rdi
    mov byte [rdi], '-'
.write:
    mov rsi, rdi
    mov rdx, buffer + 21
    sub rdx, rsi
    mov rax, 1
    mov rdi, 1
    syscall
    ret

