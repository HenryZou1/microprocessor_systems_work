
  XDEF Entry, _Startup    ; export ‘Entry’ symbol
  ABSENTRY Entry          ; for absolute assembly: mark
; this as applicat. entry point
; Include derivative-specific definitions
  INCLUDE 'derivative.inc'

*****************************************************************
*Displaying battery voltage and bumper states (s19c32)
*
*****************************************************************
; Definitions
FIVESec EQU   115; 2 second delay (at 23Hz)
 ORG   $3850
TOF_COUNTER RMB   1; The timer, incremented at 23Hz
AT_DEMO RMB   1; The alarm time for this demo 
Entry:
_Startup:  
  BSET    DDRA,%00000011
  BSET    DDRT,%00110000
  
  
  JSR     STARFWD
  JSR     PORTFWD
  JSR     STARON
  JSR     PORTON
  
  JSR     STARREV
  JSR     PORTREV
  JSR     STAROFF
  
  
  
  
  JSR     PORTOFF      
  BRA *
;turn on off pt5  


STARON
  LDAA    PTT
  ORAA    #%00100000 ;mask turn on
  STAA    PTT
  RTS

STAROFF
  LDAA    PTT
  ANDA    #%11011111 ;mask turn on
  STAA    PTT
  RTS

STARFWD
  LDAA    PORTA
  ANDA    #%11111101
  STAA    PORTA
  RTS
STARREV
  LDAA    PORTA
  ORAA    #%00000010
  STAA    PORTA
  RTS
  
PORTON
  LDAA    PTT
  ORAA    #%00010000 ;mask turn on
  STAA    PTT
  RTS

PORTOFF
  LDAA    PTT
  ANDA    #%11101111 ;mask turn on
  STAA    PTT
  RTS

PORTFWD
  LDAA    PORTA
  ANDA    #%11111110
  STAA    PORTA
  RTS
PORTREV
  LDAA    PORTA
  ORAA    #%00000001
  STAA    PORTA
  RTS         

      

CHK_DELAY   LDAA    TOF_COUNTER
            CMPA    AT_DEMO
            BEQ     STOP_HERE
            ;NOP; Do something during the display
            BRA     CHK_DELAY;  and check the alarm again
STOP_HERE   SWI
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
        

