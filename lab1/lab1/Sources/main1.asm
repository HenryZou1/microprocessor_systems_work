; export symbols
  XDEF Entry, _Startup    ; export ‘Entry’ symbol
  ABSENTRY Entry          ; for absolute assembly: mark
; this as applicat. entry point
; Include derivative-specific definitions
  INCLUDE 'derivative.inc'
 ORG   $3000
LCD_DAT EQU   PTS; LCD data port S, pins PS7,PS6,PS5,PS4
LCD_CNTR    EQU   PORTE; LCD control port E, pins PE7(RS),PE4(E)
LCD_E       EQU   $10; LCD enable signal, pin PE4
LCD_RS      EQU   $80; LCD reset signal, pin PE7
  org    $1500 
  lds    #$1500   ; set up stack pointer
  jsr    openLCD  ; initialize the LCD
  ldx    #msg1
  jsr    putsLCD
  ldaa #$C0 ; move to the second row
  jsr                        cmd2LCD                        ;                        “
  ldx    #msg2
  jsr    putsLCD
                        swi
msg1  dc.b      "hello world!",0
msg2  dc.b      "LCD is working!",0
               

cmd2LCD psha ; save the command in stack
        bclr lcd_dat,lcd_RS ; select the instruction register
        bset lcd_dat,lcd_E ; pull the E signal high
        anda #$F0 ; clear the lower 4 bits
        lsra ; match the upper 4 bits with the LCD7.8 
        lsra ; data pins
        oraa #lcd_E ; maintain the E signal value
        staa 
        lcd_dat ; send the command, along with the RS and E signals
        nop ; extend the duration of the E pulse
        nop                                                ;                        “
        nop                                                ;                        “
        bclr lcd_dat,lcd_E ; pull the E signal low
        pula ; retrieve the LCD command
        anda #$0F ; clear the upper 4 bits
        lsla ; match the lower 4 bits with the LCD
        lsla ; data pins
        bset lcd_dat,lcd_E ; pull the E signal high
        oraa #lcd_E ; maintain the E signal value
        staa lcd_dat ; send the lower 4 bits of command with E and RS
        nop ; extend the duration of the E pulse
        nop                                                ;                        “
        nop                                                ;                        “
        bclr lcd_dat,lcd_E ; clear the E signal to complete the write operation
        ldy #1 ; adding this delay will complete the internal
        jsr delayby50us ; operation for most instructions
        rts
openLCD movb     #$FF,lcd_dir ; configure Port K for output
        ldy #10 ; wait for LCD to be ready
        jsr                        delayby10ms                        ;                        “
        ldaa #$28 ; set 4-bit data, two-line display, 5 
        jsr                        cmd2lcd                        ;                        “
        ldaa #$0F ; turn on display, cursor, and blinking
        jsr                        cmd2lcd                        ;                                                “
        ldaa #$06 ; move cursor right (entry mode set instruction)
        jsr                        cmd2lcd                        ;                                                “
        ldaa #$01 ; clear display screen and return to home position
        jsr                        cmd2lcd                        ;                        “
        ldy #2 ; wait until clear display command is complete
        jsr                        delayby1ms                        ;                        “
        rts
putcLCD psha ; save a copy of the data
        bset lcd_dat,lcd_RS ; select lcd Data register
        bset lcd_dat,lcd_E ; pull E to high
        anda #$F0 ; mask out the lower 4 bits
        lsra ; match the upper 4 bits with the LCD
        lsra ; data pins
        oraa #$03 ; keep signal E and RS unchanged
        staa lcd_dat ; send the upper 4 bits and E, RS signals
        nop ; provide enough duration to the E signal
        nop                                                ;                        “
        nop                                                ;                        “
        bclr lcd_dat,lcd_E ; pull the E signal low
        pula ; retrieve the character from the stack
        anda #$0F ; clear the upper 4 bits
        lsla ; match the lower 4 bits with the LCD
        lsla ; data pins
        bset lcd_dat,lcd_E ; pull the E signal high
        oraa #$03 ; keep E and RS unchanged
        staa lcd_dat
        nop
        nop
        nop
        bclr lcd_dat,lcd_E ; pull E low to complete the write cycle
        ldy #1 ; wait until the write operation is
        jsr                        delayby50us                        ;                        complete
        rts
putsLCD ldaa 1, x+; get one character from the string
        beq donePS ; reach NULL character?
        jsr                        putcLCD
        bra                        putsLCD
donePS  rts

        org $FFFE 
        ; uncomment this line for CodeWarrior
        dc.w start ; uncomment this line for CodeWarrior
        end