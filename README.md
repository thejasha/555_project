# 555_project

Cadence library: `ECE555`

Blocks needed: multiplier, 2-bit adder, 3-bit adder, 3-bit 2-to-1 MUX

## Progress

**XNOR** (`XNOR`)
- [x] Schematic
- [x] Symbol
- [x] Tested (correct output)
- [ ] Beta matching (NMOS/PMOS sizing)

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

## Optimization approach

My goal was to use **as few transistors as possible**. Later we can decide whether to trade some transistors for fewer gates or a shorter critical path.

Example: the `XNOR` / `XNOR_Z` gates are built around a `NAND2`. `XNOR_Z` also brings that internal NAND output out as `Z`, so the adders can reuse it instead of adding another gate.

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

Guidelines:

1. Use the same layout in every cell so anyone opening it knows where to look.
2. Connect between boxes with wire labels instead of long wires. Double-check label spelling, because a typo creates a floating net. Run Check and Save to catch it.
3. The boxes are only drawings. They don't group anything electrically or change the netlist.
4. Write design notes in the boxes (critical path, beta ratios, why a gate is reused).

TODOs are tracked in the GitHub issues.
