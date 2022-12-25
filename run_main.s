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

    #calling scanf with 2 arguments
    #1. rdi = the scanf format
    movq $scan_int, %rdi
    #2. rsi = the address we scan into
    subq $256, %rsp #allocating 255 bytes for the string + 1 more for the len
    movq %rsp, %rsi
    #make rax = 0 before calling function
    movq $0, %rax
    call scanf

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

    #getting the second pstring
    #scanf the len with 2 arguments
    #1. rdi = scanf format
    movq $scan_int, %rdi
    #make space for new pstring
    subq $256, %rsp
    #2. rsi = the address to save the data
    movq %rsp, %rsi
    #make rax = 0 before calling function
    call scanf

    #at this point, rsp is pointing to the len
    #we need to save the string 1 byte after the len
    #move the address of the string (to be) to rsi (second argument)
    leaq 1(%rsp), %rsi
    #move the scanf format to the first argument
    movq $scan_str, %rdi
    #make rax = 0 before calling function
    movq $0, %rax
    call scanf
    #save the address of the first pstring in r8
    mov %rsp, %r8


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
