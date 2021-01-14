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
  ORG   $3000
MULTIPLICAND    FCB   05                ; First Number
MULTIPLIER      FCB   06                ; Second Number
PRODUCT         RMB   2                 ; Result of product
********************************************************************

********************************************************************
  ORG   $4000
Entry:
_Startup:
  LDAA  #'A'
********************************************************************

********************************************************************
  ORG   $FFFE
  FDB   Entry