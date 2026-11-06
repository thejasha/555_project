# 555_project

Blocks needed: multiplier, 2-bit adder, 3-bit adder, 3-bit 2-to-1 MUX

## Progress

**XNOR Z** (`XNOR_Z`) (Same as the XNOR, but added the NAND AB as an output (can use instead of computing NAND again))
- [x] Schematic
- [x] Symbol
- [x] Tested (correct output)
- [ ] Beta matching (NMOS/PMOS sizing)

**Half adder** (`Half_adder`): used for bit 0 (no carry-in)
- [x] Schematic
- [x] Symbol
- [ ] Tested

**Full adder** (`Full_adder`): used for bits 1 and up
- [x] Schematic
- [x] Symbol
- [ ] Tested

**2-bit adder** (`2bit_adder`): ripple carry
- [x] Schematic
- [x] Symbol
- [ ] Tested

**3-bit adder** (`3bit_adder`): ripple carry
- [x] Schematic
- [x] Symbol
- [ ] Tested

**Multiplier**
- [ ] Schematic
- [ ] Symbol
- [ ] Tested

**3-bit 2-to-1 MUX**
- [ ] Schematic
- [ ] Symbol
- [ ] Tested

Supporting cells already in the library: `INV_fin_larger`, `NAND2`, `AND2`,
(INV_fin_larger is a 1.5 beta inverter while INV is a 1 beta (could remove gates if not needed like INV and AND2))

## Adder design

Decided on a **ripple-carry adder** for least amount of transistors used (also dont really need CLA for 2/3bits):

- **Bit 0** uses a **half adder**, since there's no carry-in for the first bit.
- **Bits 1 and up** use **full adders**, each taking the carry-out from the previous bit.
- `2bit_adder` = half adder + 1 full adder
- `3bit_adder` = half adder + 2 full adders

## Boolean logic

Paste the expressions into https://www.boolean-algebra.com/ to check them. Notation: `'` = NOT, `+` = OR, `AB` = A AND B.

### XNOR / XNOR_Z

Built from one `NAND2` plus 6 transistors (see the `XNOR_Z` schematic image under Schematic conventions).

```
Z  = (AB)'                     NAND2 in the "Z Gate Input" box (XNOR_Z also outputs this)

Pull-up   (PMOS):  M3(Z) in parallel with M5(A) in series with M4(B)
          Y = 1 when  Z' + A'B'
Pull-down (NMOS):  M1(A) in parallel with M2(B), in series with M0(Z)
          Y = 0 when  (A + B)Z

Y  = ((A + B)Z)'
   = Z' + A'B'
   = AB + A'B'                 substitute Z' = AB
   = A XNOR B
```

Check: `((A+B)(AB)')'` simplifies to `AB + A'B'`.

### Half adder

One `XNOR_Z` + 2 inverters. Carry reuses the `Z` (NAND) output, so no extra AND gate is needed.

```
X    = (A XNOR B) = AB + A'B'     XNOR_Z output Y
Z    = (AB)'                      XNOR_Z output Z
Sum  = X'  = A'B + AB'  = A XOR B
Cout = Z'  = AB
```

Check: `(AB + A'B')'` simplifies to `A'B + AB'`, and `((AB)')'` simplifies to `AB`.

### Full adder

2 XNORs + 2 `NAND2` + 1 inverter. The carry is built as NAND-NAND (same as OR of ANDs).

```
X1   = A XNOR B = (A XOR B)'      XNOR_Z(A, B), also gives Z = (AB)'
Sum  = X1 XNOR Cin                2 XNORs make an XOR, no inverter needed
     = A XOR B XOR Cin
P    = X1' = A XOR B              inverter
N1   = (P Cin)'                   NAND2
Cout = (Z N1)'                    NAND2
     = AB + P Cin
     = AB + (A XOR B)Cin
     = AB + ACin + BCin           majority function
```

Critical path for Cout: XNOR, INV, NAND, NAND (4 gates).

Check: `((AB)' ((A'B + AB')C)')'` simplifies to `AB + AC + BC`, with C = Cin.

## Optimization approach

My goal was to use **as few transistors as possible**. Later we can decide whether to trade some transistors for fewer gates or a shorter critical path.


*`XNOR_Z` schematic: 6 transistors in the main circuit (M0 to M5) + a `NAND2` (4) in the Z Gate Input box = 10 transistors. It also shows the box layout described under Schematic conventions.*

### Transistor counts

| Cell | Built from | Transistors |
|---|---|---|
| `NAND2` | - | 4 |
| `INV` / `INV_fin_larger` | - | 2 |
| `XNOR` / `XNOR_Z` | 1 NAND2 (4) + 6 transistors | 10 |
| `Half_adder` | 1 XNOR_Z + 2 INV | 14 |
| `Full_adder` | 2 XNOR + 2 NAND2 + 1 INV | 30 |
| `2bit_adder` | 1 Half_adder + 1 Full_adder | 44 |
| `3bit_adder` | 1 Half_adder + 2 Full_adder | 74 |

- **Half adder:** Sum = INV(XNOR(A, B)). Carry = INV(Z), where Z is the NAND(A, B) output already inside `XNOR_Z`, so carry needs no extra NAND.
- **Full adder:** two XNORs chained give the sum (no inverter needed). The carry uses NANDs, and the critical path is 4 gates: XNOR, INV, NAND, NAND.

## Schematic conventions

Each schematic is split into boxes drawn with notes:

- **Inputs box:** input pins, plus VDD/VSS
- **Outputs box:** output pins, if needed
- **Main circuit box:** the core logic
- **Sub-circuit box(es):** helper pieces, such as the NAND inside the XNOR

Guidelines (If you guys want to change these let me know - just how I do it):

1. Use the same layout in every cell so anyone opening it knows where to look.
2. Connect between boxes with wire labels instead of long wires. Double-check label spelling, because a typo creates a floating net.
3. The boxes are only drawings. Under Notes (can do a label and a shape)
4. Write design notes in the boxes (critical path, beta ratios, why a gate is reused) (I need to do this in my schematic still).

Example:

![XNOR_Z schematic](docs/XNOR_Z_schematic.png)

Only need an output box if you have a wire bus with a bunch of wire connecting into the output.

For symbol, have VDD top, VSS bottom, Inputs left, Outputs right if it makes sense, in the 2/3bit adder I had the S pin be on the bottom.
