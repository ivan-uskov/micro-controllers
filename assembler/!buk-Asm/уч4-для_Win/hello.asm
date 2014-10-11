.model large, WINDOWS PASCAL

; ���������� ���� ��� ������� ��������� (���� "MB_OK","MB_ICONEXCLAMATION")

include windows.inc

; ������� ��� ����� ������������ ������� Windows API

extrn 	MESSAGEBOX:proc
extrn   INITAPP:PROC
extrn   INITTASK:PROC

; ������� ������

.data

; ��������� �������� ��� Windows Task Manager

freespace	db	16 dup(0)

; ��������� ����������� ����

lpszTitle	db	'Generic Sample Assembly Application',0

; ����� ����������� ����

lpszText	db	'Hello World !',0

; ������������� ����������

hInstance	dw	0

;������� ����

.code

; ��� ������ "������" start (�� ����� ���� WinMain)

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

; �������������� ����������

	call	INITAPP,hInstance
	or	ax,ax
	jnz	@@InitOK

@@Fail:

; ���� ������������� ����������� ��������

	mov	ax, 4CFFh
	int	21h          ; terminate program

@@InitOK:

; ������� �� ����� ���������� ����

	call	MESSAGEBOX,0,ds offset lpszText,ds offset lpszTitle,MB_OK+MB_ICONEXCLAMATION

; ��-�� � ��� � �����

	mov	ax,4c00h
	int	21h

end start