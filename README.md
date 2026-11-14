# 555_project
(FYI - using claude to organize the readme better)

Blocks needed: multiplier, 2-bit adder, 3-bit adder, 3-bit 2-to-1 MUX (ReLU), combined into a neuron

All schematics: [docs/project_schematics.pdf](docs/project_schematics.pdf)

## Progress

**XNOR Z** (`XNOR_Z`) (Same as the XNOR, but added the NAND AB as an output (can use instead of computing NAND again))
- [x] Schematic
- [x] Symbol
- [ ] Tested (passed before the reorder and 1.5 resizing, needs a re-test)
- [x] Beta matching (NMOS/PMOS sizing, 1.5, see [XNOR / XNOR_Z](#xnor--xnor_z))

**Half adder** (`Half_adder`): used for bit 0 (no carry-in)
- [x] Schematic
- [x] Symbol
- [ ] Tested

**Full adder** (`Full_adder`): used for bits 1 and up
- [x] Schematic
- [x] Symbol
- [ ] Tested

**2-bit adder** (`2bit_adder`): ripple carry, **signed** (2's complement), inputs limited to -1, 0, 1 (`10` never occurs), 3-bit sign-extended output `S<2:0>`
- [x] Schematic (updated for signed addition, see [2-bit signed adder](#2-bit-signed-adder))
- [x] Symbol
- [ ] Tested

**3-bit adder** (`3bit_adder`): ripple carry, signed, no changes needed. In the neuron, only `S<2:0>` is used (`S<3>` is unconnected), see [Neuron](#neuron)
- [x] Schematic
- [x] Symbol
- [ ] Tested

**Multiplier** (`Multiplier`, 2-bit signed, inputs -1, 0, 1)
- [x] Schematic
- [x] Symbol
- [x] Tested (all 9 input combos, FO4 load)

**3-bit 2-to-1 MUX / ReLU** (`MUX3_RELU`): D0 = adder sum `Y<2:0>`, D1 = `000`, select = sign bit `Y<2>`
- [x] Schematic
- [x] Symbol
- [x] Tested (exhaustive, 8 input cases, FO4 load, 0.9 V, 25 ps edges: all pass)
- [x] Beta matching (reuses `INV_fin_larger` 2n/3p and `NOR2` 2n/6p, beta 1.5)

Reuses `INV_fin_larger` and `NOR2` (no new supporting cells).

**Neuron**: 2 multipliers -> 2-bit adder -> 3-bit adder (+ bias) -> ReLU (`MUX3_RELU`)
- [x] Schematic
- [ ] Symbol
- [ ] Tested

**Optimized Neuron** (`Optimized_Neuron`): 2 multipliers -> direct Z1/Z0 logic (replaces both adders and the ReLU MUX), see [Optimized Neuron](#optimized-neuron)
- [x] Schematic (duplicate NOR2 -> INV removed, `OR` net shared)
- [ ] Symbol
- [ ] Tested

Supporting cells already in the library: `INV_fin_larger`, `NAND2`, `NOR2`, `AND2`,
(INV_fin_larger is a 1.5 beta inverter while INV is a 1 beta (could remove gates if not needed like INV and AND2))
(Might want to check to make sure my NAND AND INV is good with everyone)

## Adder design

Decided on a **ripple-carry adder** for least amount of transistors used (also dont really need CLA for 2/3bits):

- **Bit 0** uses a **half adder**, since there's no carry-in for the first bit.
- **Bits 1 and up** use **full adders**, each taking the carry-out from the previous bit.
- `2bit_adder` = half adder + 1 full adder + sign-extension logic for `S<2>` (signed, full adder `Cout` unused)
- `3bit_adder` = half adder + 2 full adders

## Boolean logic

Paste the expressions into https://www.boolean-algebra.com/ to check them. Notation: `'` = NOT, `+` = OR, `AB` = A AND B.

### XNOR / XNOR_Z

Desired Logic: AB + A'B'


```
CMOS implementation: Y = (A + B (AB)')'

Z  = (AB)'                     NAND2 in the "Z Gate Input" box (XNOR_Z also outputs this)

Y  = ((A + B)Z)'
   = Z' + A'B'
   = AB + A'B'                 substitute Z' = AB
   = A XNOR B
```

| A | B | Z = (AB)' | Y = A XNOR B |
|:-:|:-:|:-:|:-:|
| 0 | 0 | 1 | 1 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

**Pull-down reorder (done in `XNOR` and `XNOR_Z`):** M0 (gate Z) moved to the top of the pull-down stack, next to the output. Z comes from the NAND2, so it arrives one gate later than A and B. With M0 next to Y, the M1/M2 node has already settled when Z switches, so only M0 has to discharge Y. Same idea as `Y<2>` on the NOR2 input next to the output in `MUX3_RELU`. Logic and sizing are unchanged.

```
Before:  Y ── M1 (A) || M2 (B) ── net1 ── M0 (Z) ── VSS
After:   Y ── M0 (Z) ── net1 ── M1 (A) || M2 (B) ── VSS
```

- M0: drain = Y, source = net1
- M1, M2: drain = net1, source = VSS

**Beta matching, 1.5 (done in `XNOR` and `XNOR_Z`):** every worst-case pull path matches `INV_fin_larger` (2n/3p), the same reference as `NAND2` (4n/3p) and `NOR2` (2n/6p).

| Device | Gate | Network | Worst-case path | nfin | w |
|:-:|:-:|---|:-:|:-:|:-:|
| M0 | Z | pull-down, series with M1 or M2 | 2 deep | 4 | 108e-9 |
| M1 | A | pull-down, parallel with M2 | 2 deep | 4 | 108e-9 |
| M2 | B | pull-down, parallel with M1 | 2 deep | 4 | 108e-9 |
| M3 | Z | pull-up, alone | 1 deep | 3 | 81e-9 |
| M4 | B | pull-up, series with M5 | 2 deep | 6 | 162e-9 |
| M5 | A | pull-up, series with M4 | 2 deep | 6 | 162e-9 |

- Pull-down: 4 + 4 in series = 2 fins equivalent. Pull-up: 6 + 6 in series = 3, M3 alone = 3. Ratio 3 : 2 = 1.5.
- The Z Gate Input `NAND2` is already 4n/3p, no change.
- Main circuit grows from 6 fins to 27 (transistor count is unchanged).

- [x] Apply the reorder and sizing to `XNOR_Z`
- [ ] Re-test `XNOR` and `XNOR_Z` (all 4 A/B cases) after the reorder and resizing
- [ ] Re-run `Multiplier/tb_mult_func.sp` (the multiplier uses `XNOR`)

### Half adder

Desired Logic: Sum = A^B | Cout = AB

```
X    = (A XNOR B) = AB + A'B'     XNOR_Z output Y
Z    = (AB)'                      XNOR_Z output Z
Sum  = X'  = A'B + AB'  = A XOR B
Cout = Z'  = AB
```

| A | B | X (XNOR) | Z (NAND) | Sum | Cout |
|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 1 | 1 | 0 | 0 |
| 0 | 1 | 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 | 1 | 0 |
| 1 | 1 | 1 | 0 | 0 | 1 |

### Full adder

Desired: Sum = A^B^C | Cout = AB+C(A+B)

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

| A | B | Cin | X1 | P | Z | N1 | Sum | Cout |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 0 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 | 1 | 1 | 1 | 0 |
| 0 | 1 | 0 | 0 | 1 | 1 | 1 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| 1 | 0 | 0 | 0 | 1 | 1 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| 1 | 1 | 0 | 1 | 0 | 0 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 | 0 | 0 | 1 | 1 | 1 |

### 2-bit signed adder

**Fix:** the first version of `2bit_adder` did **unsigned** addition: `S<2>` was the full adder's `Cout`. The inputs are 2-bit 2's complement, limited to -1, 0, 1 (`10` = -2 never occurs). The sum (-2 to 2) needs a sign-extended 3rd bit. The fix leaves the full adder's `Cout` unconnected (noConn) and drives `S<2>` from a separate **Signed Extension Logic** box instead:

```
S<1:0>  = half adder + full adder (same as before)
N       = (A1 + B1)'                NOR2(A<1>, B<1>)
S<2>    = (S1' + N)'                NOR2(INV(S<1>), N)
        = S1 (A1 + B1)
```

| A | B | A + B | S<2:0> |
|:-:|:-:|:-:|:-:|
| 00 (0) | 00 (0) | 0 | 000 |
| 00 (0) | 01 (1) | 1 | 001 |
| 01 (1) | 01 (1) | 2 | 010 |
| 00 (0) | 11 (-1) | -1 | 111 |
| 01 (1) | 11 (-1) | 0 | 000 |
| 11 (-1) | 11 (-1) | -2 | 110 |

(A and B are symmetric, so swapped rows are omitted.)

Note: this logic is **only valid because `10` (-2) is never an input**.

### Multiplier

Inputs are 2-bit signed, limited to -1, 0, 1 (`10` never occurs), so the product is also -1, 0, 1 and fits in 2 bits:

- Bit 0 says whether the value is nonzero: the product is nonzero only if both inputs are, so `P<0> = A0 B0`.
- Bit 1 is the sign: the product is negative only if it's nonzero and the signs differ, so `P<1> = A0 B0 (A1 XOR B1)`.

```
n0   = (A0 B0)'                 NAND2
P<0> = n0' = A0 B0              INV
xn   = A1 XNOR B1               XNOR (Z output unused)
P<1> = (n0 + xn)'               NOR2
     = A0 B0 (A1 XOR B1)
```

| A | B | A x B | P<1:0> |
|:-:|:-:|:-:|:-:|
| 00 (0) | any | 0 | 00 |
| 01 (1) | 01 (1) | 1 | 01 |
| 01 (1) | 11 (-1) | -1 | 11 |
| 11 (-1) | 11 (-1) | 1 | 01 |

### 3-bit 2-to-1 MUX (ReLU)

Desired: z = max(0, y), y = `3bit_adder` output `S<2:0>` (two's complement, range -3..+3)

```
MUX:   Z<i> = S'·D0<i> + S·D1<i>      S = Y<2> (sign bit), D0 = Y, D1 = 000
     = Y<i>·Y<2>'                     D1 = 0 removes the second term
     = (Y<i>' + Y<2>)'                NOR2(A = INV(Y<i>), B = Y<2>)
Z<2> = Y<2>·Y<2>' = 0                 constant, no transistors (tie to VSS at top level)
```

| Y<2:0> | y | Z<1:0> | z |
|:-:|:-:|:-:|:-:|
| 000 | 0 | 00 | 0 |
| 001 | +1 | 01 | 1 |
| 010 | +2 | 10 | 2 |
| 011 | +3 | 11 | 3 |
| 100 | -4 (unused) | 00 | 0 |
| 101 | -3 | 00 | 0 |
| 110 | -2 | 00 | 0 |
| 111 | -1 | 00 | 0 |

- `Y<2>` is the slowest adder output (end of the ripple carry chain), so it goes straight into the NOR2: **1 gate** from sign bit to output.
  An AND2-based MUX (`AND2(Y<i>, INV(Y<2>))`) would put INV + NAND2 + INV = 3 gates on the critical path.
- `Y<2>` goes to NOR2 input `B`, whose PMOS is next to the output `Y` (late input near output).
- Both gates are shared cells: `INV_fin_larger` (2n/3p) and `NOR2` (2n parallel, 6p series each).
- Load on the adder: `Y<2>` drives 2 NOR2 inputs (2 x 8 fins); `Y<0>`, `Y<1>` drive 1 inverter each (5 fins).

Exhaustive test (`MUX3_RELU/tb_mux_func.sp`, FO4 load on each output, VDD = 0.9 V, 25 ps edges), sampled at 80% of each 1 ns state:

| Y<2:0> | Z1 (V) | Z0 (V) | Result |
|:-:|:-:|:-:|:-:|
| 000 | 4.4e-7 | 4.4e-7 | pass |
| 001 | 4.4e-7 | 0.900 | pass |
| 010 | 0.900 | 1.1e-5 | pass |
| 011 | 0.900 | 0.900 | pass |
| 100 | 4.4e-6 | 4.4e-6 | pass |
| 101 | 1.9e-6 | 4.6e-7 | pass |
| 110 | 4.6e-7 | 4.3e-6 | pass |
| 111 | 4.6e-7 | 4.6e-7 | pass |

![MUX3_RELU schematic](docs/MUX_RELU_schematic.png)

![MUX3_RELU symbol](docs/MUX_RELU_symbol.png)

![MUX3_RELU HSPICE result](docs/MUX_RELU_HSPICE_RESULT.png)

### Neuron

```
y = X0 W00 + X1 W10 + W20
z = max(0, y)
```

- 2 `Multiplier`s: `X0 x W00` and `X1 x W10` (2-bit each)
- `2bit_adder` adds the two products -> `S<2:0>` (-2 to 2)
- `3bit_adder` adds the bias `W20` (sign-extended to 3 bits) -> `Y<2:0>`. `S<3>` is left unconnected, so the result is the 3-bit 2's complement sum
- `MUX3_RELU` -> `Z<1:0>`; `Z<2>` is tied to VSS through a `cds_thru` (Disconnect / Tie to ground box)

#### W20 sign extension

Like every weight, `W20` is a 2-bit signed number (`11` = -1, `00` = 0, `01` = 1, `10` unused), so the neuron input pin is `W20<1:0>`. The 3-bit adder's `B<2:0>` needs 3 bits, so `W20` is sign-extended by copying its sign bit. This is only wiring, with no gates:

```
B<2:0> = W20<1>, W20<1>, W20<0>     wire label on the B<2:0> bus: W20<1>,W20<1:0>
```

| W20<1:0> | value | B<2:0> |
|:-:|:-:|:-:|
| 11 | -1 | 111 |
| 00 | 0 | 000 |
| 01 | +1 | 001 |

Without it, a 3-bit pin with `W20<2>` left at 0 would read `-1` as `011` (+3).

#### 3-bit adder truth table

A = `2bit_adder` output (-2 to 2), B = sign-extended `W20` (-1 to 1). The sum (-3 to 3) always fits in 3-bit 2's complement (-4 to 3), so `S<2:0>` never overflows and needs no sign extension. `S<3>` is the unsigned carry and is 1 in rows where the signed answer is correct (e.g. -1 + 1), so it must stay unconnected.

| A = S<2:0> of 2bit_adder | B = W20 (extended) | A + B | S<2:0> | S<3> (unused) |
|:-:|:-:|:-:|:-:|:-:|
| 110 (-2) | 111 (-1) | -3 | 101 | 1 |
| 110 (-2) | 000 (0) | -2 | 110 | 0 |
| 110 (-2) | 001 (+1) | -1 | 111 | 0 |
| 111 (-1) | 111 (-1) | -2 | 110 | 1 |
| 111 (-1) | 000 (0) | -1 | 111 | 0 |
| 111 (-1) | 001 (+1) | 0 | 000 | 1 |
| 000 (0) | 111 (-1) | -1 | 111 | 0 |
| 000 (0) | 000 (0) | 0 | 000 | 0 |
| 000 (0) | 001 (+1) | +1 | 001 | 0 |
| 001 (+1) | 111 (-1) | 0 | 000 | 1 |
| 001 (+1) | 000 (0) | +1 | 001 | 0 |
| 001 (+1) | 001 (+1) | +2 | 010 | 0 |
| 010 (+2) | 111 (-1) | +1 | 001 | 1 |
| 010 (+2) | 000 (0) | +2 | 010 | 0 |
| 010 (+2) | 001 (+1) | +3 | 011 | 0 |

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
| `NOR2` | - | 4 |
| `2bit_adder` | 1 Half_adder + 1 Full_adder + 1 INV + 2 NOR2 (sign ext.) | 54 |
| `3bit_adder` | 1 Half_adder + 2 Full_adder | 74 |
| `Multiplier` | 1 NAND2 + 1 INV + 1 XNOR + 1 NOR2 | 20 |
| `MUX3_RELU` | 2 INV_fin_larger + 2 NOR2 | 12 |
| `Neuron` | 2 Multiplier + 2bit_adder + 3bit_adder + MUX3_RELU | 180 |

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

## Optimized Neuron

Same function as `Neuron` (`z0 = max(0, x0·w00 + x1·w10 + w20)`), but the 2-bit adder, 3-bit adder and `MUX3_RELU` are replaced by direct logic for each output bit. The ReLU is built into the logic: every case where y would be negative gives `Z = 00`, so there is no sign bit or MUX.

Schematic: `Optimized_Neuron`, page 12 of [docs/project_schematics.pdf](docs/project_schematics.pdf)

![Optimized Neuron schematic](Optimized_neuron.png)

### Idea

Each product (`P0 = X0·W00`, `P1 = X1·W10`) and the bias `W20` is -1, 0 or +1. Split each into its two bits:

- `n` = bit 0 = the term is nonzero (`P0<0>`, `P1<0>`, `W20<0>`)
- `s` = bit 1 = the term is negative (`P0<1>`, `P1<1>`, `W20<1>`)

A full adder on the three n bits counts how many terms are nonzero (`C S` = 0 to 3). The s bits say how many of them are negative.

| Negatives | Count `C S` | z | Why |
|:-:|:-:|:-:|---|
| 0 | 00 / 01 / 10 / 11 | 0 / 1 / 2 / 3 | z = `C S` |
| 1 | 01 or 10 | 0 | result is 0 or negative |
| 1 | 11 | 1 | two +1 and one -1: count - 2 = 1 |
| 2 or 3 | any | 0 | `Majority` of the sign bits forces 0 |

### Equations

```
OR       = P0<1> + P1<1>                       NOR2 -> INV (shared by both blocks below)
NORSign  = (P0<1> + P1<1> + W20<1>)'           no negative terms
Majority = P0<1>·P1<1> + W20<1>·OR             2 or more negative terms
C, S     = Full_adder(P0<0>, P1<0>, W20<0>)    count of nonzero terms

Z<1> = NORSign · C
Z<0> = Majority' · S · (NORSign + C)
Z<2> = 0                                       tied to VSS (cds_thru)
```

`(NORSign + C)` blocks the one case where S = 1 but z must be 0: a single -1 term on its own (e.g. -1, 0, 0).

Checked in a script against all 243 input combinations (x0, w00, x1, w10, w20 each -1/0/+1): Z<2:0> matches `max(0, y)` in every row. This is a logic check, not a simulation of the schematic.

### Gates (2-input only)

| Block (schematic box) | Gates | Output |
|---|---|---|
| IF Sign bit is all Positive Logic | NOR2(P0<1>, P1<1>) -> INV -> NOR2(OR, W20<1>) | `OR`, `NORSign` |
| Majority 1 or 0 Sign Bit Logic | NAND2(W20<1>, OR), NAND2(P0<1>, P1<1>) -> NAND2 | `Majority` |
| S and C Logic | `Full_adder`(P0<0>, P1<0>, W20<0>) | `C`, `S` |
| Z<1> Logic | AND2(NORSign, C), the `AND2` cell is a NAND2 + INV inside | `Z<1>` |
| Z<0> Logic | NOR2(NORSign, C) -> NOR2(·, Majority) -> NAND2(·, S) -> INV | `Z<0>` |

### Transistor count

| Part | Built from | Transistors |
|---|---|:-:|
| 2 x `Multiplier` | unchanged | 40 |
| `Full_adder` | 2 XNOR + 2 NAND2 + 1 INV | 30 |
| `OR` / `NORSign` | 2 NOR2 + 1 INV | 10 |
| `Majority` | 3 NAND2 | 12 |
| `Z<1>` | 1 `AND2` cell = NAND2 + INV | 6 |
| `Z<0>` | 2 NOR2 + 1 NAND2 + 1 INV | 14 |
| **Optimized Neuron** | | **112** |

| | Neuron | Optimized Neuron |
|---|:-:|:-:|
| Logic after the multipliers | 140 (2bit_adder 54 + 3bit_adder 74 + MUX3_RELU 12) | 72 |
| Total | 180 | **112** (-68, about 38% fewer) |

Sharing the `OR` net between the NORSign and Majority blocks (instead of building NOR2 -> INV twice) saves 6 transistors (78 -> 72 after the multipliers).

### Notes

- Inputs: the same 2-bit encoding as before (`11` = -1, `00` = 0, `01` = +1). The logic depends on `10` never appearing.
- No ripple carry chain through two adders. The sign bits (`P<1>`, the latest multiplier outputs) go through about 5 gate levels to `Z<0>`. Delay still needs to be simulated.
- Slide 14 lists adders and a MUX as the example blocks ("you don't have to follow"), so mention in the report that the ReLU is folded into the output logic.
- [ ] Symbol
- [ ] Testbench: all 243 input combinations (or the 27 product/bias cases) against the truth table
- [ ] Beta check: every gate is a library cell (`NAND2`, `NOR2`, `INV_fin_larger`, `AND2`, `Full_adder`), confirm each is at beta 1.5
- [ ] **Majority as an AOI22 complex gate** (saves 6 T: 72 -> 66 after the multipliers, 112 -> 106 total). Logic checked against all 243 rows.
  - New `AOI22` cell: `Y = (A·B + C·D)'`. Pull-down: (A-B series) parallel (C-D series). Pull-up: (A || B) in series with (C || D). Both 2 deep, so beta 1.5 = NMOS 4 fins, PMOS 6 fins.
  - `Majority_n = AOI22(P0<1>, P1<1>, W20<1>, OR)`, replaces the 3 NAND2 in the Majority box (12 T -> 8 T). Put `OR` (latest input) on the transistor next to Y in its branch.
  - Z<0> box: delete NOR2(Tn, Majority) -> NAND2(·, S) -> INV and use `W = NAND2(Majority_n, S)`, `Z<0> = NOR2(W, Tn)` (14 T -> 12 T). `Tn = NOR2(NORSign, C)` stays.
  - After the change, update the tables above (Majority 8, Z<0> 12, total 106) and the schematic image.
