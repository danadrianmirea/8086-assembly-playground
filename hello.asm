GetStdHandle PROTO
ExitProcess PROTO
WriteConsoleA PROTO

.data
msg BYTE "Hello world",0
bytesWritten DWORD ?
adi db 65,68,73

.code
main PROC
    sub rsp, 5 * 8  

    mov rcx, -11           
    call GetStdHandle

    mov  rcx, rax       
    lea  rdx, msg
    mov  r8, LENGTHOF msg-1
    lea  r9, bytesWritten  
    mov  QWORD PTR [rsp + 4 * SIZEOF QWORD], 0
    call WriteConsoleA

    mov rcx, 0      
    call ExitProcess
main ENDP
END