; ГРАФИКА  (диагонали, рамки, закрашенные прямоугольники)
;─────────────────────────────────────────────────────────────────────────────

  .model tiny 
  .code       
   org 100h    
Start:      
  mov AL,12h
  call GrafOn    ;включение графики 480*640

         ;=== рамка вокруг экрана   
  mov CX,0       ;координаты левого верха рамки: X
  mov DX,0       ;                               Y
  mov SI,640     ;размер по X
  mov DI,480     ;размер по Y
  mov AL,14      ;цвет
  call Ramka     ;рамка
        
        ;=== диагонали
  mov CX,0       ;координаты начальной точки X
  mov DX,0       ;                           Y
  mov SI,4       ;шаг по X
  mov DI,3       ;шаг по Y
  mov BX,240     ;кол-во точек
  mov AL,14      ;цвет
  call Line      ;линия

  mov CX,0       ;координаты начальной точки X
  mov DX,479     ;                           Y
  mov SI,4       ;шаг по X
  mov DI,-3      ;шаг по Y
  mov BX,240     ;кол-во точек
  call Line      ;линия

        ;=== вложенные закрашенные прямоугольники
  mov AH,7            ;кол-во прямоугольников
  mov CX,160          ;координаты левого верха внешнего прямоугольника X
  mov DX,120          ;                                                Y
  mov SI,640-2*160    ;размер по X
  mov DI,480-2*120    ;размер по Y
  mov AL,6            ;цвет внешнего прямоугольника
Metka1:
  call Pram           ;закрашенный прямоугольник
  add CX,20           ;изменение координат: X 
  add DX,16           ;                     Y 
  sub SI,20*2         ;изменение размера: по X
  sub DI,16*2         ;                   по Y
  sub AL,1            ;изменение цвета прямоугольника
  dec AH              ;уменьшение счетчика
  jnz Metka1

        ;=== вложенные рамки
  mov AH,5            ;кол-во рамок
  mov CX,5            ;координаты левого верха внешней рамки X
  mov DX,5            ;                                      Y
  mov SI,640-2*5      ;размер по X
  mov DI,480-2*5      ;размер по Y
  mov AL,12           ;цвет внешней рамки
Metka2:
  call Ramka          ;рамка
  add CX,8            ;изменение координат рамки: Y
  add DX,6            ;                           X
  sub SI,8*2          ;изменение размеров рамки: по X
  sub DI,6*2          ;                          по Y
  sub AL,1            ;изменение цвета рамки
  dec AH              ;уменьшение счетчика
  jnz Metka2

         ;=== точка в центре экрана
  mov CX,320          ;координата точки X
  mov DX,240          ;                 Y
  mov AL,14           ;цвет
  call Point          ;точка 
                                   
         ;--- Завершение программы
  mov AH,10h          ;ожидание любого нажатия
  int 16h
  call GrafOff        ;выключение графики
  ret                 ;выход из программы

;=================== ПОДПРОГРАММЫ ====================================

  ;=== ВКЛЮЧЕНИЕ графического режима (номер режима из AL)
  ;   например, в режиме 12h  точек 480 по вертикали, 640 по горизонтали
  ;                           (0,0 слева сверху), 16 цветов (0 -стирание)
GrafOn:
  mov AH,0               
  int 10h
  ret

  ;=== ВЫКЛЮЧЕНИЕ графического режима (возврат в текстовый)
GrafOff:
  mov AX,0003h   
  int 10h
  ret

  ;=== Рисование ТОЧКИ (цвет из AL, координаты: X из CX, Y из DX)
Point:  
 push AX
 push BX
 mov BH,0          ;страница 0
 mov AH,0Ch        
 int 10h
 pop BX
 pop AX
 ret

  ;=== Рисование ЛИНИИ в любом направлении с любым шагом
  ;                   (цвет из AL, координаты начала: X из CX,        Y из DX
  ;                        кол-во точек из BX, шаг по X из SI, шаг по Y из DI)
  ;  (после рисования координаты CX и DX будут НА конце линии (а не ЗА линией)
Line: 
  push BX
 Line1:
  call Point    ;рисование точки 
  add CX,SI     ;изменение X
  add DX,DI     ;изменение Y
  dec BX        ;уменьшение счетчика
  jnz Line1
  sub CX,SI     ;вернуться на шаг назад (X и Y на последнюю нарисованную точку)
  sub DX,DI        
  pop BX
  ret

  ;== Рисование РАМКИ 
       ;   цвет из AL, координаты левого верха: X из CX,           Y из DX
       ;                              размер по X из SI, размер по Y из DI)
       ;    (после рисования CX и DX не портятся)
Ramka:
  push SI
  push DI
  push CX
  push DX
  push BX
            ;линия направо
  push SI
  push DI
  mov BX,SI      ;кол-во точек
  mov SI,1       ;шаг по X
  mov DI,0       ;шаг по Y
  call Line      ;линия
  pop DI
  pop SI
            ;линия вниз
  push SI
  push DI
  mov BX,DI      ;кол-во точек
  mov SI,0       ;шаг по X
  mov DI,1       ;шаг по Y
  call Line      ;линия
  pop DI
  pop SI
            ;линия налево
  push SI
  push DI
  mov BX,SI      ;кол-во точек
  mov SI,-1      ;шаг по X
  mov DI,0       ;шаг по Y
  call Line      ;линия
  pop DI
  pop SI
            ;линия вверх
  push SI
  push DI
  mov BX,DI      ;кол-во точек
  mov SI,0       ;шаг по X
  mov DI,-1      ;шаг по Y
  call Line      ;линия
  pop DI
  pop SI

  pop BX
  pop DX
  pop CX
  pop DI
  pop SI
  ret


  ;=== Линия ВПРАВО (цвет из AL, начало: X из CX, Y из DX, кол-во точек из BX)
  ;                 (после рисования CX и DX -на конце линии)
LineRight: 
  push BX
 LineRight1:
  call Point    ;рисование точки 
  inc CX        ;изменение X
  dec BX        ;уменьшение счетчика
  jnz LineRight1
  dec CX        ;вернуться на шаг назад (X и Y на последнюю нарисованную точку)
  pop BX
  ret

  ;=== Линия ВЛЕВО (цвет из AL, начало: X из CX, Y из DX, кол-во точек из BX)
  ;                (после рисования CX и DX -на конце линии)
LineLeft: 
  push BX
 LineLeft1:
  call Point    ;рисование точки 
  dec CX        ;изменение X
  dec BX        ;уменьшение счетчика
  jnz LineLeft1
  inc CX        ;вернуться на шаг назад (X и Y на последнюю нарисованную точку)
  pop BX
  ret

  ;=== Линия ВНИЗ (цвет из AL, начало: X из CX, Y из DX, кол-во точек из BX)
  ;               (после рисования CX и DX -на конце линии)
LineDown: 
  push BX
 LineDown1:
  call Point    ;рисование точки 
  inc DX        ;изменение Y
  dec BX        ;уменьшение счетчика
  jnz LineDown1
  dec DX        ;вернуться на шаг назад (X и Y на последнюю нарисованную точку)
  pop BX
  ret

  ;=== Линия ВВЕРХ (цвет из AL, начало: X из CX, Y из DX, кол-во точек из BX)
  ;                (после рисования CX и DX -на конце линии)
LineUp: 
  push BX
 LineUp1:
  call Point    ;рисование точки 
  dec DX        ;изменение Y
  dec BX        ;уменьшение счетчика
  jnz LineUp1
  inc DX        ;вернуться на шаг назад (X и Y на последнюю нарисованную точку)
  pop BX
  ret

  ;=== РАМКА (цвет из AL, координаты начала:   X из CX,           Y из DX, 
  ;                                  размер по X из SI, размер по Y из DI)   
  ;          (CX и DX не портятся)
Frame:
  push BX
  push CX
  push DX
  mov BX,SI           
  call LineRight      ;линия вправо
  mov BX,DI           
  call LineDown       ;линия вниз
  mov BX,SI           
  call LineLeft       ;линия влево
  mov BX,DI           
  call LineUp         ;линия вверх
  pop DX
  pop CX
  pop BX
  ret
              
 ;=== Закрашенный ПРЯМОУГОЛЬНИК
       ;   цвет из AL, координаты левого верха: X из CX,           Y из DX
       ;                              размер по X из SI, размер по Y из DI
       ;                          (CX и DX не портятся)
Pram:
   push DI 
   push BX
   push DX
 Pram1:        
   mov BX,SI         ;точек по горизонтали   
   push CX           ;сохранить координату X начала линии 
 Pram2:        ;рисование горизонтальной линии
   call Point        ;рисование точки 
   inc CX            ;изменение X
   dec BX            ;уменьшение счетчика
   jnz Pram2
   pop CX            ;восстановить начальный X
    inc DX           ;увеличить Y
    dec DI           ;уменьшение счетчика по Y
    jnz Pram1 
   pop DX
   pop BX
   pop DI
   ret

end Start
;─────────────────────────────────────────────────────────────────────────────
