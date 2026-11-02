These are all NASM directives, not CPU instructions. They tell the assembler what to put in the file, and the CPU never sees them. I assembled a test file to check each one, and the actual bytes are shown below.

The data directives (d for “define”)
Directive	Stands for	Size
db	define byte	1 byte
dw	define word	2 bytes
dd	define double word	4 bytes
dq	define quad word	8 bytes
dt	define ten bytes	10 bytes (floating point)

The “word” naming dates back to the 16-bit era, which is why a 4-byte value is a “double word” even though your CPU’s real word is 64 bits.

Each one stores bytes in the file at that spot, and the label names the address. Here are the bytes my test produced (all numbers are stored with the low byte first, called little-endian):

db "Hi", 10, 0x42   ->  48 69 0a 42        (text and numbers can mix)
dw 0x1234           ->  34 12              (reversed!)
dd 100000           ->  a0 86 01 00
dq 25               ->  19 00 00 00 00 00 00 00
times 3 db 0xFF     ->  ff ff ff
db " is "           ->  20 69 73 20

So num1: dq 25 is an 8-byte variable that starts out holding 25. That’s why you read it with mov rax, [num1].

equ (equate)

equ assigns a constant to a name. It stores nothing in memory. It’s a label for a value that the assembler works out while assembling:

nasm
fmt3:     db " is "
fmt3_len: equ $ - fmt3

$ means “the address where I am right now”. At that line, $ is just past the last byte of fmt3, so $ - fmt3 is the string’s length. In my test that came out as 4. Because it’s a constant, you use it without brackets: mov rdx, fmt3_len. That line must come directly after the string, or $ points somewhere else and the length is wrong.

Reserving space without values

These go in .bss and take no space in the file (my test reserved 48 bytes there and stored none of them):

Directive	Reserves
resb 16	16 bytes
resw, resd, resq	words, double words, quad words

nums: resq 4 gives you four 8-byte slots, initially zero.

Other directives you’ll meet
Directive	What it does
section .text / .data / .bss	Switches between code, initialised data and empty data
global _start	Makes a label visible to the linker, so ld can find the entry point
extern printf	Says this name lives in another file or library
times N db 0	Repeats an item N times (times 510 - ($ - $$) db 0 pads a boot sector)
$$	Address of the start of the current section
bits 64	Sets the instruction mode (16, 32 or 64)
default rel	Makes memory references relative to the instruction pointer, needed for modern position-independent code
align 16	Pads with filler so the next item starts at a multiple of 16
incbin "file"	Pulls a file’s raw bytes into your program
%define, %assign	Text substitution, or a number that can be changed later (unlike equ)
%macro ... %endmacro	Defines your own multi-line pseudo-instruction
%include "file"	Pastes in another source file

The % ones belong to NASM’s preprocessor, which runs before assembling.

Other assemblers use different names. GNU as (what gcc uses) writes .byte, .word, .long, .quad, .ascii and .equ. If you ever read compiler output with gcc -S, those are the same ideas.

As an exercise, add msg2: db "Total: " with a matching equ length, then print it before a number from print_number

----

Register Sub-divisions & Naming

Each 64-bit general-purpose register can be broken down into smaller pieces to maintain backward compatibility with 32-bit, 16-bit, and 8-bit software. Modifying the smaller component typically leaves the upper parts untouched, with one critical exception: writing to a 32-bit register (like EAX) automatically zeroes out the upper 32 bits of its 64-bit counterpart (RAX).

64-bit Long	32-bit Int	16-bit Short	8-bit High	8-bit Low	Historical Primary Purpose
RAX	EAX	AX	AH	AL	Accumulator: Arithmetic operations & function return values.
RBX	EBX	BX	BH	BL	Base: Pointer to data in memory.
RCX	ECX	CX	CH	CL	Counter: Loop iterations and string operations.
RDX	EDX	DX	DH	DL	Data: I/O operations, multiplication/division overflows.
RSI	ESI	SI	—	SIL	Source Index: Source pointer for string/array copying.
RDI	EDI	DI	—	DIL	Destination Index: Destination pointer for string/array copying.
RBP	EBP	BP	—	BPL	Base Pointer: References local variables on the function stack.
RSP	ESP	SP	—	SPL	Stack Pointer: Points directly to the top of the stack.


Numbered Registers (R8–R15)

Introduced in 64-bit mode, these follow a slightly different suffix pattern for sub-divisions:
• 64-bit: R8, R9, R10, R11, R12, R13, R14, R15
• 32-bit: R8D through R15D (D = Doubleword)
• 16-bit: R8W through R15W (W = Word)
• 8-bit: R8B through R15B (B = Byte)

