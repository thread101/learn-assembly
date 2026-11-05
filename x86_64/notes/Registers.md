# Assembly Reference Guide: Directives & Registers

A cheat sheet covering NASM assembly directives, memory layout definitions, and 64-bit architecture register subdivisions.

---

## 🛠️ NASM Assembly Directives

Directives are commands processed by the assembler rather than instructions executed by the CPU. They configure code structures, layout memory sections, and allocate variables.

### 1. Data Definition Directives (The `d` Family)

Used in the `.data` section to allocate initialized data. Sizing nomenclatures reflect 16-bit historical roots.

| Directive | Stands For | Size |
| :--- | :--- | :--- |
| `db` | Define Byte | 1 byte |
| `dw` | Define Word | 2 bytes |
| `dd` | Define Double Word | 4 bytes |
| `dq` | Define Quad Word | 8 bytes |
| `dt` | Define Ten Bytes | 10 bytes (Floating Point) |

#### Little-Endian Storage Examples

Intel and AMD x86-64 CPUs store data in **little-endian** format (least significant byte first). Text strings maintain standard linear order.

```nasm
db "Hi", 10, 0x42   ; Bytes: 48 69 0a 42 (Blends characters and raw numeric bytes)
dw 0x1234           ; Bytes: 34 12       (Stored in reverse byte order!)
dd 100000           ; Bytes: a0 86 01 00
dq 25               ; Bytes: 19 00 00 00 00 00 00 00
times 3 db 0xFF     ; Bytes: ff ff ff    (Repeats the byte 3 times)
```

> 💡 **Reading values:** Variables allocated like `num1: dq 25` represent base memory addresses containing data. Read their contents using memory syntax brackets: `mov rax, [num1]`.

### 2. Constants & String Length Evaluation (`equ`)

The `equ` directive defines numeric constants at compile time. It consumes **0 bytes** of memory inside the executable file.

```nasm
fmt3:     db " is "
fmt3_len: equ $ - fmt3
```
* **`$` (Location Counter):** Evaluates to the absolute address where the assembler is currently processing.
* **`$ - fmt3` Calculation:** Subtracts the starting address of the string from the current address (placed directly after the string), returning the string's length (`4`).
* **Usage:** Since it is a constant value rather than a memory pointer, load it directly without brackets: `mov rdx, fmt3_len`.

### 3. Space Reservation (`res` Family)
Used inside the `.bss` section to reserve clean, uninitialized space without adding weight to the compiled file size.

| Directive | Allocation Focus | Example |
| :--- | :--- | :--- |
| `resb` | Reserve Bytes | `resb 16` (Reserves 16 bytes) |
| `resw` | Reserve Words | `resw 10` (Reserves 10 x 2 bytes) |
| `resd` | Reserve Double Words | `resd 5`  (Reserves 5 x 4 bytes) |
| `resq` | Reserve Quad Words | `nums: resq 4` (Reserves four 8-byte slots, zeroed at startup) |

---

### 4. Structural Control Directives

| Directive | Operational Function |
| :--- | :--- |
| `section .text / .data / .bss` | Switches assembly focus between code blocks, initialized data, and empty buffer areas. |
| `global _start` | Exports a specific label symbol so that external system linkers (`ld`) can track down the program entry point. |
| `extern printf` | Informs the assembler that a designated symbol name exists in an external file or library. |
| `$$` | Resolves directly to the foundational base memory address of the current active section. |
| `times N db 0` | Repeats an identical syntax definition `N` times. (e.g., `times 510-($-$$) db 0` pads out custom boot sectors). |
| `bits 64` | Configures target CPU execution configuration constraints (Choose from 16, 32, or 64). |
| `default rel` | Enforces RIP-relative addressing formats natively across memory parameters (Critical for PIC/PIE binary hardening). |
| `align 16` | Insert padding bytes until the succeeding element memory pointer starts at an exact multiple of 16. |
| `incbin "file"` | Seamlessly pulls raw external asset file binary data verbatim straight into the localized workspace segment. |
| `%define` / `%assign` | Preprocessor text macros (`%define`) or numerical expressions (`%assign`) capable of scaling values dynamically. |
| `%include "file"` | Pastes the literal text lines from another designated source code file at that exact position. |

> 🌐 **Cross-Assembler Note:** Directives differ heavily across toolchains. For instance, GNU Assembler (GAS/GCC) uses equivalents like `.byte`, `.word`, `.long`, `.quad`, `.ascii`, and `.equ`.

---

## ⚡ Register Sub-divisions & Architecture Layout

x86-64 general-purpose registers can be sub-divided into smaller, backward-compatible components. 

### ⚠️ The 32-bit Zeroing Rule
* Modifying an 8-bit or 16-bit register subdivision **leaves the remaining upper bits of the register completely unchanged**.
* **CRITICAL EXCEPTION:** Writing any value to a 32-bit sub-register (e.g., `EAX`, `ECX`) **automatically overwrites and zeroes out the upper 32 bits** of its parent 64-bit register (`RAX`, `RCX`).

### Named General-Purpose Registers

| 64-bit Long | 32-bit Int | 16-bit Short | 8-bit High | 8-bit Low | Legacy Primary Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`RAX`** | `EAX` | `AX` | `AH` | `AL` | **Accumulator:** Mathematical calculations & function return codes. |
| **`RBX`** | `EBX` | `BX` | `BH` | `BL` | **Base:** Optional base addressing location memory pointer. |
| **`RCX`** | `ECX` | `CX` | `CH` | `CL` | **Counter:** Explicit loop track iterations & string array processing. |
| **`RDX`** | `EDX` | `DX` | `DH` | `DL` | **Data:** I/O mapping operations, product overflows for math. |
| **`RSI`** | `ESI` | `SI` | — | `SIL` | **Source Index:** Origin array block address pointer. |
| **`RDI`** | `EDI` | `DI` | — | `DIL` | **Destination Index:** Target receiver array memory address pointer. |
| **`RBP`** | `EBP` | `BP` | — | `BPL` | **Base Pointer:** Main baseline tracker for active stack frame variables. |
| **`RSP`** | `ESP` | `SP` | — | `SPL` | **Stack Pointer:** Dynamic offset memory address tracking the top of Stack. |

### Numbered Registers (`R8`–`R15`)

Introduced natively in AMD64/x86-64 architectures, these registers discard the legacy `H`/`L` high/low byte structure, applying flat uniform letter suffixes instead:

* **64-bit (Quadword):** `R8`, `R9`, `R10`, `R11`, `R12`, `R13`, `R14`, `R15`
* **32-bit (Doubleword):** `R8D`, `R9D`, `R10D`, `R11D`, `R12D`, `R13D`, `R14D`, `R15D`
* **16-bit (Word):** `R8W`, `R9W`, `R10W`, `R11W`, `R12W`, `R13W`, `R14W`, `R15W`
* **8-bit (Byte):** `R8B`, `R9B`, `R10B`, `R11B`, `R12B`, `R13B`, `R14B`, `R15B`

---

## ✍️ Code Construction Exercise

Here is how you can link string calculations (`equ`), data syntax directives (`db`), and registers together to solve the exercise challenge (printing a static message string via local pointer parameters):

```nasm
section .data
    msg2:     db "Total: "
    msg2_len: equ $ - msg2     ; Evaluates the string length dynamically (7 bytes)

section .text
    global _start

_start:
    ; Standard sys_write routine setup utilizing our directives
    mov rax, 1                ; sys_write system call index
    mov rdi, 1                ; File descriptor: stdout
    mov rsi, msg2             ; Pass string address pointer to source index
    mov rdx, msg2_len         ; Pass evaluated static size to data register
    syscall                   ; Fire execution hook to print "Total: "

    ; Program layout could continue to call print_number here...
```
