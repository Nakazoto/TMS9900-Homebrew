@echo --------------------------------------------------------------------------
@echo 	Keith's Z80 Dev Toolkit - Please see the Readme for instructions!
@echo --------------------------------------------------------------------------
@echo 				Z Drive Mount tool V1.0
@echo. 			
@echo 		This tool mounts the Z80 tools to virtual drive Z
@echo 	If the Z drive is in use, X or Y will be used as an alternative
@echo. 
@echo --------------------------------------------------------------------------
@echo off

set driveletter=T
if exist %driveletter%:\TMS9900 goto showmsg
if not exist %driveletter%:\nul goto start

set driveletter=U
if exist %driveletter%:\TMS9900 goto showmsg
if not exist %driveletter%:\nul goto start

set driveletter=V
if exist %driveletter%:\TMS9900 goto showmsg
if not exist %driveletter%:\nul goto start

Echo Drives Z, X and Y are in use already - could not map drive
pause
goto end

:start
subst %driveletter%: .
:showmsg

echo Development tools have been mounted as virtual drive %driveletter%:
pause
start %driveletter%:\
:end