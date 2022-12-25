.section .rodata
print_error:        .string "invalid option!\n"
.text
.globl pstrlen
.type pstrlen, @function
#this function gets as an argument an address to the start of a memory of pstring
#in the first arg register (rdi) and return it's length value in the return value reg (rax)
pstrlen:
    #make rax = 0
    movq $0, %rax
    #move the char (1 byte) that represent the length
    #value of the pstring to the low byte of rax
    movb (%rdi), %al
    ret


.globl replaceChar
.type replaceChar, @function
#this function gets 3 arguments:
# 1. rdi = the address of the pstring
# 2. rsi = the old char
# 3. rdx = the new char
#the function replaces all instances of the old char with the new one
replaceChar:

    #save the registers before using
    pushq %r10
    pushq %r9
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
    .loop:
        #look at the next byte
        add %r10, 1
        #let r9 be the first byte pointed by r10
        movb (%r10), %r9b
        #compare r9b with rsi (the old char)
        cmp %r9b, %rsi
        #if not equal, don't replace
        jne .skipReplacement
        #take the first byte of rdx (old char) and
        #move it to the address in r10 (the old char in the string)
        movb %rdx, (%r10)
    .skipReplacement:
        #dec rax (was the length) by 1
        dec %rax
        #if rax isn't 0 goto .loop
        jne .loop

    #at this point, the string is after the replacement
    #before returning, put the address of the pstring in rax
    movq %rdi, %rax
    #restore the registers
    popq %r9
    popq %r10
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
    pushq %r8
    pushq %rsi
    pushq %rdi
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

    #confirm that j <= len(str1)
    #getting len(str1)
    movq $0, %rax
    call pstrlen
    #now rax = len(pstr1)
    cmpq %rcx, %rax
    jl .error

    #confirm that j <= len(str2)
    #getting len(str2)
    movq $0, %rax
    movq %rsi, %rdi
    call pstrlen
    #now rax = len(pstr2)
    cmpq %rcx, %rax
    jl .error


    #at this point, i and j are valid, restore pstr1 and pstr2
    popq %rdi #pstr1
    popq %rsi #pstr2
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
    .loop:
        movb %dil, %sil
        decq %rcx
        #confirm that counter >= 0
        cmpq $0, %rcx
        #if i < 0
        jge .loop

    jmp .end
    .error:
        movq $print_error, %rdi
        call printf
    .end:

    #now we replaced all chars, now we need to return values
    movq $0, %rax
    movq %r8, %rax
    popq %r8
    ret


.globl swapCase
.type swapCase, @function
#this function gets one argument: rdi = address of pstring
#and swap every english letter to the oposite case
#and return the address after the replacement
swapCase:
    pushq %r8
    push1 %r9
    #save the address
    pushq %rdi

    #get the length of pstr
    movq $0, %rax
    call pstrlen
    #now rax is the length of the string
    #when will be 0, end the loop


    popq %r8
    movq %r8, %rdi
    .loop:
        #if rax = 0, string ended
        cmpq $0, %rax
        je .endloop

        #load next char
        incq %r8

        #check if char < 'A' (65)
        cmpb (%r8), $65
        jl .dontswap

        #check if char <= 'Z' (90)
        cmpb (%r8), $90
        jel .upper

        #check if char < 'a' (97)
        cmpb (%r8), $97
        jl .dontswap

        #check if char <= 'z' (122)
        cmpb (%r8), $122
        jel .little

        #determine if and how much to add/decrease to the char(byte pointed)
        .little:
            movb $-32, %r9
        .upper:
            movb $32, %r9
        .dontswap:
            movb $0, %r9

        addb %r9, (%r8)
        decq %rax
        jmp .loop

    .endloop:
        #at this point, each english letter swapped
        movq %rdi, %rax
        popq %r9
        popq %r8
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
    pushq %r8
    pushq %rsi
    pushq %rdi
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

    #confirm that j <= len(str1)
    #getting len(str1)
    movq $0, %rax
    call pstrlen
    #now rax = len(pstr1)
    cmpq %rcx, %rax
    jl .error

    #confirm that j <= len(str2)
    #getting len(str2)
    movq $0, %rax
    movq %rsi, %rdi
    call pstrlen
    #now rax = len(pstr2)
    cmpq %rcx, %rax
    jl .error


    #at this point, i and j are valid, restore pstr1 and pstr2
    popq %rdi #pstr1
    popq %rsi #pstr2
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
    .loop:
        cmpb %dil, %sil
        jl .firstbigger
        jg .secondbigger
        decq %rcx
        #confirm that counter >= 0
        cmpq $0, %rcx
        #if i < 0
        jge .loop

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
    #restoring r8
    popq %r8
    ret














