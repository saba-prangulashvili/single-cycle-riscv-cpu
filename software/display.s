# input x10 = ASCII code of char
# input x11 = screen memory offset (0-2399)
write_char:
    add x6, x3, x11     # x6 = base(x3) + offest(x11)
    sw x10 0(x6)        # store char
    jalr x0 0(x1)       # return


clear_screen:
    addi x2, x2, -4
    sw x1 0(x2)     # push ra

    addi x10, x0, 32        # ascii space (' ')
    addi x11, x0, 0         # offset counter
    addi x7, x0, 1200
    addi x7, x7, 1200       # max offset

    clear_loop:
        beq x11, x7, clear_done
        jal x1, write_char
        addi x11, x11, 1        # offset++
        jal x0, clear_loop

        clear_done:
            lw x1 0(x2)     # pop ra
            addi x2, x2, 4
            jalr x0, 0(x1)
