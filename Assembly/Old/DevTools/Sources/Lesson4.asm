
wspDefault equ 83C0h
wspTest    equ 83A0h
wspMonitor equ 83E0h
			
userRam    equ 8300h
CursorX    equ userRam+20h

VDPWD   EQU     8C00h           ;VDP RAM write data
VDPWA   EQU     8C02h           ;VDP RAM read/write address

	include "\srcAll\v1_Header.asm"

	bl @ScrInit	
	;jmp WorkSpaceTest1		;BLWP to protect register
	;jmp WorkSpaceTest2		;Load save special regs WP / ST
	jmp TestMultDiv			;Multiply Divide
	
WorkSpaceTest1:	
	li r0,0FFFFh
	mov r0,r1
	mov r0,r2
	mov r0,r3
	
	blwp @ShowRam		;Show Ram used by Test Workspace
	
	blwp @Monitor		;Monitor Dump
	blwp @DoNewLineW
	
	blwp @BlWpTest		;Call Test Workspace
	
	blwp @ShowRam		;Show Ram used by Test Workspace
	
	jmp InfLoop        	;Branch to Infloop	

;;;;;;;;;;;;;;;;;;;;
	
;BLWP Vector table
BlWpTest:
	word wspTest		;Workspace Address
	word DoBlWpTest		;Program Code

;BLWP Vector table	
DoBlWpTest:
	li r0,1234h
	li r1,2345h
	li r2,3456h
	li r3,4567h

	blwp @Monitor		;Monitor Dump
	blwp @DoNewLineW	;RD=WP (Workspace Pointer of caller)
						;RE=PC (Return address of caller)
						;RF=ST (Status of Caller)
		
	RTWP				;ReTurn and restore Workspace Pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WorkSpaceTest2:		
	blwp @Monitor		;Monitor Dump
	blwp @DoNewLineW
	
	lwpi wspTest		;Load Workspace Pointer from Immediate
	
	stwp r0				;Store Workspace Pointer into R0
	stst r2				;Store Status into R2
	
	blwp @Monitor		;Monitor Dump
	jmp InfLoop        	;Branch to Infloop	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestMultDiv:			;Source can be RAM - DEST must be registers
	
	li r0,00100h
	li r1,01111h
	li r2,0FE32h
	li r3,01111h
	blwp @Monitor4
	
	mpy r0,r2 			;R2.R3 = R0*R2 
	
	blwp @Monitor4
	blwp @DoNewLineW
	
	li r0,00100h
	li r1,01111h
	li r2,0000Fh
	li r3,0EDCBh
	blwp @Monitor4
	
	div r0,r2			;R2 = R2.R3 / R0 .... Remainder in R3
	
	blwp @Monitor4
	
	jmp InfLoop        	;Branch to Infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InfLoop:
	jmp InfLoop        	;Branch to Infloop

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShowRam:
	word wspMonitor
	word Doramdump
	
Doramdump:	
		li r4,wspTest		;address to show
		li r5,00005h		;words to show
		bl @ramdump			;Dump Memory
		bl @NewLine
		
		li r5,00005h		;words to show
		bl @ramdump			;Dump Memory
		bl @NewLine
		
		li r5,00005h		;words to show
		bl @ramdump			;Dump Memory
		bl @NewLine
		
		
		li r5,00001h		;words to show
		bl @ramdump			;Dump Memory
		bl @NewLine
		
		bl @NewLine
	RTWP
	
Monitor4:
	word wspMonitor
	word DoMonitor4
	
DoMonitor4:
		mov r13,r5
		li r6,0000h
DoMonitorAgain4:		
		mov *r5+,r2
		mov r6,r1
		bl @ShowReg
		ai r6,0100h
		ci r6,0400h 
		jne DoMonitorAgain4
		
		bl @NewLine
	RTWP
	
DoNewLineW:
	word wspMonitor
	word DoNewLine
	
DoNewLine:
		bl @NewLine
	RTWP
		
	include "\SrcAll\monitor.asm"
	include "\SrcAll\functions.asm"


