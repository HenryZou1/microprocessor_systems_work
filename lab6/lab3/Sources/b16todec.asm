;=================================================================
;================ 8 Binary 16 to BCD Conversion Routine ==========
;=================================================================


;* file ref b16todec.asm
;*
;***********************************************************************
BCD_BUFFER  EQU * ;The following registers are the BCD buffer area
;TEN_THOUS   RMB 1 ;10,000 digit
;THOUSANDS   RMB 1 ; 1,000 digit
;HUNDREDS    RMB 1 ;   100 digit
;TENS        RMB 1 ;    10 digit
;UNITS       RMB 1 ;     1 digit
;BCD_SPARE   RMB 2 ;Extra space for decimal point and string terminator
;NO_BLANK    RMB 1 ;Used in ’leading zero’ blanking by BCD2ASC
;*****************************************************************
;* Integer to BCD Conversion Routine
;* This routine converts a 16 bit binary number in .D into
;* BCD digits in BCD_BUFFER.
;* Peter Hiscocks
;* Algorithm:
;* Because the IDIV (Integer Division) instruction is available on
;* the HCS12, we can determine the decimal digits by repeatedly
;* dividing the binary number by ten: the remainder each time is
;* a decimal digit. Conceptually, what we are doing is shifting
;* the decimal number one place to the right past the decimal
;* point with each divide operation. The remainder must be
;* a decimal digit between 0 and 9, because we divided by 10.
;* The algorithm terminates when the quotient has become zero.
;* Bug note: XGDX does not set any condition codes, so test for
;* quotient zero must be done explicitly with CPX.
;* Data structure:
;* BCD_BUFFER EQU * The following registers are the BCD buffer area
;* TEN_THOUS RMB 1 10,000 digit, max size for 16 bit binary
;* THOUSANDS RMB 1 1,000 digit
;* HUNDREDS RMB 1 100 digit
;* TENS RMB 1 10 digit
;* UNITS RMB 1 1 digit
;* BCD_SPARE RMB 2 Extra space for decimal point and string terminator

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
