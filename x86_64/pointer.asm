; Keyword	  Size	    Description
; BYTE	    1 Byte	  Points to 8-bit data (e.g., a character)
; WORD	    2 Bytes	  Points to 16-bit data
; DWORD	    4 Bytes	  Points to 32-bit data (Double Word)
; QWORD	    8 Bytes	  Points to 64-bit data (Quad Word)


global _start

%macro print 4
  push r11
  section .data
  %%text1: db %1
  %%len1: equ $ - %%text1
  %%text2: db %3
  %%len2: equ $ - %%text2
  section .text
  mov rax, 1
  mov rdi, 1
  mov rsi, %%text1
  mov rdx, %%len1
  syscall

  mov rdi, %2
  call pnum

  mov rax, 1
  mov rdi, 1
  mov rsi, %%text2
  mov rdx, %%len2
  syscall

  pop r11
  mov rdi, %4     ; copy r11
  call pnum

  mov rax, 1
  mov rdi, 1
  mov rsi, nl
  mov rdx, 1
  syscall
%endmacro

section .bss
; Reserving uninitialized space for dynamic pointers
dyn_num: resq 1     ; 32-bit pointer
buf: resb 20

section .data
nl: db 10
num: dq 1200        ; 64 bit integer number
num32: dd 65535     ; 32 bit integer number

; Declaring pointers to num:
num_p32: dd num32   ; 32-bit pointer (uses dd / Double Word)
num_p64: dq num     ; 64-bit pointer (uses dq / Quad Word)

section .text
_start:
  print "The address=", num, " value of [num]=", [num]
  
  ;          address of num_p32                          address of num
  print "The address=", num_p64, " value of [num_p64]=", [num_p64]
  
  ; 1. Load the address stored inside the pointer variable into a register
  mov rbx, [num_p64]   ; rbx now holds the memory address of 'num'

  ; 2. Dereference the pointer (read the value it points to)
  ;    We must specify 'qword' because 'num' is 8 bytes (dq)
  mov r11, qword [rbx] ; r11 now holds value of num
  print "Value of pointer [num_p64]=", [num_p64], " value pointed to (num)=", r11
  
  mov rbx, [num_p64]
  ; 3. Modify the data through the pointer
  add qword [rbx], 800 ; 'num' in memory is now 1200 + 800 = 2000
  print "The address=", num, " value of [num]=", [num]
  
  ; (Load Effective Address) instruction: loading address at runtime
  lea rsi, [num]   ; rsi now acts as a pointer holding the address of num

  mov eax, dword [num32]  ; eax is the designated 32-bit register because of how the architecture evolved over time

  mov rax, 60
  mov rdi, 0
  syscall

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

