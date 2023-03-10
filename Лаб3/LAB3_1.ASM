	MYCODE SEGMENT 'CODE'
	ASSUME CS:MYCODE, DS:MYCODE
	START:
	
; Загрузка сегментного регистра данных DS
	PUSH CS
	POP  DS
	   
; Очистка экрана
	MOV AX, 03
	INT 10H
	
; Введем что-то
	CALL GETCH
	CALL NSTR
	
; Выведем
	MOV CX, 20
          ADD SYM, 02H
          
	CICL:
	MOV DL, SYM
	ADD SYM, 02H
	CALL PUTCH
	CALL NSTR
	LOOP CICL
       	          
; Выход из программы
	MOV AL, 0
	MOV AH, 4CH
 	INT 21H
 	
; Процедура вывода символа
	PUTCH  proc
	MOV AH, 02
	INT 21H 
	RET
	PUTCH endp
	
; Процедура перехода на новую строку
	NSTR proc
	MOV AH, 02
	MOV DL, CLRF
	INT 21H   
	RET
	NSTR endp 
	
; Ввод символа с сохранением в SYM
	GETCH proc
	MOV AH, 01H
	INT 21H
	MOV SYM, AL
	RET
	GETCH endp
	 
; Переменные            
	SYM DB 80H
	CLRF DB 10, 13
	
	MYCODE ENDS
	END START