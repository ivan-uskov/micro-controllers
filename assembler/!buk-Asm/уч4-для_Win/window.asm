locals
jumps

.model large, WINDOWS PASCAL

; Подключаем файл описания констант и структур API

include windows.inc

; Описываем используемые функции

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

; Для Windows Task Manager

		db	16 dup(0)

; HINSTANCE нашего приложения

hInstance	dw	?

; Параметр просмотра окна 

cmdShow		dw	?

; Структура PAINTSTRUCT

lppaint     PAINTSTRUCT <0>

; Структура сообщения MSGSTRUCT

msg         MSGSTRUCT   <0>

; Структура описания окна

wc          WNDCLASS    <0>

; Заголовок окна

lpszTitleName     db 'First Window',0

; Название класса окна

lpszClassName     db 'ASMCLASS',0

; Выводимая в окно строка

lpszText	db	'Hello World'

; Длина строки lpszText

lpszTextLength	equ	$-lpszText

; Заголовок диалогового окна

lpszCaption	db	'Mouse Event',0

; Сообщения диалогового окна

lpszLeftMsg	db	'Left button pressed',0
lpszRightMsg	db	'Right button pressed',0

.code
.286

; Как говоритья в WarLords "Lets The War Begins"

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

; Сохраняем параметр просмотра окна

	mov	[cmdShow],dx

; Инициализируем приложение

	call	INITAPP,hInstance
	or	ax,ax
	jnz	@@InitOK

@@Fail:

; Если инициализация завершилась неудачно

	mov	ax, 4CFFh
	int	21h          ; terminate program


@@InitOK:

; Заполняем структуру описания окна
	
	mov	[wc.clsStyle],0
	mov	word ptr [wc.clsLpfnWndProc],offset WndProc
	mov	word ptr [wc.clsLpfnWndProc+2],seg WndProc
	mov	[wc.clsCbClsExtra],0
	mov	[wc.clsCbWndExtra],0
	mov	ax,[hInstance]
	mov	[wc.clsHInstance],ax
	mov	[wc.clsHIcon],0

; Загружаем курсор IDC_ARROW и вставляем его в структуру

	xor	ax,ax
	call   	LOADCURSOR,ax IDC_ARROW
	mov    	[wc.clsHCursor],ax

; Загружаем цвет белого фона и вставляем его в структуру

	call   	GETSTOCKOBJECT,WHITE_BRUSH
	mov    	[wc.clsHbrBackground],ax

	mov    	word ptr [wc.clsLpszMenuName],0
	mov    	word ptr [wc.clsLpszMenuName+2],0

	mov    	word ptr [wc.clsLpszClassName],offset lpszClassName
	mov    	word ptr [wc.clsLpszClassName+2],ds

; Регистрируем структуру описания окна

	call   	REGISTERCLASS,ds offset wc

; Создаем окно

	xor	ax,ax
	mov	bx,CW_USEDEFAULT
	call	CREATEWINDOW,ds offset lpszClassName,ds offset lpszTitleName,\
		             WS_OVERLAPPEDWINDOW,ax,bx,bx,bx,bx,ax,ax,\
			     [hInstance],ax,ax

; Показываем окно

	push	ax
	call	SHOWWINDOW,ax,cmdShow

; Обновляем окно

	pop	ax
	call	UPDATEWINDOW,ax

; Цикл обработки сообщений

msg_loop:

; Получаем сообщение

	call	GETMESSAGE,ds offset msg,0,0,0

; Проверяем на наличие сообщения WM_QUIT (AX=0)

	cmp	ax,0
	je	end_loop

; Обрабатываем сообщение

	call	TRANSLATEMESSAGE,ds offset msg

	call	DISPATCHMESSAGE,ds offset msg

; Обрабатываем следующее сообщение

	jmp	msg_loop

end_loop:

; Выходим из программы

	mov	ax,[msg.msWPARAM]
	mov	ah,4Ch
	int	21h

;
; Процедура обработки сообщений
;

WndProc		PROC
	ARG	hwnd:WORD,wmsg:WORD,wparam:WORD,lparam:DWORD

	cmp	[wmsg],WM_DESTROY

; Если получили сообщение WM_DESTROY (получено сообщение "на выход")

	je	wmdestroy
	cmp	[wmsg],WM_LBUTTONDOWN

; Если получили сообщение WM_LBUTTONDOWN (нажата левая кнопка мыши)

	je	wmlbuttondown
	cmp	[wmsg],WM_CREATE

; Если получили сообщение WM_CREATE (получено сообщение "создать окно")

	je	wmcreate
	cmp	[wmsg],WM_RBUTTONDOWN

; Если получили сообщение WM_RBUTTONDOWN (нажата правая кнопка мыши) 

	je	wmrbuttondown
	cmp	[wmsg],WM_PAINT

; Если получили сообщение WM_PAINT (получено сообщение "нарисуйся")

	je	wmpaint

; Если мы не обрабатываем ни одно из вышеперечисленных сообщений передаем
; управление стандартному обработчику

	jmp	defwndproc

; 
; Обработка сообщения WM_PAINT
;

wmpaint:

; Начинаем рисование и получаем указатель на текущий DC

	call	BEGINPAINT,hwnd,ds offset lppaint

; AX содержит контекст устройства вывода DC, полученный после вызова BEGINPAINT

; Вызываем TEXTOUT для вывода строки lpszText

	call	TEXTOUT,ax,5,5,ds offset lpszText,lpszTextLength

; Заканчиваем рисование

	call    ENDPAINT,hwnd,ds offset lppaint

; Обнуляем AX и на выход

	xor	ax,ax
	jmp	finish

;
; Обработка сообщения WM_CREATE
;

wmcreate:

; Обнуляем AX и на выход

	xor	ax,ax
	jmp	finish

;
; Вызов стандартного обработчика сообщений 
;

defwndproc:

	call	DEFWINDOWPROC,hwnd,wmsg,wparam,lparam
	jmp	finish

;
; Обработка сообщения WM_DESTROY
;

wmdestroy:

; Вызываем POSTQUITMESSAGE

	call	POSTQUITMESSAGE,0

; Обнуляем AX и на выход

	xor	ax,ax
	jmp	finish

;
; Обработка сообщения WM_LBUTTONDOWN
;

wmlbuttondown:

; Выводим на экран MESSAGEBOX с надписью "Left button pressed"

	call	MESSAGEBOX,0,ds offset lpszLeftMsg,ds offset lpszCaption,0

; Обнуляем AX и на выход

	xor	ax,ax
	jmp	finish

;
; Обработка сообщения WM_RBUTTONDOWN
;

wmrbuttondown:

; Выводим на экран MESSAGEBOX с надписью "Right button pressed"

	call	MESSAGEBOX,0,ds offset lpszRightMsg,ds offset lpszCaption,0

; Обнуляем AX и на выход

	xor	ax,ax
	jmp	finish

;
; "Финишная прямая"
;

finish:

; Обнуляем DX и на выход

	xor	dx,dx
	ret

WndProc         ENDP


end start

