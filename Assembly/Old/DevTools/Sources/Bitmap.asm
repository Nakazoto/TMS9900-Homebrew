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
VWTR 	EQU 	2030h

START
		

	LIMI    0               ;* disable interrupts
    LWPI    WRKSP           ;* set default workspace

		
; set VDP RAM start address (low and high byte)

	
		
	
		
        LI      R0,4020h
	    bl @VDP_SetWriteAddress

		li r0,0000h
		movb r0,@CursorX
		
		li r15,0ff15h


		
		
		li R1,VDPInit
		li R2,VDPInit_End-VDPInit
VDPAgain:		
		MOVB *R1+,@VDPWA
		dec r2
		jne VDPAgain
		
		LI R0,0000h+(128*8)
	    bl @VDP_SetWriteAddress
		
		li R1,TestSprite
		li R2,(TestSprite_end-TestSprite)
		bl @otir
		
		LI R0,2000h+(128*8)	;Address 2000
	    bl @VDP_SetWriteAddress
		
		li R1,TestSpritePalette
		li R2,(TestSpritePalette_end-TestSpritePalette)
		bl @otir
		
		li r3,1	;x
		li r4,2	;y
		li r5,6 ;w
		li r6,6 ;h
		li r7,128*256 ;Tilenum
		
		bl @FillAreaWithTiles		;(r3,r4) =XY (r5,r6)=WH ;R7=Tile
		
		
		JMP LOOPBACK
		
		
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

		
FillAreaWithTiles:		;(r3,r4) =XY (r5,r6)=WH ;R7=Tile
	mov r11,r10
FillAreaWithTiles_Yagain:
	mov r3,r1
	mov r4,r2
	bl @GetVDPScreenPos
	mov r5,r1
FillAreaWithTiles_Xagain:
	movb r7,@VDPWD
	ai r7,0100h
	dec r1
	jne FillAreaWithTiles_Xagain
	inc r4
	dec r6
	jne FillAreaWithTiles_Yagain

	B *R10			;RETURN

		
GetVDPScreenPos:	;(R1,R2)=X,Y
	
		mov r2,r0
		SLA R0,5
		a r1,r0
		ai r0,1800h
VDP_SetWriteAddress:		
		ai r0,4000h
		SWPB    R0
        MOVB    R0,@VDPWA		;H
        SWPB    R0
        MOVB    R0,@VDPWA		;L

	B *R11			;RETURN

otir:	
	MOVB *R1+,@VDPWD
	dec r2
	jne otir
	B *R11			;RETURN


	
	
testsprite:				;1 bit per pixel smiley

	;Don't put one byte on a line, or the assembler will word align it !?

	;BYTE 00111100b,01111110b	
	;BYTE 11011011b,11111111b	
	;BYTE 11111111b,11011011b	
	;BYTE 01100110b,00111100b	
	
	binclude "\ResALL\Sprites\RawMSX1.RAW"

TestSprite_end:	

TestSpritePalette:

	;   FB 		=Fore		Back	
	;BYTE 0A0h,0A0h,0BCh,0BCh,0BCh,0BCh,0ACh,0A0h		;DarkYellow	Black
	

	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	BYTE 60h,60h,60h,60h,60h,60h,60h,60h		;Line 1=DarkRed
	

TestSpritePalette_end:

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

VDPInit:
	BYTE 00000010b,128+0	;mode register #0
	BYTE 01100000b,128+1	;mode register #1
	BYTE 00000110b,128+2	;Pattern table name
	BYTE 10011111b,128+3	;colour table (LOW)
	BYTE 00000000b,128+4	;pattern generator table
	BYTE 00110110b,128+5	;sprite attribute table (LOW)
	BYTE 00000111b,128+6	;sprite pattern generator table
	BYTE 11110000b,128+7	;border colour/character colour at text mode
VDPInit_End:
	
HELLOWORLD
        BYTE "HELLo WoRLD!123:@"     ;* string data
        BYTE 255
		BYTE "HELLo WoRLD!123:@"     ;* string data

        END