shell_init:
    jal  x1, clear_screen
    addi x20, x0, 0              # cursor = 0
    shell_loop:
        jal  x1, get_char           # x10 = key
        addi x21, x0, 13            # Enter
        beq  x10, x21, shell_enter
        add  x11, x0, x20
        jal  x1, write_char
        addi x20, x20, 1
        jal  x0, shell_check
        shell_enter:
            add  x10, x0, x20
            addi x11, x0, 80
            jal  x1, div_mod            # row = cursor / 80
            addi x11, x10, 1
            addi x10, x0, 80
            jal  x1, mult               # cursor = 80 * (row + 1)
            add  x20, x0, x10
        shell_check:
            add  x10, x0, x20
            jal  x1, check_bouds        # 1 if cursor < 2400
            beq  x10, x0, shell_init
            jal  x0, shell_loop