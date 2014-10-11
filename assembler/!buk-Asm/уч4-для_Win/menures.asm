locals
jumps

.model large, WINDOWS PASCAL

; Подключаем файл описания констант и структур API

include windows.inc

; Подключаем файл описания ресурсов

include menures.ri

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
extrn   LOADICON:PROC
extrn   MESSAGEBOX:PROC
extrn   POSTQUITMESSAGE:PROC
extrn   REGISTERCLASS:PROC
extrn   SHOWWINDOW:PROC
extrn   TEXTOUT:PROC
extrn   TRANSLATEMESSAGE:PROC
extrn   UPDATEWINDOW:PROC
extrn   WAITEVENT:PROC
extrn	GETLASTERROR:PROC

.data

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

lpszTitleName     db 'Menu and Resources Window',0

; Название класса окна

lpszClassName     db 'ASMCLASS',0

; Выводимая в окно строка

lpszText	db	'Hello World'

; Длина строки lpszText

lpszTextLength	equ	$-lpszText

; Заголовок диалогового окна

lpszMenuCaption	db	'Menu Event',0

; Идентификатор меню

MenuString	db	'MENU_1',0

; Сообщения диалогового окна

lpszMenu1Msg	db	'First menu item selected',0
lpszMenu2Msg	db	'Second menu item selected',0
lpszMenu3Msg	db	'Third menu item selected',0


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
	
	
	call	LOADICON,ax,ICON_1
	mov	[wc.clsHIcon],ax

; Загружаем курсор IDC_ARROW и вставляем его в структуру

	mov	ax,[hInstance]
	call   	LOADCURSOR,ax IDC_ARROW
	mov    	[wc.clsHCursor],ax

; Загружаем цвет белого фона и вставляем его в структуру

	call   	GETSTOCKOBJECT,WHITE_BRUSH
	mov    	[wc.clsHbrBackground],ax

	mov    	word ptr [wc.clsLpszMenuName],offset MenuString
	mov    	word ptr [wc.clsLpszMenuName+2],seg MenuString

	mov    	word ptr [wc.clsLpszClassName],offset lpszClassName
	mov    	word ptr [wc.clsLpszClassName+2],seg lpszClassName

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
	cmp	[wmsg],WM_CREATE

; Если получили сообщение WM_CREATE (получено сообщение "создать окно")

	je	wmcreate
	cmp	[wmsg],WM_PAINT

; Если получили сообщение WM_PAINT (получено сообщение "нарисуйся")

	je	wmpaint
	cmp	[wmsg],WM_COMMAND
	
; Если получили сообщение WM_COMMAND (получено сообщение от меню)

	je	wmcommand

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
; Обработка сообщения WM_COMMAND
;

wmcommand:

; Если выбран первый пункт меню File

	cmp	[wparam],CM_FIRSTMENU
	jne	wmcommand1

; Выводим на экран диалоговое окно

	call	MESSAGEBOX,0,ds offset lpszMenu1Msg,ds offset lpszMenuCaption,0

; Выход из обработчика WM_COMMAND

	jmp	exit_wmcommand

wmcommand1:

; Если выбран второй пункт меню File

	cmp	[wparam],CM_SECONDMENU
	jne	wmcommand2

; Выводим на экран диалоговое окно

	call	MESSAGEBOX,0,ds offset lpszMenu2Msg,ds offset lpszMenuCaption,0

; Выход из обработчика WM_COMMAND

	jmp	exit_wmcommand

wmcommand2:

; Если выбран третий пункт меню File

	cmp	[wparam],CM_THIRDMENU
	jne	wmcommand3

; Выводим на экран диалоговое окно

	call	MESSAGEBOX,0,ds offset lpszMenu3Msg,ds offset lpszMenuCaption,0

; Выход из обработчика WM_COMMAND

	jmp	exit_wmcommand

wmcommand3:

; Если выбран пункт Exit NOW меню Exit

	cmp	[wparam],CM_EXIT

; Вызываем POSTQUITMESSAGE

	call	POSTQUITMESSAGE,0

; Выход из обработчика WM_COMMAND

	jmp	exit_wmcommand
	
exit_wmcommand:

; Выходим из обработчика WM_COMMAND

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

