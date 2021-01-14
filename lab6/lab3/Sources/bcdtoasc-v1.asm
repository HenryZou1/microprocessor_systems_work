;=================================================================
;========= 9 BCD to ASCII Conversion Routine: Version 1 ==========
;=================================================================

;; @name itoa_u16
;; Converts an unsigned 16-bit number to a decimal string.
;;
;; @param AccD 16-bit unsigned number to convert
;; @param IX Starting address of string.
;; @return Nothing
;; @side CC modified
;; @author K.Clowes
itoa_u16: psha
          pshb
          pshy
          pshx
          pshx
          puly
          cpd    #0
          bne     u16_cont
          ldaa    #'0
          staa    0,x
          clr     1,x
          pulx
          bra     u16_ret     ;We’re outa-here!
          ; it’s not zero

u16_cont: ldx     #10
          idiv            ; AccB is remainder, IX is quotient
          addb    #’0        ; Convert remainder to ASCII
          stab    0,y
          iny
          cpx    #0
          beq     u16_done
          xgdx
          bra     u16_cont          
          
          
u16_done: clr 0,y         ; ensure generated string is null-terminated
          pulx
          jsr strrev      ; string is in reverse order-->reverse it!

u16_ret:  puly            ; restore original registers
          pulb
          pula
          rts 
