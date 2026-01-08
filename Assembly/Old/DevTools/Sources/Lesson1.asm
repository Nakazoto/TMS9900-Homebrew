
wspDefault equ 83C0h
wspMonitor equ 83E0h
			
userRam    equ 8300h
CursorX    equ userRam+20h

VDPWD   EQU     8C00h           ;VDP RAM write data
VDPWA   EQU     8C02h           ;VDP RAM read/write address

	include "\srcAll\v1_Header.asm"

	bl @ScrInit
	
	
	jmp MoveLoad		;Test Move and LoadImmediate commands
	jmp AddSub			;Test Add and Subtract commands
	jmp IncDec			;Test Increment and Decrement commands
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MoveLoad:

;LI loads immediate values into registers.
;Destination is on the left of the comman, Source value is on the right

;We can use Hex Dec Bin or Oct!
	li r0,01234h		;1234h->R0 (hex)
	li r1,1234			;1234->R1 (dec)
	li r2,11111001b		;11111001->R2 (bin)
	li r3,377o			;377 ->R3 (Oct)
	
	blwp @Monitor4		;Monitor Dump
	
;We can use ASCII too!	
	li r0,'A ' 	
	li r1,'A'
	li r2,'AA'
	li r3,'  '
	
	blwp @Monitor4		;Monitor Dump
	
;Transfer data between registers (or memory) with MOV
;Source is on the left... Destination is on the right.
	mov r0,r1			;R0->R1
	mov r0,r2			;R0->R2
	mov r0,r3			;R0->R3
	
	blwp @Monitor4		;Monitor Dump
	
	blwp @DoNewLineW
	
;There are faster smaller commands to set a register to 0000 or FFFFh	
	
	clr r0				;R0=0000h
	seto r1				;R1=FFFFh
	
	blwp @Monitor4		;Monitor Dump
	
	jmp InfLoop        	;Branch to Infloop	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
AddSub:

	blwp @Monitor4		;Monitor Dump
	
	ai r2,4				;R2=R2+4
	ai r3,-4			;R3=R3-4
	blwp @Monitor4		;Monitor Dump
	
	li r1,10h
	
	a r1,r2				;R2=R2+R1
	s r1,r3				;R3=R3+R1
	
	blwp @Monitor4		;Monitor Dump
	blwp @DoNewLineW			
	
	li r0,01234h		;1234h->R0
	li r1,01234h		;1234h->R0
	li r2,01234h		;1234h->R0
	li r3,01234h		;1234h->R0
	blwp @Monitor4		;Monitor Dump
	jmp InfLoop        	;Branch to Infloop	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
IncDec:	
	inc  r0				;Add 1 to R0
	inct r1				;Add 2 to R1
	dec  r2				;Subtract 1 from R2
	dect r3				;Subtract 2 from R3
	blwp @Monitor4		;Monitor Dump
	
	inc  r0				;Add 1 to R0
	inct r1				;Add 2 to R1
	dec  r2				;Subtract 1 from R2
	dect r3				;Subtract 2 from R3
	blwp @Monitor4		;Monitor Dump
	
	inc  r0				;Add 1 to R0
	inct r1				;Add 2 to R1
	dec  r2				;Subtract 1 from R2
	dect r3				;Subtract 2 from R3
	blwp @Monitor4		;Monitor Dump
	
	inc  r0				;Add 1 to R0
	inct r1				;Add 2 to R1
	dec  r2				;Subtract 1 from R2
	dect r3				;Subtract 2 from R3
	blwp @Monitor4		;Monitor Dump
	
	jmp InfLoop        	;Branch to Infloop	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
InfLoop:
	jmp InfLoop        	;Branch to Infloop

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
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

