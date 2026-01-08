
	include "\srcAll\v1_Header.asm"

	bl @ScrInit
	jmp TestBitShifts		;Rotations
	;jmp TestBitOps			
	
	;jmp TestAndOrSocSzc	
	;jmp TestCocCzc
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

TestBitShifts:
	li r0,850Dh
	li r1,16
	blwp @MonitorBitsR0
	blwp @DoNewLineW
TestBitShiftsA:	
	;src r0,1		;Shift Right Circular (ROR)
	
	;srl r0,1		;Shift Right Logical
	
	;sra r0,1		;Shift Right Arithmetic 
	
	sla r0,1		;Shift Left Arithmetic (also works as SLL)
	
	;src r0,3		;Can rotate by any amount! (0-15!)
	
	;src r0,15		;Equivalent of Shift Left 1
	
	blwp @MonitorBitsR0
	dec r1
	jne TestBitShiftsA
	
	jmp InfLoop        	;Branch to Infloop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
TestBitOps:
	li  r0,1234h
	mov r0,r1
	mov r0,r2
	li r3,00FFh
	blwp @Monitor4
	
	inv r0				;flip bits
	neg r1				;Positive <-> Negative number
	xor r3,r2			;Flip bits of R2 using R3 (Dest=R2)
	blwp @Monitor4
	
	abs r0				;Convert Negative R0 to positive
	abs r1				;Convert Negative R1 to positive
	abs r2				;Convert Negative R2 to positive
	abs r3				;Convert Negative R3 to positive
	blwp @Monitor4
	blwp @DoNewLineW
	jmp InfLoop        	;Branch to Infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
TestAndOrSocSzc:
	li  r0,1234h
	mov r0,r1
	mov r0,r2
	mov r0,r3
	li  r5,0FFFh
	
	blwp @Monitor4
	andi r0,0FFFh	;And Immediate
	ori r1,0FFFh	;Or  Immediate
	
	soc r5,r2		;Set Ones Corresponding - OR
	szc r5,r3		;Set Zeroes Corresponding - Reverse AND
	
	blwp @Monitor4
	blwp @DoNewLineW
	
	li  r0,1234h
	mov r0,r1
	mov r0,r2
	mov r0,r3
	li  r5,0FF0h
	
	blwp @Monitor4
	
	socb r5,r2		;Set Ones Corresponding - OR (Byte)
	szcb r5,r3		;Set Zeroes Corresponding - Reverse AND (Byte)
	
	blwp @Monitor4
	jmp InfLoop        	;Branch to Infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		



TestCocCzc:
	li r0,00FFFh
;Test Dest to determine if 1 bits are 1 in Source... If so Zero flag set
	li r1,00FFFh
	coc r0,r1			;Compare Ones Corresponding
	blwp @MonitorFlagsR0R1
	
	li r1,0F0FFh
	coc r0,r1			;Compare Ones Corresponding
	blwp @MonitorFlagsR0R1
	
	li r1,0FF0Fh
	coc r0,r1			;Compare Ones Corresponding
	blwp @MonitorFlagsR0R1
	
	li r1,000FFh
	coc r0,r1			;Compare Ones Corresponding
	blwp @MonitorFlagsR0R1
	
	li r1,000FFh
	coc r1,r0			;Compare Ones Corresponding
	blwp @MonitorFlagsR0R1
	
	blwp @DoNewLineW
	
;Test Dest to determine if 1 bits are 0 in Source... If so Zero flag set
	li r0,00FFFh
	
	li r1,0F000h
	czc r0,r1			;Compare Zeros Corresponding
	blwp @MonitorFlagsR0R1
	
	li r1,00F00h
	czc r0,r1			;Compare Zeros Corresponding
	blwp @MonitorFlagsR0R1
		
	li r1,0FF00h
	czc r0,r1			;Compare Zeros Corresponding
	blwp @MonitorFlagsR0R1

	li r1,000FFh
	czc r1,r0			;Compare Zeros Corresponding
	blwp @MonitorFlagsR0R1
	
	li r1,08000h
	czc r1,r0			;Compare Zeros Corresponding
	blwp @MonitorFlagsR0R1
	
	jmp InfLoop        	;Branch to Infloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
InfLoop:
	jmp InfLoop        	;Branch to Infloop

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LDIR:
		mov *r0+,*r1+		;copy from (R1) to (R0)
		dec r2
		jne LDIR
		B *R11				;Return
ShowRam:
	word wspMonitor
	word Doramdump
	
Doramdump:	
		li r4,userRam		;address to show
		li r5,00005h		;words to show
		bl @ramdump			;Dump Memory
		bl @NewLine
		bl @NewLine
	RTWP
	
MonitorFlags:	
	word wspMonitor
	word DoMonitorFlags
	
DoMonitorFlags:	
		stst r4
		li r3,FlagChars
		li r1,16
FlagAgain:
		movb *r3+,r0
		sla r4,1
		joc FlagOn
		li r0,'. '
FlagOn:
		bl @PrintChar
		
		dec r1
		jne FlagAgain
		bl @NewLine
		bl @NewLine
	RTWP

MonitorBitsR0:	
	word wspMonitor
	word DoMonitorBitsR0
	
DoMonitorBitsR0:	
	li r1,0000h
	mov *r13,r2
	bl @ShowReg
	
	li r0,'-C'
	mov r15,r2
	andi r2,1000h
	jeq DoMonitorBitsR0NC
	swpb r0
DoMonitorBitsR0NC:		
	bl @PrintChar

	li r0,'  '
	bl @PrintChar
	
	mov *r13,r4
	li r1,16
DoMonitorBitsR0AgainB:
	li r0,'10'
	sla r4,1
	joc DoMonitorBitsR0OnB
	swpb r0
DoMonitorBitsR0OnB:
	bl @PrintChar
	
	dec r1
	jne DoMonitorBitsR0AgainB
		
	li r0,'  '
	bl @PrintChar
	
	bl @NewLine
	RTWP
	
MonitorFlagsR0R1:	
	word wspMonitor
	word DoMonitorFlagsR0R1
		
	
DoMonitorFlagsR0R1:	
		stst r4
		mov r13,r5
		li r6,0000h
DoMonitorAgain2:		
		mov *r5+,r2
		mov r6,r1
		bl @ShowReg
		ai r6,0100h
		ci r6,0200h 
		jne DoMonitorAgain2
		
		li r3,FlagChars
		li r1,16
FlagAgainB:
		movb *r3+,r0
		sla r4,1
		joc FlagOnB
		li r0,'. '
FlagOnB:
		bl @PrintChar
		
		dec r1
		jne FlagAgainB
		bl @NewLine
	RTWP

	
FlagChars:	
	byte 'L','A','=','C','V','P','X','!',  'I','I','I','I','!','!','!','!'
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


