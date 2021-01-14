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


ORG   $3000 
Entry:
_Startup:
  
  BSET    DDRA,%00000011
  BSET    DDRT,%00110000
  SWI
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
  ANDA    #%11011111 ;mask turn off
  STAA    PTT
  RTS
;turn on off PT4 

PORTON
  LDAA    PTT
  ORAA    #%00010000
  STAA    PTT
  RTS
PORTOFF
  LDAA    PTT
  ANDA    #%11101111
  STAA    PTT
  RTS
  
;turn pa1 to 0 or 1  
STARFWD
  LDAA    PORTA
  ORAA    #%00000010
  STAA    PORTA
  RTS
STARREV
  LDAA    PORTA
  ANDA    #%11111101
  STAA    PORTA
  RTS  


PORTFWD
        LDAA    PORTA
        ORAA    #%11111110
        STAA    PORTA
        RTS
PORTREV
        LDAA    PORTA
        ORAA    #%00000001
        STAA    PORTA
        RTS
        
  ORG   $FFFE
  FDB   Entry 
  
