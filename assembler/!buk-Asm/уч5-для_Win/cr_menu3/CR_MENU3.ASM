.386
.model flat, stdcall
include win32.inc

extrn            DefWindowProcA:PROC
extrn            DispatchMessageA:PROC
extrn            ExitProcess:PROC
extrn            GetMessageA:PROC
extrn            GetModuleHandleA:PROC
extrn            LoadCursorA:PROC
extrn            LoadIconA:PROC
extrn            LoadMenuIndirectA:PROC
extrn            MessageBoxA:PROC
extrn            PostQuitMessage:PROC
extrn            RegisterClassA:PROC
extrn            ShowWindow:PROC
extrn            TranslateMessage:PROC
extrn            UpdateWindow:PROC

; Menu flags
; win40  -- A lot of MF_* flags have been renamed as MFT_* and MFS_* flags
;
; Menu flags for Add/Check/EnableMenuItem()
MF_INSERT               equ 0000h
MF_CHANGE               equ 0080h
MF_APPEND               equ 0100h
MF_DELETE               equ 0200h
MF_REMOVE               equ 1000h

MF_BYCOMMAND    equ 0000h
MF_BYPOSITION   equ 0400h

MF_SEPARATOR    equ 0800h

MF_ENABLED              equ 0000h
MF_GRAYED               equ 0001h
MF_DISABLED             equ 0002h

MF_UNCHECKED    equ 0000h
MF_CHECKED              equ 0008h
MF_USECHECKBITMAPS equ 0200h

MF_STRING               equ 0000h
MF_BITMAP               equ 0004h
MF_OWNERDRAW    equ 0100h

MF_POPUP                equ 0010h
MF_MENUBARBREAK equ 0020h
MF_MENUBREAK    equ 0040h

MF_UNHILITE             equ 0000h
MF_HILITE               equ 0080h

MF_DEFAULT              equ 1000h
MF_SYSMENU              equ 2000h
MF_HELP         equ 4000h
MF_RIGHTJUSTIFY equ 4000h

MF_MOUSESELECT  equ 8000h
MF_END          equ 0080h  ; Obsolete -- only used by old RES files

MFT_STRING              equ MF_STRING
MFT_BITMAP              equ MF_BITMAP
MFT_MENUBARBREAK        equ MF_MENUBARBREAK
MFT_MENUBREAK   equ MF_MENUBREAK
MFT_OWNERDRAW   equ MF_OWNERDRAW
MFT_RADIOCHECK  equ 0200h
MFT_SEPARATOR   equ MF_SEPARATOR
MFT_RIGHTORDER  equ 2000h
MFT_RIGHTJUSTIFY        equ MF_RIGHTJUSTIFY

; Menu flags for Add/Check/EnableMenuItem()
MFS_GRAYED          equ 0003h
MFS_DISABLED        equ MFS_GRAYED
MFS_CHECKED         equ MF_CHECKED
MFS_HILITE          equ MF_HILITE
MFS_ENABLED         equ MF_ENABLED
MFS_UNCHECKED       equ MF_UNCHECKED
MFS_UNHILITE        equ MF_UNHILITE
MFS_DEFAULT         equ MF_DEFAULT

;-----------------------------------

IDM_1     EQU 1
IDM_2     EQU 2
IDM_EXIT  EQU 3
IDM_ABOUT EQU 4

MENUEX_TEMPLATE_HEADER struct
    wVersion       dw ?
    wOffset        dw ?
    dwHelpId       dd ?
MENUEX_TEMPLATE_HEADER ends

;MENUEX_TEMPLATE_ITEM struct
;     dwType        dd ?
;     dwState       dd ?
;     uId           dd ?
;     bResInfo      dw ?
;     WCHAR  szText[1]
;    dwHelpId       dd ?
;MENUEX_TEMPLATE_ITEM

.data

hMenu            dd ?
newhwnd          dd 0
msg              MSGSTRUCT   <?>
wc               WNDCLASS    <?>

hInst            dd 0

szTitleName      db 'Win32 Assembly Program', 0
szClassName      db 'ASMCLASS32',0
mb_message       db 'Win32 Assembler: Menu',0
mb_title         db 'About',0

;
; Menu template
;
MFR_END equ 80h
MFR_POPUP       equ 01h

align   4              ; must align on DWORD boundary
MenuTemplate      MENUEX_TEMPLATE_HEADER<1,4,0>

                  ; &File
                  dd MFT_STRING  ;     Type
                  dd MFS_ENABLED ;     State
                  dd 0           ;     Id
                  dw MFR_POPUP   ;     ResInfo
                  dw '&','F','i','l','e',0,0   ;     Text
                  dd 0           ;     HelpId

                  ; MenuItem &GRAYED
                  dd MFT_STRING  ;     Type
                  dd MFS_GRAYED  ;     State
                  dd IDM_1       ;     Id
                  dw 0           ;     ResInfo
                  dw 'M','e','n','u','I','t','e','m',' '   ; Text
                  dw '&','G','R','A','Y','E','D',0
                  ; dd 0 - HelpId only with popup menu

                  ; MenuItem &DISABLED
                  dd MFT_STRING  ;     Type
                  dd MF_DISABLED ;     State
                  dd IDM_2       ;     Id
                  dw 0           ;     ResInfo
                  dw 'M','e','n','u','I','t','e','m',' '   ; Text
                  dw '&','D','I','S','A','B','L','E','D',0
                  ; dd 0         ;     HelpId

                  ; ------------------
                  dd MFT_SEPARATOR,0,0
                  dw 0,0

                  ; E&xit
                  dd MFT_STRING  ;     Type
                  dd MFS_ENABLED ;     State
                  dd IDM_EXIT    ;     Id
                  dw MFR_END     ;     ResInfo
                  dw 'E','&','x','i','t',0,0    ; Text
                  ; dd 0         ;     HelpId

                  ; &About
                  dd MFT_STRING  ;     Type
                  dd MFS_ENABLED ;     State
                  dd IDM_ABOUT   ;     Id
                  dw MFR_END     ;     ResInfo
                  dw '&','A','b','o','u','t',0    ; Text
                  ;  dd 0        ;     HelpId

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

        push    offset MenuTemplate
        call    LoadMenuIndirectA
        mov     [hMenu], eax

        mov     [wc.clsHbrBackground], COLOR_WINDOW + 1
        mov     dword ptr [wc.clsLpszMenuName], 0
        mov     dword ptr [wc.clsLpszClassName], offset szClassName

        push    offset wc
        call    RegisterClassA
extrn            CreateWindowExA:PROC

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
        xor    eax, eax
wmnext:
        cmp     eax, IDM_EXIT
        je      wmdestroy

finish:
        ret
WndProc          endp
ends
end start

