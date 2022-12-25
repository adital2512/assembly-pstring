    .section .rodata
print_pstrlen:      .string "first pstring length: %d, second pstring length: %d\n"
print_pstr:         .string "length: %d, string: %s\n"
print_replace_char: .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
print_cmpres:       .string "compare result: %d\n"
scan_chars:         .string "%s %s"
scan_int:           .string "%d"
    .align 8
.jmpTable: #jump table
    .quad .pstrlenLable
    .quad .replacecharLable
    .quad .replacecharLable
    .quad .nothingLable
    .quad .pstrijcpyLable
    .quad .swapcaseLable
    .quad .pstrijcmpLable


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

    subq $30, %rdi
    # choice is within range, jump to label in jump table
    jmp *.jmpTable(, %rdi, 8)


pstrijcmpLable:
    pushq %r8
    pushq %r9
    #save pstrings
    pushq %rdx
    pushq %rsi

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
    #making r8 = 0
    movq $0, %r8
    movq (%rsp), %r8

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
    #making r9 = 0
    movq $0, %r9
    movq (%rsp), %r9

    #restore the address of rsp after acanf
    leaq 16(%rsp), %rsp

    #calling function with 4 arguments
    #1. rdi = address of first pstring
    popq %rdi
    #2. rsi = address of second pstring
    popq %rsi
    #3. rdx = i
    movq %r8, %rdx
    #4. rcx = j
    movq %r9, %rcx
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
    popq %r9
    popq %r8
    jmp .finish


.swapcaseLable:
    pushq %r8
    #save pstrings
    pushq %rdx
    pushq %rsi


    #calling swapcase with 1 argument - rdi = address of pstr1
    movq %rsi, %rdi
    movq $0, %rax
    call swapcase

    #get length of pstr 1
    popq %rdi
    movq %rdi, %r8 #tmp
    movq $0, %rax
    call pstrlen


    #print pstr1
    movq $print_pstr, %rdi
    leaq 1(%r8), %rsi
    movq %rax, %rdx
    movq $0, %rax
    call printf


    #calling swapcase with 1 argument - rdi = address of pstr2
    popq %rdi
    movq %rdi, %r8 #tmp
    movq $0, %rax
    call swapcase

    #get length
    movq %r8, %rdi
    movq $0, %rax
    call pstrlen

    #print pstr2
    movq $print_pstr, %rdi
    leaq 1(%r8), %rsi
    movq %rax, %rdx
    movq $0, %rax
    call printf
    #restore
    popq %r8

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
    pushq %r8
    pushq %r9
    pushq %r10

    #save the pstrings (we want to access the first before the second)
    pushq %rdx
    pushq %rsi

    # make place to the chars
    leaq    -16(%rsp), %rsp
    #make rax 0 before calling function
    movq $0, %rax
    #move the format to the first argument
    movq    $scan_chars, %rdi
    #make the second argument contain the address we want to save the chars in
    movq    %rsp, %rsi
    #call scanf - scan according to the format into the pointed address by rsi
    call    scanf
    #make r9 and r8 to be 0
    movq $0, %r9
    movq $0, %r8

    #save the first char (the old char) in r8
    movb (%rsp), %r8b
    #save the second char (the new char) in r9
    #one byte from the pointed address
    mov 1(%rsp), %r9b

    #let rsp ignore this 16 bytes and restore last address
    leaq 16(%rsp), %rsp


    #at this point, oldchar is in r8, and newchar is in r9
    #now we want to call the replacechar function, with 3 arguments
    #1. rdi = the address of the first pstring
    popq %rdi
    #2. rsi = old char
    movq $0, %rsi
    movb %r8b, %sil
    #3. rdx = new char
    movq $0, %rdx
    movb %r9b, %dl
    #make rax = 0 before calling function
    movq $0, %rax
    #calling the replace char function
    call replaceChar

    #at this point rax = the address to the first pstring after the replacement
    #save it in r10 register
    movq %rax, %r10
    #now we want to call replaceChar for the second pstring
    #1. rdi  = the address of the second pstring
    popq %rdi
    #2. rsi = the old char
    movq %r8, %rsi
    #3. rdx = new char
    movq %r9, %rdx
    #make rax = 0 before calling a function
    movq $0, %rax
    #call replace char with the second pstring
    call replaceChar

    #at this point,rax has the address of the second pstring after the replacement
    #now we want to call printf with 5 argument
    #1. rdi = the printing format
    movq $print_replace_char, %rdi
    #2. rsi = the old char
    movq %r8, %rsi
    #3. rdx = the new char
    movq %r9, %rdx
    #4. rcx = the new string's address (first pstring)
    movq %r10, %rcx
    #5. r8 = the new string's address (second pstring)
    movq %rax, %r8
    #calling printf with 5 args
    call printf

    #restoring the registers
    popq %r10
    popq %r9
    popq %r8

    #goto .finish code
    jmp .finish


.pstrijcpyLable:
     #save registers
     pushq %r8
     pushq %r9
     pushq %r10

     #save the pstrings (we want to access the first before the second)
     pushq %rdx
     pushq %rsi

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
    #making r8 = 0
    movq $0, %r8
    movq (%rsp), %r8

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
    #making r9 = 0
    movq $0, %r9
    movq (%rsp), %r9


    #restore the address of rsp after acanf
    leaq 16(%rsp), %rsp

    #at this point r8 is i, r9 is j
    #we want to call pstrijcpy with 4 arguments
    #1. rdi = the address of the first pstring
    popq %rdi
    #2. rsi = the address of the second pstring
    popq %rsi
    #3. rdx = i
    movq %r8, %rdx
    #4. rcx = j
    movq %r9, %rcx
    #save the pstrings addresses before calling the function
    movq %rdi, %r8
    movq %rsi, %r9
    #calling pstrijcpy withe 2 pstrings, i, j
    call pstrijcpy



    #at this point, rax is the adress of
    #the second pstring after the replacement
    #now we want to print the values of every pstring
    #with 3 arguments: (r8 and r9 are the addresses of pstr1 and pstr2)

    #first we want to call pstrlen to have the length of pstr1
    #with one argument - rdi = the address of pstr1
    movq %r8, %rdi
    #making rax = 0 before calling function
    movq $0, %rax
    call pstrlen

    #arguments for the printf (rax is the length of pstr1)
    #1. rdi = the printing format
    movq $print_pstr, %rdi
    #2. rsi = the address of the string in the pstring
    leaq 1(%r8), %rsi
    #3. rdx = the length of the string
    movq %rax, %rdx
    #making rax = 0 before calling function
    movq $0, %rax
    #calling printf with 3 args
    call printf

    #now we want to call printf for the second pstring
    #get the length of pstr2
    movq %r9, %rdi
    movq $0, %rax
    call pstrlen

    #argument for the printf
    movq $print_pstr, %rdi
    leaq 1(%r9), %rsi
    movq %rax, %rdx
    call printf

    popq %r10
    popq %r9
    popq %r8
    jmp .finish

.finish:
    #get the pointers to the stack back
    movq %rbp, %rsp
    popq %rbp
    #return from this function
    ret





    
