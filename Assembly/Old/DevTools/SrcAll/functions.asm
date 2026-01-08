PrintCharR3:		
	mov r3,r0			;Move R3 into R0
PrintChar:
	ci r0,6000h			;compare to 96
	jlt PrintCharOk		;<96 then jump
	
	ai r0,0E000h 		;R0=R0-32
PrintCharOk:
	;sb r2,r0
	movb r0,@VDPWD     ;* put next char on screen
	
	movb @CursorX,r0	;Load Cursor X
	ai r0,0100h			;Inc 1 char
	movb r0,@CursorX	;Save back
		
	B *R11				;Return
	
	
NewLine:
	movb @CursorX,r0	;Get Xpos
	
NewLineb:
	li r1,0000h
	movb r1,@VDPWD     	;Put Char on screen
	li r1,0100h
	ab r1,r0			;Inc 1 byte
	andi r0,1F00h		;Line 32?
	jne NewLineb		;Inc Xpos
	movb r0,@CursorX    ;Save New XPos
	
	B *R11				;Return
	
	
	
	

; set VDP RAM start address (low and high byte)
ScrInit:
	LI      R0,4020h
	SWPB    R0
	MOVB    R0,@VDPWA		;L
	SWPB    R0
	MOVB    R0,@VDPWA		;H

	li r0,0000h
	movb r0,@CursorX		;Xpos
	B *R11				;Return