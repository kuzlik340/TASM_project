.model small
.stack 100h

.data
    prompt1 db 'Enter line: ', '$'
    prompt2 db 13, 10, 'Enter symbol: '
    hello_msg db 13, 10, 'Hello', 13, 10, '$'
    bye_msg db 13, 10, 'Bye', 13, 10, '$'
    buffer db 100 dup('$')  ; buffer for user input
    symbol db 2 dup('$')

.code
start:
    mov ax, @data
    mov ds, ax

    ; Display prompts
    mov dx, offset prompt1
    mov ah, 09h
    int 21h

    ; Read user input
    lea dx, buffer
    mov ah, 0Ah
    int 21h

    mov dx, offset prompt2
    mov ah, 09h
    int 21h

    ; Read user input
    lea dx, symbol
    mov ah, 0Ah
    int 21h



    ; Compare input with '-h'
    lea si, buffer + 2     ; Skip input length bytes
    lea dx, symbol + 2
    mov al, [si]           ; First character
    cmp al, 
    jne print_bye

    mov al, [si+1]         ; Second character
    cmp al, 'h'
    jne print_bye

    ; If match, print "Hello"
    mov dx, offset hello_msg
    mov ah, 09h
    int 21h
    jmp exit_program

print_bye:
    ; Otherwise, print "Bye"
    mov dx, offset bye_msg
    mov ah, 09h
    int 21h

exit_program:
    mov ah, 4Ch
    int 21h

end start
