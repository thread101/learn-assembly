; Anatomy of an Assembly Function
; A standard assembly function is divided into three distinct phases to ensure it safely handles data without overwriting the rest of the application
; 1. Prologue
; - Before executing the core logic, the function creates its own Stack Frame to handle local data. It saves the base pointer of the caller and allocates space for its own local variables
; push ebp       ; Save the caller's base pointer
; mov ebp, esp   ; Set the current stack pointer as the new base pointer
; sub esp, 8     ; Allocate 8 bytes for local variables (optional)

; 2. Body
; - This is where the actual code execution happens. Data is manipulated inside CPU registers or local variables allocated on the stack frame

; 3. Epilogue
; - Before returning, the function must clean up its stack frame so the CPU doesn't read garbage data when attempting to find the return address.
; mov esp, ebp   ; Deallocate local variables by resetting the stack pointer
; pop ebp        ; Restore the caller's base pointer
; ret            ; Return control to the caller

; The stack
; The stack is a region of memory that rsp points to. It grows downward, toward lower addresses.
; • push rax does rsp -= 8, then stores rax at [rsp].
; • pop rax loads [rsp] into rax, then does rsp += 8.

; That’s why a function must leave the stack exactly as it found it before ret. If it doesn’t, ret pops the wrong value and jumps to nonsense.

; How Parameters and Return Values Work
; Because assembly has no function signature arguments, data must be placed where both the caller and callee can see it. Depending on the CPU architecture, this is done in one of two ways:

; Option A: Passing by Registers (Fast)
; Modern architectures like x86-64 or ARM pass the first few parameters directly inside specific general-purpose registers.
; • x86-64 Standard: Arguments 1 through 6 are placed in RDI, RSI, RDX, RCX, R8, and R9 respectively. The return value is stored in RAX.
; • ARM Standard: Arguments 1 through 4 go in R0 through R3. The return value is placed back into R0

; Option B: Passing via Stack (Legacy/Overflow)
; Older architectures (like 32-bit x86) or functions with too many parameters push arguments onto the stack right before calling the function. The function then uses positive offsets relative to the Base Pointer (EBP) to read them.

section .bss
buffer: resb 20

section .text
global print_num

; ---------------------------------------------------------------------
; Function: sum_two_nums
; Inputs:
;   RDI - First Integer (passed by caller)
; Output:
;   RAX - The length of the printed integer
; ---------------------------------------------------------------------

print_num:
  ; --- Prologue ---
  push rbp        ; save the old base pointer
  mov rbp, rsp    ; set up new frame pointer

  ; --- Body ---
  mov rax, rdi
  mov rsi, buffer
  add rsi, 20

  mov rcx, 10
  .next_digit:
    xor rdx, rdx
    div rcx       ; quotient = rax, remainder = rdx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    test rax, rax
    jnz .next_digit

  ; length
  mov rbx, buffer
  add rbx, 20
  sub rbx, rsi    ; length = rbx

  mov rax, 1
  mov rdi, 1
  ; mov rsi, rsi
  mov rdx, rbx
  syscall

  mov rax, rbx

  ; --- Epilogue ---
  mov rsp, rbp      ; restore stack pointer
  pop rbp           ; restore old base pointer

  ret

