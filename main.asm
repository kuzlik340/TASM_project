; ==================================================================================================
; Task:             Number 4
; Author:           Timofei Kuzin
;
; Text:             Read a character and print the positions of all its occurrences in 
;                   the input. If the character is not provided as an argument, it will 
;                   be entered from the keyboard.
;
; Bonus tasks:      1) Paging is enabled by flag -p (1 point)
;                   2) MOVS instruction is used when copying arguments from PSP to buffer (1 point)
;                   3) Extern procedure is used for printing decimal numbers (2 point)
;                   4) Also the program counts how many times the symbol appeared in document. 
;                   This bonus task is not listed but still was done by me.
;                   5) Lots of comments in english and documentation in english (1 point)
;                   6) Filename will be written into the terminal while paging is enabled (1 point)
;
; Date:             26.02.2025
;
; Academic year:    2
; Semester:         4
; Field of study:   informatika
; ===================================================================================================


;                               H O W   T O    R U N    P R O G R A M
; ==================================================================================================
; To run this code please use this commands in DOS:   
; 1) tasm main                                        
; 2) tasm printnum                                    
; 3) tlink main printnum                              
; 4) main -h (to see what program is capable of)      
; 5) main <filename> <symbol>                         
; ==================================================================================================


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
    help_msg1 db 'This program will write positions of specific symbol in document and will count how many times the symbol appeared in the document. The symbol could be passed as an argument or just inserted from keyboard.', '$'
    help_msg2 db 'To start the program please open it via MS-DOS like this "main <filename> <symbol>" or "main <filename>". If you want to see the output as pages use -p flag before inserting filename.', '$'
    no_args_msg db 'No arguments were passed, shutting down. Please try the main -h command.', '$'
    open_err_msg db 'The file could not be opened, shutting down.', '$'
    close_err_msg db 'The file could not be closed, shutting down.', '$'
    undefined_flag_msg db 'Undefined flag was used with program. You can use -h to see what this program is for.', '$'
    pos db 'The position is: ', '$'
    newline db 13, 10, '$'
    read_err_msg db 'Error while reading file', '$'
    prompt2 db 'Enter symbol: ', '$'
    stats_msg db 'The symbol appeared ', '$'
    stats_msg2 db ' times.', '$'
    press_key db 'Press enter to continue to new page...', '$'
    file_read_msg db 'Currently working with file: ', '$'
    args_buffer db 128 dup(0)       ; Buffer for arguments from command line
    buffer db 128 dup('$')          ; Buffer for reading from file
    symbol db 4 dup('$')            ; Buffer for symbol
    appearance_counter dw 0         ; Space to store the counter for appearance of symbol
    flag_p db 0                     ; Flag to see if -p is enabled

.code
EXTRN print_num:far                 ; Using far since the extern procedure is in the other code segment
start:
    mov ax, @data                   ; Move start of data segment into DS register
    mov ds, ax 

    mov ax, @stack                  ; Move start of stack segment into SP register
    mov sp, ax

    mov ah, 62h                     ; Get PSP segment
    int 21h                         ; Call DOS
    mov es, bx                      ; Put the descriptor of PSP into es

    mov cl, es:[80h]                ; Get the number of bytes in PSP
    cmp cl, 0                       ; If 0 bytes are in PSP then we have no arguments
    je err_no_arguments

    mov al, es:[82h]                ; Check if we have some flag
    cmp al, '-'                     
    jne parser

    mov al, es:[83h]                  
    cmp al, 'h'                     ; Check if the flag is help then write help message
    je display_help_message
    cmp al, 'p'                     ; Check if the flag is for paging then enable paging
    jne err_undefined_flag          ; If the flag is not 'p' or 'h' then write error
    mov [flag_p], 1                 ; Set flag as 1
    jmp parser                        

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
    
; ------------------------------------------------------------------------------------------------
; Main program 
parser:                   
    push ds                         ; Exchange registers before starting copying since
    push es                         ; movsb copies from ds:si to es:di
    pop ds
    pop es

    mov di, offset args_buffer      ; Prepare all registers for the movsb intruction    
    mov si, 82h
    mov al, es:[flag_p]             ;  If the flag is set then we have '-' on the 82h address and 'p'
    cmp al, 0                       ; on the 83h with [space] on 84h so we have to set SI as 85h
    je copy
    mov si, 85h                     ; If the paging flag enabled set SI as 85h
copy:    
    cld                             ; Clear direction flag to copy the line into buffer
    rep movsb                       ; Copy PSP into args_buffer
    push ds                         ; Exchange registers as they were before 
    push es                         ; Set segment registers as they were before 
    pop ds                           
    pop es
    mov si, offset args_buffer
    jmp check_symbol_args           ; Go to check if we have symbol that we want to check in document in the args

display_help_message:               ; Will be displayed when '-h' is used with program
    PRINT_LOGO
    PRINT newline
    PRINT help_msg1
    PRINT newline
    PRINT help_msg2
    PRINT newline
    jmp exit_program

check_symbol_args:                  ; Check if the symbol that will be checked was inserted via command line
    mov al, [si]                    ; Load symbol into AL register
    inc si                          ; Increment pointer
    cmp al, 0                       
    je ins_symbol_from_keyboard     ; If end of the buffer then go to insert symbol from keyboard
    cmp al, ' '                     ; If we saw [SPACE] than it means that probably after that will be symbol
    je checksym                     
    jmp check_symbol_args           ; Cycle while we will not see end of buffer or [SPACE]
checksym:
    mov ah, [si]
    cmp ah, 0                       ; If there was no symbol
    je ins_symbol_from_keyboard
    push ax                         ; Macro will use AX register but we want to save symbol
    OPEN_FILE args_buffer, 2, bx    ; BX will have file handle
    pop ax
    mov BYTE PTR [si], '$'          ; args_buffer will be used later to print name of file while paging
    mov dx, 0                       ; Set printed lines counter to 0  
    mov di, 0                       ; Set position in file to 0
    jmp main_loop

ins_symbol_from_keyboard:
    dec si
    mov BYTE PTR [si], '$'          ; args_buffer will be used later to print name of file while paging
    PRINT prompt2 
    mov dx, offset symbol           ; Read user input into symbol buffer
    mov ah, 0Ah
    int 21h                         ; DOS call to read symbol from keyboard
    OPEN_FILE args_buffer, 2, bx
    mov ah, [symbol+2]              ; First two bytes are size of input and [SPACE]
    mov dx, 0                       ; Set printed lines counter to 0 
    mov di, 0                       ; Set position in file to 0
    jmp main_loop 

err_open_file:                      ; If there was an error during opening file
    PRINT newline
    PRINT open_err_msg
    PRINT newline
    jmp exit_program

; ==============================================================================
; DX register - counter for printed lines into terminal for paging
; AX register - (AH - symbol) and (AL - char that we are reading at the moment)
; BX register - file descriptor
; CX register - nested loop iterator(CX <= 128)
; DI register - current position in file
; ==============================================================================
main_loop:
    push ax                         ; Save the symbol that we are comparing to
    push dx                         ; Save counter of appearance of symbol
    READ_FILE bx, buffer            ; Read file into buffer of 128 bytes
    pop dx                          ; Load counter of appearance of symbol
    mov cx, ax                      ; Load into cx the number of bytes that could be read
    pop ax                          ; Load symbol that we are comparing to
    mov si, offset buffer           ; Set si as start of buffer              
    cmp cx, 0                       ; Check if there is no bytes to read
    je print_counter                ; If nothing to read go to print all stats and end message
nested_loop:
    mov al, [si]                    ; Load char from buffer
    inc si                          ; Increment pointer on buffer
    inc di                          ; Increment position in file
    cmp al, ah                      ; Compare if same as symbol that user inserted
    jne skip_increment              ; Do not increment counter of appearance if not equal                         
    cmp dx, 23                      ; If 23 lines printed, wait for user input before continuing
    jne continue_processing         ; If DX is < 23 then just go to printing position      
    jmp end_page                    ; If DX is 23 then call end_page
continue_processing:  
    inc dx                          ; Increment DX  
    push ax                         ; Saving registers info so we can restore them later
    push bx                         ; All of the registers here will be used in PRINT macro or in print_num procedure
    push dx
    PRINT newline                   ; Print position of symbol in file
    PRINT pos
    mov ax, di
    mov bp, sp                      ; Saving stack pointer(procedure will have its own stack and will overwrite SP register)
    call print_num                  ; Write position of symbol into terminal
    mov sp, bp                      ; Load previous SP into SP
    pop dx                          ; Restore registers
    pop bx 
    pop ax
skip_increment:                              
    loop nested_loop                ; Iterate through nested loop
    jmp main_loop                   ; If CX == 0 then go to main loop
end_page:
    cmp [flag_p], 1                 ; Check if we have flag for paging enabled
    jne continue_processing         ; If not then just go print other pages
    je wait_for_page                ; If it is then wait for 'Enter' to be clicked
    jmp continue_processing         ; And then go print other lines
; ------------------------------------------------------------------------------------------------

err_read_file:                      ; If there was an error during reading file
    PRINT newline                       
    PRINT read_err_msg
    PRINT newline
    CLOSE_FILE bx                   ; Try closing file still
    jmp exit_program

print_counter:  
    add [appearance_counter], dx    ; This will add last symbols(since we are increasing number always by 23 because its size of page)
    ; Also instruction 'add' when paging is not enabled will add here entire counter, since DX will not be resetted to 0 while program runs without '-p' 
    CLOSE_FILE bx                   
    PRINT newline                   ; The block of instructions here will print the number of times when symbol appeared in document
    PRINT stats_msg                         
    mov ax, [appearance_counter]
    mov bp, sp    
    call print_num                  ; Call extern procedure to print decimal number
    mov sp, bp 
    PRINT stats_msg2
    jmp exit_program

wait_for_page:                      ; Print the message for user to click 'Enter' to go on new page
    push ax                         ; Saving registers since they will be used in PRINT macro
    push dx
    PRINT newline
    PRINT file_read_msg             ; Print file name on the page
    PRINT args_buffer
    PRINT newline
    PRINT press_key                 ; Print prompt to click an enter, to go on other page
    
wait_for_the_key:                   ; Block of instructions to wait for user to click 'Enter'
    mov ah, 08h                     ; Read key by DOS call
    int 21h
    cmp al, 13                      ; Waiting for enter key to be clicked by user
    jne wait_for_the_key            ; Busy wait
    pop dx                          ; Load previous info in registers
    pop ax
    add [appearance_counter], dx    ; Increment the appearance counter by 23
    mov dx, 0                       ; Set DX as zero since we will print new page
    jmp continue_processing       

exit_program:                       
    mov ah, 4Ch
    int 21h

err_close_file:                     ; When file could not be closed properly
    PRINT newline
    PRINT close_err_msg
    PRINT newline
    jmp exit_program    

end start

; ==================================================================================================
;                                E V A L U A T I O N   F O R   W O R K
; ==================================================================================================
; The program successfully runs in MS-DOS, processing character input from both arguments and 
; keyboard. It correctly finds and prints all occurrences of the given character in the file.
; Also program prints how many times the symbol appeared in the document, and has user friendly 
; paging mechanism to show the output as pages.
;
;                                   F U N C T I O N A L I T Y
; - The program works as expected, including file handling and symbol counting.  
; - Bonus tasks like paging and external procedure for number printing are implemented correctly.  
; - Error handling is included for missing files and invalid input.  
;
;
;                               P O S S I B L E    I M P R O V E M E N T S
; - Could support files located deep in directories 
; (i.e., filenames that are too long to open due to excessive directory depth)  
; - Buffered output might improve performance for large files.  
; - More user-friendly formatting in the terminal could be added(reverse output/navigation in pages).
; - Could support files that are larger then 64KB   
;
;                                            T E S T I N G 
;  The file was tested with 65535 bytes document containing 'Lorem Ipsum' text and other smaller
; files also. The files that are larger then 64KB will be handled without error but the position
; of symbols after 65535 byte of document will start from 0 again. Also in the situation when file
; file will contain only 'a' and we will search for the 'a' symbol the counter of appearance will 
; be overflowed. Still the code works for almost all input, except files that are larger then 64KB.
; 
;                                          C O N C L U S I O N
;  This program works for lots of input. It uses 128 byte buffer to read file segments and then 
; program reads symbols from 128 byte buffer. Program implmenets paging and user-friendly interface
; with lots of comments near almost every instruction.
; ==================================================================================================
