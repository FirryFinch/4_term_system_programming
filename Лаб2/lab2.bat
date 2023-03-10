ECHO OFF

REM Необходимость очистки экрана перед завершением программы - параметр %1
REM Название файла справки - параметр %2
IF (%1)==() goto noparam   
IF (%2)==() goto noparam

REM Меню
:menu
CLS
echo 1.Справка
echo 2.Команда FIND
echo 3.Вывод параметра 1
echo 4.Вывод параметра 2
echo 5.Выход 

set /p choice="Выбор [1,2,3,4,5]:"
if "%choice%"=="5" goto fin
if "%choice%"=="4" goto 4
if "%choice%"=="3" goto 3
if "%choice%"=="2" goto 2
if "%choice%"=="1" goto 1

:1
CALL %2
PAUSE
goto menu

:2
CLS
FIND /C "!" file.txt
PAUSE
goto menu

:3
CLS
ECHO %1
PAUSE
goto menu 

:4
CLS
ECHO %2
PAUSE
goto menu  

:fin
IF (%1)==(yes) CALL cls.bat
ECHO Завершение программы
EXIT /B

:noparam
ECHO Нет входящих параметров
PAUSE
goto menu                  