.MODEL TINY
.CODE 
ORG 100h
START:
  CALL TEXTY           ;���� ������� �����
  CALL OPROS
  MOV CH,AL
  SUB CH, 30h
  CALL STRLN

  CALL TEXTY           ;���� ������� �����
  CALL OPROS
  MOV CL,AL
  SUB CL, 30h
  CALL STRLN 

  CALL EZNAK           ;���� �����
  CALL OPROS
  CALL STRLN 

  CMP AL,'+'           ;�������� ��� ��������� �� �������
  JNZ IFNSUM
  ADD CH, CL
IFNSUM:  
  CMP AL,'-'
  JNZ IFNSUB
  SUB CH, CL
IFNSUB: 
                       
  MOV AL, CH           ;�������������� � ������
  CMP AL, 9
  JBE IF
  ADD AL, 07h
IF:
  ADD AL, 30h 
       
  MOV AH, 0Eh  ;������ ����������
  INT 10h 

  RET ;����� ���������

  y DB 'Enter num:','$'
  znak DB 'Enter simb:','$'
  ln DB 0Dh,0Ah,'$'

TEXTY:   ;������ ������ �� y
  PUSH AX
  PUSH DX
  MOV DX, OFFSET y
  MOV AH, 09h
  INT 21h
  POP DX
  POP AX 
RET

STRLN:   ;������� ������
  PUSH AX
  PUSH DX
  MOV DX, OFFSET ln
  MOV AH, 09h
  INT 21h
  POP DX
  POP AX 
RET

EZNAK:    ;������ ������ � �����
  PUSH AX
  PUSH DX
  MOV DX, OFFSET znak
  MOV AH, 09h
  INT 21h
  POP DX
  POP AX 
RET

OPROS:    ;����� ����������
  MOV AH, 10h
  INT 16h
RET

END START        