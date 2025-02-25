.model small
.stack 100h

INCLUDE macros.inc
PUBLIC print_num
.data
    buffer_num db 5

.code
print_num PROC
; ============================================================================
; Block of instructions to convert number that is >9 into decimal and print it
; into the terminal.
; ============================================================================
print_number:
    mov bx, 10          ; Делитель для выделения цифр
    mov di, offset buffer_num ; Буфер для хранения цифр

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
    cmp di, offset buffer_num
    jne print_loop
    ret

print_num ENDP
END