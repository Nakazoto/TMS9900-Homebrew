        ORG  6000h
		
		WORD 0AA01h			;header
		Word 0
		Word 0
        WORD  PROG				;Pointer to 1st program
        Word 0
		Word 0
PROG    WORD  0				;1st entry 0=only
        WORD  RUNLIB		;Start Ofr Program
        BYTE  16			;Text Length
        BYTE  "CHIBIAKUMAS.COM"		;Text Message
		
Runlib


WRKSP   EQU     8300h

CursorX equ 	83F0h

VDPWD   EQU     8C00h           ;* VDP RAM write data
VDPWA   EQU     8C02h           ;* VDP RAM read/write address


START   LIMI    0               ;* disable interrupts
        LWPI    WRKSP           ;* set default workspace

		
; set VDP RAM start address (low and high byte)

        LI      R0,4020h
	    SWPB    R0
        MOVB    R0,@VDPWA		;L
        SWPB    R0
        MOVB    R0,@VDPWA		;H

		li r0,0000h
		movb r0,@CursorX
		
		li r0,0000h
		lst r0
		stst r1
		blwp @Monitor
		
		
		li r15,0ff15h

		bl @NewLine
		bl @NewLine
		blwp @Monitor

		
		
		
		bl @NewLine
		
		li r4,06000h
		li r5,00010h
		
		bl @ramdump
		
        bl @NewLine
		bl @NewLine
		
		
		LI      R1,HELLOWORLD   ;* ascii string address
NEXTCHAR
        MOVB *R1+,R0
		 
		li r2,255
		Cb r0,r2
		jeq LOOPBACK
		
		
		bl @PrintChar
        Jmp NEXTCHAR

LOOPBACK
        JMP LOOPBACK            ;* stop and do nothing

PrintCharR3:		
	mov r3,r0
PrintChar:
	ci r0,6000h
	jlt PrintCharOk
	
	ai r0,0E000h ;-32
PrintCharOk:
	;sb r2,r0
	movb r0,@VDPWD     ;* put next char on screen
	
	movb @CursorX,r0
	ai r0,0100h		;Inc 1 byte
	movb r0,@CursorX
	
	B *R11
NewLine:
	movb @CursorX,r0
	
NewLineb:
	li r1,0000h
	movb r1,@VDPWD     ;* put next char on screen	
	li r1,0100h
	ab r1,r0		;Inc 1 byte
	andi r0,1F00h
	jne NewLineb
	;li r0,0000h
	movb r0,@CursorX    ;* put next char on screen
	
	
	
	B *R11	
	include "\SrcAll\monitor.asm"
ShowHex:
		ai r0,3000h				;0
		ci r0,3A00h
		jlt ShowHexDigitOk
		ai r0,0700h				;Letters
ShowHexDigitOk:
		b @PrintChar
		
ShowHexDigit:
	mov r11,r10
		mov r2,r0
		andi r0,0F000h
		srl r0,4
		bl @ShowHex
		sla r2,4
	B *R10
ShowReg:
	mov r11,r9
		li r0,"R "
		bl @PrintChar
		
		mov r1,r0
		bl @ShowHex
		li r3,": "
		bl @PrintCharR3
		swpb r3
ShowHex4b:		
		bl @ShowHexDigit
		bl @ShowHexDigit
		bl @ShowHexDigit
		bl @ShowHexDigit
		bl @PrintCharR3
	B *r9
ShowHex4:		
	mov r11,r9
	b @ShowHex4b
		;li r4,06000h
		;li r5,00010h
		
ramdump:
	mov r11,r8
	mov r4,r2
	li r3,": "
	bl @ShowHex4
	swpb r3
ramdumpAgain:		
	mov *r4+,r2
	bl @ShowHex4
	dec r5
	jne ramdumpAgain
	
	b *r8
Monitor:
	word 8320h
	word DoMonitor	
	
	
DoMonitor:
		mov r13,r5
		li r6,0000h
DoMonitorAgain:		
		mov *r5+,r2
		mov r6,r1
		bl @ShowReg
		ai r6,0100h
		ci r6,1000h 
		jne DoMonitorAgain
	RTWP



	
HELLOWORLD
        BYTE "HELLo WoRLD!123:@"     ;* string data
        BYTE 255
		BYTE "HELLo WoRLD!123:@"     ;* string data

        END