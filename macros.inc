; ===========================
; Macro to print a message
; ===========================
PRINT MACRO msg
    mov dx, offset msg     ; This will load to DX register offset to the start of msg
    mov ah, 09h            ; This will call an API from MS-DOS to print prompt1
    int 21h                ; Call MS-DOS kernel
ENDM

; ===========================
; Macro to open a file
; ===========================
OPEN_FILE MACRO filename, mode, file_handle
    mov ah, 3Dh            ; Function: Open file
    mov al, mode           ; Mode: 0 = Read, 1 = Write, 2 = Read/Write
    lea dx, filename       ; Pointer to filename
    int 21h                ; DOS Interrupt
    jc err_open_file       ; Jump if error (Carry Flag set)
    mov file_handle, ax    ; Store file handle
ENDM

; ===========================
; Macro to close a file
; ===========================
CLOSE_FILE MACRO file_handle
    mov ah, 3Eh            ; Function: Close file
    mov bx, file_handle    ; Pass file handle
    int 21h                ; DOS Interrupt
    jc err_close_file        ; Jump if error (Carry Flag set)
ENDM


; ===================================
; Macro to read file
; ===================================

READ_FILE MACRO file_handle, buffer_name
    mov ah, 3Fh              ; Function: Read from file
    mov bx, file_handle      ; File handle
    mov cx, 128              ; Number of bytes to read
    lea dx, buffer_name      ; Load buffer address into DX
    int 21h                  ; DOS interrupt
    jc err_read_file         ; Jump if an error occurred
ENDM

; ===================================
; Macro to print logo of project
; ===================================

PRINT_LOGO MACRO
    PRINT logo1
    PRINT newline
    PRINT logo2
    PRINT newline
    PRINT logo3
    PRINT newline
    PRINT logo4
    PRINT newline
    PRINT logo5
    PRINT newline
    PRINT logo6
    PRINT newline
ENDM
