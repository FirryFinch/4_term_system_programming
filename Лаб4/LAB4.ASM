	MYCODE SEGMENT 'CODE'
	ASSUME CS:MYCODE, DS:MYCODE
	START:
	
; ????㧪? ᥣ???⭮?? ॣ????? DS
	PUSH CS
	POP  DS
	   
; ????⪠
	MOV AX, 03
	INT 10H
	
; ???????
	CALL GETCH
	CALL NSTR
	
; ?뢥???
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
        
        	MOV DL, 68H       ; 68H = H
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
       	          
; ?????襭??
	MOV AL, 0
	MOV AH, 4CH
 	INT 21H
 	
; ?뢮?
	PUTCH  proc
	MOV AH, 02
	INT 21H 
	RET
	PUTCH endp
	
; ????? ??ப?
	NSTR proc
	MOV AH, 02
	MOV DL, CLRF
	INT 21H   
	RET
	NSTR endp 
	
; ???? ? SYM
	GETCH proc
	MOV AH, 01H
	INT 21H
	MOV SYM, AL
	RET
	GETCH endp
	
; ?८?ࠧ?????? 	 
 	NHEX PROC
	LEA BX, HEX
 	MOV AL, SYM
	SHR AL, 4
	XLAT
	MOV DX, AX
	CALL PUTCH
	MOV AL, SYM
         	AND AL, 0FH 
	XLAT
	MOV DX, AX
	CALL PUTCH
	RET
	NHEX ENDP
	
; ??६?????           
	SYM DB 80H
	DEF DB '-'
	HEX DB '0123456789ABCDEF'
	CLRF DB 10, 13
	PROB DB ' '
	MSG DB '??? ??室? ??????? * $'
	
	MYCODE ENDS
	END START