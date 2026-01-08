ORG 1000


	mov #Stack,sp
	mov #0xFF,r0
	mov #111111,r1
	mov #test,r2
test:	
	mov #12345,r2
	jsr pc,monitor
	bic #17770,r2
	jsr pc,monitor
	
	mov #lbl,r4
	mov #20,r3
	jsr pc,memdump
	;.if df mytes
	
	;.endc
	
	mov #Message,r1
PrintString:	
	movb (r1)+,r0
	cmpb #377,r0
	beq wait
	jsr pc,PrintChar
	br PrintString
	
memdump:
	mov r4,r2
	jsr PC,ShowOct16
	mov #':',r0
	jsr PC,PrintChar
	
	;jsr pc,NewLine
memdumpB:
	mov (r4)+,r2
	jsr PC,ShowOct16
	mov #' ',r0
	jsr PC,PrintChar
	dec r3
	bit #7,r3
	bne memdumpB
	jsr PC,NewLine
memdumpAgainB:
	cmp r3,#0
	bne memdump
	
	
	RTS PC
lbl:
	inc r0
	br lbl
	
wait:   tstb @#177560       ; character received?
		bpl wait        ; no, loop
		mov @#177562,r0 	; transmit data
		inc r0
		jsr PC,PrintChar
       br wait         ; get next character
newline:
	mov #15,r0		;CHR 13
	jsr PC,PrintChar
	mov #12,r0		;CHR 10
	;jsr PC,PrintChar
	;RTS PC   
PrintChar:
	tstb @#177564
	bpl PrintChar		;Wait for transmit ready
	mov r0,@#177566 	; transmit data
	RTS PC
Monitor:


	mov r2,-(sp)
	mov r1,-(sp)
		
		mov r2,-(sp)
			mov r1,-(sp)
				mov #'0',r1
				mov r0,r2
				jsr PC,MonitorReg		
			mov (sp)+,r1
			mov r1,r2
			mov #'1',r1
			jsr PC,MonitorReg

		mov (sp)+,r2
		inc r1
		jsr PC,MonitorReg
		
		mov r3,r2
		inc r1
		jsr PC,MonitorReg
		mov r4,r2
		inc r1
		jsr PC,MonitorReg
		mov r5,r2
		inc r1
		jsr PC,MonitorReg
		mov r6,r2
		inc r1
		jsr PC,MonitorReg
		mov 4(r6),r2
		sub #4,r2
		inc r1
		jsr PC,MonitorReg
		
		jsr pc,newline
	mov (sp)+,r1
	mov (sp)+,r2
	RTS PC

MonitorReg:
	mov r0,-(sp)
	mov r1,-(sp)
	mov r2,-(sp)
		mov #'R',r0
		jsr PC,PrintChar
		mov r1,r0
		jsr PC,PrintChar
		mov #':',r0
		jsr PC,PrintChar
		
		;mov #154321,r2
		
		
		jsr pc,ShowOct16
		mov #' ',r0
		jsr pc,PrintChar
	mov (sp)+,r2
	mov (sp)+,r1
	mov (sp)+,r0
	RTS PC
	
ShowOct16:	
		clr r1
		jsr pc,ShowOct
		jsr pc,ShowOctR2
		jsr pc,ShowOctR2pair
		
ShowOctR2pair:	
	jsr pc,ShowOctR2
ShowOctR2:	
	clr r1
	rol r2		;Get bit 3
	rol r1
	rol r2		;Get bit 2
	rol r1
ShowOct:
	rol r2		;Get Bit 1
	rol r1
	mov r1,r0
	
	add #'0',r0
	jsr PC,PrintChar
	RTS PC


	mov #1022,r5 ;point at string
again:
	tstb @#177564 ;is port ready?
	bpl again ;spin until it is
	movb (r5)+,@#177566 ;send next character
	bne again ;loop unless it was a NUL
	halt ;stop in that case

	Message:
	.ascii 'Hello Wurld'
	.byte 377
	.even
	

.blkw 64
	
Stack: