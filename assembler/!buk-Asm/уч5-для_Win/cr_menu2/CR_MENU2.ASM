.386
.model flat, stdcall
include win32.inc

extrn            CreateWindowExA:PROC
extrn            DefWindowProcA:PROC
extrn            DispatchMessageA:PROC
extrn            ExitProcess:PROC
extrn            GetMessageA:PROC
extrn            GetModuleHandleA:PROC
extrn            LoadCursorA:PROC
extrn            LoadIconA:PROC
extrn            LoadMenuA:PROC
extrn            MessageBoxA:PROC
extrn            PostQuitMessage:PROC
extrn            RegisterClassA:PROC
extrn            ShowWindow:PROC
extrn            TranslateMessage:PROC
extrn            UpdateWindow:PROC


IDM_1     EQU 1
IDM_2     EQU 2
IDM_EXIT  EQU 3
IDM_ABOUT EQU 4

.data

newhwnd          dd 0
hMenu            dd ?
msg              MSGSTRUCT   <?>
wc               WNDCLASS    <?>

hInst            dd 0

szMenuName       db 'MENU_1', 0
szTitleName      db 'Win32 Assembly Program', 0
szClassName      db 'ASMCLASS32',0
mb_message       db 'Win32 Assembler: Menu',0
mb_title         db 'About',0

.code
;-----------------------------------------------------------------------------
start:

        push    0
        call    GetModuleHandleA        ; get hmod (in eax)
        mov     [hInst], eax            ; hInstance is same as HMODULE
                                        ; in the Win32 world
; initialize the WndClass structure
        mov     [wc.clsStyle], CS_HREDRAW + CS_VREDRAW + CS_GLOBALCLASS
        mov     [wc.clsLpfnWndProc], offset WndProc
        mov     [wc.clsCbClsExtra], 0
        mov     [wc.clsCbWndExtra], 0

        mov     eax, [hInst]
        mov     [wc.clsHInstance], eax

        push    IDI_APPLICATION
        push    0
        call    LoadIconA
        mov     [wc.clsHIcon], eax

        push    IDC_ARROW
        push    0
        call    LoadCursorA
        mov     [wc.clsHCursor], eax

        push    offset szMenuName
        push    [hInst]
        call    LoadMenuA
        mov     [hMenu], eax

        mov     [wc.clsHbrBackground], COLOR_WINDOW + 1
        mov     dword ptr [wc.clsLpszMenuName], 0
        mov     dword ptr [wc.clsLpszClassName], offset szClassName

        push    offset wc
        call    RegisterClassA

        push    0                        ; lpParam
        push    [hInst]                  ; hInstance
        push    [hMenu]                  ; menu
        push    0                        ; parent hwnd
        push    CW_USEDEFAULT            ; height
        push    CW_USEDEFAULT            ; width
        push    CW_USEDEFAULT            ; y
        push    CW_USEDEFAULT            ; x
        push    WS_OVERLAPPEDWINDOW      ; Style
        push    offset szTitleName       ; Title string
        push    offset szClassName       ; Class name
        push    0                        ; extra style

        call    CreateWindowExA

        mov     [newhwnd], eax

        push    SW_SHOWNORMAL
        push    [newhwnd]
        call    ShowWindow

        push    [newhwnd]
        call    UpdateWindow

msg_loop:
        push    0
        push    0
        push    0
        push    offset msg
        call    GetMessageA

        cmp     ax, 0
        je      end_loop

        push    offset msg
        call    TranslateMessage

        push    offset msg
        call    DispatchMessageA

        jmp     msg_loop

end_loop:
        push    [msg.msWPARAM]
        call    ExitProcess


;-----------------------------------------------------------------------------
WndProc          proc uses ebx edi esi, hwnd:DWORD, wmsg:DWORD,\
                 wparam:DWORD, lparam:DWORD

        cmp     [wmsg], WM_DESTROY
        je      wmdestroy
        cmp     [wmsg], WM_COMMAND
        je      wmcommand

        push    [lparam]
        push    [wparam]
        push    [wmsg]
        push    [hwnd]
        call    DefWindowProcA
        jmp     finish

wmdestroy:
        push    0
        call    PostQuitMessage
        mov     eax, 0
        jmp     finish

wmcommand:
        mov     eax, [wparam]
        cmp     eax, IDM_ABOUT
        jne     wmnext
        push   0
        push   offset mb_title
        push   offset mb_message
        push   0
        call   MessageBoxA
wmnext:
        cmp     eax, IDM_EXIT
        je      wmdestroy

finish:
        ret
WndProc          endp
ends
end start

