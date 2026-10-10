# Input:  x10 = Dividend (a), x11 = Divisor (b)
# Output: x10 = Quotient c = (a / b), x11 = Remainder d = (a % b)
div_mod:
    add x6, x0, x0 # c = x6
    add x7, x0, x10 # d = x7

    div_loop:
        slt x8, x7, x11     # is d < b ?
        beq x8, x0, div_sub
        jal x0, div_done

        div_sub:
            sub x7, x7, x11     # d -= b
            addi x6, x6, 1      # c++
            jal x0, div_loop
        
        div_done:
            add x10, x0, x6     # move c in x10
            add x11, x0, x7     # move d in x11
            jalr x0, 0(x1)      # return


# Input:  x10 = a, x11 = b
# Output: x10 = c = a*b
mult:
    add x6, x0, x0  # x6 = c
    
    mult_loop:
        beq x11, x0, mult_done  # if b == 0 -> done
        add x6, x6, x10     # c += a
        addi x11, x11, -1   # b -= 1
        jal x0, mult_loop
        
    mult_done:
        add x10, x0, x6     # move c into x10
        jalr x0, 0(x1)      # return