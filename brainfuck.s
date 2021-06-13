.global brainfuck                                                       # declare brainfuck to be global

format_char:    .asciz "%c"                                             # reserve space for character
format_str:     .asciz "We should be executing the following code:\n%s" # initialise the first format string
format_str2:    .asciz "Interpreted code:\n"                            # initialise the second format string

brainfuck:                                                              # start of brainfuck subroutine
    pushq   %rbp                                                        # store the caller's basepointer
    movq    %rsp, %rbp                                                  # initialise the base pointer    

    movq    %rdi, %r15                                                  # character is stored in %rdi so we move it to %r15
    # decq   %r15                                                       # decrementing the pointer 

    movq    %rdi, %rsi                                                  # move first parameter to %rsi so it can be printed as string
    movq    $format_str, %rdi                                           # move format_str to %rdi
    movq    $0, %rax                                                    # clear the %rax register
    # xor    %rax, %rax                                                 # optimise the script by xor the register instead of moving %0 into %rax
    call    printf                                                      # call the printf function    

    movq    $format_str2, %rdi                                          # use format_str2
    movq    $0, %rax                                                    # clear the %rax register
    # xor    %rax, %rax                                                 # optimise the script by xor the register instead of moving %0 into %rax
    call    printf                                                      # call the printf function

    movq    $30000, %rdi         # Creating new cells in %rdi to store the characters
    movq    $1, %rsi             # The size of each cell is 1 byte (8bit) 
    call    calloc               # Calling the C function (we need the two lines above for this function)
                                 # returns a pointer to allocated memory of the instructions

    movq    %rax, %r14           # move the returned pointer pointing to the allocated memory to %r14
    movq    $0, %r13             # clear %r13
    # xor   %r13, %r13           # optimise the script by xor the register instead of moving $0 into %r13

switch:                          # start of the switch subroutine
    # incq    %r15               # increment pointer to point to the first cell
    movb    (%r15), %al          # move the value to al to check which ASCII character we have

    cmpb    $62, %al             # > 
    je      incrptr              # increment pointer   

    cmpb    $60, %al             # < 
    je      decptr               # decrement pointer

    cmpb    $43, %al             # +
    je      incrdata             # increment cell

    cmpb    $45, %al             # -
    je      decdata              # decrement cell

    cmpb    $46, %al             # . 
    je      print                # print cell

    cmpb    $44, %al             # ,
    je      input                # input cell

    cmpb    $91, %al             # [ 
    je      startloop            # start loop

    cmpb    $93, %al             # ]
    je      endloop              # end loop

    cmpb    $0, %al              # 0
    je      endroutine           # end of the routine

    jmp     switch               # jump to the beginning of the switch

    incrptr:                     # increment the pointer
    inc     %r14                 # Increment the pointer %r14
    jmp     switch               # jump to the beginning of the switch
  
    decptr:                      # decrement the pointer
    dec     %r14                 # Decrement the pointer %r14
    jmp     switch               # jump to beginning of the switch

    incrdata:                    # increment the cell
    incb    (%r14)               # increment the data in %r14
    jmp     switch               # jump to beginning of the switch

    decdata:                     # decrement the cell
    decb    (%r14)               # increment the value in %r14 
    jmp     switch               # jump to beginning of the switch

    print:                       # print character
    movq    (%r14), %rsi         # move the data in %r14 to %rsi
    movq    $format_char, %rdi   # move format_char to %rdi
    movq    $0, %rax             # clear %rax
    # xor   %rax, %rax           # optimise the script by xor the register instead of moving $0 into %rax
    call    printf               # prints all of characters

    jmp     switch               # jump to beginning of the switch

    input:                       # input cell
    movq    %r14, %rsi           # move %r14 to %rsi
    movq    $format_char, %rdi   # move format_char to %rdi
    movq    $0, %rax             # clear rax
    # xor   %rax, %rax           # optimise the script by xor the register instead of moving $0 into %rax
    call    scanf                # call scanf for language C
  
    jmp     switch               # jump to beginning of the switch

    startloop:
    cmpb    $0, (%r14)           # compare the current character to 0
    je      innerloop            # jump to innerloop

    pushq   %r15                 # push %r15 to the stack
    jmp     switch               # jump to beginning of the switch

    innerloop:
    incq    %r15                # increment %r15
    movb    (%r15), %al         # copy the data from %r15 to %al

    cmpb    $91, %al    
    je      numofinnerloopsstart   # jump to numofinnerloopsstart
    
    cmpb    $93, %al                
    je      numofinnerloopsend      # jump to jump to numofinnerloopsstart

    jmp     innerloop               # jump to innerloop

    numofinnerloopsstart:
    incq    %r13                    # Add 1 to the counter to move it to the next cell
    jmp     innerloop               # jump to innerloop

    numofinnerloopsend:
    cmpq    $0, %r13                # compare 0 to %r13
    je      switch                  # jump to beginning of the switch
    decq    %r13                    # decrement %r13
    jmp     innerloop               # jump to innerloop

    endloop:
    popq    %r15                    # pop %15 from stack
    decq    %r15                    # decrement %r15
    jmp     switch                  # jump to beginning of the switch

    endroutine:                     
    movq    %rbp, %rsp              # epilogue: clear local variables from stack
    popq    %rbp                    # restore caller’s base pointer
    ret                             # return from brainfuck subroutine


