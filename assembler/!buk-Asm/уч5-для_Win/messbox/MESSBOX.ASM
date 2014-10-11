.386
.model flat, stdcall

extrn            MessageBoxA:PROC
extrn            ExitProcess:PROC


.data

mb_text             db 'Hello, World!',0
mb_title            db 'My first program',0

.code
start:
                 push   0
                 push   offset mb_title
                 push   offset mb_text
                 push   0
                 call   MessageBoxA
                 push   0
                 call   ExitProcess

ends
end start

