.model large, WINDOWS PASCAL

; Подключаем файл где описаны константы (типа "MB_OK","MB_ICONEXCLAMATION")

include windows.inc

; Говорим что будем использовать функции Windows API

extrn 	MESSAGEBOX:proc
extrn   INITAPP:PROC
extrn   INITTASK:PROC

; Сегмент данных

.data

; маленькая хитрость для Windows Task Manager

freespace	db	16 dup(0)

; заголовок диалогового окна

lpszTitle	db	'Generic Sample Assembly Application',0

; текст диалогового окна

lpszText	db	'Hello World !',0

; идентификатор приложения

hInstance	dw	0

;Сегмент кода

.code

; Наш старый "добрый" start (На самом деле WinMain)

start:

; Инициализируем задачу и получаем входные параметры

	call	INITTASK
	or	ax,ax

; Если инициализация прошла успешно 

	jnz	@@OK

; Если ошибка 

	jmp	@@Fail

@@OK: 

; Сохраняем HINSTANCE

	mov	[hInstance],di

; Инициализируем приложение

	call	INITAPP,hInstance
	or	ax,ax
	jnz	@@InitOK

@@Fail:

; Если инициализация завершилась неудачно

	mov	ax, 4CFFh
	int	21h          ; terminate program

@@InitOK:

; Выводим на экран диалоговое окно

	call	MESSAGEBOX,0,ds offset lpszText,ds offset lpszTitle,MB_OK+MB_ICONEXCLAMATION

; Хе-хе а вот и выход

	mov	ax,4c00h
	int	21h

end start