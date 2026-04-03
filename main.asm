section     .data
    hline           db "----------------------------------------", 0x0A
    hline_len       equ ($ - hline)

    array_msg1      db "Original Array: ", 0x0A
    array_msg1_len  equ ($ - array_msg1)

    array_msg2      db "Sorted Array: ", 0x0A
    array_msg2_len  equ ($ - array_msg2)

    msg1            db "Enter the array size: "
    msg1_len        equ ($ - msg1)

    msg2            db "Enter the contents of the array: ", 0x0A
    msg2_len        equ ($ - msg2)

    msg3            db "Enter the search target: "
    msg3_len        equ ($ - msg3)

    success_msg     db "The search target was found at index: "
    success_msg_len equ ($ - success_msg)

    failure_msg     db "The search target was not found"
    failure_msg_len equ ($ - failure_msg)
    
    exit_msg        db "Program Ended", 0x0A
    exit_msg_len    equ ($ - exit_msg)

    newline         db 0x0A

    arr_len         dd 0


section     .bss
    buffer      resb 16             ; reserve 16 bytes as a buffer used for user input
    arr         resd 10000          ; reserve 10000 4-byte words for the array

section     .text
    global      _start


_start:
    ; print horizontal line
    mov ecx, hline                  ; move hline into ecx to print it
    mov eax, 4                      ; print system call
    mov ebx, 1                      ; set the file descriptor
    mov edx, hline_len              ; mov the length
    int 0x80                        ; interrupt

    ; print message "Enter the array size: "
    mov ecx, msg1                   
    mov eax, 4
    mov ebx, 1
    mov edx, msg1_len
    int 0x80

    ; take user input for array length
    mov eax, 3                      ; system call for reading
    mov ebx, 0                      ; set file descriptor
    mov ecx, buffer                 ; store input in buffer
    mov edx, 16                     ; size of buffer
    int 0x80                        ; interrupt

    ; move user input into array length
    xor eax, eax                    ; clear eax
    mov edi, buffer                 ; move the buffer into edi
    call atoi                       ; convert ascii to integer
    mov [arr_len], eax              ; store the integer in the arr_len label

    ; print horizontal line
    mov ecx, hline
    mov eax, 4
    mov ebx, 1
    mov edx, hline_len
    int 0x80

    ; print message "Enter the contents of the array: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, msg2_len
    int 0x80

    ; fill_array function takes arguments: the array, length of array, the buffer, and a counter
    ; it fills the array with user input
    mov edi, arr                    ; move array buffer into edi
    mov esi, [arr_len]              ; move array length into esi
    mov edx, buffer                 ; move buffer into edx
    xor ecx, ecx                    ; zero out ecx

    call fill_array

    ; print horizontal line
    mov eax, 4
    mov ebx, 1
    mov ecx, hline
    mov edx, hline_len
    int 0x80

    ; print message "Original Array: "
    mov eax, 4
    mov ebx, 1
    mov ecx, array_msg1
    mov edx, array_msg1_len
    int 0x80
    
    ; print_array function takes arguments: a pointer to base address of the array, length of the array, pointer to the buffer, and a counter
    ; print the array before sorting
    mov edi, arr                    ; move array buffer into edi 
    mov esi, [arr_len]              ; move array length into esi
    mov edx, buffer                 ; move buffer into edx
    xor ecx, ecx                    ; zero out ecx

    call print_array
                                
    ; the quicksort function takes three arguments: a pointer to the base address of the array, and low and a high indices
    mov edi, arr
    mov esi, 0
    mov edx, [arr_len]
    dec edx

    call quicksort

    ; print a newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; print horizontal line
    mov eax, 4
    mov ebx, 1
    mov ecx, hline
    mov edx, hline_len
    int 0x80

    ; print message "Sorted Array: "
    mov eax, 4
    mov ebx, 1
    mov ecx, array_msg2
    mov edx, array_msg2_len
    int 0x80

    ; print the sorted array
    mov edi, arr
    mov esi, [arr_len]
    mov edx, buffer
    call print_array

    ; print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
   
    ; print horizontal line
    mov eax, 4
    mov ebx, 1
    mov ecx, hline
    mov edx, hline_len
    int 0x80

    ; print message "Enter the search target: "
    mov ecx, msg3
    mov eax, 4
    mov ebx, 1
    mov edx, msg3_len
    int 0x80
    
    ; take user input for search target
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; convert user input from ascii to integer
    xor eax, eax
    mov edi, buffer
    call atoi

    ; the binary_search function takes three arguments: pointer to base address of array, the length of the array, and a pointer to the target
    mov edi, arr
    mov esi, [arr_len]
    dec esi
    mov ebx, eax
    call binary_search
    
    ; if the result is greater than -1 then the target was found and we print the respective success message
    ; if the result is -1 then the target wasn't found and we print the respective failure message
    cmp eax, -1
    jg success
    je failure


success:
    ; convert the result of binary search to ascii to be printed
    mov edi, buffer
    call itoa

    push eax                    ; preserve the result of binary search
    push edx                    ; preserve the length of the result

    ; print horizontal line
    mov eax, 4
    mov ebx, 1
    mov ecx, hline
    mov edx, hline_len
    int 0x80
    
    
    ; print "The search target was found at index: "
    mov ecx, success_msg
    mov eax, 4
    mov ebx, 1
    mov edx, success_msg_len
    int 0x80

    pop edx                     ; restore edx so we can use the length of the result
    pop eax                     ; restore eax so we can use the result of binary search

    ; print the result
    mov ecx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80

    jmp exit
failure:
    ; print horizontal line
    mov eax, 4
    mov ebx, 1
    mov ecx, hline
    mov edx, hline_len
    int 0x80

    ; print the message corresponding to the search target not being found in the array
    mov ecx, failure_msg
    mov eax, 4
    mov ebx, 1
    mov edx, failure_msg_len
    int 0x80

    jmp exit
exit:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ; print the message "Program Ended"
    mov ecx, exit_msg
    mov eax, 4
    mov ebx, 1
    mov edx, exit_msg_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, hline
    mov edx, hline_len
    int 0x80

    ; exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80




fill_array:
    cmp ecx, esi 
    jge .end

    push ecx
    push edi

    mov eax, 3
    mov ebx, 0
    mov ecx, edx
    push edx
    mov edx, 16
    int 0x80

    pop edx
    xor eax, eax
    mov edi, edx
    push edx
    call atoi
    
    pop edx
    pop edi
    pop ecx

    mov [edi + ecx*4], eax

    inc ecx
    jmp fill_array
.end:
    ret   




; parameters: array, start index, array length, buffer
print_array:
    mov ecx, esi
    xor esi, esi
.loop:
    cmp esi, ecx
    jge .end
    mov eax, [edi + esi*4]

    push esi                    ; preserve the counter
    push ecx                    ; preserve the array length
    push edi                    ; preserve the array
    
    mov edi, edx
    push edx

    call itoa
        
    mov ecx, eax
    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx
    pop edi                     ; restore the array
    pop ecx                     ; restore the array length
    pop esi                     ; restore the counter
    
    inc esi                     ; increment the counter
    jmp .loop                   ; jump to the next iteration
.end:
    ; print a newline
    mov ecx, 0x0A
    mov eax, 4
    mov ebx, 1
    mov edx, 1
    int 0x80

    ret




atoi:
    xor eax, eax                       ; clear eax
    xor ebx, ebx                       ; clear ebx

    mov dl, [edi]                      ; move value stored in [edi] to 8-bit register dl
    cmp dl, '-'                        ; compare byte stored in dl to minus sign '-'
    jne .loop                          ; if dl is not equal to minus sign then jump to the loop

    mov bl, 1                          ; if dl is equal to minus sign then move 1 into bl. Here I set the value of bl to 1 and use it as a boolean to later determine if the input was negative or not 
    inc edi                            ; increment edi to go to the next byte in the buffer
    jmp .loop
.loop:
    movzx edx, byte [edi]
    cmp dl, 0x0A
    je .end

    imul eax, 10
    sub edx, '0'
    add eax, edx

    inc edi
    jmp .loop
.end:
    cmp bl, 1                          ; compare bl to 1
    jne .done                          ; if bl is 1 then the input was negative and the converted integer should be negated to make it negative
    neg eax                            ; negate eax which will be the return value
.done:
    ret




itoa:
    mov ecx, 10                        ; divisor
    xor esi, esi                       ; clear esi
    
    mov ebx, eax                
    cmp eax, 0                         ; compare eax to zero to check if its positive
    jge .loop1                         ; if eax is positive, then jump to the loop
    
    neg eax                            ; if not then negate eax to make it positive
.loop1:
    cdq                                ; prepare edx:eax for division
    idiv ecx                           ; divide edx:eax by ecx (10)
    push edx                           ; push the remainder onto the stack
    inc esi                            ; increment the remainder counter
    test eax, eax                      ; check if eax is zero
    jne .loop1                         ; if not then jump to next iteration. if it is then go to loop2

    mov eax, edi                       ; this will be returned. it is the base address of the buffer

    cmp ebx, 0                         ; compare ebx, which contains the original value of eax, to 0
    jge .loop2                         ; if ebx is positive, then jump to loop2
    
    mov byte [edi], '-'                ; if not, then mov a negative sign "-" to edi. This will be the first character in edi, and denotes that the integer is negative
    inc edi                            ; increment edi to move to the next byte in the buffer
.loop2:
    pop edx                            ; pop a remainder from the stack
    add dl, '0'                        ; append a '0' to convert it to ascii
    mov [edi], dl                      ; mov it into the buffer
    inc edi                            ; increment the buffer so we can append the next digit
    dec esi                            ; decrement the remainder counter
    jnz .loop2                         ; if esi is not zero then jump to next iteration. if it is then the loop is done

    mov byte [edi], 0x20               ; append a space character to the buffer
    inc edi                            ; increment the buffer

    mov edx, edi                       ; move the address of the buffer into edx
    sub edx, eax                       ; calculate length of the buffer by subtracting the current address with the base address that was previously stored in eax

    ret




partition:
    mov ecx, esi                       ; move start index to j
    mov ebx, esi                       ; move start index to i
    dec ebx

    cmp ecx, edx                       ; compare j to end index
    jl .loop                           ; if j smaller than end, enter loop
    jge .end                           ; else go to end of loop
.loop:   
    mov eax, [edi + ecx*4]             ; move element of arr at index j into eax
    cmp eax, [edi + edx*4]             ; compare element of arr at index j to element of arr at index end
    jg .continue                       ; if arr[j] > arr[end] do nothing, go to next iteration

    inc ebx                            ; else i++ and swap arr[i] with arr[j]
    
    push esi                           ; push esi to save current value and free it for use
    mov esi, ebx                       ; move i into esi

    push ebx                           ; push ebx to save current value and free it for use

    ; swap ith element with jth element
    mov eax, [edi + esi*4]             ; ith element
    mov ebx, [edi + ecx*4]             ; jth element
    mov [edi + ecx*4], eax             ; move ith element into jth index
    mov [edi + esi*4], ebx             ; move jth element into ith index
     
    pop ebx                            ; pop ebx to restore its value
    pop esi                            ; pop esi to restore its value 

    jmp .continue                      

.continue:
        inc ecx                        ; increment j to access the next element
        cmp ecx, edx                   ; compare j to the end index
        jl .loop                       ; if j is smaller than end, jump to start of loop for the next iteration
.end:
        mov ecx, ebx                   ; move i into ecx
        add ecx, 1                     ; add 1 to ecx
        
        push ebx                       ; push ebx to save its current value and free it for use

        ; swap i+1 element with end element 
        mov eax, [edi + ecx*4]
        mov ebx, [edi + edx*4]
        mov [edi + ecx*4], ebx
        mov [edi + edx*4], eax

        pop ebx                         ; pop ebx to restore its value

        mov eax, ebx                   ; move i into eax
        add eax, 1                     ; add 1 to eax
        ret                            ; return (eax will be returned)




quicksort:
    cmp esi, edx                       ; compare esi (start) to edx (end)
    jge .base_case                     ; if start is greater than or equal to then we need to exit

    call partition

                                       ; left partition
    push edx                           ; save edx (end)
    mov edx, eax                       ; move the return value from partition call to edx
    dec edx                            ; decrement edx
    
    call quicksort                     ; call quicksort on left partition

    pop edx                            ; pop back edx to restore value from before recuesive call

    push esi                           ; save esi by pushing to stack (start)
    mov esi, eax                       ; move the return value from partition call to esi
    inc esi                            ; increment esi

    call quicksort                     ; call quicksort on right partition

    pop esi                            ; pop back esi to restore value from before recursive call
.base_case:                            ; in the base case we just need to exit the function
    ret


binary_search:
    mov edx, esi                        ; array length

    xor esi, esi                        ; esi used to hold low index
    xor ecx, ecx                        ; ecx used to hold mid index
.loop:
    cmp esi, edx                   ; Compare low index to high index
    jg .not_found                  ; If low is greater than high, then exit by jumping to not_found

    mov eax, esi                   ; move low index to rax
    add eax, edx                   ; add high to low
    shr eax, 1                     ; shift right by 1 bit to divide by 2
    mov ecx, eax                   ; mov the quotient into rcx

    mov eax, [edi + ecx*4]         ; Move element at index mid into eax

                                   ; The following three comparisons are made:
    cmp ebx, eax           
    jg .greater_than               ; target > arr[mid]                
    jl .less_than                  ; target < arr[mid]
    je .found                      ; target == arr[mid]
.greater_than:                     ; target is greater than arr[mid] so we update low to be mid+1
    mov esi, ecx
    inc esi
    jmp .loop                      ; Jump to the beginning of the binary_search section
.less_than:                        ; target is less than arr[mid] so we update high to be mid - 1
    mov edx, ecx               
    dec edx                     
    jmp .loop                      ; Jump to the beginning of the binary_search section
.found:                           
    mov eax, ecx                   ; move the index into eax to be returned
    ret                            ; target was found so we can exit the function and return the index where it was found
.not_found:                        ; the loop ended and the target was not found
    mov eax, -1
    ret                            ; since target was not found we can exit the function and return -1 as an indication that the search was unsuccessful

