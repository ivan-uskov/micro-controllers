; �������  (���������, ࠬ��, ����襭�� ��אַ㣮�쭨��)
;�����������������������������������������������������������������������������

  .model tiny 
  .code       
   org 100h    
Start:      
  mov AL,12h
  call GrafOn    ;����祭�� ��䨪� 480*640

         ;=== ࠬ�� ����� �࠭�   
  mov CX,0       ;���न���� ������ ���� ࠬ��: X
  mov DX,0       ;                               Y
  mov SI,640     ;ࠧ��� �� X
  mov DI,480     ;ࠧ��� �� Y
  mov AL,14      ;梥�
  call Ramka     ;ࠬ��
        
        ;=== ���������
  mov CX,0       ;���न���� ��砫쭮� �窨 X
  mov DX,0       ;                           Y
  mov SI,4       ;蠣 �� X
  mov DI,3       ;蠣 �� Y
  mov BX,240     ;���-�� �祪
  mov AL,14      ;梥�
  call Line      ;�����

  mov CX,0       ;���न���� ��砫쭮� �窨 X
  mov DX,479     ;                           Y
  mov SI,4       ;蠣 �� X
  mov DI,-3      ;蠣 �� Y
  mov BX,240     ;���-�� �祪
  call Line      ;�����

        ;=== �������� ����襭�� ��אַ㣮�쭨��
  mov AH,7            ;���-�� ��אַ㣮�쭨���
  mov CX,160          ;���न���� ������ ���� ���譥�� ��אַ㣮�쭨�� X
  mov DX,120          ;                                                Y
  mov SI,640-2*160    ;ࠧ��� �� X
  mov DI,480-2*120    ;ࠧ��� �� Y
  mov AL,6            ;梥� ���譥�� ��אַ㣮�쭨��
Metka1:
  call Pram           ;����襭�� ��אַ㣮�쭨�
  add CX,20           ;��������� ���न���: X 
  add DX,16           ;                     Y 
  sub SI,20*2         ;��������� ࠧ���: �� X
  sub DI,16*2         ;                   �� Y
  sub AL,1            ;��������� 梥� ��אַ㣮�쭨��
  dec AH              ;㬥��襭�� ���稪�
  jnz Metka1

        ;=== �������� ࠬ��
  mov AH,5            ;���-�� ࠬ��
  mov CX,5            ;���न���� ������ ���� ���譥� ࠬ�� X
  mov DX,5            ;                                      Y
  mov SI,640-2*5      ;ࠧ��� �� X
  mov DI,480-2*5      ;ࠧ��� �� Y
  mov AL,12           ;梥� ���譥� ࠬ��
Metka2:
  call Ramka          ;ࠬ��
  add CX,8            ;��������� ���न��� ࠬ��: Y
  add DX,6            ;                           X
  sub SI,8*2          ;��������� ࠧ��஢ ࠬ��: �� X
  sub DI,6*2          ;                          �� Y
  sub AL,1            ;��������� 梥� ࠬ��
  dec AH              ;㬥��襭�� ���稪�
  jnz Metka2

         ;=== �窠 � 業�� �࠭�
  mov CX,320          ;���न��� �窨 X
  mov DX,240          ;                 Y
  mov AL,14           ;梥�
  call Point          ;�窠 
                                   
         ;--- �����襭�� �ணࠬ��
  mov AH,10h          ;�������� ��� ������
  int 16h
  call GrafOff        ;�몫�祭�� ��䨪�
  ret                 ;��室 �� �ணࠬ��

;=================== ������������ ====================================

  ;=== ��������� ����᪮�� ०��� (����� ०��� �� AL)
  ;   ���ਬ��, � ०��� 12h  �祪 480 �� ���⨪���, 640 �� ��ਧ��⠫�
  ;                           (0,0 ᫥�� ᢥ���), 16 梥⮢ (0 -��࠭��)
GrafOn:
  mov AH,0               
  int 10h
  ret

  ;=== ���������� ����᪮�� ०��� (������ � ⥪�⮢�)
GrafOff:
  mov AX,0003h   
  int 10h
  ret

  ;=== ��ᮢ���� ����� (梥� �� AL, ���न����: X �� CX, Y �� DX)
Point:  
 push AX
 push BX
 mov BH,0          ;��࠭�� 0
 mov AH,0Ch        
 int 10h
 pop BX
 pop AX
 ret

  ;=== ��ᮢ���� ����� � �� ���ࠢ����� � ��� 蠣��
  ;                   (梥� �� AL, ���न���� ��砫�: X �� CX,        Y �� DX
  ;                        ���-�� �祪 �� BX, 蠣 �� X �� SI, 蠣 �� Y �� DI)
  ;  (��᫥ �ᮢ���� ���न���� CX � DX ���� �� ���� ����� (� �� �� ������)
Line: 
  push BX
 Line1:
  call Point    ;�ᮢ���� �窨 
  add CX,SI     ;��������� X
  add DX,DI     ;��������� Y
  dec BX        ;㬥��襭�� ���稪�
  jnz Line1
  sub CX,SI     ;�������� �� 蠣 ����� (X � Y �� ��᫥���� ���ᮢ����� ���)
  sub DX,DI        
  pop BX
  ret

  ;== ��ᮢ���� ����� 
       ;   梥� �� AL, ���न���� ������ ����: X �� CX,           Y �� DX
       ;                              ࠧ��� �� X �� SI, ࠧ��� �� Y �� DI)
       ;    (��᫥ �ᮢ���� CX � DX �� ��������)
Ramka:
  push SI
  push DI
  push CX
  push DX
  push BX
            ;����� ���ࠢ�
  push SI
  push DI
  mov BX,SI      ;���-�� �祪
  mov SI,1       ;蠣 �� X
  mov DI,0       ;蠣 �� Y
  call Line      ;�����
  pop DI
  pop SI
            ;����� ����
  push SI
  push DI
  mov BX,DI      ;���-�� �祪
  mov SI,0       ;蠣 �� X
  mov DI,1       ;蠣 �� Y
  call Line      ;�����
  pop DI
  pop SI
            ;����� ������
  push SI
  push DI
  mov BX,SI      ;���-�� �祪
  mov SI,-1      ;蠣 �� X
  mov DI,0       ;蠣 �� Y
  call Line      ;�����
  pop DI
  pop SI
            ;����� �����
  push SI
  push DI
  mov BX,DI      ;���-�� �祪
  mov SI,0       ;蠣 �� X
  mov DI,-1      ;蠣 �� Y
  call Line      ;�����
  pop DI
  pop SI

  pop BX
  pop DX
  pop CX
  pop DI
  pop SI
  ret


  ;=== ����� ������ (梥� �� AL, ��砫�: X �� CX, Y �� DX, ���-�� �祪 �� BX)
  ;                 (��᫥ �ᮢ���� CX � DX -�� ���� �����)
LineRight: 
  push BX
 LineRight1:
  call Point    ;�ᮢ���� �窨 
  inc CX        ;��������� X
  dec BX        ;㬥��襭�� ���稪�
  jnz LineRight1
  dec CX        ;�������� �� 蠣 ����� (X � Y �� ��᫥���� ���ᮢ����� ���)
  pop BX
  ret

  ;=== ����� ����� (梥� �� AL, ��砫�: X �� CX, Y �� DX, ���-�� �祪 �� BX)
  ;                (��᫥ �ᮢ���� CX � DX -�� ���� �����)
LineLeft: 
  push BX
 LineLeft1:
  call Point    ;�ᮢ���� �窨 
  dec CX        ;��������� X
  dec BX        ;㬥��襭�� ���稪�
  jnz LineLeft1
  inc CX        ;�������� �� 蠣 ����� (X � Y �� ��᫥���� ���ᮢ����� ���)
  pop BX
  ret

  ;=== ����� ���� (梥� �� AL, ��砫�: X �� CX, Y �� DX, ���-�� �祪 �� BX)
  ;               (��᫥ �ᮢ���� CX � DX -�� ���� �����)
LineDown: 
  push BX
 LineDown1:
  call Point    ;�ᮢ���� �窨 
  inc DX        ;��������� Y
  dec BX        ;㬥��襭�� ���稪�
  jnz LineDown1
  dec DX        ;�������� �� 蠣 ����� (X � Y �� ��᫥���� ���ᮢ����� ���)
  pop BX
  ret

  ;=== ����� ����� (梥� �� AL, ��砫�: X �� CX, Y �� DX, ���-�� �祪 �� BX)
  ;                (��᫥ �ᮢ���� CX � DX -�� ���� �����)
LineUp: 
  push BX
 LineUp1:
  call Point    ;�ᮢ���� �窨 
  dec DX        ;��������� Y
  dec BX        ;㬥��襭�� ���稪�
  jnz LineUp1
  inc DX        ;�������� �� 蠣 ����� (X � Y �� ��᫥���� ���ᮢ����� ���)
  pop BX
  ret

  ;=== ����� (梥� �� AL, ���न���� ��砫�:   X �� CX,           Y �� DX, 
  ;                                  ࠧ��� �� X �� SI, ࠧ��� �� Y �� DI)   
  ;          (CX � DX �� ��������)
Frame:
  push BX
  push CX
  push DX
  mov BX,SI           
  call LineRight      ;����� ��ࠢ�
  mov BX,DI           
  call LineDown       ;����� ����
  mov BX,SI           
  call LineLeft       ;����� �����
  mov BX,DI           
  call LineUp         ;����� �����
  pop DX
  pop CX
  pop BX
  ret
              
 ;=== ����襭�� �������������
       ;   梥� �� AL, ���न���� ������ ����: X �� CX,           Y �� DX
       ;                              ࠧ��� �� X �� SI, ࠧ��� �� Y �� DI
       ;                          (CX � DX �� ��������)
Pram:
   push DI 
   push BX
   push DX
 Pram1:        
   mov BX,SI         ;�祪 �� ��ਧ��⠫�   
   push CX           ;��࠭��� ���न���� X ��砫� ����� 
 Pram2:        ;�ᮢ���� ��ਧ��⠫쭮� �����
   call Point        ;�ᮢ���� �窨 
   inc CX            ;��������� X
   dec BX            ;㬥��襭�� ���稪�
   jnz Pram2
   pop CX            ;����⠭����� ��砫�� X
    inc DX           ;㢥����� Y
    dec DI           ;㬥��襭�� ���稪� �� Y
    jnz Pram1 
   pop DX
   pop BX
   pop DI
   ret

end Start
;�����������������������������������������������������������������������������
