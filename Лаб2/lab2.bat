ECHO OFF

REM ����室������ ���⪨ �࠭� ��। �����襭��� �ணࠬ�� - ��ࠬ��� %1
REM �������� 䠩�� �ࠢ�� - ��ࠬ��� %2
IF (%1)==() goto noparam   
IF (%2)==() goto noparam

REM ����
:menu
CLS
echo 1.��ࠢ��
echo 2.������� FIND
echo 3.�뢮� ��ࠬ��� 1
echo 4.�뢮� ��ࠬ��� 2
echo 5.��室 

set /p choice="�롮� [1,2,3,4,5]:"
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
ECHO �����襭�� �ணࠬ��
EXIT /B

:noparam
ECHO ��� �室��� ��ࠬ��஢
PAUSE
goto menu                  