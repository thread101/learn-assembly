; The mental model
; - Registers are a few dozen tiny, very fast storage slots inside the CPU: rax, rbx, rcx, rdx, rsi, rdi, rsp, rbp, r8 to r15. Most instructions work on them.
; - Memory is large but slower. You read and write it by address.
; - rip is the instruction pointer. It holds the address of the next instruction.
; - Flags are single bits the CPU sets after an operation, for example “the result was zero”. Conditional jumps read them.
; - System calls are how a program asks the kernel for things like printing or exiting. On Linux you put the call number in rax, the arguments in rdi, rsi, rdx, then run syscall.

global _start

section .text
_start:
  mov rax, 60   ; syscall 60 = exit
  mov rdi, 42   ; argument 1 the exit code = 42
  syscall

