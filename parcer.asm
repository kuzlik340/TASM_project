.model small
.stack

INCLUDE macros.inc


.data
    help_msg1 db ' _____  ___  ______  _____  _____ _____ ', '$'
    help_msg2 db '| ___ \/ _ \ | ___ \/  __ \|  ___| ___ \', '$'
    help_msg3 db '| |_/ / /_\ \| |_/ /| /  \/| |__ | |_/ /', '$'
    help_msg4 db '|  __/|  _  ||    / | |    |  __||    / ', '$'
    help_msg5 db '| |   | | | || |\ \ | \__/\| |___| |\ \ ', '$'
    help_msg6 db '\_|   \_| |_/\_| \_| \____/\____/\_| \_|', '$'
    help_msg db 'This program will count how many times the symbol appeared in the document. The symbol could be passed as an argument or just inserted from keyboard', '$'

    open_error_msg db 'The file could not be opened, restart program'
    close_error_msg db 'The file could not be closed, restart program'
    
    prompt1 db 'Enter line: ', '$'
    prompt2 db 'Enter symbol: ', '$'
    bye_msg db 'The symbol appeared ', '$'
    bye_msg2 db ' times', '$'
    buffer db 100 dup('$')  ; buffer for user input
    symbol db 5 dup('$')

.code
start:
    mov si, 82h
    mov al, [si]
    cmp al, '-'
    jne main_start

    inc si
    mov al, [si]
    cmp al, 'h'
    jne main_start
    mov ax, @data           ; Since we can not move directly start of data segment to DS we have to make this via another register
    mov ds, ax 

    jmp print_logo

main_start:
    mov ax, @data           ; Since we can not move directly start of data segment to DS we have to make this via another register
    mov ds, ax 

    PRINT prompt1

    mov dx, offset buffer
    mov ah, 0Ah             ; API call for MS-DOS to read input
    int 21h                 ; Call MS-DOS kernel

    NEWLINE
    PRINT prompt2

    ; Read user input
    mov dx, offset symbol
    mov ah, 0Ah
    int 21h


    ; Prepare for loop
    mov bl, [symbol+2]
    lea dx, buffer + 2 
    mov si, dx
    mov cl, 0


main_loop:
    mov al, [si]            ; Load char from buffer
    inc si                  ; Increment pointer on buffer
    cmp al, '$'             ; Compare if end of the line
    je print_bye            ; If end then go print data
    cmp al, bl              ; Compare if same as symbol that we wrote
    je inc_stats
    jmp main_loop

inc_stats:
    inc cl
    jmp main_loop

print_bye:
    NEWLINE
    PRINT bye_msg
    add cl, 30h             ; transform to ASCII(5 -> '5')
    mov ah, 02h             ; MS-DOS API func to print symbol
    mov dl, cl             
    int 21h
    PRINT bye_msg2
    NEWLINE

exit_program:
    mov ah, 4Ch
    int 21h

open_error:
    NEWLINE
    PRINT open_error_msg
    NEWLINE
    jmp exit_program

close_error:
    NEWLINE
    PRINT close_error_msg
    NEWLINE
    jmp exit_program

print_logo:
    PRINT help_msg1
    NEWLINE
    PRINT help_msg2
    NEWLINE
    PRINT help_msg3
    NEWLINE
    PRINT help_msg4
    NEWLINE
    PRINT help_msg5
    NEWLINE
    PRINT help_msg6
    NEWLINE
    NEWLINE
    PRINT help_msg
    NEWLINE
    jmp exit_program

end start
