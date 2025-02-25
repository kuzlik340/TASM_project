.model small
.stack 100h

INCLUDE macros.inc
PUBLIC parser


.data
    logo1 db ' _____  ___   _____  _____ ___________  ', '$'   ; Project logo
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
    newline db 13, 10, '$'
    read_err_msg db 'Error while reading file', '$'
    prompt2 db 'Enter symbol: ', '$'
    bye_msg db 'The symbol appeared ', '$'
    bye_msg2 db ' times.', '$'
    args_buffer db 128 dup(0) 
    buffer db 128 dup('$')  
    symbol db 5 dup('$')



.code
parser PROC

parser ENDP
END