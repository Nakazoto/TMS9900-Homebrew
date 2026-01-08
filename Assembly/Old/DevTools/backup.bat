@echo --------------------------------------------------------------------------
@echo 	Keith's Z80 Dev Toolkit - Please see the Readme for instructions!
@echo --------------------------------------------------------------------------
@echo 			     Generic Backup Script V1.0
@echo. 			
@echo 	     This tool backs up all your files, with the exception of the 
@echo 	    Emulators (to save space) - it uses 7zip for it's compression
@echo. 
@echo --------------------------------------------------------------------------

set bf=%date:/=%_%time::=%
Utils\7z a -r -x!emu -x!bak bak\bak_%bf%.7z *.* 
pause
