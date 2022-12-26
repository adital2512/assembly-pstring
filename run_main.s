.section .rodata
scan_int:    .string "%d"
scan_str:    .string "%s"

.text
.globl run_main
.type run_main, @function
run_main:
    pushq %rbp
    movq %rsp, %rbp
    pushq %r9
    pushq %r8
    pushq %r10
    pushq $0x41
    #calling scanf with 2 arguments
    #1. rdi = the scanf format
    movq $scan_int, %rdi
    #2. rsi = the address we scan into
    subq $256, %rsp #allocating 255 bytes for the string + 1 more for the len
    movq %rsp, %rsi
    #make rax = 0 before calling function
    movq $0, %rax
    call scanf
    movq $0, %r10
    movb (%rsp), %r10b #save the length of pstr1

    #at this point, rsp is pointing to the len
    #we need to save the string 1 byte after the len
    #move the address of the string (to be) to rsi (second argument)
    leaq 1(%rsp), %rsi
    #move the scanf format to the first argument
    movq $scan_str, %rdi
    #make rax = 0 before calling function
    movq $0, %rax
    call scanf
    #save the address of the first pstring in r9
    mov %rsp, %r9
    #puting \0 at the end of the string
    subq %r10, %rsp
    movb $0, (%rsp)
    addq %r10, %rsp
    addq $2, %rsp

    #getting the second pstring
    #scanf the len with 2 arguments
    #1. rdi = scanf format
    movq $scan_int, %rdi
    #make space for new pstring
    subq $256, %rsp
    #2. rsi = the address to save the data
    movq %rsp, %rsi
    #make rax = 0 before calling function
    pushq $0x41
    call scanf
    movq $0, %r10
    movb (%rsp), %r10b #save the length of pstr1

    #at this point, rsp is pointing to the len
    #we need to save the string 1 byte after the len
    #move the address of the string (to be) to rsi (second argument)
    leaq 1(%rsp), %rsi
    #move the scanf format to the first argument
    movq $scan_str, %rdi
    #make rax = 0 before calling function
    movq $0, %rax
    call scanf
    #save the address of the second pstring in r8
    mov %rsp, %r8

    #puting \0 at the end of the string
    subq %r10, %rsp
    movb $0, (%rsp)
    addq %r10, %rsp


    #getting the option from the table
    #make space for the scanf
    subq $16, %rsp
    #calling scanf with 2 arguments
    #1. rdi = the scanf format
    movq $scan_int, %rdi
    #2. rsi = the address we want to scan into
    movq %rsp, %rsi
    #make rax = 0 before calling function
    call scanf
    #save the choise in register
    movq $0, %rdi
    movb (%rsp), %dil

    #calling the run_func function with 3 arguments
    #1. rdi = the choise from the table (already is)
    #2. rsi = the address of the first pstring
    movq %r9, %rsi
    #3. rdx = the address of the second pstring
    movq %r8, %rdx
    call run_func

    popq %r8
    popq %r9

    movq %rbp, %rsp
    popq %rbp
    ret
