	MYCODE SEGMENT 'CODE'
	ASSUME CS:MYCODE, DS:MYCODE
	START:
; ????㧪? ᥣ???⭮?? ॣ????? ?????? DS
	PUSH CS
	POP  DS   
	
; ????⪠ ??࠭?
	MOV AX, 03
	INT 10H
	
	MOV DL, WriteLetter1
	CALL PUTCH
	CALL NSTR 
           
	MOV DL, WriteLetter2  
	CALL PUTCH
	CALL NSTR   
        
	MOV DL, WriteLetter3  
	CALL PUTCH
	CALL NSTR  

	CALL GETCH

; ??室 ?? ?ணࠬ??
	MOV AL, 0
	MOV AH, 4CH
 	INT 21H

; ?뢮?
	PUTCH  proc
	MOV AH, 02
	INT 21H 
	RET
	PUTCH endp

; ????室 ?? ????? ??ப?
	NSTR proc
	MOV AH, 02
	MOV DL, CLRF
	INT 21H   
	RET
	NSTR endp

; ???? ᨬ????
	GETCH proc
	MOV AH, 01H
	INT 21H
	RET
	GETCH endp 

	WriteLetter1 DB 80H 
	WriteLetter2 DB 81H       
	WriteLetter3 DB 82H
	CLRF DB 10, 13
	MYCODE ENDS
	END START