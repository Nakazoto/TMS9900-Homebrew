@echo --------------------------------------------------------------------------
@echo 	Keith's Z80 Dev Toolkit - Please see the Readme for instructions!
@echo --------------------------------------------------------------------------
@echo 				Z Drive Removetool V1.0
@echo. 			
@echo 		This tool removes the virtual mounted drive
@echo 	it must be executed from the virtually mounted drive itself.
@echo. 
@echo --------------------------------------------------------------------------
taskkill -im wabbitemu.exe
subst %cd:~0,1%: /d