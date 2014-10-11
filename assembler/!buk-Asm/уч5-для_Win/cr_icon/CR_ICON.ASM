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
extrn            PostQuitMessage:PROC
extrn            RegisterClassExA:PROC
extrn            ShowWindow:PROC
extrn            TranslateMessage:PROC
extrn            UpdateWindow:PROC


WNDCLASSEX struct
        clSize           dword    ?   ; class style
        clStyle          dword    ?   ; class style
        clLpfnWndProc    dword    ?
        clCbClsExtra     dword    ?
        clCbWndExtra     dword    ?
        clHInstance      dword    ?   ; instance handle
        clHIcon          dword    ?   ; class icon handle
        clHCursor        dword    ?   ; class cursor handle
        clHbrBackground  dword    ?   ; class background brush
        clLpszMenuName   dword    ?   ; menu name
        clLpszClassName  dword    ?   ; far ptr to class name
        clHIconSm        dword    ?   ; class small icon handle
WNDCLASSEX ends


.data

newhwnd          dd 0
msg              MSGSTRUCT   <?>
wc               WNDCLASSEX   <?>

hInst            dd 0

szIconName       db 'ICON_1', 0
szIconSmName     db 'ICON_SM', 0
szTitleName      db 'Win32 Assembly Program', 0
szClassName      db 'ASMCLASS32',0

.code
;-----------------------------------------------------------------------------
start:

        push    0
        call    GetModuleHandleA        ; get hmod (in eax)
        mov     [hInst], eax            ; hInstance is same as HMODULE
                                        ; in the Win32 world
; initialize the WndClass structure
        mov     [wc.clSize], size WNDCLASSEX
        mov     [wc.clStyle], CS_HREDRAW + CS_VREDRAW + CS_GLOBALCLASS
        mov     [wc.clLpfnWndProc], offset WndProc
        mov     [wc.clCbClsExtra], 0
        mov     [wc.clCbWndExtra], 0

        mov     eax, [hInst]
        mov     [wc.clHInstance], eax

        push    offset szIconName
        push    [hInst]
        call    LoadIconA
        mov     [wc.clHIcon], eax

        push    offset szIconSmName
        push    [hInst]
        call    LoadIconA
        mov     [wc.clHIconSm], eax

        push    IDC_ARROW
        push    0
        call    LoadCursorA
        mov     [wc.clHCursor], eax

        mov     [wc.clHbrBackground], COLOR_WINDOW + 1
        mov     dword ptr [wc.clLpszMenuName], 0
        mov     dword ptr [wc.clLpszClassName], offset szClassName

        push    offset wc
        call    RegisterClassExA

        push    0                        ; lpParam
        push    [hInst]                  ; hInstance
        push    0                        ; menu
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
finish:
        ret
WndProc          endp
ends
end start

