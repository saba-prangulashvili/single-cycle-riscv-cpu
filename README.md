# Single-Cycle RISC-V Computer

A small computer built from scratch on a Terasic **DE10-Lite** (Intel/Altera MAX 10 `10M50DAF484C7G`). It includes:

- a **single-cycle RV32I-subset CPU** written in SystemVerilog
- an **80×30 VGA text display** (640×480 @ 60 Hz, 8×16 font)
- a **PS/2 keyboard** interface with scancode-to-ASCII translation
- a **Python assembler** for the supported instruction subset
- **RISC-V assembly software**: startup code, display/keyboard/math routines and a simple interactive text shell

On reset the board clears the screen and shows a `_` cursor. You can type on a PS/2 keyboard, delete with Backspace and start a new line with Enter.

---

## Repository layout

```
HDL/
  top.sv              Top level: CPU, memories, memory decoder, keyboard, display
  imem.sv             Instruction ROM, 1024 words, loaded from main.txt
  dmem.sv             Data RAM, 64 words (256 bytes)
  mem_decoder.sv      Address decoding for RAM / keyboard / display
  cpu/                CPU: cpu, datapath, maindec, aludec, alu, regfile, extendImm, flopr, mux
  display/            VGA timing, text renderer, character RAM, font ROM
  keyboard/           PS/2 receiver (ps2rx) and scancode → ASCII decoder
assembler/
  assembler.py        Two-pass assembler → hex image
  assemble.sh         Builds software/*.s into quartus_scc/main.txt
software/
  start.s             Entry point: sets up sp and MMIO base registers, jumps to shell
  shell.s             Interactive text shell (cursor, Backspace, Enter, wrap)
  display.s           Screen output routines
  keyboard.s          Keyboard input routine
  math.s              Software multiply and divide
quartus_scc/
  scc.qpf / scc.qsf   Quartus project and pin assignments
  main.txt            Assembled program (instruction ROM init)
  fontMem.mem         8×16 bitmap font, 128 ASCII glyphs
  output_files/       Prebuilt scc.sof (JTAG) and scc.pof (flash)
instruction_formats.numbers   Instruction encoding reference (Apple Numbers)
```

---

## Hardware

### CPU

This is a classic single-cycle design: every instruction is fetched, decoded, executed and written back in one clock cycle. It uses a Harvard layout, with separate instruction and data memories.

- **Datapath** (`cpu/datapath.sv`): 32×32-bit register file (`x0` hard-wired to zero), immediate extender (I/S/B/J formats), ALU, and PC logic choosing between `PC+4`, `PC+imm` (branch/`jal`) and `rs1+imm` (`jalr`).
- **Control** (`cpu/maindec.sv`, `cpu/aludec.sv`): decodes the opcode into register write, ALU source, memory read/write, result select, branch and jump signals.
- **ALU** (`cpu/alu.sv`): add, sub, and, or, signed set-less-than, plus a zero flag for `beq`.

**Supported instructions**

| Type | Instructions |
|------|--------------|
| R    | `add`, `sub`, `and`, `or`, `slt` |
| I    | `addi`, `lw`, `jalr` (hardware also decodes `slti`, `ori`, `andi`; the assembler does not emit them yet) |
| S    | `sw` |
| B    | `beq` |
| J    | `jal` |

### Memory map

All data accesses go through `mem_decoder.sv`, using the ALU result as the address.

| Address (bytes) | Read | Write |
|-----------------|------|-------|
| `0 – 255`       | Data RAM (64 words) | Data RAM |
| `244`           | Keyboard data: ASCII code of last key; reading clears "ready" | (RAM) |
| `248`           | Keyboard status: `1` when a key is waiting | (RAM) |
| `256 – 2655`    | reads return `0` | Screen character cell `addr − 256` (low byte of `sw` data) |

The screen is byte-addressed per character: cell `n` (row `n / 80`, column `n % 80`) is at address `256 + n`. Instruction memory is separate: 1024 words (4 KB) starting at PC `0`.

### VGA text display

- 640×480 @ 60 Hz timing generated from the 50 MHz clock (25 MHz pixel enable)
- 80 columns × 30 rows, 8×16 glyphs from `fontMem.mem` (7-bit ASCII)
- Monochrome, white on black, 4-bit-per-channel VGA DAC on the DE10-Lite
- The character RAM initialises to spaces

### PS/2 keyboard

- `ps2rx.sv` samples PS/2 clock falling edges and shifts in 11-bit frames.
- `keyboard.sv` maps make codes to ASCII, ignoring break (`F0`) sequences:
  - letters (returned as **uppercase**), digits, `` ` - = \ [ ] ; ' , . / `` and Space
  - Enter → `0x0D`, Backspace → `0x08`, Esc → `0x1B`, Tab → `0x09`
  - anything else → `?`

### Board I/O (from `scc.qsf`)

| Signal | Pin | DE10-Lite resource |
|--------|-----|--------------------|
| `clk` | `P11` | 50 MHz oscillator |
| `KEY[0]` | `B8` | Push-button, **reset** (active low) |
| `KEY[1]` | `A7` | Assigned, currently unused |
| `VGA_R/G/B[3:0]`, `VGA_HS`, `VGA_VS` | on-board VGA | VGA connector |
| `ps2c`, `ps2d` | `V10`, `W10` | GPIO header (the DE10-Lite has no PS/2 jack, so an external PS/2 connector is wired here) |

---

## Software

**Shell** (`shell.s`): clears the screen, draws a `_` cursor and echoes typed characters. Backspace moves back one cell. Enter moves to the start of the next row. When the cursor runs past the last cell, the screen clears and the shell starts over. Typed lines are not parsed or run as commands yet.

---

## Building

### Requirements

- Intel Quartus Prime Lite (the project was last built with **25.1std**) with MAX 10 device support
- Python 3 and a POSIX shell (bash) for the assembler script
- DE10-Lite board, USB-Blaster driver, VGA monitor, PS/2 keyboard

### 1. Assemble the software

```bash
./assembler/assemble.sh
```

This concatenates `software/start.s` first, followed by every other `software/*.s` file in alphabetical order. It assembles the result and writes a 1024-line hex image to `quartus_scc/main.txt`.

To assemble a single file by hand:

```bash
cd assembler
python3 assembler.py program.s     # writes main.txt in the current directory
```

### 2. Compile the FPGA image

`imem.sv` loads `main.txt` with `$readmemh` **at synthesis time**, so you need to recompile in Quartus every time the software changes.

1. Open `quartus_scc/scc.qpf` in Quartus Prime.
2. Run **Processing → Start Compilation**.
3. The outputs are written to `quartus_scc/output_files/`: `scc.sof` (JTAG) and `scc.pof` (flash).

---

## Resource usage

These figures come from the most recent build of `quartus_scc/output_files/` on a 10M50DAF484C7G:

| Resource | Used |
|----------|------|
| Logic elements | 29,829 / 49,760 (60%) |
| Registers | 19,982 |
| Embedded memory bits | 0 |
| Pins | 19 / 360 |
