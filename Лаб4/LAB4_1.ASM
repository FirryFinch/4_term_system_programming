	MYCODE SEGMENT 'CODE'
	ASSUME CS:MYCODE, DS:MYCODE
	START:
	
; Загрузка сегментного регистра DS
	PUSH CS
	POP  DS
	   
; Очистка
	MOV AX, 03
	INT 10H
	
; Считать
	CALL GETCH
	CALL NSTR
	
; Вывести
	MOV CX, 20
          
	CICL:
	MOV DL, SYM
	CALL PUTCH
	
	MOV DL, PROB
	CALL PUTCH
         
	MOV DL, DEF
	CALL PUTCH
	
	MOV DL, PROB
	CALL PUTCH

        	CALL NHEX
        
        	MOV DL, 68H       ; 68H = h
         	CALL PUTCH
         	
         	MOV DL, 2EH       ; 2EH = .
 	CALL PUTCH
 	
 	ADD SYM, 01H
	
	CALL NSTR
	LOOP CICL
	
	MOV CX, 20
	
	MOV AH, 9
	MOV DX, OFFSET MSG
	INT 21H 
	
       	CALL GETCH  
       	
       	MOV AX, 03
	INT 10H
       	
        	CMP SYM, 2AH
         	JNE CICL
       	          
; Завершение
	MOV AL, 0
	MOV AH, 4CH
 	INT 21H
 	
; Вывод
	PUTCH  proc
	MOV AH, 02
	INT 21H 
	RET
	PUTCH endp
	
; Новая строка
	NSTR proc
	MOV AH, 02
	MOV DL, CLRF
	INT 21H   
	RET
	NSTR endp 
	
; Ввод с SYM
	GETCH proc
	MOV AH, 01H
	INT 21H
	MOV SYM, AL
	RET
	GETCH endp
	
; Преобразование 	 
 	NHEX PROC
	LEA BX, HEX
 	MOV AL, SYM
	SHR AL, 4
	MOV DL, 15
	SUB DL, AL
	MOV AL, DL
	XLAT
	MOV DX, AX
	CALL PUTCH
	MOV AL, SYM
         	AND AL, 0FH
         	MOV DL, 15
	SUB DL, AL
	MOV AL, DL 
	XLAT
	MOV DX, AX
	CALL PUTCH
	RET
	NHEX ENDP
	
; Переменные           
	SYM DB 80H
	DEF DB '-'
	; HEX DB '0123456789ABCDEF'
	HEX DB 'FEDCBA9876543210'
	CLRF DB 10, 13
	PROB DB ' '
	MSG DB 'Для выхода нажмите * $'
	
	MYCODE ENDS
	END START