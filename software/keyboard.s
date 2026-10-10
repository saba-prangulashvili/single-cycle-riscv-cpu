# output x10 = ASCII key code
get_char:
    lw x6 0(x4)             # read keyboard status register(adr 248) into x6
    beq x6, x0, get_char    # loop until key ready
    lw x10 0(x5)            # read ascii code into x10
    jalr x0, 0(x1)          # return