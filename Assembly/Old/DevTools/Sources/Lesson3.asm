
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
	
	li r0,0				;Zero the test registers
	mov r0,r1
	mov r0,r2
	mov r0,r3
	
	jmp ByteTests		;Commands using a single byte of register
	;jmp BranchTest		;Branches
	;jmp TestCmpJe		;= !=
	;b @TestCmpGl		;> <
	;b @TestCmpGlSigned ;> < Signed
	;b @TestCarry		;C (Bit pushed out)
	;b @TestOverflow	;V (Sign changed)
	b @TestParity		;P  (no of 1 bits odd/even in Byte)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
ByteTests:				;Byte commands use the high byte of the register

	blwp @ShowRam		;Show 8300h test data
	li r3,0FFFFh
	blwp @Monitor4		;Monitor Dump
	
	li r0,TestData		;Load source TestData into R0
	
	mov *r0,r1			;Move Word from address R0 into R1 (1122)
	movb *r0,r2			;Move Byte from address R0 into R2 (11??)
	
	movb *r0,r3			;Move Byte from address R0 into R3 (11??)
	
	blwp @Monitor4		;Monitor Dump
	
	blwp @DoNewLineW	;Start a new line
	
	li r1,0FFFFh
	li r0,00100h
	blwp @Monitor4		;Monitor Dump
	
	ab r0,r1			;Add R0 Byte (1) to R1
	ab r0,r2			;Add R0 Byte (1) to R2
	ab r0,r3			;Add R0 Byte (1) to R3
	
	blwp @Monitor4		;Monitor Dump
	
	sb r0,r1			;Subtract R0 Byte (1) to R1
	sb r0,r2			;Subtract R0 Byte (1) to R2
	sb r0,r3			;Subtract R0 Byte (1) to R3
	
	blwp @Monitor4		;Monitor Dump


	blwp @DoNewLineW	;Start a new line

	li r0,TestData		;Load source TestData into R0
	blwp @Monitor4		;Monitor Dump

	swpb r0				;Swap high and low byte of R0
	swpb r1				;Swap high and low byte of R1
	swpb r2				;Swap high and low byte of R2
	swpb r3				;Swap high and low byte of R3
	
	blwp @Monitor4		;Monitor Dump

	
	b @InfLoop        	;Branch to Infloop	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
BranchTest:	
	li r0,'A '			;Show A
	bl @PrintChar
	
	li r1,BranchTest_Skip1
	b *r1				;Branch to address in R1
		li r0,'1 '			;This will never happen
		bl @PrintChar		;This will never happen
BranchTest_Skip1:	

	li r0,'B '			;Show B
	bl @PrintChar

	b @BranchTest_Skip2	;Branch to address BranchTest_Skip2
		li r0,'2 '			;This will never happen
		bl @PrintChar		;;This will never happen
BranchTest_Skip2:	
	
	li r0,'C '			;Show C
	bl @PrintChar
	
	bl @BLTest1			;Jump to BLTest... Return address in R11
	bl @PrintChar			;This will show a '!'
	
	li r0,'D '			;Show D
	bl @PrintChar
	
	bl @BLTest2			;Jump to BLTest... Return address in R11
							;This will show a '*'
	
	li r0,'E '			;Show E
	bl @PrintChar
	
	b @InfLoop        	;Branch to Infloop	


BLTest1:	
	li r0,'! '			;change R0
	B *R11				;Return
	
BLTest2:
	mov r11,r10			;Move Return addr R11->R10
							;We NEED R11
	
	li r11,'* '			;Use R11 as a test
	mov r11,r0				;It's usually the return address
	
	bl @PrintChar		;BL... so we used R11 again!
	
	B *R10				;Return
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestCmpJe:
	li r0,10FFh
	li r1,10FEh
	li r2,10FFh
	li r3,1100h
	blwp @Monitor4		;Monitor Dump
	
	;ci r0,10FEh		;Compare Immediate ... 10FF != 10FF 
	;ci r0,10FFh		;Compare Immediate ... 10FF  = 10FF
	
	;c r0,r1			;Compare R0 to R1 ... 10FF != 10FE
	;c r0,r2			;Compare R0 to R1 ... 10FF  = 10FF
	
	cb r0,r1			;Compare Byte R0 to R1 ... 10  = 10	
							;FF / FE ignored
	;cb r0,r3			;Compare Byte R0 to R1 ... 11 != 10
							
	blwp @MonitorFlags
	
	Jeq ResultEQ		;Jump if both are the same
	Jne ResultNE		;Jump if both are different
	
;Jump is relative - it can only be neerby (branch on 6502)	
;Branch is absolute - it can jump anywhere
	
	b @InfLoop        	;Branch to Infloop	

	
ResultNE:
	li r0,'! '
	bl @PrintChar
ResultEQ:
	li r0,'= '
	bl @PrintChar
	b @InfLoop        	;Branch to Infloop	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestCmpGlSigned:
	li r0,6000h			;+24576
	li r1,7000h			;+28672
	li r2,8000h			;-32768
	li r3,9000h			;-28672
	blwp @Monitor4		;Monitor Dump
	

	
	;c r1,r0			;Compare r1>r0	(> if unsigned)
	;c r1,r2			;Compare r>r2	(< if unsigned!!!!!)
	c r2,r3				;Compare r2<r3	(> if unsigned)
	
	
	blwp @MonitorFlags
	
	jgt	ResultGT		;Signed Jump if Greater
	jlt ResultLT		;Signed Jump if Less
	
	jmp InfLoop        	;Branch to Infloop	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
TestCmpGl:
	li r0,6000h
	li r1,7000h
	li r2,8000h
	li r3,9000h
	blwp @Monitor4		;Monitor Dump
	

	
	;c r1,r0				;r1>r0
	;c r1,r2				;r1<r2
	;c r2,r3				;r2<r3
	
	;c r0,r0				;r0=r0
	
	blwp @MonitorFlags
	
	;jh	ResultGT		;Unsigned Jump if Higher
	;jl  ResultLT		;Unsigned Jump if Lower
	
	;jh	ResultGT		;Unsigned Jump if Higher
	;jl  ResultLT		;Unsigned Jump if Lower
	
	;jhe	ResultGT	;Unsigned Jump if Higher or Equal
	;jle ResultLT		;Unsigned Jump if Less or Equal
	
	jmp InfLoop        	;Branch to Infloop	
	
ResultGT:
	li r0,'> '
	bl @PrintChar
	jmp InfLoop        	;Branch to Infloop	
ResultLT:
	li r0,'< '
	bl @PrintChar
	jmp InfLoop        	;Branch to Infloop	

	
TestCarry:

	li r0,0FFFDh
	blwp @MonitorFlagsR0R1		;0FFFDh -
	inc r0
	blwp @MonitorFlagsR0R1		;0FFFEh -
	inc r0
	blwp @MonitorFlagsR0R1		;0FFFFh -
	inc r0
	blwp @MonitorFlagsR0R1		;00000h Carry
	inc r0
	blwp @MonitorFlagsR0R1		;00001h -	
	
	jnc ResultNC		;Jump if Carry Clear
	joc ResultC			;Jump if Carry Set 
	
	jmp InfLoop        	;Branch to Infloop	
ResultNC:
	li r0,'N '
	bl @PrintChar
ResultC:
	li r0,'C '
	bl @PrintChar
	jmp InfLoop        	;Branch to Infloop	

TestOverflow:
	li r0,07FFDh
	blwp @MonitorFlagsR0R1		;07FFDh +32765
	inc r0
	blwp @MonitorFlagsR0R1		;07FFEh +32766
	inc r0
	blwp @MonitorFlagsR0R1		;07FFFh +32767
	inc r0
	blwp @MonitorFlagsR0R1		;08000h -32768 Overflow
	inc r0
	blwp @MonitorFlagsR0R1		;08001h -32767	
	
	jno ResultNV		;Jump if Not Overflow
	
	jmp ResultV			;If we got here, we Overflowed
ResultNV:
	li r0,'N '
	bl @PrintChar
ResultV:
	li r0,'V '
	bl @PrintChar
	jmp InfLoop        	;Branch to Infloop	

TestParity:						
	;Parity bit set when number of bits is odd
	;This only works on Bytes not Words

	li r0,0300h					;0000011b
	li r1,0100h
	ab r1,r0		
	blwp @MonitorFlagsR0R1		;0000100b	=1 bit Parity Odd
	ab r1,r0		
	blwp @MonitorFlagsR0R1		;0000101b	=2 bits Even
	ab r1,r0		
	blwp @MonitorFlagsR0R1		;0000110b	=2 bits Even
	ab r1,r0		
	blwp @MonitorFlagsR0R1		;0000111b	=3 bits Parity Odd
	ab r1,r0		
	blwp @MonitorFlagsR0R1		;0001000b	=1 bit  Parity Odd
	ab r1,r0		
	blwp @MonitorFlagsR0R1		;0001001b	=2 bits Even
	
	jop ResultNP		;Odd Parity
	
	jmp ResultP			;If we got here, byte has parity.
ResultNP:
	li r0,'N '
	bl @PrintChar
ResultP:
	li r0,'P '
	bl @PrintChar
	jmp InfLoop        	;Branch to Infloop	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TestData:
	byte 11h,22h,33h,44h,55h,66h,77h,88h,99h,0AAh


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


