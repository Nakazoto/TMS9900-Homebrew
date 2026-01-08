@echo off
cd %2
\Utils\Asw\bin\asw %1 -CPU TMS9900 -L -olist \BuildT99\Listing.txt  -D BuildT99 -o \BuildT99\prog.bld
if not "%errorlevel%"=="0" goto Abandon

\Utils\Asw\bin\p2bin \BuildT99\prog.bld \BuildT99\progC.bin
if not "%errorlevel%"=="0" goto Abandon

cd \Emu\VecGL

\Emu\classic99\classic99.exe -rom "\BuildT99\progC.bin"
:Abandon
if "%3"=="nopause" exit
pause
