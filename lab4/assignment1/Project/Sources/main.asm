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

; Variable/data section  
Entry:
_Startup:
  ORG   $3850
  BSET    DDRA,%00000011
  BSET    DDRT,%00110000
  
  JSR     STARON
 
  BRA *
;turn on off pt5  
STARON
  LDAA    PTT
  
  ORAA    #%00100000 ;mask turn on
  STAA    PTT
  
  RTS

        
  ORG   $FFFE
  FDB   Entry 
