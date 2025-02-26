; ===============================================================================
; Task:     Number 4
; Author:   Timofei Kuzin
;
; Text:     Read a character and print the positions of all its occurrences in 
;           the input. If the character is not provided as an argument, it will 
;           be entered from the keyboard.
;
; Date:     26.02.2025
;
; Academic year:    2
; Semester:         4
; Field of study:   informatika
; ===============================================================================
.model small
.stack 100h

INCLUDE macros.inc

.data
    logo1 db ' _____  ___   _____  _____ ___________  ', '$'   ; Logo of the project 
    logo2 db '| ___ \/ _ \ | ___ \/  ___|  ___| ___ \ ', '$' 
    logo3 db '| |_/ / /_\ \| |_/ /\ `--.| |__ | |_/ / ', '$'
    logo4 db '|  __/|  _  ||    /  `--. \  __||    /  ', '$'
    logo5 db '| |   | | | || |\ \ /\__/ / |___| |\ \  ', '$'
    logo6 db '\_|   \_| |_/\_| \_|\____/\____/\_| \_| ', '$'
    help_msg1 db 'This program will count how many times the symbol appeared in the document. The symbol could be passed as an argument or just inserted from keyboard.', '$'
    help_msg2 db 'To start the program please open it via MS-DOS like this "parser <filename> <symbol>" or "parser <filename>"', '$'
    no_args_msg db 'No arguments were passed, shutting down. Please try the parser -h command.', '$'
    open_error_msg db 'The file could not be opened, shutting down.', '$'
    close_error_msg db 'The file could not be closed, shutting down.', '$'
    undefined_flag_msg db 'Undefined flag was used with program. You can use -h to see what this program is for.', '$'
    pos db 'The position is: ', '$'
    newline db 13, 10, '$'
    read_err_msg db 'Error while reading file', '$'
    prompt2 db 'Enter symbol: ', '$'
    bye_msg db 'The symbol appeared ', '$'
    press_key db 13, 10, 'Press enter to continue to new page...', '$'
    bye_msg2 db ' times.', '$'
    args_buffer db 128 dup(0)       ; Buffer for arguments from command line
    buffer db 128 dup('$')          ; Buffer for reading from file
    symbol db 5 dup('$')            ; Buffer for saving symbol
    saved_reg1 dw ?
    saved_reg2 dw ?
    saved_reg3 dw ?
    printed_lines_counter dw 0
    flag_p db 0

.code
EXTRN print_num:near                ; WHY FAR??????? TODO
start:
    mov ax, @data                   ; Move start of data segment into DS register
    mov ds, ax 

    mov sp, 100h                    ; Load stack into stack pointer
    mov bp, sp                      ; Also load base pointer  ;;;;;;;; TODO

    mov ah, 62h                     ; Get PSP segment
    int 21h                         ; Call DOS
    mov es, bx                      ; Put the descriptor of PSP into es

    mov cl, es:[80h]                ; Get the number of bytes in PSP
    cmp cl, 0               
    je err_no_arguments

    mov al, es:[82h]                ; Check if we have some flag
    cmp al, '-'
    jne pars

    mov al, es:[83h]                ; Check if the flag is help then write help message
    cmp al, 'h'
    je display_help_message
    cmp al, 'p'
    je pages_flag_set
    jmp err_undefined_flag

err_no_arguments:                   ; If there was no arguments while starting program
    PRINT newline
    PRINT no_args_msg
    PRINT newline
    jmp exit_program

err_undefined_flag:                 ; If the flag is undefined
    PRINT newline
    PRINT undefined_flag_msg
    PRINT newline
    jmp exit_program

display_help_message:
;    PRINT logo1
;    PRINT newline
;    PRINT logo2
;    PRINT newline
;    PRINT logo3
;    PRINT newline
;    PRINT logo4
;    PRINT newline
;    PRINT logo5
;    PRINT newline
;    PRINT logo6
;    PRINT newline
;    PRINT newline
;    PRINT help_msg1
    PRINT newline
    PRINT help_msg2
    PRINT newline
    jmp exit_program

pages_flag_set:
    mov [flag_p], 1
    jmp pars

; Main program 
pars:                   
    push ds                         ; Exchange registers before starting copying since
    push es                         ; movsb copies from ds:si to es:di
    pop ds
    pop es

    mov di, offset args_buffer  
    mov si, 82h
    mov al, es:[flag_p]
    cmp al, 1
    je update_si  
copy:    
    cld                             ; ????????????? TODO
    rep movsb                       ; Copy PSP into args_buffer
    push ds                         ; Exchange registers as they were before 
    push es
    pop ds
    pop es
    mov si, offset args_buffer
    jmp check_symbol_args

update_si:
    mov si, 85h
    jmp copy
check_symbol_args:                  ; Check if the symbol that will be checked was inserted via command line
    mov al, [si]
    inc si
    cmp al, 0
    je ins_symbol_from_keyboard
    cmp al, ' '                     ; If we saw [SPACE] than it means that probably after that will be symbol
    je checksym
    jmp check_symbol_args
checksym:
    mov ah, [si]
    cmp ah, 0                       ; If there was no symbol
    je ins_symbol_from_keyboard
    push ax                         ; Macro will use AX register but we want to save symbol
    OPEN_FILE args_buffer, 2, bx    
    pop ax
    mov dx, 0                       ; Set counter to 0  
    mov di, 0                
    jmp main_loop

ins_symbol_from_keyboard:
    PRINT prompt2 
    ; Read user input
    mov dx, offset symbol
    mov ah, 0Ah
    int 21h
    OPEN_FILE args_buffer, 2, bx
    mov ah, [symbol+2]
    mov dx, 0                       ; Set counter to 0 
    mov di, 0 
    jmp main_loop 

err_open_file:                      ; If there was an error during opening file
    PRINT newline
    PRINT open_error_msg
    PRINT newline
    jmp exit_program

; ==============================================================================
; DX register - counter for printed lines into terminal for paging
; AX register - (AH - symbol) and (AL - char that we are reading at the moment)
; BX register - file descriptor
; CX register - nested loop iterator(CX <= 128)
; ==============================================================================
main_loop:
    push ax                         ; Save the symbol that we are comparing to
    push dx                         ; Save counter of appearence of symbol
    READ_FILE bx, buffer            ; Read file into buffer of 128 bytes
    pop dx                          ; Load counter of appearance of symbol
    mov cx, ax                      ; Load into cx the number of bytes that could be read
    pop ax                          ; Load symbol that we are comparing to
    mov si, offset buffer                         
    cmp cx, 0                       ; Check if there is no bytes to read
    je print_counter
nested_loop:
    mov al, [si]                    ; Load char from buffer
    inc si                          ; Increment pointer on buffer
    inc di
    cmp al, ah                      ; Compare if same as symbol that we wrote
    jne skip_increment              ; Do not increment counter of appearance 
    inc dx
    cmp dx, 25
    je waait 
meee:    
    mov [saved_reg1], ax
    mov [saved_reg2], bx
    mov [saved_reg3], dx
    PRINT newline
    PRINT pos
    mov ax, di
    call print_num 
    mov ax, [saved_reg1] 
    mov bx, [saved_reg2] 
    mov dx, [saved_reg3]
skip_increment:                              
    loop nested_loop                ; Iterate through nested loop
    jmp main_loop                   ; If CX == 0 then go to main loop
waait:
    cmp [flag_p], 1
    jne meee
    call wait_for_page
    jmp meee

err_read_file:                      ; If there was an error during reading file
    PRINT newline                       
    PRINT read_err_msg
    PRINT newline
    CLOSE_FILE bx                   ; Try closing file
    jmp exit_program

print_counter:  
    add [printed_lines_counter], dx
    CLOSE_FILE bx        
    PRINT newline                   
    PRINT bye_msg               
    mov ax, [printed_lines_counter]
    call print_num
    PRINT bye_msg2
    jmp exit_program


wait_for_page:
    mov [saved_reg1], ax
    mov [saved_reg2], dx
    mov dx, offset press_key
    mov ah, 09h
    int 21h
wait_key:  
    mov ah, 08h         ; Read key without echo
    int 21h
    cmp al, 13          ; ENTER key?
    jne wait_key
    mov ax, [saved_reg1]
    mov dx, [saved_reg2]
    add [printed_lines_counter], dx
    mov dx, 0
    ret

exit_program:
    mov ah, 4Ch
    int 21h

err_close_file:
    PRINT newline
    PRINT close_error_msg
    PRINT newline
    jmp exit_program    

end start
