       TITL 'NEWHWTEST'
********************************************************************************
*       Define start of RAM and allocate storage for registers and data        *
********************************************************************************
*
        RORG >1000       ; RAM start
RSTWP   BSS 32           ; Set aside 32 bytes/16 words for primary workspace
LV1WP   BSS 32           ; Next 32 bytes for level 1 interrupt workspace
TAPWP   BSS 32           ; Next 32 bytes for tape drive interrupt workspace
MX0WP   BSS 32           ; Next 32 bytes for MUX 0 interrupt workspace
MX1WP   BSS 32           ; Next 32 bytes for MUX 1 interrupt workspace
TIMWP   BSS 32           ; Next 32 bytes for TIMER based interrupt workspace
LV6WP   BSS 32           ; Next 32 bytes for level 6 interrupt workspace
LV7WP   BSS 32           ; Next 32 bytes for level 7 interrupt workspace
*
********************************************************************************
*                   Define the memory mapped I/O Addresses                     *
********************************************************************************
*
* MUX 0 MMIO ADDRESSES
M0STAT  EQU >F000       ; THRE onto Bus[8], DR onto Bus[9]
M0RERD  EQU >F002       ; Clear DR, connect Reveiver Reg. to Bus[15:8]
M0THLO  EQU >F004       ; Load Bus[15:8] into Transmit Holding Reg.
M0RSET  EQU >F006       ; Reset interrupt flip flop
* MUX 1 MMIO ADDRESSES
M1STAT  EQU >F008       ; THRE onto Bus[8], DR onto Bus[9]
M1RERD  EQU >F00A       ; Clear DR, connect Reveiver Reg. to Bus[15:8]
M1THLO  EQU >F00C       ; Load Bus[15:8] into Transmit Holding Reg.
M1RSET  EQU >F00E       ; Reset interrupt flip flop
* TIMER MMIO ADDRESS
TIRSET  EQU >F010       ; Reset Timer Interrupt Flip Flop
* PARALLEL PORT MMIO ADDRESSES
PRBUSY  EQU >F012       ; Puts the printer busy signal onto Bus[8]
PPRFED  EQU >F014       ; Feed paper through the printer
PRSTRB  EQU >F016       ; Load Data Bus[15:8] into buffer to print
*
********************************************************************************
*            Define the Workspaces and PC for the Interrupt Levels             *
********************************************************************************
*
        RORG >0000              ; Reset Level / Primary interrupt
        DATA RSTWP
        DATA >0400
        DATA LV1WP              ; Interrupt Level 1 interrupt
        DATA >0080
        DATA TAPWP              ; Tape drive interrupt
        DATA >0100
        DATA MX0WP              ; MUX 0 UART interrupt
        DATA >0180
        DATA MX1WP              ; MUX 1 UART interrupt
        DATA >0200
        DATA TIMWP              ; Timer Based interrupt
        DATA >0280
        DATA LV6WP              ; Interrupt Level 6 interrupt
        DATA >0300
        DATA LV7WP              ; Interrupt Level 7 interrupt
        DATA >0380
*
********************************************************************************
*                             The Primary Loop                                 *
********************************************************************************
* This is just a dead simple loop to do nothing, the point of this program is
* purely to test interrupts for the two UARTs and the TIMER.
*
        RORG >0400
        LIMI 7                  ; Enable all interrupts from level 0 to 7
WASTE   JMP WASTE               ; Jump back and loop forever
*
********************************************************************************
*                           MUX 0 Interrupt Code                               *
********************************************************************************
* Check if a byte has been received or a byte has finished transmitting. If
* received, just shove that byte back out. Simple echo, nothing fancy.
*
        RORG >0180
        MOV @M0STAT, R0          ; Grab the status of the UART
        ANDI R0, >0200          ; AND it with a mask to see if DR is set
        JEQ DON0                ; If it isn't set, skip the next stuff
ECH0    MOV @M0STAT, R0          ; Grab the status of the UART
        ANDI R0, >0200          ; AND it with a mask to see if DR is set
        JEQ ECH0                ; If THRE isn't ready, loop until it is
        MOV @M0RERD, R0          ; Copy byte received into R0 (reset DR)
        MOV R0, @M0THLO          ; I say send it, send it good
DON0    RTWP
*
*
********************************************************************************
*                           MUX 1 Interrupt Code                               *
********************************************************************************
* Check if a byte has been received or a byte has finished transmitting. If
* received, just shove that byte back out. Simple echo, nothing fancy.
*
        RORG >0200
        MOV @M1STAT, R0          ; Grab the status of the UART
        ANDI R0, >0200          ; AND it with a mask to see if DR is set
        JEQ DON1                ; If it isn't set, skip the next stuff
ECH1    MOV @M1STAT, R0          ; Grab the status of the UART
        ANDI R0, >0200          ; AND it with a mask to see if DR is set
        JEQ ECH1                ; If THRE isn't ready, loop until it is
        MOV @M1RERD, R0          ; Copy byte received into R0 (reset DR)
        MOV R0, @M1THLO          ; I say send it, send it good
DON1    RTWP
*
********************************************************************************
*                          TIMER Based Interrupt Code                          *
********************************************************************************
* All this does is reset the timer interrupt.
*
        RORG >0280
        MOV R1, @TIRSET          ; Hit the TIMER reset MMIO address
        RTWP
*
********************************************************************************
*                            Ding! Fries are Done!                             *
********************************************************************************
*
        END                     ; This is the end of the program.
