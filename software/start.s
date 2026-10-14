# x1 = ra
addi x2, x0, 244    # x2 = sp
addi x3, x0, 256    # x3 = VGA RAM Base Address
addi x4, x0, 248    # x4 = Keyboard Status Address
addi x5, x0, 244    # x5 = Keyboard Data Address

jal x0, shell_init