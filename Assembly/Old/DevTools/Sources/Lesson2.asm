
wspDefault equ 83C0h
wspMonitor equ 83E0h
			
userRam    equ 8300h
CursorX    equ userRam+20h

VDPWD   EQU     8C00h           ;VDP RAM write data
VDPWA   EQU     8C02h           ;VDP RAM read/write address

	include "\srcAll\v1_Header.asm"

	bl @ScrInit
	
	li r0,TestData
	li r1,UserRam
	li r2,5
	bl @LDIR			;Copy 10 test bytes to 8300h
	
	li r0,0				;Zero first 4 registers
	mov r0,r1
	mov r0,r2
	mov r0,r3
	
	blwp @ShowRam		;Show 8300h test data
	blwp @Monitor4		;Monitor Dump
	
	
	
	
	;jmp AddressTests1	;Addressing Mode tests 1
	jmp AddressTests2	;Addressing Mode tests 2
	jmp AddressTests3	;Addressing Mode tests 3
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

AddressTests1:	
;Immediate Addressing
	li r0,UserRam		;load 'Userram' (8300h) into r0
	li r1,0FFEEh		;Hex must start with a 0
	blwp @Monitor4		;Monitor Dump
	
;Workspace Regsiter Addressing
	mov r0,r2			;Move value in R0 into R2
	mov r1,r3			;Move value in R1 into R3
	blwp @Monitor4		;Monitor Dump

;Workspace Regsister Indirect Addressing
	mov *r0,r3			;Set R3 from address in R0
	mov *r1,r2			;Set R2 from address in R1
	blwp @Monitor4		;Monitor Dump
	
	jmp InfLoop        	;Branch to Infloop	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AddressTests2:
	li r0,UserRam		;load 'Userram' (8300h) into r0
	
;Workspace Regsister Indirect Auto Increment Addressing
	mov *r0+,r1			;Set R1 from address in R0...inc RO
	blwp @Monitor4		;Monitor Dump
	mov *r0+,r2			;Set R1 from address in R0...inc RO
	blwp @Monitor4		;Monitor Dump
	mov *r0+,r3			;Set R1 from address in R0...inc RO
	blwp @Monitor4		;Monitor Dump

	blwp @DoNewLineW
	
;Load from fixed addresses.
	mov @UserRam,r0
	mov @UserRam+2,r1
	mov @UserRam+4,r2
	mov @UserRam+6,r3
	blwp @Monitor4		;Monitor Dump

;Loading words from odd addresses will fail
	mov @UserRam,r0		;Even - Works 
	mov @UserRam+1,r1	;Odd - Malfunctions
	mov @UserRam+2,r2	;Even - Works 
	mov @UserRam+3,r3	;Odd - Malfunctions
	blwp @Monitor4		;Monitor Dump
	
	jmp InfLoop        	;Branch to Infloop	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AddressTests3:
	
;Indexed Addressing (Can use any register except R0)

	li r3,TestData		;Can use any register except R0
	
	mov @0(r3),r0		;Load R0 from UserRam+0
	mov @2(r3),r1		;Load R1 from UserRam+2
	mov @4(r3),r2		;Load R2 from UserRam+4
	
	blwp @Monitor4		;Monitor Dump
	
	li r3,TestData+4	;Can use any register except R0
	
	mov @-0(r3),r0		;Load R0 from UserRam-0
	mov @-2(r3),r1		;Load R1 from UserRam-2
	mov @-4(r3),r2		;Load R2 from UserRam-4
	
	blwp @Monitor4		;Monitor Dump	

	li r3,TestData		;Can use any register except R0
	
;We can define symbols to make things clearer!

off0	equ 0	
off2	equ 2
off4	equ 4
	
	mov @off0(r3),r0	;Load R0 from UserRam+0
	mov @off2(r3),r1	;Load R1 from UserRam+2
	mov @off4(r3),r2	;Load R2 from UserRam+4
	
	blwp @Monitor4		;Monitor Dump

	jmp InfLoop        	;Branch to Infloop	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

TestData:
	byte 11h,22h,33h,44h,55h,66h,77h,88h,99h,0AAh


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
InfLoop:
	jmp InfLoop        	;Branch to Infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LDIR:
		mov *r0+,*r1+	;copy from (R1) to (R0)
		dec r2
		jne LDIR
		B *R11			;Return
ShowRam:
	word wspMonitor
	word Doramdump
	
Doramdump:	
		li r4,userRam	;address to show
		li r5,00005h	;words to show
		bl @ramdump		;Dump Memory
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



	