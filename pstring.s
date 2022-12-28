.section .rodata
print_error:        .string "invalid input!\n"
.text
.globl pstrlen
.type pstrlen, @function
# this function gets as an argument an address to the start of a memory of pstring
# in the first arg register (rdi) and return it's length value in the return value reg (rax)
pstrlen:
    pushq %rbp
    movq %rsp, %rbp
    #make rax = 0
    movq $0, %rax
    #move the char (1 byte) that represent the length
    #value of the pstring to the low byte of rax
    movb (%rdi), %al
#get the pointers to the stack back
    movq %rbp, %rsp
    popq %rbp
    #return from this function
    ret

#this function gets 3 arguments:
# 1. rdi = the address of the pstring
# 2. rsi = the old char
# 3. rdx = the new char
#the function replaces all instances of the old char with the new one
.globl replaceChar
.type replaceChar, @function
replaceChar:
    pushq %rbp
    movq %rsp, %rbp
    #save the registers before using

    #we want to get the length of the string by calling pstrlen
    #rdi is already the address of the pstring, just make rax = 0
    movq $0, %rax
    call pstrlen
    #now rax is the length of the string of this pstring

    #make r10 be a pointer to the string of the pstring (rdi + 1)
    movq %rdi, %r10
    #make r9 = 0
    movq $0, %r9

    #iterate through the bytes of the string
    .loop3:
        #look at the next byte
        incq %r10
        #let r9 be the first byte pointed by r10
        movb (%r10), %r9b
        #compare r9b with rsi (the old char)
        cmpb %r9b, %sil
        #if not equal, don't replace
        jne .skipReplacement
        #take the first byte of rdx (old char) and
        #move it to the address in r10 (the old char in the string)
        movb %dl, (%r10)
    .skipReplacement:
        #dec rax (was the length) by 1
        dec %rax
        #if rax isn't 0 goto .loop
        jne .loop3

    #at this point, the string is after the replacement
    #before returning, put the address of the pstring in rax
    movq %rdi, %rax
    #get the pointers to the stack back
    movq %rbp, %rsp
    popq %rbp
    #return from this function
    ret


.globl pstrijcpy
.type pstrijcpy, @function
#this function gets 4 arguments
#1. rdi = the address of the first pstring
#2. rsi = the address of the second pstring
#3. rdx = i
#4. rcx = j
#and copy pstr1[i:j] into pstr2[i:j]
pstrijcpy:
    pushq %rbp
    movq %rsp, %rbp
    movq %rsi, %r11
    movq %rdi, %r10
    #first we want to check that i and j are valid
    #it should be 0 <= i <= j <= len(str1) and j <= len(str2)

    #confirm that i >= 0
    cmpq $0, %rdx
    #if i < 0
    jl .error1

    #confirm that i <= j
    cmpq %rdx, %rcx
    #if j < i
    jl .error1

    #confirm that j < len(str1)
    #getting len(str1)
    movq $0, %rax
    call pstrlen
    #now rax = len(pstr1)
    cmpq %rcx, %rax
    jle .error1

    #confirm that j < len(str2)
    #getting len(str2)
    movq $0, %rax
    movq %rsi, %rdi
    call pstrlen
    #now rax = len(pstr2)
    cmpq %rcx, %rax
    jle .error1


    #at this point, i and j are valid, restore pstr1 and pstr2
    movq %r10, %rdi
    movq %r11, %rsi
    movq %rsi, %r8 #tmp
    #rdx = i
    #rcx = j


    #make rdi point to the i's byte in the first pstring's str
    #and rsi to the second's
    addq $1, %rdi
    addq $1, %rsi
    addq %rdx, %rdi
    addq %rdx, %rsi

    #make a counter
    subq %rdx, %rcx
    incq %rcx
    #when rcx == 0 it means we replaced all
    .loop1:
        movq $0, %r9
        movb (%rdi), %r9b
        movb %r9b, (%rsi)
        incq %rdi
        incq %rsi
        decq %rcx
        #confirm that counter >= 0
        cmpq $0, %rcx
        #if i > 0
        jg .loop1

    jmp .end1
    .error1:
        movq $print_error, %rdi
        movq $0, %rax
        movq %rsp, %r10
        andq $-16, %rsp
        call printf
        movq %r10, %rsp
    .end1:

    #now we replaced all chars, now we need to return values
    movq $0, %rax
    movq %r8, %rax
#get the pointers to the stack back
    movq %rbp, %rsp
    popq %rbp
    #return from this function
    ret


.globl swapcase
.type swapcase, @function
#this function gets one argument: rdi = address of pstring
#and swap every english letter to the oposite case
#and return the address after the replacement
swapcase:
    pushq %rbp
    movq %rsp, %rbp
    #save the address
    movq %rdi, %r10

    #get the length of pstr
    movq $0, %rax
    call pstrlen
    #now rax is the length of the string
    #when will be 0, end the loop


    movq %r10, %r8
    movq %r8, %rdi
    .loop2:
        #if rax = 0, string ended
        cmpq $0, %rax
        je .endloop

        #load next char
        incq %r8

        #check if char < 'A' (65)
        cmpb $65, (%r8)
        jle .dontswap

        #check if char <= 'Z' (90)
        cmpb $90, (%r8)
        jle .upper

        #check if char < 'a' (97)
        cmpb $97, (%r8)
        jl .dontswap

        #check if char <= 'z' (122)
        cmpb $122, (%r8)
        jle .little

        #determine if and how much to add/decrease to the char(byte pointed)
        .little:
            movb $-32, %r9b
            jmp .add
        .upper:
            movb $32, %r9b
            jmp .add
        .dontswap:
            movb $0, %r9b
        .add:
            addb %r9b, (%r8)
            decq %rax
            jmp .loop2

    .endloop:
        #at this point, each english letter swapped
        movq %rdi, %rax
    #get the pointers to the stack back
        movq %rbp, %rsp
        popq %rbp
        #return from this function
        ret


.globl pstrijcmp
.type pstrijcmp, @function
#this function gets 4 arguments
#1. rdi = the address of the first pstring
#2. rsi = the address of the second pstring
#3. rdx = i
#4. rcx = j
#and return the value of strcmp on pstr1[i:j] and pstr2[i:j]
pstrijcmp:
    pushq %rbp
    movq %rsp, %rbp
    movq %rdi, %r9
    movq %rsi, %r10
    #first we want to check that i and j are valid
    #it should be 0 <= i <= j <= len(str1) and j <= len(str2)

    #confirm that i >= 0
    cmpq $0, %rdx
    #if i < 0
    jl .error

    #confirm that i <= j
    cmpq %rdx, %rcx
    #if j < i
    jl .error

    #confirm that j < len(str1)
    #getting len(str1)
    movq $0, %rax
    call pstrlen
    #now rax = len(pstr1)
    cmpq %rcx, %rax
    jle .error

    #confirm that j < len(str2)
    #getting len(str2)
    movq $0, %rax
    movq %rsi, %rdi
    call pstrlen
    #now rax = len(pstr2)
    cmpq %rcx, %rax
    jle .error


    #at this point, i and j are valid, restore pstr1 and pstr2
    movq %r9, %rdi
    movq %r10, %rsi
    movq %rsi, %r8 #tmp
    #rdx = i
    #rcx = j


    #make rdi point to the i's byte in the first pstring's str
    #and rsi to the second's
    addq $1, %rdi
    addq $1, %rsi
    addq %rdx, %rdi
    addq %rdx, %rsi

    #make a counter
    subq %rdx, %rcx
    incq %rcx
    movq $0, %r8 #tmp
    #when rcx == 0 it means we replaced all
    .loop:
        movb (%rsi), %r8b
        cmpb (%rdi), %r8b
        jl .firstbigger
        jg .secondbigger
        incq %rsi
        incq %rdi
        decq %rcx
        #confirm that counter >= 0
        cmpq $0, %rcx
        #if i < 0
        jg .loop

    #if the code is here it means that the strings were equal
    #and din't jump to any lable, so return 0
    movq $0, %rax
    jmp .end
    .error:
        movq $print_error, %rdi
        movq $0, %rax
        call printf
        movq $-2, %rax
        jmp .end
    .firstbigger:
        movq $1, %rax
        jmp .end
    .secondbigger:
        movq $-1, %rax
    .end:

    #now the right value is in rax, we can return after
    #get the pointers to the stack back
    movq %rbp, %rsp
    popq %rbp
    #return from this function
    ret














