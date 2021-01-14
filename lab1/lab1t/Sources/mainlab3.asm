*************************************************************
*product of two number with no signs
********************************************************************
; export symbols
  XDEF Entry, _Startup    ; export ‘Entry’ symbol
  ABSENTRY Entry          ; for absolute assembly: mark
; this as applicat. entry point
; Include derivative-specific definitions
  INCLUDE 'derivative.inc'
********************************************************************

********************************************************************

******************************************************************
*Writing to the LCD
*
*******************************************************************
; Definitions
 ORG   $3000
ADDATA RMB 8
; code section
    ORG   $4000
Entry:
_Startup:    
  LDAA    ATDSTAT0
  ANDA    #%100000
  ORG   $FFFE
  FDB   Entry