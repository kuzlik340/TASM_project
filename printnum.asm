.model small
.stack

; ===============================================================================
; Procedure to convert number that is >9 into decimal and print it into the
; terminal via DOS API. To call this procedure please use EXTRN print_num
; in code segment, compile this module separately and link it via TLINK
; ===============================================================================

PUBLIC print_num
.data
    buffer_num db 5            ; Buffer to contain the num that will be < 65536

.code
print_num PROC
print_number:
    push si
    mov bx, 10                  ; Diviser for the decimal system 
    mov si, offset buffer_num   ; Save pointer on buffer

convert:
    mov dx, 0                   ; Set as 0
    div bx                      ; AX / 10, AX = result of division, DX = modulo
    add dl, '0'                 ; Translate number into ASCII character
    mov [si], dl                ; Save into buffer ASCII number
    inc si                      ; Increment pointer on buffer
    cmp ax, 0                   ; If the number was transformed
    jne convert                 ; Continue division until AX = 0

print_loop:
    dec si                      ; Decrement pointer (the printing of number will be reversed from buffer)
    mov dl, [si]                ; Load number into DL
    mov ah, 02h                 ; DOS func to print character
    int 21h                     ; call DOS
    cmp si, offset buffer_num
    jne print_loop              ; print untill start of buffer
    pop si
    ret

print_num ENDP
END