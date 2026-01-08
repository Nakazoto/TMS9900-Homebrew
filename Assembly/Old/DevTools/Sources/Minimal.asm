
wspDefault equ 8300h
wspMonitor equ 8320h
			
userRam    equ 83E0h
CursorX    equ userRam

VDPWD   EQU     8C00h           ;VDP RAM write data
VDPWA   EQU     8C02h           ;VDP RAM read/write address

	include "\srcAll\v1_Header.asm"

	bl @ScrInit
			
	LI R1,HELLOWORLD   	;ascii string address
	bl @PrintString
	
	bl @NewLine
	
	blwp @Monitor		;Monitor Dump

	bl @NewLine			
	
	li r4,userRam		;address to show
	li r5,00005h		;words to show
	bl @ramdump			;Dump Memory
	
InfLoop:
	JMP InfLoop        ;stop and do nothing

	
PrintString:
	mov r11,r10
PrintStringAgain:
	MOVB *R1+,R0
	 
	li r2,255
	Cb r0,r2
	jeq PrintStringDone
	bl @PrintChar
	Jmp PrintStringAgain
PrintStringDone:
	B *R10				;Return		
	
	include "\SrcAll\monitor.asm"
	include "\SrcAll\functions.asm"



	
HELLOWORLD
    BYTE "HELLo WoRLD!123:@"     ;* string data
    BYTE 255
;    END