# Macros

A comprehensive overview of macro usage, syntax, and behaviors in NASM assembly language, including comparative syntax for other major assemblers.

---

## 🔍 Are Macros NASM-Specific?

The concept of macros exists in almost every assembler, but the specific syntax is unique to each tool. The table below compares how a macro with one argument and a local label is defined across different assemblers:

| Assembler | Define | Argument | Local Label |
| :--- | :--- | :--- | :--- |
| **NASM / YASM** | `%macro name 1 ... %endmacro` | `%1` | `%%label` |
| **GNU as (GAS)** | `.macro name arg ... .endm` | `\arg` | `\@` (counter) |
| **MASM** | `name MACRO arg ... ENDM` | `arg` | `LOCAL label` |
| **FASM** | `macro name arg { ... }` | `arg` | `local label` |

> ⚠️ **Note:** To port macro code to another assembler, you must rewrite it entirely. Basic directives also vary by assembler flavor (e.g., NASM uses `global`, `section`, `db`, and `equ`, while GAS uses `.globl`, `.byte`, and `.equ`).

---

## ⚙️ Parameter Count Declarations

NASM supports flexible argument handling, enabling ranges, greedy arguments, and defaults:

| Declaration | Rule / Behavior |
| :--- | :--- |
| `%macro m 2` | Accepts **exactly** 2 arguments. |
| `%macro m 2+` | Accepts 2 arguments; the last one greedily swallows all remaining commas/text. |
| `%macro m 0-1 0` | Accepts 0 or 1 arguments; defaults `%1` to `0` if omitted. |
| `%macro m 1-*` | Variadic; accepts **1 or more** arguments. |

---

## 🛠️ Usage Examples

### 1. Fixed Number of Arguments

Arguments are parsed as literal text substitution. In this example, `%1` is a label string and `%2` can be a literal value, a register, or a memory reference:

```nasm
%macro show 2
    push rax
    write 1, %1, ": "
    pop rax
    mov rax, %2
    call print_number
%endmacro

; Usage:
show "number", 42         ; Literal value
show "register", rbx      ; Register
show "memory", [counter]  ; Memory address
```

### 2. Greedy Arguments (The `+` Modifier)

Appending `+` to the argument count allows the final parameter to consume commas, making it useful for string/data definitions like `db`:

```nasm
%macro write 2+
    ; ...
    %%text: db %2
%endmacro

; Usage:
write 1, "Hi", 10         ; %1 is '1', %2 swallows '"Hi", 10'
```

### 3. Optional Arguments with Defaults

Define a range of allowed parameters followed by default values for trailing arguments:

```nasm
%macro exit 0-1 0
    mov rax, 60
    mov rdi, %1
    syscall
%endmacro

; Usage:
exit 3                    ; Exits with status 3
exit                      ; Exits with status 0 (uses default)
```

### 4. Variadic Arguments (Any Number of Arguments)

Use `%0` to get the total argument count, combined with `%rep` and `%rotate` to loop through parameters sequentially:

```nasm
%macro pushall 1-*
%rep %0                   ; Repeat once per argument
    push %1
%rotate 1                 ; Shift list left: %2 becomes the new %1
%endrep
%endmacro

; Usage:
pushall rbx, r12, r13     ; Expands to: push rbx -> push r12 -> push r13
```

> 💡 **Tip:** To pop in reverse order, rotate the other way using `%rotate -1`.

---

## ⚠️ Important Considerations

### Comma Passing via Braces

If you need to pass an expression containing commas as a *single* argument, wrap it in curly braces:
```nasm
twice {add rax, 5}        ; Passes "add rax, 5" as a single argument
```

### Argument Mismatch Errors

If you pass the wrong number of arguments to a macro, NASM will throw an error specifying that the macro exists but does not take that number of parameters:

```text
warning: multi-line macro `write' exists, but not taking 1 parameter
error: parser: instruction expected
```

### Overloading Macro Names

You can define multiple macros with the **same name but different parameter counts**. NASM will automatically resolve and dispatch to the correct definition based on the arguments passed.

### Watch Out For

* **Side Effects:** Arguments are treated as text blocks, not evaluated values. If an argument containing an operation or a function call is repeated inside a macro (e.g., in a `twice` macro), it will run multiple times along with any intentional or unintentional side effects.
* **Register Pollution:** Nested macros often share and overwrite registers. Ensure you isolate and preserve critical volatile registers (or leverage non-volatile registers like `rbx`, `r12`, `r13`) across macro boundaries.
* **Debugging Macro Expansions:** Compiler errors point to the line where the macro is *called*, not where it fails internally. To debug, expand the macro text directly by running:

  ```bash
  nasm -E file.asm
  ```
  