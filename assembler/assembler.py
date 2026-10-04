import sys

instructions = {
    'add':  ('R',   '0110011',    '000',     '0000000'),
    'sub':  ('R',   '0110011',    '000',     '0100000'),
    'and':  ('R',   '0110011',    '111',     '0000000'),
    'or':   ('R',   '0110011',    '110',     '0000000'),
    'slt':  ('R',   '0110011',    '010',     '0000000'),
    'addi': ('I',   '0010011',    '000',     None),
    'lw':   ('I',   '0000011',    '010',     None),
    'jalr': ('I',   '1100111',    '000',     None),
    'sw':   ('S',   '0100011',    '010',     None),
    'beq':  ('B',   '1100011',    '000',     None),
    'jal':  ('J',   '1101111',    None,      None)
}

def to_bin(val, bits):
    mask = (1<<bits) - 1
    unsigned_val = val & mask
    return f"{unsigned_val:0{bits}b}"

def parse_reg(r):
    num = int(r.replace('x', ''))
    return f"{num:05b}"

def assemble(input_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    pc = 0
    labels = {}
    clean_lines = []

    for line in lines:
        line = line.split('#')[0]
        line = line.split('//')[0]
        line = line.strip()

        if not line:
            continue
        
        if ':' in line:
            label, line = line.split(':', 1)
            label = label.strip()
            labels[label] = pc
        
        if line:
            clean_lines.append((pc, line))
            pc += 4

    hex_output = []
    for pc, line in clean_lines:
        for char in ',()':
            line = line.replace(char, ' ')
        parts = line.split()

        inst = parts[0]
        inst_type, opcode, funct3, funct7 = instructions[inst]

        if inst_type == 'R':
            rd = parse_reg(parts[1])
            rs1 = parse_reg(parts[2])
            rs2 = parse_reg(parts[3])
            binary = funct7 + rs2 + rs1 + funct3 + rd + opcode

        elif inst_type == 'S':
            rs2 = parse_reg(parts[1])
            imm = to_bin(int(parts[2]), 12)
            rs1 = parse_reg(parts[3])
            binary = imm[0:7] + rs2 + rs1 + funct3 + imm[7:12] + opcode

        elif inst_type == 'B':
            rs1 = parse_reg(parts[1])
            rs2 = parse_reg(parts[2])
            offset = labels[parts[3]] - pc
            imm = to_bin(offset, 13)
            binary = imm[0] + imm[2:8] + rs2 + rs1 + funct3 + imm[8:12] + imm[1] + opcode

        elif inst_type == 'J':
            rd = parse_reg(parts[1])
            offset = labels[parts[2]] - pc
            imm = to_bin(offset, 21)
            binary = imm[0] + imm[10:20] + imm[9] + imm[1:9] + rd + opcode

        elif inst_type == 'I':
            if inst == 'lw' or inst == 'jalr':
                rd = parse_reg(parts[1])
                imm = to_bin(int(parts[2]), 12)
                rs1 = parse_reg(parts[3])
            else:    # addi rd, rs1, imm
                rd = parse_reg(parts[1])
                rs1 = parse_reg(parts[2])
                imm = to_bin(int(parts[3]), 12)
            binary = imm + rs1 + funct3 + rd + opcode

        binary = int(binary, 2)
        hex_output.append(f"{binary:08x}")
    
    siz = 1024
    while len(hex_output) < siz:
        hex_output.append("00000000")

    with open('main.txt', 'w') as f:
        f.write("\n".join(hex_output) + "\n")

    print(f"successfully assembled {len(clean_lines)} instructions into main.txt")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: python3 assembler.py input.s")
    else:
        assemble(sys.argv[1])