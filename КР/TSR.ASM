; tsr.asm
;
; Сборка:
; tasm.exe /l tsr.asm
; tlink /t /x tsr.obj
; Автор:
; МГТУ им. Н.Э. Баумана, ИУ5-41Б, 2021 год
; Анцифров Н.С.
;

code segment	'code'
	assume	CS:code, DS:code
	org	100h
	_start:
	
	jmp _initTSR ; начало программы
	
	; Данные
	ignoredChars 				DB	'абвгдеёжзийклмнопрстуфхцчшщъыьэюя'		; что менять
	replaceWith 				DB	'f,dult`;pbqrkvyjghcnea[wxio]sm|.z'               ; на что менять
	ignoredLength 				equ	$-ignoredChars				; длина строки ignoredChars
	ignoreEnabled 				DB	0					; работа функции игнорирования ввода
	translateFrom 				DB	'T;PBR'					; что русифицировать
	translateTo 				DB	'ЕЖЗИК'					; на что русифицировать
	translateLength				equ	$-translateTo				; длина строки trasnlateFrom
	translateEnabled				DB	0					; работа функции перевода
	signaturePrintingEnabled 			DB	0					; работа функции вывода информации об авторе
	cursiveEnabled 				DB	0					; работа перевода символа в курсив

	cursiveSymbol 				DB 00000000b
						DB 00000000b
						DB 00000000b
						DB 00011111b
						DB 00011000b
						DB 00110000b
						DB 00110000b
						DB 01101100b
						DB 01100011b
						DB 11001100b
						DB 11110000b
						DB 00000000b
						DB 00000000b
						DB 00000000b
						DB 00000000b
						DB 00000000b
	
	charToCursiveIndex 		         		DB 'Б'						; символ для курсива
	savedSymbol 				DB 16 dup(0FFh)					; переменная для хранения старого символа
	
	true 					equ	0FFh					; константа истинности
	old_int9hOffset 				DW	?					; адрес старого обработчика int 9h
	old_int9hSegment 				DW	?					; сегмент старого обработчика int 9h
	old_int1ChOffset 				DW	?					; адрес старого обработчика int 1Ch
	old_int1ChSegment 				DW	?					; сегмент старого обработчика int 1Ch
	old_int2FhOffset 				DW	?					; адрес старого обработчика int 2Fh
	old_int2FhSegment 				DW	?					; сегмент старого обработчика int 2Fh
	
	notLoadTSR				DB	0					; 1 - не загружать TSR
	counter	  				DW	0
	printDelay				equ	5 					; задержка перед выводом подписи в секундах
	
	signatureLine1				DB	179, 'Анцифров Никита Сергеевич                                               ', 179
	Line1_length 					equ	$-signatureLine1
	signatureLine2				DB	179, 'ИУ5-41Б                                    			        ', 179
	Line2_length 					equ	$-signatureLine2
	signatureLine3				DB	179, 'Вариант 4                                			        ', 179
	Line3_length 					equ	$-signatureLine3
	helpMsg 		DB '  Справка:', 10, 13
			DB '  /?		 - вывод справки', 10, 13  
			DB '  Ctrl+U/Ctrl+u  - выгрузка резидента из памяти', 10, 13
			DB '  F2		 - вывод ФИО и группы через 5 секунд вверху экрана', 10, 13
			DB '  F3		 - включение и отключение курсивного вывода русского символа Б', 10, 13
			DB '  F4		 - включение и отключение русификации подмножества букв ЕЖЗИК', 10, 13
			DB '  F5		 - замена ввода русских букв на латинские', 10, 13
			
	helpMsg_length				equ  	$-helpMsg
	errorParamMsg				DB	'Ошибка параметров КС', 10, 13
	errorParamMsg_length			equ	$-errorParamMsg
	
	tableTop					DB	218, Line1_length-2 dup (196), 191
	tableTop_length 				equ	$-tableTop
	tableBottom				DB	192, Line1_length-2 dup (196), 217
	tableBottom_length 				equ  	$-tableBottom
	
	; сообщения		
	installedMsg				DB  'Успешная загрузка резидента$'
	alreadyInstalledMsg				DB  'Резидент уже был загружен$'
	noMemMsg					DB  'Недостаточно памяти$'
	notInstalledMsg				DB  'Ошибка загрузки резидента$'
	removedMsg				DB  'Резидент выгружен'
	removedMsg_length				equ  $-removedMsg
	noRemoveMsg				DB  'Ошибка выгрузки резидента$'
	noRemoveMsg_length		         		equ  $-noRemoveMsg
	
	f2_txt					DB	'F2'
	f3_txt					DB	'F3'
	f4_txt					DB	'F4'
	f5_txt					DB	'F5'
	fx_length					equ	$-f5_txt
	
	changeFx proc
		push AX
		push BX
		push CX
		push DX
		push BP
		push ES
		xor BX, BX
		
		mov AH, 03h
		int 10h
		push DX
		
		push CS
		pop ES
		
	_checkF2:
		lea BP, f2_txt
		mov CX, fx_length
		mov BH, 0
		mov DH, 0
		mov DL, 78
		mov AX, 1301h
		
		cmp signaturePrintingEnabled, true
		je _greenF2
		
		_redF2:
			mov BL, 01001111b ; red
			int 10h
			jmp _checkF3
		
		_greenF2:
			lea BP, f2_txt
			mov BL, 00101111b ; green
			int 10h
			
	_checkF3:
		lea BP, f3_txt
		mov CX, fx_length
		mov BH, 0
		mov DH, 1
		mov DL, 78
		mov AX, 1301h
		
		cmp cursiveEnabled, true
		je _greenF3
		
		_redF3:
			mov BL, 01001111b ; red
			int 10h
			jmp _checkF4
		
		_greenF3:
			mov BL, 00101111b ; green
			int 10h
		
	_checkF4:
		lea BP, f4_txt
		mov CX, fx_length
		mov BH, 0
		mov DH, 2
		mov DL, 78
		mov AX, 1301h
		
		cmp translateEnabled, true
		je _greenF4
		
		_redF4:
			mov BL, 01001111b ; red
			int 10h
			jmp _checkF5
		
		_greenF4:
			mov BL, 00101111b ; green
			int 10h
			
	_checkF5:
		lea BP, f5_txt
		mov CX, fx_length
		mov BH, 0
		mov DH, 3
		mov DL, 78
		mov AX, 1301h
		
		cmp ignoreEnabled, true
		je _greenF5
		
		_redF5:
			mov BL, 01001111b ; red
			int 10h
			jmp _outFx
		
		_greenF5:
			mov BL, 00101111b ; green
			int 10h
			
	_outFx:
		pop DX
		mov AH, 02h
		int 10h
		
		pop ES
		pop BP
		pop DX
		pop CX
		pop BX
		pop AX
		ret
	changeFx endp
	
    ;новый обработчик
    new_int9h proc far
		push SI
		push AX
		push BX
		push CX
		push DX
		push ES
		push DS
				; синхронизируем CS и DS
		push CS
		pop  DS

		mov	AX, 40h 	; 40h-сегмент,где хранятся флаги сост-я клавиатуры, кольц. буфер ввода 
		mov	ES, AX
		in	AL, 60h 	; записываем в AL скан-код нажатой клавиши
		      
		cmp	AL, 22 	; проверка нажатия U
		jne	_test_Fx
		mov	AH, ES:[17h]     ; флаги клавиатуры
		and	AH, 00001111b
		cmp	AH, 00000100b    ; проверка нажатия ctrl
		jne	_test_Fx
		
		; выгрузка
			mov AH, 0FFh
			mov AL, 01h
			int 2Fh
			
			in	AL, 61h  		; контроллер состояния клавиатуры
			or	AL, 10000000b	; клавишу нажали
			out	61h, AL
			and	AL, 01111111b	; клавишу отпустили
			out	61h, AL
			mov	AL, 20h
			out	20h, AL		; отправим в контроллер прерываний признак конца прерывания
			
			jmp _quit
		
		_test_Fx:
		sub AL, 58 			; в AL теперь номер функциональной клавиши
		_F2:
			cmp AL, 2 ; F2
			jne _F3
			not signaturePrintingEnabled
			call changeFx
			jmp _translate_or_ignore
		_F3:
			cmp AL, 3 ; F3
			jne _F4
			not cursiveEnabled
			call changeFx
			call setCursive 		; перевод символа в курсив и обратно
			jmp _translate_or_ignore
		_F4:
			cmp AL, 4 ; F4
			jne _F5
			not translateEnabled
			call changeFx
			jmp _translate_or_ignore
		_F5:
			cmp AL, 5 ; F5
			jne _translate_or_ignore
			not ignoreEnabled
			call changeFx
			jmp _translate_or_ignore
				
		_translate_or_ignore:
		
		pushf
		call dword ptr CS:[old_int9hOffset] 	; вызываем стандартный обработчик прерывания
		mov	AX, 40h  			; 40h-сегмент,где хранятся флаги состояния клавиатуры
		mov	ES, AX
		mov	BX, ES:[1Ch]		; адрес хвоста
		dec	BX			; переход назад к последнему введенному символу
		dec	BX			
		cmp	BX, 1Eh			; проверка предела буфера
		jae	_go
		mov	BX, 3Ch			; вышли за пределы => последний символ в конце буфера

	_go:		
		mov DX, ES:[BX] 			; в DX 0 введённый символ
		cmp ignoreEnabled, true
		jne _check_translate
		
		mov SI, 0
		mov CX, ignoredLength
		
	_check_ignored:
		cmp DL, ignoredChars[SI]
		je _block
		inc SI
	loop _check_ignored
		jmp _check_translate
		
	_block:   
		mov ES:[BX], AX
		xor AX, AX
		mov AL, replaceWith[SI]
		mov ES:[BX], AX    			; замена символа
		jmp _quit
	
	_check_translate:
		cmp translateEnabled, true
		jne _quit
		
		mov SI, 0
		mov CX, translateLength
		_check_translate_loop:
			cmp DL, translateFrom[SI]
			je _translate
			inc SI
		loop _check_translate_loop
		jmp _quit
		
		_translate:		
			xor AX, AX
			mov AL, translateTo[SI]
			mov ES:[BX], AX
			
	_quit:
		pop	DS
		pop	ES
		pop DX
		pop CX
		pop	BX
		pop	AX
		pop SI
		iret
new_int9h endp  

; Обработчик прерывания int 1Ch
; Вызывается каждые 55 мс
new_int1Ch proc far
	 push AX
	 push CS
         	 pop DS
	
	pushf
	call dword ptr CS:[old_int1ChOffset]
	
	cmp signaturePrintingEnabled, true 			; если нажата управляющая клавиша (в данном случае F1)
	jne _notToPrint		
	
		cmp counter, printDelay*1000/55 + 1 		; если кол-во "тактов" эквивалентно %printDelay% секундам
		je _letsPrint
		
		jmp _dontPrint
		
		_letsPrint:
			not signaturePrintingEnabled
			mov counter, 0
			call printSignature
		
		_dontPrint:
			add counter, 1
		
	_notToPrint:
	
	pop AX
	
	iret
new_int1Ch endp

; Обработчик прерывания int 2Fh
; Служит для:
; 1) проверки факта присутствия TSR в памяти (при AH=0FFh, AL=0)
;    будет возвращён AH='i' в случае, если TSR уже загружен
; 2) выгрузки TSR из памяти (при AH=0FFh, AL=1)
;     
new_int2Fh proc
	cmp	AH, 0FFh				; наша функция?
	jne	_2Fh_std				; нет - на старый обработчик
	cmp	AL, 0    				; подфункция проверки, загружен ли резидент в память?
	je	_already_installed
	cmp	AL, 1				; подфункция выгрузки из памяти?
	je	_uninstall	
	jmp	_2Fh_std				; нет - на старый обработчик
	
_2Fh_std:
	jmp	dword ptr CS:[old_int2FhOffset]	; вызов старого обработчика
	
_already_installed:
		mov	AH, 'i'			; вернём 'i', если резидент загружен в память
		iret
	
_uninstall:
	push	DS
	push	ES
	push	DX
	push	BX
	
	xor BX, BX
	
						; CS = ES, для доступа к переменным
	push CS
	pop ES
	
	mov	AX, 2509h
	mov DX, ES:old_int9hOffset         		; возвращаем вектор прерывания на место
    	mov DS, ES:old_int9hSegment        	
	int	21h
	
	mov	AX, 251Ch
	mov DX, ES:old_int1ChOffset         		; возвращаем вектор прерывания на место
    	mov DS, ES:old_int1ChSegment
	int	21h

	mov	AX, 252Fh
	mov DX, ES:old_int2FhOffset         		; возвращаем вектор прерывания на место
    	mov DS, ES:old_int2FhSegment
	int	21h

	mov	ES, CS:2Ch         			; загрузим в ES адрес окружения			
	mov	AH, 49h				; выгрузим из памяти окружение
	int	21h
	jc _notRemove
	
	push	CS
	pop	ES				; в ES - адрес резидентной программы
	mov	AH, 49h  				; выгрузим из памяти резидент
	int	21h
	jc _notRemove
	jmp _unloaded
	
_notRemove: 					; не удалось выполнить выгрузку
	mov AH, 03h				; получаем позицию курсора
	int 10h
	lea BP, noRemoveMsg
	mov CX, noRemoveMsg_length
	mov BL, 0111b
	mov AX, 1301h
	int 10h
	jmp _2Fh_exit
	
_unloaded: 					; выгрузка прошла успешно
	mov AH, 03h				; получаем позицию курсора
	int 10h
	lea BP, removedMsg
	mov CX, removedMsg_length
	mov BL, 0111b
	mov AX, 1301h
	int 10h
	
_2Fh_exit:
	pop BX
	pop	DX
	pop	ES
	pop	DS
	iret
new_int2Fh endp

; Процедура вывода подписи (ФИО, группа)
;
printSignature proc
	push AX
	push DX
	push CX
	push BX
	push ES
	push SP
	push BP
	push SI
	push DI

	xor AX, AX
	xor BX, BX
	xor DX, DX
	
	mov AH, 03h						; чтение текущей позиции курсора
	int 10h
	push DX							; помещаем информацию о положении курсора в стек

	_printTop:
		mov DH, 0
		mov DL, 15
		jmp _actualPrint
		
	_actualPrint:	
		mov AH, 0Fh					; чтение текущего видеорежима
		int 10h

		push CS						
		pop ES						; указываем ES на CS    
		
								; вывод "верхушки" таблицы
		push DX
		lea BP, tableTop					; помещаем в BP указатель на выводимую строку
		mov CX, tableTop_length	         			; в CX - длина строки
		mov BL, 0111b 					
		mov AX, 1301h					; AH=13h - номер фамилии, AL=01h - курсор перемещается при выводе каждого из символов строки
		int 10h
		pop DX
		inc DH
								; вывод первой линии
		push DX
		lea BP, signatureLine1
		mov CX, Line1_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		pop DX
		inc DH
		
	         							; вывод второй линии
		push DX
		lea BP, signatureLine2
		mov CX, Line2_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		pop DX
		inc DH
		
	         							; вывод третьей линии
		push DX
		lea BP, signatureLine3
		mov CX, Line3_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		pop DX
		inc DH
		
	         							; вывод 'низа' таблицы
		push DX
		lea BP, tableBottom
		mov CX, tableBottom_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		pop DX
		inc DH
		
		xor BX, BX
		pop DX						; восстанавливаем из стека прежнее положение курсора
		mov AH, 02h					; меняем положение курсора на первоначальное
		int 10h
		call changeFx
		
	pop DI
	pop SI
	pop BP
	pop SP
	pop ES
	pop BX
	pop CX
	pop DX
	pop AX
	
	ret
printSignature endp

; Изменение на курсив и наоборот
;
setCursive proc
	push ES 				; сохраняем регистры
	push AX
	push CS
	pop ES

	cmp cursiveEnabled, true
	jne _restoreSymbol
					; если флаг равен true, выполняем замену символа на курсивный вариант,
         					; предварительно сохраняя старый символ в savedSymbol
	
	call saveFont
	mov CL, charToCursiveIndex
_shifTtable:
					; мы получаем в BP таблицу всех символов. адрес указывает на символ 0
					; поэтому нужно совершить сдвиг 16*X, где X - код символа
	add BP, 16
	loop _shiftTable
	
         					; пpи savefont смещается pегистp ES
					; поэтомy пpиходится делать такие махинации, чтобы 
         					; записать полyченный элемент в savedSymbol
	push DS
	pop AX
	push ES
	pop DS
	push AX
	pop ES
	push AX

	mov SI, BP
	lea DI, savedSymbol
					; сохpаняем в пеpеменнyю savedSymbol
					; таблицy нyжного символа
	mov CX, 16
					; movsb из DS:SI в ES:DI
	rep movsb
					; исходные позиции сегментов возвpащены	
	pop DS 				; восстановление DS

         					; заменим написание символа на кypсив
	mov CX, 1
	mov DH, 0
	mov DL, charToCursiveIndex
	lea BP, cursiveSymbol
	call changeFont
	jmp _exitSetCursive
	
_restoreSymbol:	
	; если флаг равен 0, выполняем замену курсивного символа на старый вариант
	mov CX, 1
	mov DH, 0
	mov DL, charToCursiveIndex
	lea bp, savedSymbol
	call changeFont
	
_exitSetCursive:
	pop AX
	pop ES
	ret
setCursive endp	
	
; Функция смены начертания символа (курсив/нормальное)
;
; Входные данные:
; DL - номер символа для замены
; CX - кол-во символов заменяемых изображений символов (начиная с DX)
; ES:bp = адрес таблицы
;
; Описание работы процедуры:
; Происходит вызов int 10h (видеосервис)
; с функцией AH = 11h (функции знакогенератора)
; Параметр AL = 0 сообщает, что будет заменено изображение
; символа для текущего шрифта
; В случаях, когда AL = 1 или 2, будет заменено изображение
; только для опредленного шрифта (8x14 и 8x8 соответственно)
; Параметр BH = 0Eh сообщает, что на опредление каждого изображения символа
; расходуется по 14 байт (режим 8x14 бит как раз 14 байт)
; Параметр BL = 0 - блок шрифта для загрузки (от 0 до 4)
;

changeFont proc
	push AX
	push BX
	mov AX, 1100h
	mov BX, 1000h
	int 10h
	pop AX
	pop BX
	ret
changeFont endp

; Нормальное начертание
; 
; Входные данные:
; BH - тип возвращаемой символьной таблицы
; 0 - таблица из int 1fh
; 1 - таблица из int 44h
; 2-5 - таблица из 8x14, 8x8, 8x8 (top), 9x14
; 6 - 8x16
;
; Описание работы процедуры:
; Происходит вызов int 10h (видеосервис)
; с функцией AH = 11h (функции знакогенератора)
; Параметр AL = 30 - подфункция получения информации о EGA
;
; Результаты:
; в ES:BP находится таблица символов (полная)
; в CX находится байт на символ
; в DL количество экранных строк
; Происходит сдвиг регистра ES
; (ES становится равным C000h)

saveFont proc
	push AX
	push BX
	mov AX, 1130h
	mov BX, 0600h
	int 10h
	pop AX
	pop BX
	ret
saveFont endp


_initTSR:                         	; старт резидента
	mov AH, 03h
	int 10h
	push DX
	mov AH,00h		; установка видеорежима (83h  текст  80x25  16/8  CGA,EGA  b800  Comp,RGB,Enhanced), без очистки экрана
	mov AL,83h
	int 10h
	pop DX
	mov AH, 02h
	int 10h
	
	
    call commandParamsParser    
	mov AX,3509h                   ; получить в ES:BX вектор 09 прерывания
    int 21h                         	

	
	cmp notLoadTSR, true	 ; если была выведена справка, выход
	je _exit_tmp		

	mov AH, 0FFh
	mov AL, 0
	int 2Fh
	cmp AH, 'i'  		; проверка того, загружена ли уже программа
	je _alreadyInstalled
    
	jmp _tmp
	
	_exit_tmp:
		jmp _exit
	
	_tmp:
	push ES
    	mov AX, DS:[2Ch]                ; psp
    	mov ES, AX
    	mov AH, 49h                     ; хватит лм памяти, чтобы остаться резидентом?
    	int 21h                         
    	pop ES
    	jc _notMem                      ; если нет - выход
	
	; int 09h

	mov	word ptr CS:old_int9hOffset, BX
	mov	word ptr CS:old_int9hSegment, ES
    	mov AX, 2509h                   		; установим вектор на 09
    	mov DX, offset new_int9h            		; прерывание
    	int 21h
	
	; int 1Ch
	mov AX,351Ch                    		; получить в ES:BX вектор 1C
    	int 21h                         		; прерывания
	mov word ptr CS:old_int1ChOffset, BX
	mov word ptr CS:old_int1ChSegment, ES
	mov AX, 251Ch                   		; установим вектор на 1C
	mov DX, offset new_int1Ch            		; прерывание
	int 21h
	
	; int 2Fh
	mov AX,352Fh                    		; получить в ES:BX вектор 1C
    	int 21h                         		; прерывания
	mov word ptr CS:old_int2FhOffset, BX
	mov word ptr CS:old_int2FhSegment, ES
	mov AX, 252Fh                   		; установим вектор на 2F
	mov DX, offset new_int2Fh            		; прерывание
	int 21h

	call changeFx
    	mov DX, offset installedMsg         		
    	mov AH, 9
    	int 21h
    	mov DX, offset _initTSR       		; остаемся резидентом и выходим
    	int 27h                         
 
_alreadyInstalled:
	mov AH, 09h
	lea DX, alreadyInstalledMsg
	int 21h
	jmp _exit
_notMem:                            			; не хватает памяти, чтобы оставаться резидентом
    mov DX, offset noMemMsg
    mov AH, 9
    int 21h
_exit:                               			; выход
    int 20h                          

; Проверка параметров КС;
;
commandParamsParser proc
	push CS
	pop ES
	mov notLoadTSR, 0
	
	mov SI, 80h   				; смещение параметров КС
	lodsb        				; кол-во символов.
	or AL, AL     				
	jz _exitHelp   				

	_nextChar:
	
	inc SI       				
	
	cmp [SI], BYTE ptr 13
	je _exitHelp
	
	
		lodsw       				; получаем два символа
		cmp AX, '?/' 				 
		je _question
		
		;cmp AH, '/'
		;je _errorParam
		
		jmp _exitHelp
   
	_question:
		mov AH,03
		int 10h	
		lea BP, helpMsg
		mov CX, helpMsg_length
		mov BL, 0111b
		mov AX, 1301h
		int 10h
		not notLoadTSR	        
		jmp _nextChar

	jmp _exitHelp

	_errorParam:
			mov AH,03
			int 10h	
			lea BP, CS:errorParamMsg
			mov CX, errorParamMsg_length
			mov BL, 0111b
			mov AX, 1301h
			int 10h
	_exitHelp:
	ret
commandParamsParser endp

code ends
end _start