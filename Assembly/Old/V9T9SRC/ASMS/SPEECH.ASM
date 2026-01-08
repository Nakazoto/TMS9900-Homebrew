; *******************************************
; SPEECH.ASM  V9t9 speech routines
; *******************************************
; by Edward Swartz.  3/27/1994
;		     2/28/1995	
; *******************************************

_SPEECH_ = 1

	include	standard.h
	include	tiemul.h
	include	video.h			; for DRAWPHRASE
	include	int.h
	include	sound.h
	include	special.h		; for DOSPRINT
	include	support.h
	include	record.h
	include	speech.h

	include	memory.inc
	include	lpc.inc


	.data

speechqueuesize dw	2048
speechqueue	dw	0		; queue segment for speech data
speechqueueptr	dw	0		; where, 0 - speechbuffersize-1
speechqueuecur	dw	0		; current spoken limit
speechqueueleft	dw	0		; # bytes still in queue



;speechdataoffs 	dw 0		; offset into sample at SADDR:0

err_nospeechmem db	'Not enough memory for speech.',0

	even
sdelay	dw	0		; delay for displaying phrase on screen
addr	db	3 dup (0)	; only 5 nybbles used
cmmnd	db	0
spdata	db	0		; what is read from speech port


uselpc	db	0

	even



;	If digitized speech isn't available:

sphrase	db	64	dup(0)	; phrase that has been "spoken"
garbage	db	3,'???'		; phrase not found

;	If it is:

tidigispeech	db	'TISPEECH.BIN',0
tispeechptrs	db	'TISPEECH.IND',0

speechexcite	db	14 dup(0)
speechpitches	db	14 dup(0)

sheader	db	1
	dw	0		; size
	db	0
	db	156		; 10000 Hz
	db	0
	db	0
	even


IFDEF	DEMO
	include demoequs.inc
ENDIF


queueing db	0		; is the digitized device active?




	.code


;===========================================================================
;	SPEECH:	Pre-config init.
;===========================================================================

speech_preconfiginit proc near
	clc
	ret
	endp


;===========================================================================
;	SPEECH:	Post-config initialization.
;
;	þ  Initialize LPC speech.		(later, digitized too)
;===========================================================================

speech_postconfiginit proc near
	call	speechinitlpc

	ret
	endp


;===========================================================================
;	SPEECH:	Restart.
;
;	þ  If speech was going, then we need to turn on the
;	speech device again.  (Clearsound should've turned it off.)
;
;	****************************************************************
;===========================================================================

speech_restart proc near
	clc
	ret
	endp


;===========================================================================
;	SPEECH:	Restop.
;
;	þ  If speech is going, then we need to turn off the
;	speech device.  (Clearsound should turn it off.)
;
;	****************************************************************
;===========================================================================

speech_restop proc near
	clc
	ret
	endp


;===========================================================================
;	SPEECH:	Shutdown.
;
;	DOS frees memory for us, so we won't do it here.
;===========================================================================

speech_shutdown proc near
	clc
	ret
	endp






;	Initialize LPC stuff.
;
;	þ  Allocate buffer for LPC speech.
;	þ  Load patches for "periodic" and "pitchtrans"
;

	.data

sil_msg	db	'Setting up LPC speech...',0dh,0ah,'$'
sil_merr db	'Not enough memory for LPC speech buffers.',0dh,0ah,0
sil_ferr db	'LPC patch file % not found or invalid size.',0dh,0ah,0


	.code

speechinitlpc proc near
	IFDEF	T386

	cmp	uselpc,0
	jne	silwant
       	jmp	silout

silwant:
	lea	dx,sil_msg
	call	dosprint

	mov	ah,48h				; get memory
	mov	bx,speechqueuesize
	add	bx,15
	shr	bx,4
	int	21h
	jc	silmerr
	mov	speechqueue,ax

	mov	speechqueueptr,0

	or	features,FE_LPCspeech

	lea	si,speechpath
	lea	bx,speechexcite
	cmp	byte ptr [bx],0
	je	silnoexc
	call	opensupportfile
	or	ax,ax
	jz	silferr

	push	ax
	mov	ax,ds
	mov	es,ax
	pop	ax
	lea	dx,periodic
	mov	cx,50*2
	call	readchunk
	mov	bx,ax
	mov	ah,3eh
	int	21h
silnoexc:
	lea	si,speechpath
	lea	bx,speechpitches
	cmp	byte ptr [bx],0
	je	silnopit
	call	opensupportfile
	or	ax,ax
	jz	silferr

	push	ax
	mov	ax,ds
	mov	es,ax
	pop	ax
	lea	dx,pitchtrans
	mov	cx,64*2
	call	readchunk
	mov	bx,ax
	mov	ah,3eh
	int	21h
silnopit:
	clc
	jmp	silout

silmerr:
	lea	dx,sil_merr
	jmp	silerrout

silferr:
	lea	dx,sil_ferr

silerrout:
	call	setuperror
	mov	uselpc,0
	and	features,not (FE_lpcspeech)
	stc
silout:
	ENDIF
	ret
	endp



speechcleanup proc near
	call	terminatespeech
	clc
	ret
	endp





;	Handle Speech Synthesizer write command
;
;	AL=byte sent
;	
handlespeechwrite	proc	near
	pusha
	push	es

	test	features,FE_speechROM
	jnz	hswnoignore
	jmp	hswout
hswnoignore:

	cmp	cmmnd,s_speakext	; speaking externally?
	jne	hswcommand

	call	swapbits
	call	addspeech

	cmp	lpcdecoding,0
	jnz	hswnotdecoded

	mov	cmmnd,0			; done -- we decoded the data
hswnotdecoded:
	jmp	hswout

hswcommand:
	cmp	al,10h			; ask to read a byte
	jne	hsw30

	mov	bx,word ptr addr      	; ignore high nybble
	mov	es,speechseg
	mov	al,es:[bx]
	mov	spdata,al
	inc	word ptr addr		; ?!  I guess so

	mov	cmmnd,s_readbyte	; notify HSRead to return value
	jmp	hswout

hsw30:
	cmp	al,30h			; read and branch
	jne	hsw50

	mov	bx,word ptr addr
	mov	es,speechseg
	mov	ah,es:[bx]
	mov	al,es:[bx+1]
	and	word ptr addr,0c000h
	and	ax,3fffh
	or	word ptr addr,ax
	jmp	hswout

hsw50:
	cmp	al,50h			; speak a vocabulary word at ADDR
	jne	hsw60

;	"SPEAK" this word

	call	hsspeak
	jmp	hswout

hsw60:
	cmp	al,60h			; speak direct data
	jne	hsw70

	mov	cmmnd,S_speakext

	call	startspeech

	jmp	hswout

hsw70:
	cmp	al,70h
	jne	hsw40

	call	terminatespeech

	jmp	hswout

hsw40:
	mov	ah,al
	and	ah,0f0h
	cmp	ah,40h
	je	hsw400

	mov	cmmnd,0			; NOP
	jmp	hswout			

hsw400:

;	Shift address right and put least-sig nybble at top

	mov	bx,word ptr addr
	mov	cl,byte ptr addr+2

	shr	bx,4
	mov	ch,cl
	shl	ch,4
	or	bh,ch
	and	al,0fh
	mov	cl,al

	mov	word ptr addr,bx
	mov	byte ptr addr+2,cl
	jmp	hswout

hswout:
	pop	es
	popa
	ret
	endp



;	Handle speech read
;
;	Return AL=byte read
;

handlespeechread	proc	near

	test	features,FE_speechROM
	jnz	hsrnoignore

	xor	al,al
	jmp	hsrout

hsrnoignore:

	cmp	cmmnd,s_readbyte
	je	hsrbyte

;	Otherwise return status

	cmp	cmmnd,s_speakext
	jne	hsrother

	mov	al,40h			; force "buffer low"
					; since we process data immediately
	cmp	lpcdecoding,0		
	jnz	hsrnotdone
	jmp	hsrout

hsrnotdone:
	or	al,80h			; "speaking"
	jmp	hsrout


hsrother:
	mov	al,60h			; "buffer low, buffer empty"
	jmp	hsrout

hsrbyte:
	mov	al,spdata
	mov	cmmnd,0
hsrout:
	ret
	endp


;===========================================================================
;	This routine says, "Hey, buddy, we're starting to decode a
;	brand fresh spankin' new speech phrase, so get to it!"
;
;
startspeech proc near

IFDEF	DEMO
	test	stateflag,demoing
	jz	sschnope
	push	ax
	mov	ah,SPEECHSTARTING
	call	dspeechdata
	pop	ax
sschnope:
ENDIF

	call	lpcparaminit

	cmp	queueing,0
	jnz	ssspeakeron

	call	speakdeviceinit
	call	speakqueueinit

ssspeakeron:
	ret
	endp


;--------------------------------------------------------------------------
;	Initialize output device for speech.
;
speakdeviceinit proc near
	push	bx

	mov	bx,speech
	call	[bx].sinit

	pop	bx
	ret
	endp


;--------------------------------------------------------------------------
;	Initialize timer and queue for speech. 
;
;
speakqueueinit proc near
	push	ax

	mov	speechqueueptr,0
	mov	speechqueueleft,0
	mov	speechqueuecur,0

	mov	ax,8000
	mov	currentfunc,offset hsspeakbyte
	call	setcurrentspeed

	mov	queueing,1

	pop	ax
	ret
	endp


;--------------------------------------------------------------------------
;	This routine simply pushes a new byte onto the queue.
;
;	AL=byte
;
addspeech proc	near
IFDEF	DEMO
	test	stateflag,demoing
	jz	aschnope
     	push	ax
	mov	ah,ADDINGBYTE
	call	dspeechdata
	pop	ax
aschnope:
ENDIF
	call	hspush
	ret
	endp


;--------------------------------------------------------------------------
;	This routine is called to say that the end-of-speech
;	command has been encountered.
;
stopspeech proc near
IFDEF	DEMO
	test	stateflag,demoing
	jz	spschnope
	push	ax
	mov	ah,SPEECHSTOPPING
	call	dspeechdata
	pop	ax
spschnope:
ENDIF

	mov	lpcdecoding,0
	ret
	endp


;--------------------------------------------------------------------------
;	This routine is called to force the speech synthesizer
;	to reset.
;
terminatespeech proc near
IFDEF	DEMO
	test	stateflag,demoing
	jz	tsnope
	push	ax
	mov	ah,TERMINATINGSPEECH
	call	dspeechdata
	pop	ax
tsnope:
ENDIF

	mov	cmmnd,0				; no command
	mov	lpcdecoding,0
	call	speakqueuedone
	call	speakdevicedone
	clc
	ret
	endp


;--------------------------------------------------------------------------
;	This routine is called when the speech queue has emptied
;	and LPC decoding is finished.
;
speakqueuedone proc near
	push	ax

	mov	ax,0
	call	setcurrentspeed			; kill queue

	mov	queueing,0

	pop	ax
	ret
	endp


;-------------------------------------------------------------------------
;	This routine is called when the speech device is finished.
;
;
speakdevicedone proc near
	push	bx

	mov	bx,speech
	call	[bx].sshut

	pop	bx
	ret
	endp



;	Timer-called routine which does this to queued speech data:
;
;	1)  If spoken=0 and speechqueueleft<(speechqueuesize/2, then exits
;	2)  If spoken=0 and speechqueueleft>=(speechqueuesize/2), speaks
;	3)  If spoken=1 and speechqueueleft>0, speaks
;	4)  If spoken=1 and speechqueueleft=0, resets currentfunc.

hsspeakbyte proc near
	
	push	ax
	push	bx
	push	di
	push	es

	pushf
	cli

	mov	bx,speechqueuesize

	cmp	lpcdecoding,0	      	; is all the decoding done yet?
	jz	hsbfinishqueue

	cmp	queueing,0
	jz	hsbfinishqueue

	mov	ax,bx
	shr	ax,1
	cmp	speechqueueleft,ax
	jb	hsbexit			; uh..., get some more data first

	jmp	hsbspeak

hsbfinishqueue:				; LPC decoding finished!
	cmp	speechqueueleft,0	; any bytes left?
	jg	hsbspeak		; yup!

	call	speakqueuedone
	call	speakdevicedone
	jmp	hsbexit			; terminate ourselves


hsbspeak:
	mov	es,speechqueue
	mov	di,speechqueuecur	; point to queue
	mov	ah,es:[di]		; get next byte
	inc	di			; increment queue pointer
	cmp	di,bx			; wrapped?
	jb	hsbnowrap
	xor	di,di			; yuppers
hsbnowrap:
	mov	speechqueuecur,di	; update
	dec	speechqueueleft		; one less byte to speak, bay-beee
	mov	di,speech
	call	[di].sone		; speak the byte

hsbexit:
	popf

	pop	es
	pop	di
	pop	bx
	pop	ax
	ret
	endp


hsqueuebyte proc near
	push	ax
	push	bx
	push	es

	pushf
	cli

	cmp	silence,0	    	; silence means, simply, no queueing!
	jnz	hssbnot

	mov	es,speechqueue
	mov	bx,speechqueueptr	; point to queue
	mov	es:[bx],al		; stuff byte
	inc	bx			; inc ptr
	cmp	bx,speechqueuesize
	jb	hssbput
	xor	bx,bx		  	; wrapped
hssbput:
	mov	speechqueueptr,bx	; save ptr

	inc	speechqueueleft		; one more byte to speak

	cmp	bx,speechqueuecur
	jne	hssbnot			; not colliding with unspoken stuff

	mov	bx,speechqueuesize	; it IS full... we must wait it out
	shr	bx,1

hssbwaituntilnotfull:	
	cmp	queueing,0
	jz	hssbnot			; uh...?

	mov	ax,speechqueueleft
	cmp	ax,bx
	jae	hssbwaituntilnotfull	; wait until half empty

hssbnot:
	popf
	pop	es
	pop	bx
	pop	ax
	ret
	endp





	end








	
