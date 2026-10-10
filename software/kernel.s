# x1 = ra
addi x3, x0, 256         # x3 = VGA RAM Base Address
addi x4, x0, 244         # x4 = Keyboard Data Address
addi x5, x0, 248         # x5 = Keyboard Status Address

jal x0, shell_init