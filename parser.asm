.model small
.stack

INCLUDE macros.inc


.data
    logo1 db ' _____  ___   _____  _____ ___________  ', '$'
    logo2 db '| ___ \/ _ \ | ___ \/  ___|  ___| ___ \ ', '$'
    logo3 db '| |_/ / /_\ \| |_/ /\ `--.| |__ | |_/ / ', '$'
    logo4 db '|  __/|  _  ||    /  `--. \  __||    /  ', '$'
    logo5 db '| |   | | | || |\ \ /\__/ / |___| |\ \  ', '$'
    logo6 db '\_|   \_| |_/\_| \_|\____/\____/\_| \_| ', '$'
    help_msg db 'This program will count how many times the symbol appeared in the document. The symbol could be passed as an argument or just inserted from keyboard.', '$'
    no_args_msg db 'No arguments were passed, shutting down...', '$'
    open_error_msg db 'The file could not be opened, restart program.', '$'
    close_error_msg db 'The file could not be closed, restart program.', '$'
    undefined_flag_msg db 'Undefined flag was used with program. You can use -h to see what this program is for.', '$'

    read_err_msg db 'Error while reading file', '$'
    prompt2 db 'Enter symbol: ', '$'
    bye_msg db 'The symbol appeared ', '$'
    bye_msg2 db ' times.', '$'
    args_buffer db 128 dup(0) 
    buffer db 128 dup('$')  
    symbol db 5 dup('$')

.code
start:
    mov si, 80h
    mov cl, [si]
    cmp cl, 0
    je no_arguments

    mov si, 82h
    mov al, [si]
    cmp al, '-'
    jne main_start

    inc si
    mov al, [si]
    cmp al, 'h'
    mov ax, @data           ; Since we can not move directly start of data segment to DS we have to make this via another register
    mov ds, ax 
    jne undefined_flag

    jmp print_logo

no_arguments:
    mov ax, @data           ; Since we can not move directly start of data segment to DS we have to make this via another register
    mov ds, ax 
    NEWLINE
    PRINT no_args_msg
    NEWLINE
    jmp exit_program

undefined_flag:
    NEWLINE
    PRINT undefined_flag_msg
    NEWLINE
    jmp exit_program

main_start:
    mov si, 80h
    mov cl, [si]
    mov di, offset args_buffer 
    mov si, 82h
    rep movsb   

    OPEN_FILE args_buffer, 2, bx

    mov ax, @data           ; Since we can not move directly start of data segment to DS we have to make this via another register
    mov ds, ax 

    PRINT prompt2

    ; Read user input
    mov dx, offset symbol
    mov ah, 0Ah
    int 21h

    ; Prepare for loop
    mov cx, 0

main_loop:
    push cx
    READ_FILE bx, buffer
    pop cx
    mov dl, [symbol+2]
    mov si, offset buffer
    mov dh, al
    cmp al, 0
    je print_bye
nested_loop:
    mov al, [si]            ; Load char from buffer
    inc si                  ; Increment pointer on buffer
    cmp al, dl              ; Compare if same as symbol that we wrote
    je inc_stats
still_loop:    
    dec dh
    cmp dh, 0
    je main_loop
    jmp nested_loop    

inc_stats:
    inc cx
    jmp still_loop   


open_error:
    NEWLINE
    PRINT open_error_msg
    NEWLINE
    jmp exit_program

read_error:
    NEWLINE
    PRINT undefined_flag_msg
    NEWLINE
    jmp exit_program

print_bye:
    CLOSE_FILE bx
    NEWLINE
    PRINT bye_msg
    mov ax, cx
    call print_number
    PRINT bye_msg2
    NEWLINE

exit_program:
    mov ah, 4Ch
    int 21h




print_number:
    mov bx, 10          ; Делитель для выделения цифр
    mov di, offset buffer ; Буфер для хранения цифр

convert:
    xor dx, dx          ; Обнуляем DX перед делением (важно для 16-битного деления)
    div bx              ; AX / 10, AX = результат деления, DX = остаток
    add dl, '0'         ; Преобразуем остаток (DX) в ASCII-символ
    mov [di], dl        ; Сохраняем цифру в буфер
    inc di
    cmp ax, 0
    jne convert         ; Продолжаем деление, пока AX != 0

; Выводим цифры в правильном порядке
print_loop:
    dec di              ; Сдвигаем указатель назад для вывода цифр в правильном порядке
    mov dl, [di]        ; Загружаем цифру в DL
    mov ah, 02h         ; Функция DOS для вывода символа
    int 21h             ; Печатаем символ
    cmp di, offset buffer
    jne print_loop

    ret







close_error:
    NEWLINE
    PRINT close_error_msg
    NEWLINE
    jmp exit_program    

print_logo:
    PRINT logo1
    NEWLINE
    PRINT logo2
    NEWLINE
    PRINT logo3
    NEWLINE
    PRINT logo4
    NEWLINE
    PRINT logo5
    NEWLINE
    PRINT logo6
    NEWLINE
    NEWLINE
    PRINT help_msg
    NEWLINE
    jmp exit_program

end start
