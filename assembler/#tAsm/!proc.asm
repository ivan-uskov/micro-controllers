;---------------------------Печать чисел-----------------------------
PRINT_BYTE:    ;печать байта из AL
  PUSH AX
  PUSH CX
  MOV AH, AL
  MOV CX, 04h
  SHR AL, CL
  CALL PRINT_DIGIT
  MOV AL, AH
  AND AL, 0Fh
  CALL PRINT_DIGIT
  POP CX
  POP AX
RET

PRINT_DIGIT:   ;печать числа из AL 
  PUSH AX
  CMP AL, 09h
  JBE LESS_NINE
  ADD AL, 07h
LESS_NINE:
  ADD AL, 30h
  MOV AH, 0Eh
  INT 10h
  POP AX
RET                                                                                                      
;---------------------------Печать чисел-----------------------------