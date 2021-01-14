  XDEF Entry, _Startup    ; export ‘Entry’ symbol
  ABSENTRY Entry          ; for absolute assembly: mark
; this as applicat. entry point
; Include derivative-specific definitions
  INCLUDE 'derivative.inc'

************************************************************
*Timer Alams
*
************************************************************
;definitions
OneSec EQU   23; 1 second delay (at 23Hz)
TwoSec EQU   46; 2 second delay (at 23Hz)
LCD_DAT EQU   PORTB; LCD data port, bits - PB7,...,PB0
LCD_CNTR    EQU   PTJ; LCD control port, bits - PJ7(E),PJ6(RS)
LCD_E EQU   $80; LCD E-signal pin
LCD_RS EQU   $40; LCD RS-signal pin
;variable/data section
  ORG   $3850
; Where our TOF counter register lives
TOF_COUNTER RMB   1; The timer, incremented at 23Hz
AT_DEMO RMB   1; The alarm time for this demo
TEN_THOUS   RMB 1               ;10,000 digit
THOUSANDS   RMB 1               ;1,000 digit
HUNDREDS    RMB 1               ;100 digit
TENS        RMB 1               ;10 digit
UNITS       RMB 1               ;1 digit
NO_BLANK    RMB 1               ;Used in ’leading zero’ blanking by BCD2ASC
BCD_SPARE   RMB 2 ;Extra space for decimal point and string terminator
;code section
  ORG   $4000
; Where the code starts
Entry:
_Startup:
  LDS   #$4000; initialize the stack pointer
  JSR   initLCD; initialize the LCD
  JSR   clrLCD; clear LCD & home cursor
  JSR   ENABLE_TOF; Jump to TOF initialization
  CLI; Enable global interrupt
  
  LDAA  #'A'; Display A (for 1 sec)
  JSR   putcLCD;  --"--
  
  LDAA  TOF_COUNTER; Initialize the alarm time
  ADDA  #OneSec;  by adding on the 1 sec delay
  STAA  AT_DEMO;  and save it in the alarm
  
CHK_DELAY_1 
  LDAA  TOF_COUNTER; If the current time
  CMPA  AT_DEMO;  equals the alarm time
  BEQ   A1;  then display B
  BRA   CHK_DELAY_1;  and check the alarm again
  
A1  LDAA  #'B'; Display B (for 2 sec)
    JSR   putcLCD;  --"--
    LDAA  AT_DEMO; Initialize the alarm time
    ADDA  #TwoSec;  by adding on the 2 sec delay
    STAA  AT_DEMO  ;and save it in the alarm
    
CHK_DELAY_2 LDAA  TOF_COUNTER; If the current time
    CMPA  AT_DEMO;  equals the alarm time
    BEQ   A2;  then display C
    BRA   CHK_DELAY_2;  and check the alarm again
    
A2  LDAA  #'C'; Display C (forever)
    JSR   putcLCD;  --"--
    SWI
    
;subroutine section
;*******************************************************************
;*  Initialization of the LCD: 4-bit data width, 2-line display,   *
;*  turn on display, cursor and blinking off. Shift cursor right.  *
;******************************************************************* 
 
initLCD    BSET  DDRB,%11110000    ; configure pins PB7,PB6,PB5,PB4 for output
           BSET  DDRJ,%11000000    ; configure pins PJ7,PJ6 for output
           LDY   #2000             ; wait for LCD to be ready
           JSR   del_50us          ;-"-
           LDAA  #$28              ; set 4-bit data, 2-line display
           JSR   cmd2LCD           ;-"-
           LDAA  #$0C              ; display on, cursor off, blinking off
           JSR   cmd2LCD           ;-"-
           LDAA  #$06              ; move cursor right after entering a character
           JSR   cmd2LCD           ;-"-
           RTS
 
 
;*******************************************************************
;*                Clear display and home cursor                    *
;*******************************************************************

clrLCD     LDAA  #$01              ; clear cursor and return to home position
           JSR   cmd2LCD           ;-"-
           LDY   #40               ; wait until "clear cursor" command is complete
           JSR   del_50us          ;-"-
           RTS



;*******************************************************************
;*       ([Y] x 50us)-delay subroutine. E-clk=41,67ns.             *
;*******************************************************************
del_50us:   PSHX                  ;2 E-clk
eloop:      LDX   #$46 ;-clk -
iloop:      PSHA;2 E-clk  |
            PULA;3 E-clk  |
            PSHA;2 E-clk  | 50us
            PULA;3 E-clk  |
            NOP;1 E-clk  |
            NOP;1 E-clk  |
            DBNE  X,iloop;3 E-clk -
            DBNE  Y,eloop;3 E-clk
            PULX;3 E-clk
            RTS;5 E-clk


;*******************************************************************
;*  This function sends a command in accumulator A to the LCD      *
;*******************************************************************
cmd2LCD:    BCLR  LCD_CNTR,LCD_RS   ; select the LCD Instruction Register (IR)
            JSR   dataMov           ; send data to IR
            RTS
            
;*******************************************************************
;*  This function outputs a NULL-terminated string pointed to by X *
;*******************************************************************
putsLCD    LDAA  1,X+               ; get one character from the string
           BEQ   donePS             ; reach NULL character?
           JSR   putcLCD
           BRA   putsLCD
donePS     RTS


;*******************************************************************
;*  This function outputs the character in accumulator in A to LCD *
;*******************************************************************
putcLCD   BSET  LCD_CNTR,LCD_RS   ; select the LCD Data register (DR)
          JSR   dataMov           ; send data to DR
          RTS



;*******************************************************************
;*  This function sends data to the LCD IR or DR depening on RS    *
;*******************************************************************

dataMov   BSET  LCD_CNTR,LCD_E    ; pull the LCD E-sigal high
          STAA  LCD_DAT           ; send the upper 4 bits of data to LCD
          BCLR  LCD_CNTR,LCD_E    ; pull the LCD E-signal low to complete the write oper.
          LSLA                    ; match the lower 4 bits with the LCD data pins
          LSLA                    ;-"-
          LSLA                    ;-"-
          LSLA                    ;-"-
          BSET  LCD_CNTR,LCD_E    ; pull the LCD E signal high
          STAA  LCD_DAT           ; send the lower 4 bits of data to LCD
          BCLR  LCD_CNTR,LCD_E    ; pull the LCD E-signal low to complete the write oper.
          LDY   #20000                ; adding this delay will complete the internal
          JSR   del_50us          ; operation for most instructions
          RTS
          
          
;*******************************************************************
;*                          Binary to ASCII                        *
;*******************************************************************

leftHLF     LSRA                   ; shift data to right
            LSRA
            LSRA  
            LSRA
rightHLF    ANDA  #$0F             ; mask top half
            ADDA  #$30             ; convert to ascii
            CMPA  #$39
            BLE   out              ; jump if 0-9
            ADDA  #$07             ; convert to hex A-F
out         RTS

          
          

;**************************************************************
;*                           int2BCD                          *
;**************************************************************

INT2BCD   XGDX             ;Save the binary number into .X
          LDAA #0          ;Clear the BCD_BUFFER
          STAA TEN_THOUS
          STAA THOUSANDS
          STAA HUNDREDS
          STAA TENS
          STAA UNITS
          STAA BCD_SPARE
          STAA BCD_SPARE+1
;*
          CPX #0            ;Check for a zero input
          BEQ CON_EXIT      ;and if so, CON_EXIT
;*
          XGDX              ;Not zero, get the binary number back to .D as dividend
          LDX #10           ;Setup 10 (Decimal!) as the divisor
          IDIV              ;Divide: Quotient is now in .X, remainder in .D
          STAB UNITS        ;Store remainder
          CPX #0            ;If quotient is zero,
          BEQ CON_EXIT      ;then CON_EXIT
;*                          
          XGDX              ;else swap first quotient back into .D
          LDX #10           ;and setup for another divide by 10
          IDIV
          STAB TENS
          CPX #0
          BEQ CON_EXIT
;*
          XGDX              ;Swap quotient back into .D
          LDX #10           ;and setup for another divide by 10
          IDIV
          STAB HUNDREDS
          CPX #0
          BEQ CON_EXIT
;*
          XGDX               ;Swap quotient back into .D
          LDX #10            ;and setup for another divide by 10
          IDIV
          STAB THOUSANDS
          CPX #0
          BEQ CON_EXIT
;*
          XGDX                ;Swap quotient back into .D
          LDX #10             ;and setup for another divide by 10
          IDIV
          STAB TEN_THOUS
;*
CON_EXIT  RTS        ;We’re done the conversion          






;**************************************************************
;*                            BCD2ASC                         *
;**************************************************************

BCD2ASC     LDAA #0           ;Initialize the blanking flag
            STAA NO_BLANK
;*
C_TTHOU     LDAA TEN_THOUS    ;Check the ’ten_thousands’ digit
            ORAA NO_BLANK
            BNE NOT_BLANK1
;*
ISBLANK1    LDAA #' '         ;It’s blank
            STAA TEN_THOUS    ;so store a space
            BRA C_THOU        ;and check the ’thousands’ digit
;*
NOT_BLANK1  LDAA TEN_THOUS    ;Get the ’ten_thousands’ digit
            ORAA #$30         ;Convert to ascii
            STAA TEN_THOUS
            LDAA #$1          ;Signal that we have seen a ’non-blank’ digit
            STAA NO_BLANK
;*
C_THOU      LDAA THOUSANDS    ;Check the thousands digit for blankness
            ORAA NO_BLANK     ;If it’s blank and ’no-blank’ is still zero
            BNE NOT_BLANK2
;*
ISBLANK2    LDAA #' '         ;Thousands digit is blank
            STAA THOUSANDS    ;so store a space
            BRA C_HUNS        ;and check the hundreds digit
;*
NOT_BLANK2  LDAA THOUSANDS    ;(similar to ’ten_thousands’ case)
            ORAA #$30
            STAA THOUSANDS
            LDAA #$1
            STAA NO_BLANK
;*
C_HUNS      LDAA HUNDREDS     ;Check the hundreds digit for blankness
            ORAA NO_BLANK     ;If it’s blank and ’no-blank’ is still zero
            BNE NOT_BLANK3
;*
ISBLANK3    LDAA #' '         ;Hundreds digit is blank
            STAA HUNDREDS     ;so store a space
            BRA C_TENS        ;and check the tens digit
;*
NOT_BLANK3  LDAA HUNDREDS     ;(similar to ’ten_thousands’ case)
            ORAA #$30
            STAA HUNDREDS
            LDAA #$1
            STAA NO_BLANK
;*
C_TENS     LDAA TENS         ;Check the tens digit for blankness
            ORAA NO_BLANK     ;If it’s blank and ’no-blank’ is still zero
            BNE NOT_BLANK4
;*
ISBLANK4    LDAA #' '         ;Tens digit is blank
            STAA TENS         ;so store a space
            BRA C_UNITS       ;and check the units digit
;*
NOT_BLANK4  LDAA TENS         ;(similar to ’ten_thousands’ case)
            ORAA #$30
            STAA TENS
;*
C_UNITS     LDAA UNITS        ;No blank check necessary, convert to ascii.
            ORAA #$30
            STAA UNITS
;*
            RTS               ;We’re done
          


     



initAD      MOVB #$C0,ATDCTL2     ;power up AD, select fast flag clear
            JSR del_50us          ;wait for 50 us
            MOVB #$00,ATDCTL3     ;8 conversions in a sequence
            MOVB #$85,ATDCTL4     ;res=8, conv-clks=2, prescal=12
            BSET ATDDIEN,$0C      ;configure pins AN03,AN02 as digital inputs
            RTS

************************************************************
ENABLE_TOF  LDAA    #%10000000
            STAA    TSCR1; Enable TCNT
            STAA    TFLG2; Clear TOF
            LDAA    #%10000100; Enable TOI and select prescale factor equal to 16
            STAA    TSCR2
            RTS
************************************************************
TOF_ISR     INC     TOF_COUNTER
            
            LDAA    #%10000000; Clear
            STAA    TFLG2;  TOF
            RTI
************************************************************
DISABLE_TOF LDAA    #%00000100; Disable TOI and leave prescale factor at 16
            STAA    TSCR2
            RTS
************************************************************
*Interrupt Vectors
*
************************************************************
  ORG     $FFFE
  DC.W    Entry; Reset Vector
  
  ORG     $FFDE
  DC.W    TOF_ISR; Timer Overflow Interrupt Vector
        

  
