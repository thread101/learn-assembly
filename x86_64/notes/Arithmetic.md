# Arithmetic

## 1. add, sub, inc, dec, neg

Almost every instruction here follows one pattern: op dest, source means dest = dest op source.

```asm
add rax, 2     ; rax = rax + 2      -> 42
sub rax, 8     ; rax = rax - 8
inc rax        ; rax + 1
dec rax        ; rax - 1
neg rax        ; 0 - rax            -> -42
```

All of these set the flags (zero, sign, carry, overflow), which is why dec rbx followed by jnz works without a cmp. One quirk is that inc and dec leave the carry flag alone.

## 2. Multiplication has three forms

```asm
imul rax, rbx         ; rax = rax * rbx             6*7   -> 42
imul rax, rbx, 10     ; rax = rbx * 10              7*10  -> 70
mul  rbx              ; rdx:rax = rax * rbx         (unsigned, full result)
```

A 64-bit times a 64-bit number can need 128 bits. imul keeps only the low 64, which is what you want most of the time and works for negative numbers (-6*7 gave -42). One-operand mul keeps the whole answer: 2^62 * 4 = 2^64 gave high half 1 (in rdx) and low half 0 (in rax).

## 3. Division (recap)

idiv divides rdx:rax by its operand, so cqo has to fill rdx first. The quotient lands in rax, the remainder in rdx.

`17 / 5` gave quotient `3` and remainder `2`.
`-17 / 5` gave quotient `-3` and remainder `-2`. It rounds toward zero, and the remainder takes the sign of the dividend.

## 4. Shifts: fast powers of two

```asm
shl rax, 3     ; multiply by 2^3        5<<3   -> 40
shr rax, 1     ; unsigned divide by 2   100>>1 -> 50
sar rax, 1     ; signed divide by 2     -7>>1  -> -4
```

For negative numbers, sar and idiv disagree. sar rounds down (-7 → -4) while idiv rounds toward zero (-7/2 → -3). Neither is wrong, but you need to know which one you’re using. A compiler can swap a division for a shift only after correcting for that.

## 5. lea: arithmetic that doesn’t touch the flags

```asm
lea rax, [rbx + rcx*4 + 10]   ; 7 + 5*4 + 10 = 37
lea rax, [rbx + rbx*4]        ; x * 5 = 35
```

lea (“load effective address”) computes the address expression but doesn’t read memory. It was designed for pointer maths, but it’s also a quick way to do small multiplications and sums in one instruction. The scale can be 1, 2, 4 or 8.

## 6. Bitwise operations

Instruction | Result for 1100 and 1010 | Rule
--- | --- | ---
and | 1000 | 1 only where both have 1
or | 1110 | 1 where either has 1
xor | 0110 | 1 where they differ
not | flips all bits | not 0 is -1

A useful one: and rax, 1 leaves just the lowest bit, so it’s 1 for odd numbers (43 gave 1).

## 7. Wrap-around, carry and overflow

Hardware numbers have a fixed size, so results that don’t fit wrap around:

`mov al, 250` then `add al, 10` gave `4`, with the carry flag set. Carry means “this overflowed as an unsigned number”.
The largest signed 64-bit number plus `1` gave `-9223372036854775808`, with the overflow flag set. Overflow means “this overflowed as a signed number”.

The same add instruction sets both flags. The CPU doesn’t know whether your numbers are signed. You choose by what you test afterwards: `jc`/`jb` for unsigned, jo for signed. `setc` and `seto` copy the flags into a register so you can look at them.

adc (“add with carry”) adds the carry flag too. That lets you build numbers bigger than 64 bits. `add rax, 1` wrapped the low half to `0` and set the carry, and `adc rdx, 0` pushed it into the high half, giving a 128-bit result of 1:0.

## 8. Register sizes change what you overwrite

`mov eax, 5` (32-bit) clears the upper 32 bits of rax. After rax = -1 it gave 5.
`mov ax, 5` (16-bit) leaves the rest alone. After rax = -1 it gave -65531, which is 0xFFFFFFFFFFFF0005.

Writes to 8-bit and 16-bit registers leave the rest untouched, and only 32-bit writes clear the upper half. That rule causes a lot of bugs.

### Exercises

> Compute x * 10 using only lea and shl (hint: x*5*2).
Make a number negative with neg, then use both sar and idiv by 4 on -9 and see which numbers differ.
Write a 192-bit addition using add, adc, adc.
