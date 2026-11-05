; A macro is a text substitution done by the assembler before it assembles anything. Wherever you write print "...", NASM pastes in the body of the macro and fills in the argument. Nothing runs at that point and there’s no call. The result is the same as if you had typed out all those lines yourself, each time.

; You can see this with nasm -E macro_demo.asm, which prints the expanded source.

global _start


; print "your string"
%macro print 1
  push rax  ; save rax
  section .data
  %%text: db %1, 10
  %%len: equ $ - %%text
  section .text
  mov rax, 1
  mov rdi, 1
  mov rsi, %%text
  mov rdx, %%len
  syscall
  pop rax ; restore rax
%endmacro

; Walking through:
; %macro print 1 defines a macro named print that takes 1 parameter. %endmacro closes it.
; %1 is the first argument, here the string you passed. So db %1, 10 becomes db "Hello my name is Andre", 10, and the 10 is the newline.
; %%text and %%len are local labels. NASM gives each use of the macro its own unique name, and in the expansion above you can see them become ..@2.text and ..@5.text. Without the %%, the second print would define text: a second time and the assembler would report a duplicate label.
; section .data ... section .text switches sections inside the macro. The string goes into .data, and the instructions stay in .text.
; $ - %%text is the string-length trick from before, evaluated once per use.
; push rax ... pop rax saves and restores rax. It only protects rax. The macro still changes rdi, rsi, rdx, and syscall overwrites rcx and r11, so don’t keep values in those across a print. Registers like rbx are safe.

; Read notes/Macro.txt for more on arguments

%macro printn 3
  push rax
  section .data
  %%text: db %1
  %%len: equ $ - %%text
  section .text
  mov rax, 1
  mov rdi, 1
  mov rsi, %%text
  mov rdx, %%len
  syscall
  pop rax

  mov rdi, %2
  call print_num

  print %3
%endmacro

%macro exit 1
  print "exiting ..."
  mov rax, 60
  mov rdi, %1
  syscall
%endmacro

; One thing to watch: these macro ends with section .text. If you ever use it while you’re inside a different section, it silently moves you to .text.

section .bss
num_buf: resb 20

section .text
_start:
  mov rax, 300
  print "Hello my name is Andre"
  printn "Number: ", rax, " was restored successfully"

  exit 0

; Macro versus function
; 	                    Macro                                       Function
;   When it happens ->	At assembly time, as text	                  At run time, with call and ret
;   Code size	      ->  A fresh copy at every use	                  One copy
;   Arguments	      ->  Any text: a string, a register, a number	  Values in registers
;   Speed	          ->  No call overhead	                          A little overhead

;   Your macro is a good fit for a macro. The argument is a string literal, which a function can’t take directly, and print is short. The two uses produced two separate copies of the code and two separate strings (you can see both in the symbol table). For a long routine called many times, a function is the better choice.

print_num:
  mov rax, rdi
  mov rcx, num_buf
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
  mov rbx, num_buf
  add rbx, 20
  sub rbx, rcx  ; length in rbx

  mov rax, 1
  mov rdi, 1
  mov rsi, rcx
  mov rdx, rbx
  syscall

  ret

