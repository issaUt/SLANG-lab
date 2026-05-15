; MZ-2500 IOCS / FNC definitions for AILZ80ASM
; Source: uploaded IOCS call list PDF and user-supplied IPL ROM
; Notes:
;   - AILZ80ASM macro syntax uses: <name> MACRO ... ENDM
;   - SVC uses RST 18H + 1-byte function number.
;   - FNC uses RST 28H + 1-byte function number.
;   - Some names in the source PDF are OCR-unclear; such items are marked.

; ----------------------------------------------------------------------
; Macros
; ----------------------------------------------------------------------
FNC MACRO n
    RST 28H
    DB  n
ENDM

; ----------------------------------------------------------------------
; FNC (RST 28H)
; ----------------------------------------------------------------------
FNC_INT        EQU 00H
FNC_ABS        EQU 01H
FNC_SIN        EQU 02H
FNC_COS        EQU 03H
FNC_TAN        EQU 04H
FNC_LN         EQU 05H
FNC_EXP        EQU 06H
FNC_SQR        EQU 07H
FNC_RND        EQU 08H
FNC_UNUSED_09  EQU 09H
FNC_ATN        EQU 0AH
FNC_SGN        EQU 0BH
FNC_LOG        EQU 0CH
FNC_FRAC       EQU 0DH
FNC_PAI        EQU 0EH
FNC_RAD        EQU 0FH
FNC_FAC        EQU 10H
FNC_DEG        EQU 11H
FNC_FIX        EQU 12H
FNC_CINT       EQU 13H
FNC_CSNG       EQU 14H
FNC_CDBL       EQU 15H
FNC_UNUSED_16  EQU 16H
FNC_UNUSED_17  EQU 17H
FNC_UNUSED_18  EQU 18H
FNC_UNUSED_19  EQU 19H
FNC_UNUSED_1A  EQU 1AH
FNC_UNUSED_1B  EQU 1BH
FNC_UNUSED_1C  EQU 1CH
FNC_UNUSED_1D  EQU 1DH
FNC_UNUSED_1E  EQU 1EH
FNC_UNUSED_1F  EQU 1FH
FNC_ADD        EQU 20H
FNC_SUB        EQU 21H
FNC_MUL        EQU 22H
FNC_DIV        EQU 23H
FNC_CMP        EQU 24H
FNC_MOD        EQU 25H
FNC_YEN        EQU 26H
FNC_POWER      EQU 27H
FNC_NEG        EQU 28H
FNC_RNDMIZ     EQU 29H
FNC_INT0       EQU 2AH
FNC_INT2       EQU 2BH
FNC_FLT0       EQU 2CH
FNC_UNUSED_2D  EQU 2DH
FNC_UNUSED_2E  EQU 2EH
FNC_UNUSED_2F  EQU 2FH
FNC_C_FLAS     EQU 30H
FNC_C_NMFL     EQU 31H
FNC_C_ASFL     EQU 32H
FNC_USING      EQU 33H
FNC_C_FLHX     EQU 34H
FNC_C_HXFL     EQU 35H
FNC_C_NBFL     EQU 36H
FNC_C_FXAS     EQU 37H
