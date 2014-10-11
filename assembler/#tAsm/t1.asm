.MODEL TINY
.CODE 
ORG 100h
START:
  CALL TEXTY           ;ввод первого числа
  CALL OPROS
  MOV CH,AL
  SUB CH, 30h
  CALL STRLN

  CALL TEXTY           ;ввод второго числа
  CALL OPROS
  MOV CL,AL
  SUB CL, 30h
  CALL STRLN 

  CALL EZNAK           ;ввод знака
  CALL OPROS
  CALL STRLN 

  CMP AL,'+'           ;сложение или вычитание по условию
  JNZ IFNSUM
  ADD CH, CL
IFNSUM:  
  CMP AL,'-'
  JNZ IFNSUB
  SUB CH, CL
IFNSUB: 
                       
  MOV AL, CH           ;преобразование в символ
  CMP AL, 9
  JBE IF
  ADD AL, 07h
IF:
  ADD AL, 30h 
       
  MOV AH, 0Eh  ;печать результата
  INT 10h 

  RET ;Конец программы

  y DB 'Enter num:','$'
  znak DB 'Enter simb:','$'
  ln DB 0Dh,0Ah,'$'

TEXTY:   ;печать текста из y
  PUSH AX
  PUSH DX
  MOV DX, OFFSET y
  MOV AH, 09h
  INT 21h
  POP DX
  POP AX 
RET

STRLN:   ;перенос строки
  PUSH AX
  PUSH DX
  MOV DX, OFFSET ln
  MOV AH, 09h
  INT 21h
  POP DX
  POP AX 
RET

EZNAK:    ;печать текста о знаке
  PUSH AX
  PUSH DX
  MOV DX, OFFSET znak
  MOV AH, 09h
  INT 21h
  POP DX
  POP AX 
RET

OPROS:    ;опрос клавиатуры
  MOV AH, 10h
  INT 16h
RET

END START        