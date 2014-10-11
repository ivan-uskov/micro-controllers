locals
jumps

.model large, WINDOWS PASCAL

; ���������� ���� �������� �������� � �������� API

include windows.inc

; ��������� ������������ �������

extrn   BEGINPAINT:PROC
extrn   CREATEWINDOW:PROC
extrn   DEFWINDOWPROC:PROC
extrn   DISPATCHMESSAGE:PROC
extrn   ENDPAINT:PROC
extrn   GETMESSAGE:PROC
extrn   GETSTOCKOBJECT:PROC
extrn   INITAPP:PROC
extrn   INITTASK:PROC
extrn   LOADCURSOR:PROC
extrn   MESSAGEBOX:PROC
extrn   POSTQUITMESSAGE:PROC
extrn   REGISTERCLASS:PROC
extrn   SHOWWINDOW:PROC
extrn   TEXTOUT:PROC
extrn   TRANSLATEMESSAGE:PROC
extrn   UPDATEWINDOW:PROC
extrn   WAITEVENT:PROC


.data

; ��� Windows Task Manager

		db	16 dup(0)

; HINSTANCE ������ ����������

hInstance	dw	?

; �������� ��������� ���� 

cmdShow		dw	?

; ��������� PAINTSTRUCT

lppaint     PAINTSTRUCT <0>

; ��������� ��������� MSGSTRUCT

msg         MSGSTRUCT   <0>

; ��������� �������� ����

wc          WNDCLASS    <0>

; ��������� ����

lpszTitleName     db 'First Window',0

; �������� ������ ����

lpszClassName     db 'ASMCLASS',0

; ��������� � ���� ������

lpszText	db	'Hello World'

; ����� ������ lpszText

lpszTextLength	equ	$-lpszText

; ��������� ����������� ����

lpszCaption	db	'Mouse Event',0

; ��������� ����������� ����

lpszLeftMsg	db	'Left button pressed',0
lpszRightMsg	db	'Right button pressed',0

.code
.286

; ��� ��������� � WarLords "Lets The War Begins"

start:

; �������������� ������ � �������� ������� ���������

	call	INITTASK
	or	ax,ax

; ���� ������������� ������ ������� 

	jnz	@@OK

; ���� ������ 

	jmp	@@Fail

@@OK: 

; ��������� HINSTANCE

	mov	[hInstance],di

; ��������� �������� ��������� ����

	mov	[cmdShow],dx

; �������������� ����������

	call	INITAPP,hInstance
	or	ax,ax
	jnz	@@InitOK

@@Fail:

; ���� ������������� ����������� ��������

	mov	ax, 4CFFh
	int	21h          ; terminate program


@@InitOK:

; ��������� ��������� �������� ����
	
	mov	[wc.clsStyle],0
	mov	word ptr [wc.clsLpfnWndProc],offset WndProc
	mov	word ptr [wc.clsLpfnWndProc+2],seg WndProc
	mov	[wc.clsCbClsExtra],0
	mov	[wc.clsCbWndExtra],0
	mov	ax,[hInstance]
	mov	[wc.clsHInstance],ax
	mov	[wc.clsHIcon],0

; ��������� ������ IDC_ARROW � ��������� ��� � ���������

	xor	ax,ax
	call   	LOADCURSOR,ax IDC_ARROW
	mov    	[wc.clsHCursor],ax

; ��������� ���� ������ ���� � ��������� ��� � ���������

	call   	GETSTOCKOBJECT,WHITE_BRUSH
	mov    	[wc.clsHbrBackground],ax

	mov    	word ptr [wc.clsLpszMenuName],0
	mov    	word ptr [wc.clsLpszMenuName+2],0

	mov    	word ptr [wc.clsLpszClassName],offset lpszClassName
	mov    	word ptr [wc.clsLpszClassName+2],ds

; ������������ ��������� �������� ����

	call   	REGISTERCLASS,ds offset wc

; ������� ����

	xor	ax,ax
	mov	bx,CW_USEDEFAULT
	call	CREATEWINDOW,ds offset lpszClassName,ds offset lpszTitleName,\
		             WS_OVERLAPPEDWINDOW,ax,bx,bx,bx,bx,ax,ax,\
			     [hInstance],ax,ax

; ���������� ����

	push	ax
	call	SHOWWINDOW,ax,cmdShow

; ��������� ����

	pop	ax
	call	UPDATEWINDOW,ax

; ���� ��������� ���������

msg_loop:

; �������� ���������

	call	GETMESSAGE,ds offset msg,0,0,0

; ��������� �� ������� ��������� WM_QUIT (AX=0)

	cmp	ax,0
	je	end_loop

; ������������ ���������

	call	TRANSLATEMESSAGE,ds offset msg

	call	DISPATCHMESSAGE,ds offset msg

; ������������ ��������� ���������

	jmp	msg_loop

end_loop:

; ������� �� ���������

	mov	ax,[msg.msWPARAM]
	mov	ah,4Ch
	int	21h

;
; ��������� ��������� ���������
;

WndProc		PROC
	ARG	hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

	cmp	[wmsg],WM_DESTROY

; ���� �������� ��������� WM_DESTROY (�������� ��������� "�� �����")

	je	wmdestroy
	cmp	[wmsg],WM_LBUTTONDOWN

; ���� �������� ��������� WM_LBUTTONDOWN (������ ����� ������ ����)

	je	wmlbuttondown
	cmp	[wmsg],WM_CREATE

; ���� �������� ��������� WM_CREATE (�������� ��������� "������� ����")

	je	wmcreate
	cmp	[wmsg],WM_RBUTTONDOWN

; ���� �������� ��������� WM_RBUTTONDOWN (������ ������ ������ ����) 

	je	wmrbuttondown
	cmp	[wmsg],WM_PAINT

; ���� �������� ��������� WM_PAINT (�������� ��������� "���������")

	je	wmpaint

; ���� �� �� ������������ �� ���� �� ����������������� ��������� ��������
; ���������� ������������ �����������

	jmp	defwndproc

; 
; ��������� ��������� WM_PAINT
;

wmpaint:

; �������� ��������� � �������� ��������� �� ������� DC

	call	BEGINPAINT,hwnd,ds offset lppaint

; AX �������� �������� ���������� ������ DC, ���������� ����� ������ BEGINPAINT

; �������� TEXTOUT ��� ������ ������ lpszText

	call	TEXTOUT,ax,5,5,ds offset lpszText,lpszTextLength

; ����������� ���������

	call    ENDPAINT,hwnd,ds offset lppaint

; �������� AX � �� �����

	xor	ax,ax
	jmp	finish

;
; ��������� ��������� WM_CREATE
;

wmcreate:

; �������� AX � �� �����

	xor	ax,ax
	jmp	finish

;
; ����� ������������ ����������� ��������� 
;

defwndproc:

	call	DEFWINDOWPROC,hwnd,wmsg,wparam,lparam
	jmp	finish

;
; ��������� ��������� WM_DESTROY
;

wmdestroy:

; �������� POSTQUITMESSAGE

	call	POSTQUITMESSAGE,0

; �������� AX � �� �����

	xor	ax,ax
	jmp	finish

;
; ��������� ��������� WM_LBUTTONDOWN
;

wmlbuttondown:

; ������� �� ����� MESSAGEBOX � �������� "Left button pressed"

	call	MESSAGEBOX,0,ds offset lpszLeftMsg,ds offset lpszCaption,0

; �������� AX � �� �����

	xor	ax,ax
	jmp	finish

;
; ��������� ��������� WM_RBUTTONDOWN
;

wmrbuttondown:

; ������� �� ����� MESSAGEBOX � �������� "Right button pressed"

	call	MESSAGEBOX,0,ds offset lpszRightMsg,ds offset lpszCaption,0

; �������� AX � �� �����

	xor	ax,ax
	jmp	finish

;
; "�������� ������"
;

finish:

; �������� DX � �� �����

	xor	dx,dx
	ret

WndProc         ENDP


end start

