	MYCODE SEGMENT 'CODE'
	ASSUME CS:MYCODE, DS:MYCODE
	START:
  
	PUSH CS
	POP DS
	
	CALL CLRSCR
		
          MOV CL, ES:80H  
    	DEC CL
   	MOV CH, 0
	LEA BX, ES:82H	
	MOV DI, 82H		
	LEA SI, SUR	
	
	FCHECK:
	MOV AL, ES:[DI]  
	CMP AL, ' '
	JE FEND
	CMP AL, BYTE PTR [SI]
	JNE NOTMATCH
	INC SI
         	INC DI
	INC AH  
	LOOP FCHECK
	
	FEND:         
	PUSH AX
	CMP AH, 9      
	JE ISMATCH
	JNE NOTMATCH

	ISMATCH:
	MOV DX, OFFSET FR
	CALL PUTSTR 
	MOV DI, 82H
	POP AX  
	PUSH CX
	PUSH AX
	MOV CL, AH
          
          WRITESUR:
 	MOV DL, ES:[DI]
  	CALL PUTCH
	INC DI
	LOOP WRITESUR
	
	POP AX 
	MOV CL, AH
	MOV DI, 82H  
	MOV AH, 0
	POP CX
	MOV AL, ES:[DI]
	JMP SCHECK

	NOTMATCH:
	MOV DX, OFFSET FNR
	CALL PUTSTR     
 	PUSH CX
	JMP SCHECK
	     
	SCHECK:
	CMP CX, 0
	JE SFAIL
	CMP AL, ' '
	JE SSKIP
	CMP CX, 4
	JGE SSUC
	
	SFAIL:  
	CALL NEWSTR
	MOV DX, OFFSET SNR 
	CALL PUTSTR
	JMP ENDPROG
	
	SSUC: 
	CALL NEWSTR
	MOV DX, OFFSET SR
	CALL PUTSTR
	JMP ENDPROG
	
	SSKIP:
	DEC CX                         
	INC DI  
	MOV AL, ES:[DI]              
	JMP SCHECK
	
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

; Вывод          
	PUTCH PROC
	MOV AH, 02
	INT 21H
	RET	
 	PUTCH ENDP
 	
 	PUTSTR PROC
	MOV AH, 09
	INT 21H
	RET	
 	PUTSTR ENDP
 		 
 ; Данные
	 
          SUR DB 'Antsifrov$'
          FR DB 'Первый параметр верен = $'
	FNR DB 'Первый параметр неправильный$'      
	SR DB 'Второй параметр есть$'
	SNR DB 'Второй параметр отсутствует$' 
			
	MYCODE ENDS
	END START