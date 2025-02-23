PRINT MACRO msg
    mov dx, offset msg     ; This will load to DX register offset to the start of msg
    mov ah, 09h            ; This will call an API from MS-DOS to print prompt1
    int 21h                ; Call MS-DOS kernel
ENDM

NEWLINE MACRO
    mov dl, 0Dh     ; Carriage Return
    mov ah, 02h     ; DOS Function: Print Character
    int 21h

    mov dl, 0Ah     ; Line Feed
    mov ah, 02h
    int 21h
ENDM

; ===========================
; Macro to open a file
; ===========================
OPEN_FILE MACRO filename, mode, file_handle
    mov ah, 3Dh            ; Function: Open file
    mov al, mode           ; Mode: 0 = Read, 1 = Write, 2 = Read/Write
    mov dx, filename       ; Pointer to filename
    int 21h                ; DOS Interrupt
    jc open_error          ; Jump if error (Carry Flag set)
    mov file_handle, ax    ; Store file handle
ENDM

; ===========================
; Macro to close a file
; ===========================
CLOSE_FILE MACRO file_handle
    mov ah, 3Eh            ; Function: Close file
    mov bx, file_handle    ; Pass file handle
    int 21h                ; DOS Interrupt
    jc close_error         ; Jump if error (Carry Flag set)
ENDM
