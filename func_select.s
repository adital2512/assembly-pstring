    .section .rodata
print_pstrlen:      .string "first pstring length: %d, second pstring length: %d\n"
print_pstr:         .string "length: %d, string: %s\n"
print_replace_char: .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
print_cmpres:       .string "compare result: %d\n"
print_invalid:      .string "invalid option!\n"
scan_chars:         .string "%s %s"
scan_int:           .string "%d"

    .section .text
    .global      run_func
    .type        run_func, @function

run_func:
    #at this point the arguments are:
    #1. rdi - the choise from the jump table
    #2. rsi - the first pstring address
    #3. rdx - the second pstring address

    # save the pointers
    pushq   %rbp
    movq    %rsp, %rbp


    # check if choice is less than 31
    cmp $31, %rdi
    jl .nothingLable

    # check if choice is greater than 37
    cmp $37, %rdi
    jg .nothingLable

    subq $31, %rdi
    # choice is within range, jump to label in jump table
    jmp *.jmpTable(, %rdi, 8)

    .align 8
.jmpTable: #jump table
    .quad .pstrlenLable #31
    .quad .replacecharLable #32
    .quad .replacecharLable #33
    .quad .nothingLable #34
    .quad .pstrijcpyLable #35
    .quad .swapcaseLable #36
    .quad .pstrijcmpLable #37

.pstrijcmpLable:
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    #save pstrings
    movq %rdx, %r13
    movq %rsi, %r12

    #scanf i
    #make place for scanf
    leaq -16(%rsp), %rsp
    #arguments for scanf:
    #1. rdi = the scanf format
    movq $scan_int, %rdi
    #2. rsi = the address to save the value
    movq %rsp, %rsi
    #make rax = 0 before calling function
    movq $0, %rax
    #calling scanf with the format and save in the address rsi
    call scanf

    #save the result in another register
    #making r14 = 0
    movq $0, %r14
    movb (%rsp), %r14b

    #scanf j
    #at this point rsp is pointing a 16 byte area we want to scan into
    #arguments for scanf:
    #1. rdi = the scanf format
    movq $scan_int, %rdi
    #2. rsi = the address we want to scan into
    leaq 1(%rsp), %rsi
    #make rax = 0
    movq $0, %rax
    #calling scanf with the format and save in the address rsi
    call scanf

    #save the result in another register
    #making r15 = 0
    movq $0, %r15
    incq %rsp
    movb (%rsp), %r15b
    decq %rsp

    #restore the address of rsp after acanf
    leaq 16(%rsp), %rsp

    #calling function with 4 arguments
    #1. rdi = address of first pstring
    movq %r12, %rdi
    #2. rsi = address of second pstring
    movq %r13, %rsi
    #3. rdx = i
    movq %r14, %rdx
    #4. rcx = j
    movq %r15, %rcx
    #make rax = 0 before calling function
    movq $0, %rax
    call pstrijcmp

    #at this point rax has the return value of the cmp

    #printing the result with 2 arguments
    #1. rdi = the printing format
    movq $print_cmpres, %rdi
    #2. rsi = the result of the function
    movq %rax, %rsi
    #make rax = 0
    movq $0, %rax
    call printf

    #restore
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    jmp .finish


.swapcaseLable:
    pushq %r12
    pushq %r13
    #save pstrings
    movq %rsi, %r12
    movq %rdx, %r13

    #calling swapcase with 1 argument - rdi = address of pstr1
    movq %r12, %rdi
    movq $0, %rax
    call swapcase

    #calling swapcase with 1 argument - rdi = address of pstr2
    movq %r13, %rdi
    movq $0, %rax
    call swapcase

    #get length of pstr 1
    movq %r12, %rdi
    movq $0, %rax
    call pstrlen

    #print pstr1
    movq $print_pstr, %rdi
    leaq 1(%r12), %rdx
    movq %rax, %rsi
    movq $0, %rax
    call printf


    #get length
    movq %r13, %rdi
    movq $0, %rax
    call pstrlen

    #print pstr1
    movq $print_pstr, %rdi
    leaq 1(%r13), %rdx
    movq %rax, %rsi
    movq $0, %rax
    call printf
    #restore
    popq %r13
    popq %r12

    jmp .finish


.pstrlenLable:
    #now we will call the pstrlen with the first pstring
    #we need to pass it with the first register - rdi
    #it is now in rsi
    movq %rsi, %rdi
    #caller save the second pstring's address before use
    pushq %rdx
    #make rax (the return value register) 0
    movq $0, %rax
    #call the pstrlen function with the first pstr
    call pstrlen
    #save the answer in another register
    movq %rax, %r10

    #get the address of the second pstr from the stack
    popq %rdi
    #make rax (the return value register) 0
    movq $0, %rax
    #call the pstrlen function with the second pstr
    call pstrlen
    #save the answer in another register
    movq %rax, %r11

    #now we want to call the printf function with 3 args:
    #1. a pointer to the correct porinting format
    movq $print_pstrlen, %rdi
    #2. the length of the first pstring
    movq %r10, %rsi
    #3. the length of the second pstring
    movq %r11, %rdx
    #make rax (the return value register) 0
    movq $0, %rax
    #calling printf function
    call printf
    #goto .finish code
    jmp .finish



.replacecharLable:
    #save registers
    pushq %r12
    pushq %r14
    pushq %r15
    pushq %r13

    #save the pstrings (we want to access the first before the second)
    pushq %rdx
    pushq %rsi

    #save rsp
    movq %rsp, %r13
    # make place to the first char
    leaq -16(%rsp), %rsp
    andq $-16, %rsp
    #make the second argument contain the address we want to save the chars in
    movq    %rsp, %rsi
    #make third argument cntain the address we want to save the second char
    leaq 1(%rsi), %rdx
    #make rax 0 before calling function
    movq $0, %rax
    #move the format to the first argument
    movq    $scan_chars, %rdi

    #call scanf - scan according to the format into the pointed address by rsi
    call  scanf
    #make r14 and r12 to be 0
    movq $0, %r14
    movq $0, %r12

    #save the first char (the old char) in r12
    movb (%rsp), %r12b
    #save the second char (the new char) in r14
    #one byte from the pointed address
    mov 1(%rsp), %r14b

    #restore rsp
    movq %r13, %rsp


    #at this point, oldchar is in r12, and newchar is in r14
    #now we want to call the replacechar function, with 3 arguments
    #1. rdi = the address of the first pstring
    popq %rdi
    #2. rsi = old char
    movq $0, %rsi
    movb %r12b, %sil
    #3. rdx = new char
    movq $0, %rdx
    movb %r14b, %dl
    #make rax = 0 before calling function
    movq $0, %rax
    #calling the replace char function
    call replaceChar

    #at this point rax = the address to the first pstring after the replacement
    #save it in r15 register (+1 skips the len)
    leaq 1(%rax), %r15
    #now we want to call replaceChar for the second pstring
    #1. rdi  = the address of the second pstring
    popq %rdi
    #2. rsi = the old char
    movq %r12, %rsi
    #3. rdx = new char
    movq %r14, %rdx
    #make rax = 0 before calling a function
    movq $0, %rax
    #call replace char with the second pstring
    call replaceChar

    #at this point,rax has the address of the second pstring after the replacement
    #now we want to call printf with 5 argument
    #1. rdi = the printing format
    movq $print_replace_char, %rdi
    #2. rsi = the old char
    movq %r12, %rsi
    #3. rdx = the new char
    movq %r14, %rdx
    #4. rcx = the new string's address (first pstring)
    movq %r15, %rcx
    #5. r8 = the new string's address (second pstring)
    leaq 1(%rax), %r8
    #calling printf with 5 args
    call printf

    #restoring the registers
    popq %r13
    popq %r15
    popq %r14
    popq %r12

    #goto .finish code
    jmp .finish


.pstrijcpyLable:
     #save registers
     pushq %r15
     pushq %r14
     pushq %r13

     #save the pstrings (we want to access the first before the second)
     pushq %rdx
     pushq %rsi

    #scanf i
    movq %rsp, %r13 #tmp
    #make place for scanf
    leaq -16(%rsp), %rsp
    andq $-16, %rsp
    #arguments for scanf:
    #1. rdi = the scanf format
    movq $scan_int, %rdi
    #2. rsi = the address to save the value
    movq %rsp, %rsi
    #make rax = 0 before calling function
    movq $0, %rax
    #calling scanf with the format and save in the address rsi
    call scanf

    #save the result in another register
    #making r15 = 0
    movq $0, %r15
    movb (%rsp), %r15b

    #scanf j
    #at this point rsp is pointing a 16 byte area we want to scan into
    #arguments for scanf:
    #1. rdi = the scanf format
    movq $scan_int, %rdi
    #2. rsi = the address we want to scan into
    movq %rsp, %rsi
    #make rax = 0
    movq $0, %rax
    #calling scanf with the format and save in the address rsi
    call scanf

    #save the result in another register
    #making r14 = 0
    movq $0, %r14
    movb (%rsp), %r14b


    #restore the address of rsp after acanf
    movq %r13, %rsp

    #at this point r15 is i, r14 is j
    #we want to call pstrijcpy with 4 arguments
    #2. rsi = the address of the second pstring
    popq %rsi
    #2. rdi = the address of the first pstring
    popq %rdi
    #3. rdx = i
    movq %r15, %rdx
    #4. rcx = j
    movq %r14, %rcx
    #save the pstrings addresses before calling the function
    movq %rdi, %r14
    movq %rsi, %r15
    #calling pstrijcpy withe 2 pstrings, i, j
    call pstrijcpy



    #at this point, rax is the adress of
    #the second pstring after the replacement
    #now we want to print the values of every pstring
    #with 3 arguments: (r15 and r14 are the addresses of pstr1 and pstr2)

    #first we want to call pstrlen to have the length of pstr1
    #with one argument - rdi = the address of pstr1
    movq %r15, %rdi
    #making rax = 0 before calling function
    movq $0, %rax
    call pstrlen

    #arguments for the printf (rax is the length of pstr1)
    #1. rdi = the printing format
    movq $print_pstr, %rdi
    #2. rsi = the length of the string
    movq %rax, %rsi
    #3. rdx = the address of the string in the pstring
    leaq 1(%r15), %rdx
    #making rax = 0 before calling function
    movq $0, %rax
    #calling printf with 3 args
    andq $-16, %rsp
    call printf

    #now we want to call printf for the second pstring
    #get the length of pstr2
    movq %r14, %rdi
    movq $0, %rax
    call pstrlen

    #argument for the printf
    movq $print_pstr, %rdi
    leaq 1(%r14), %rdx
    movq %rax, %rsi
    call printf

    popq %r13
    popq %r14
    popq %r15
    jmp .finish


.nothingLable:
    movq $print_invalid, %rdi
    movq $0, %rax
    call printf
    jmp .finish




.finish:
    #get the pointers to the stack back
    movq %rbp, %rsp
    popq %rbp
    #return from this function
    ret





    
