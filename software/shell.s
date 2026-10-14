# x20 = cursor offset (0-2399)
# x21 = scratch for key constants
# x22 = last key pressed

shell_init:
    jal  x1, clear_screen
    addi x20, x0, 0                 # cursor = 0

    shell_loop:
        addi x10, x0, 95            # '_'
        add  x11, x0, x20
        jal  x1, write_char         # draw cursor
        jal  x1, get_char
        add  x22, x0, x10           # x22 = key

        addi x21, x0, 13            # Enter
        beq  x22, x21, shell_enter
        addi x21, x0, 8             # Backspace
        beq  x22, x21, shell_backspace

        add  x10, x0, x22
        add  x11, x0, x20
        jal  x1, write_char         # print char over the cursor
        addi x20, x20, 1            # cursor++
        jal  x0, shell_check

    shell_backspace:
        beq  x20, x0, shell_loop    # already at 0 -> ignore
        addi x10, x0, 32
        add  x11, x0, x20
        jal  x1, write_char         # erase cursor
        addi x20, x20, -1           # cursor-- ('_' gets drawn over the deleted char)
        jal  x0, shell_loop

    shell_enter:
        addi x10, x0, 32
        add  x11, x0, x20
        jal  x1, write_char         # erase cursor
        add  x10, x0, x20
        addi x11, x0, 80
        jal  x1, div_mod            # row = cursor / 80
        addi x11, x10, 1
        addi x10, x0, 80
        jal  x1, mult               # cursor = 80 * (row + 1)
        add  x20, x0, x10

    shell_check:
        add  x10, x0, x20
        jal  x1, check_bouds
        beq  x10, x0, shell_init
        jal  x0, shell_loop