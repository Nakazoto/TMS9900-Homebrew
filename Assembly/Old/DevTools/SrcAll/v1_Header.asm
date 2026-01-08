
        ORG  6000h
		
		WORD 0AA01h				;header
		Word 0
		Word 0
        WORD PROGA				;Pointer to 1st program
        Word 0
		Word 0
PROGA   WORD 0					;1st entry 0=only
        WORD ProgramStart		;Start of Program
        BYTE 16				;Text Length
        BYTE "LEARNASM.NET   "	;Text Message
		

ProgramStart:
		LIMI    0               ;disable interrupts
        LWPI    wspDefault      ;set default workspace