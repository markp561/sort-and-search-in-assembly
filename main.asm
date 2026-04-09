section     .data
    
       
    array_msg1              db "Original order: "
    array_msg1_len          equ ($ - array_msg1)

    array_msg2              db "Sorted order:   "
    array_msg2_len          equ ($ - array_msg2)

    msg1                    db "Please enter the size of your data: "
    msg1_len                equ ($ - msg1)

    msg2                    db "Please enter your data: ", 0x0A
    msg2_len                equ ($ - msg2)

    msg3                    db "Please enter a search target: "
    msg3_len                equ ($ - msg3)

    overflow_msg1           db "Size of data exceeds maximum of "
    overflow_msg1_len       equ ($ - overflow_msg1)

    overflow_msg2           db "elements", 0x0A, "Please enter a smaller size: "
    overflow_msg2_len       equ ($ - overflow_msg2)

    sorting_msg             db "Sorting data...", 0x0A
    sorting_msg_len         equ ($ - sorting_msg)

    search_success_msg      db "The search target was found at index: "
    search_success_msg_len  equ ($ - search_success_msg)

    search_failure_msg      db "The search target was not found"
    search_failure_msg_len  equ ($ - search_failure_msg)
    
    exit_msg                db "Program Ended", 0x0A
    exit_msg_len            equ ($ - exit_msg)

    nl                      db 0x0A
    hl                      db "--------------------------------------------------", 0x0A
    hl_len                  equ ($ - hl)

    arr_len                 dd 0
    max_elements            equ 10000


section     .bss
    buffer                  resb 16             ; reserve 16 bytes as a buffer used for user input
    arr                     resd max_elements   ; reserve as many 4-byte words for the array as determined by the max_elements constant declared above


section     .text
    global      _start


_start:
    ; print horizontal line
    call horizontal_line
    
    ; print message 1, "Please enter the size of your data: "
    mov edi, msg1
    mov esi, msg1_len
    call print


; take user input for array length
; allow the user to repeatedly give input until the input is valid
; here a valid input for the size is a number less than or equal to the maximul number of elements which is held in max_elements and is the reserved number of integers for the array buffer
.data_size_input:
    mov eax, 3                                  ; system call for reading
    mov ebx, 0                                  ; set file descriptor
    mov ecx, buffer                             ; store input in buffer
    mov edx, 16                                 ; size of buffer
    int 0x80                                    ; interrupt

    xor eax, eax                                ; clear eax
    mov edi, buffer                             ; move the buffer into edi
    call atoi                                   ; convert ascii to integer

    cmp eax, max_elements                       ; check if the input is less than or equal to the value of max_elements
    jle .valid_data_size                        ; if so, then jump to the next section, titled valid_data_size and continue with the program

    ; print message "Size of data exceeds maximum of (max_elements). Please enter a smaller size: "
    mov edi, overflow_msg1
    mov esi, overflow_msg1_len
    call print

    mov eax, max_elements
    mov edi, buffer
    call itoa

    mov edi, eax
    mov esi, edx
    call print

    mov edi, overflow_msg2
    mov esi, overflow_msg2_len
    call print

    jmp .data_size_input                        ; jump to the start of the loop

 
.valid_data_size:

    mov [arr_len], eax                          ; store the integer in the arr_len label
    
    call horizontal_line                        ; print a horizontal line


    ; print message  "Please enter your data"
    mov edi, msg2
    mov esi, msg2_len
    call print    

    ; fill_array function takes arguments: the array, length of array, the buffer, and a counter
    ; it fills the array with user input
    mov edi, arr                                ; move array buffer into edi
    mov esi, [arr_len]                          ; move array length into esi
    mov edx, buffer                             ; move buffer into edx
    xor ecx, ecx                                ; zero out ecx

    call fill_array

    ; print horizontal line
    call horizontal_line


    ; print message "Original order: "
    mov edi, array_msg1
    mov esi, array_msg1_len
    call print

    
    ; print_array function takes arguments: a pointer to base address of the array, length of the array, pointer to the buffer, and a counter
    ; print the array before sorting
    mov edi, arr                                ; move array buffer into edi 
    mov esi, [arr_len]                          ; move array length into esi
    mov edx, buffer                             ; move buffer into edx
    xor ecx, ecx                                ; zero out ecx

    call print_array

    ; print a newline
    call newline
    
    ; check if the array is already in an ascending order, if not then sort it
    mov edi, arr
    mov esi, [arr_len]
    xor edx, edx                                ; default check is for ascending order, can set as 1 for descending
    xor ecx, ecx                                ; zero out ecx to use as iterator for the array

    call check_order               

    test eax, eax                               ; test if the result of eax is zero or one
    jz sort                                     ; if zero then the data is not sorted and we should jump to the sort section 
    jnz search                                  ; if one then the data is correctly ordered and we can search for an element
    
sort:
    ; print a horizontal line
    call horizontal_line

    ; print message "Sorting data..."
    mov edi, sorting_msg
    mov esi, sorting_msg_len
    call print

    ; the quicksort function takes three arguments: a pointer to the base address of the array, and low and a high indices
    mov edi, arr
    mov esi, 0
    mov edx, [arr_len]
    dec edx
    call quicksort

    ; print horizontal line
    call horizontal_line


    ; print message "Sorted Array: "
    mov edi, array_msg2
    mov esi, array_msg2_len
    call print

    ; print the sorted array
    mov edi, arr
    mov esi, [arr_len]
    mov edx, buffer
    call print_array

    ; print a newline
    call newline

search:
    ;print horizontal line
    call horizontal_line

    ; print message "Enter the search target: "
    mov edi, msg3
    mov esi, msg3_len
    call print
    
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

    ; print horizontal line
    call horizontal_line
    
    ; print "The search target was found at index: "
    mov edi, search_success_msg
    mov esi, search_success_msg_len
    call print

    ; print the result of binary search
    mov edi, eax
    mov esi, 1
    call print

    jmp exit
failure:
    ; print horizontal line
    call horizontal_line

    ; print the message "The search target was not found"
    mov edi, search_failure_msg
    mov esi, search_failure_msg_len
    call print
    
    jmp exit
exit:
    ; print a newline
    call newline

    ; print the message "Program Ended"
    mov edi, exit_msg
    mov esi, exit_msg_len
    call print

    ; print a horizontal line
    call horizontal_line

    ; exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80




; this function is used for populating an array with user input
; arguments: ecx=0, esi=array_len, edi=arr, edx=buffer
fill_array:
    cmp ecx, esi                                ; compare the iterator with the array size
    jge .end                                    ; if ecx is greater than or equal to the size, then exit the loop

    push ecx                                    ; preserve ecx
    push edi                                    ; preserve edi

    ; system call for reading
    mov eax, 3                      
    mov ebx, 0
    mov ecx, edx                                ; move the buffer into ecx to read into the buffer
    push edx                                    ; preserve the buffer
    mov edx, 16                                 ; length of the buffer
    int 0x80                                    ; interrupt

    pop edx                                     ; restore edx
    xor eax, eax                                ; clear eax
    mov edi, edx                                ; move the buffer into edi
    push edx                                    ; preserve edx
    call atoi                                   ; convert the user input from ascii to integer using atoi function
    
    ; restore these registers
    pop edx     
    pop edi
    pop ecx

    ; move the output of atoi, the integer into the array at the current index
    mov [edi + ecx*4], eax

    inc ecx                                     ; increment the counter
    jmp fill_array                              ; jump to the beginning of the loop
.end:
    ret                                         ; return




; arguments: arr, arr_len, comparison function (i.g. a < b, a > b)
; arguments: edx=0 or 1, ecx=0, esi=array_length, edi=arr
check_order:
    mov eax, 1                                  ; initialize eax with value 1 indicating the array is sorted

    cmp edx, 1                                  ; the function by default checks for ascending order but the user may specify to check descending order by setting edx to 1 before making the function call
    je .descending_check
    test edx, edx
    jz .ascending_check

.ascending_check:                               ; this section checks if the array is in an ascending order
    cmp ecx, esi                                ; check if ecx, the iterator count, is less than the size of the array
    jg .end                                     ; if not then the loop is over and we should exit
    
    ; move the element at index ecx into ebx
    mov ebx, [edi + ecx*4]          
    inc ecx                                     ; increment ecx

    ; move the element at the incremented index (ecx + 1) into edx
    mov edx, [edi + ecx*4]          
    dec ecx                                     ; decrement ecx to return to the current index

    cmp ebx, edx                                ; compare ebx to edx
    jg .check_fail                              ; if ebx is greater than edx, meaning an element is larger than the element that comes after itm then the array is not in an ascending order and the check has failed
             
    inc ecx                                     ; otherwise increment the counter, ecx
    jmp .ascending_check                        ; and jump to the start of the loop


.descending_check:                              ; this section does the same thing, but checks for a descending order
    cmp ecx, esi 
    jge .end 

    mov ebx, [edi + ecx*4]
    inc ecx

    mov edx, [edi + ecx*4]
    dec ecx

    cmp [edi], edx
    jl .check_fail
 
    inc ecx
    jmp .descending_check

.check_fail:                                    ; in this section, the check has failed so eax is set to 0, indicating the array is not correctly ordered
    xor eax, eax                                ; xor eax with itself to set it to zero
    jmp .end                                    ; jump to the end
.end:
    ret                                         ; exit the function by returning




; this function prints a newline characters
; no arguments needed to call this function
newline:            
    ; save the following registers
    push eax                        
    push ebx
    push ecx
    push edx
    
    ; use print system call to print nl, which contains hexadecimal representation for newline character, 0x0A
    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80
    
    ; pop all the registers that were pushed to restore their contents
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret

; this function prints a horizontal line of fifty dashes, "-"
; no arguments needed to call this function
horizontal_line:
    ; save registers
    push eax
    push ebx
    push ecx
    push edx
    
    ; use print system call to print hl, which contains a string of fifty dashes
    mov eax, 4
    mov ebx, 1
    mov ecx, hl
    mov edx, hl_len
    int 0x80
    
    ; pop all the pushed registers to restore their contents
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret


; this function takes a string and prints it
; a number should be converted to ascii, using the itoa function, before being passed to the print function
; arguments: edi=string to print, esi=length of string
print:
    ; save registers
    push eax
    push ebx
    push ecx
    push edx

    ; use print system call to print message held in edi, with length held in esi
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, esi
    int 0x80

    ; restore the registers
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret


; arguments: esi=array_len, edi=arr, edx=buffer,
print_array:
    mov ecx, esi                                ; move the array length into ecx
    xor esi, esi                                ; zero out esi to use it as the iterator
.loop:
    cmp esi, ecx                                ; compare the iterator to the array length
    jge .end                                    ; if greater than or equal then exit the loop
    mov eax, [edi + esi*4]                      ; move an element from the array into eax

    push esi                                    ; preserve the counter
    push ecx                                    ; preserve the array length
    push edi                                    ; preserve the array
    
    mov edi, edx                                ; move the buffer into edi
    push edx                                    ; preserve the buffer

    call itoa                                   ; use itoa function to convert number to string
   
    ; use print syscall to print the element of the array
    mov ecx, eax                
    mov eax, 4
    mov ebx, 1
    int 0x80

    pop edx                                     ; restore the buffer
    pop edi                                     ; restore the array
    pop ecx                                     ; restore the array length
    pop esi                                     ; restore the counter
    
    inc esi                                     ; increment the counter
    jmp .loop                                   ; jump to the next iteration
.end:
    ret




; arguments: edi=buffer
atoi:
    xor eax, eax                                ; clear eax
    xor ebx, ebx                                ; clear ebx

    mov dl, [edi]                               ; move value stored in [edi] to 8-bit register dl
    cmp dl, '-'                                 ; compare byte stored in dl to minus sign '-'
    jne .loop                                   ; if dl is not equal to minus sign then jump to the loop

    mov bl, 1                                   ; if dl is equal to minus sign then move 1 into bl. Here I set the value of bl to 1 and use it as a boolean to later determine if the input was negative or not 
    inc edi                                     ; increment edi to go to the next byte in the buffer
    jmp .loop
.loop:
    movzx edx, byte [edi]                       ; move a byte from the buffer into edx, padded with zeros everywhere else
    cmp dl, 0x0A                                ; compare the byte from edx to the newline character
    je .end                                     ; if dl == newline, then the last character in the string has already been converted to an integer

    imul eax, 10                                ; eax contains the converted integer. we add a zero to it by multiplying by 10
    sub edx, '0'                                ; subtract from the byte in edx '0' which converts it to an integer
    add eax, edx                                ; add the converted integer to eax

    inc edi                                     ; increment the buffer to go to the next character
    jmp .loop
.end:
    cmp bl, 1                                   ; compare bl to 1
    jne .done                                   ; if bl is 1 then the input was negative and the converted integer should be negated to make it negative
    neg eax                                     ; negate eax which will be the return value
.done:
    ret




itoa:
    mov ecx, 10                                 ; divisor
    xor esi, esi                                ; clear esi
    
    mov ebx, eax                
    cmp eax, 0                                  ; compare eax to zero to check if its positive
    jge .loop1                                  ; if eax is positive, then jump to the loop
    
    neg eax                                     ; if not then negate eax to make it positive
.loop1:
    cdq                                         ; prepare edx:eax for division
    idiv ecx                                    ; divide edx:eax by ecx (10)
    push edx                                    ; push the remainder onto the stack
    inc esi                                     ; increment the remainder counter
    test eax, eax                               ; check if eax is zero
    jne .loop1                                  ; if not then jump to next iteration. if it is then go to loop2

    mov eax, edi                                ; this will be returned. it is the base address of the buffer

    cmp ebx, 0                                  ; compare ebx, which contains the original value of eax, to 0
    jge .loop2                                  ; if ebx is positive, then jump to loop2
    
    mov byte [edi], '-'                         ; if not, then mov a negative sign "-" to edi. This will be the first character in edi, and denotes that the integer is negative
    inc edi                                     ; increment edi to move to the next byte in the buffer
.loop2:
    pop edx                                     ; pop a remainder from the stack
    add dl, '0'                                 ; append a '0' to convert it to ascii
    mov [edi], dl                               ; mov it into the buffer
    inc edi                                     ; increment the buffer so we can append the next digit
    dec esi                                     ; decrement the remainder counter
    jnz .loop2                                  ; if esi is not zero then jump to next iteration. if it is then the loop is done

    mov byte [edi], 0x20                        ; append a space character to the buffer
    inc edi                                     ; increment the buffer

    mov edx, edi                                ; move the address of the buffer into edx
    sub edx, eax                                ; calculate length of the buffer by subtracting the current address with the base address that was previously stored in eax

    ret




partition:
    mov ecx, esi                                ; move start index to j
    mov ebx, esi                                ; move start index to i
    dec ebx

    cmp ecx, edx                                ; compare j to end index
    jl .loop                                    ; if j smaller than end, enter loop
    jge .end                                    ; else go to end of loop
.loop:   
    mov eax, [edi + ecx*4]                      ; move element of arr at index j into eax
    cmp eax, [edi + edx*4]                      ; compare element of arr at index j to element of arr at index end
    jg .continue                                ; if arr[j] > arr[end] do nothing, go to next iteration

    inc ebx                                     ; else i++ and swap arr[i] with arr[j]
    
    push esi                                    ; push esi to save current value and free it for use
    mov esi, ebx                                ; move i into esi

    push ebx                                    ; push ebx to save current value and free it for use

    ; swap ith element with jth element
    mov eax, [edi + esi*4]                      ; ith element
    mov ebx, [edi + ecx*4]                      ; jth element
    mov [edi + ecx*4], eax                      ; move ith element into jth index
    mov [edi + esi*4], ebx                      ; move jth element into ith index
     
    pop ebx                                     ; pop ebx to restore its value
    pop esi                                     ; pop esi to restore its value 

    jmp .continue                      

.continue:
        inc ecx                                 ; increment j to access the next element
        cmp ecx, edx                            ; compare j to the end index
        jl .loop                                ; if j is smaller than end, jump to start of loop for the next iteration
.end:
        mov ecx, ebx                            ; move i into ecx
        add ecx, 1                              ; add 1 to ecx
        
        push ebx                                ; push ebx to save its current value and free it for use

        ; swap i+1 element with end element 
        mov eax, [edi + ecx*4]
        mov ebx, [edi + edx*4]
        mov [edi + ecx*4], ebx
        mov [edi + edx*4], eax

        pop ebx                                 ; pop ebx to restore its value

        mov eax, ebx                            ; move i into eax
        add eax, 1                              ; add 1 to eax
        ret                                     ; return (eax will be returned)




quicksort:
    cmp esi, edx                                ; compare esi (start) to edx (end)
    jge .base_case                              ; if start is greater than or equal to then we need to exit

    call partition                              ; call partition to sort 

                                                ; left partition
    push edx                                    ; save edx (end)
    mov edx, eax                                ; move the return value from partition call to edx
    dec edx                                     ; decrement edx
    
    call quicksort                              ; call quicksort on left partition

    pop edx                                     ; pop back edx to restore value from before recuesive call

    push esi                                    ; save esi by pushing to stack (start)
    mov esi, eax                                ; move the return value from partition call to esi
    inc esi                                     ; increment esi

    call quicksort                              ; call quicksort on right partition

    pop esi                                     ; pop back esi to restore value from before recursive call
.base_case:                                     ; in the base case we just need to exit the function
    ret




binary_search:
    mov edx, esi                                ; array length

    xor esi, esi                                ; esi used to hold low index
    xor ecx, ecx                                ; ecx used to hold mid index
.loop:
    cmp esi, edx                                ; Compare low index to high index
    jg .not_found                               ; If low is greater than high, then exit by jumping to not_found

    mov eax, esi                                ; move low index to eax
    add eax, edx                                ; add high to low
    shr eax, 1                                  ; shift right by 1 bit to divide by 2
    mov ecx, eax                                ; mov the quotient into ecx

    mov eax, [edi + ecx*4]                      ; Move element at index mid into eax

    ; compare the target to the element at the current middle index
    cmp ebx, eax           
    jg .greater_than                            ; target > arr[mid]                
    jl .less_than                               ; target < arr[mid]
    je .found                                   ; target == arr[mid]

.greater_than:                                  ; target is greater than arr[mid] so we update low to be mid+1
    mov esi, ecx                                ; move mid into esi
    inc esi                                     ; increment by 1
    jmp .loop                                   ; jump to the beginning of the binary_search section

.less_than:                                     ; target is less than arr[mid] so we update high, edx, to be mid - 1
    mov edx, ecx                                ; move mid into edx
    dec edx                                     ; decrement by 1
    jmp .loop                                   ; jump to the beginning of the binary_search section

.found:                           
    mov eax, ecx                                ; target was found so we exit and return the index by moving it into eax
    ret                                 

.not_found:                                     ; the loop ended and the target was not found
    mov eax, -1                                 ; the target was not found, so we exit and return -1 to indicate thatthe search was unsuccessful
    ret                            

