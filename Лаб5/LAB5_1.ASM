	MYCODE SEGMENT 'CODE'
	ASSUME CS:MYCODE, DS:MYCODE
	START:
; Данные
	DTSEG SEGMENT 'DATA'  
	MYSTR DB 20 DUP ('0'), '$'
	HEX DB '0123456789ABCDEF'
         	MSG1 DB 'Для завершения ввода символов введите символ "доллар"$'
	MSG2 DB 'Для завершения ввода строк введите символ "звёздочка"$'
	DTSEG ENDS      
	
; Проверка загрузки из сегмента данных в DS    
	MOV AX, DTSEG
	MOV DS, AX
	PUSH DS
	POP ES
	
	CALL CLRSCR
		
          MOV AH, 09H
	MOV DX, OFFSET MSG1
	INT 21H
	CALL NEWSTR
	
	MOV AH, 09H
	MOV DX, OFFSET MSG2
	INT 21H
	CALL NEWSTR
	
	CALL NEWSTR
	
	MOV CX, 10
	
	PROGSTR:
	PUSH CX 
	
	BI:
	LEA DI, MYSTR
	MOV DX, 0
	PUSH DX  
         	MOV CX, 10
         	CALL GETCH
         	CMP AL, '*'
         	JE ENDPROG                     
       
       	I:                   
      	CMP AL, '$'                    
   	JE THENDO
      	STOSB                               
      	POP DX
       	INC DX  
        	PUSH DX
         	CMP CX, 1
        	JE BPR
        	CALL GETCH   
        	LOOP I 
	
	THENDO:
	CMP DX, 0
	JNE BPR
	CALL NEWSTR
	JMP BI

	BPR:
     	PUSH DX
         	MOV DL, ' '
         	CALL PUTCH
         	MOV DL, '='
         	CALL PUTCH
         	MOV DL, ' '
        	CALL PUTCH
         	LEA SI, MYSTR
         	POP DX
        	MOV CX, DX
        	
        	SHR CX, 1
        	
         ;	PUSH AX
         ;	MOV AX, DX
         ;	MOV BL, 2
         ;	IDIV BL
         ;	CMP AH, 0
         ;	JE NECHET
         ;	POP AX
         ;	NECHET:
         ;	INC CX
         	         	         	
         	PR:
         	LODSB
         	PUSH AX
         	LODSB
         	CALL NHEX
	MOV DL, ' '
     	CALL PUTCH
     	POP DX
     	MOV AX, DX
     	CALL NHEX
     	MOV DL, ' '
     	CALL PUTCH
     	LOOP PR
           	
	CALL NEWSTR
	POP CX
	POP CX	
	LOOP PROGSTR
	
; Завершение программы
	ENDPROG:
	CALL NEWSTR
	MOV AL, 0
	MOV AH, 4CH
 	INT 21H
 	
; Очистка экрана
	CLRSCR PROC
	MOV AX, 03
	INT 10H
	RET
	CLRSCR ENDP
	           
; Новая строка
	NEWSTR PROC
	MOV AH, 02
	MOV DL, 10
	INT 21H         
	MOV DL, 13
	INT 21H   
	RET
	NEWSTR ENDP

; Ввод
	GETCH PROC
	MOV AH, 01
	INT 21H
	RET
	GETCH ENDP

; Вывод          
	PUTCH PROC
	MOV AH, 02
	INT 21H
	RET	
 	PUTCH ENDP
 		
; Преобразование
	NHEX PROC
	LEA BX, HEX
     	PUSH AX
	SHR AL, 4
	XLAT
	MOV DX, AX
	CALL PUTCH
         	POP AX
     	PUSH AX
         	AND AL, 0FH 
	XLAT
	MOV DX, AX
	CALL PUTCH
	POP AX
	RET
	NHEX ENDP
	
	MYCODE ENDS
	END START