
MAP_WIDTH      = 128
MAP_HEIGHT     = 26

;ZP VARIABLES
.segment "ZEROPAGE"
BLOCK_PTR = $29

SMOOTH_X = $4F
SMOOTH_Y = $50


.define WORLD_X  $65
.define WORLD_Y  $66

.define MAP_BASE  $9000
CHARSET_COLORS = $cf00


.segment "MAP_UTILITY"

;.org $0200
VAR_0200:
.BYTE $00


;.org $0214
VAR_0214:
.BYTE $00


;.org $1FAF
VAR_1FAF:
.BYTE $00


;.org $2A0F
VAR_2A0F:
.BYTE $00

VAR_2BDE:


; $49  MAP_PTR = X_POS2
  ;$4a
  ;$4b
  ;$4c

  ;$4F        SMOOTH_X = $04, don't swap
  ;$50 [0..7] SMOOTH_Y = $04, don´t swap
; $5f  : FLIP_SCREENBUFFER ()
; $54  HORI_INBLOCK_COUNTER [0-3]
; $56  SUB_BLOCK_COUNTER
; $58  X_POS1
; 
; $63
; $64
; $65  WORLD_X
; $66  WORLD_Y

; $8B  incremented every COLOUR_SCROLL 
; $90  decremented when go right, increment when left
; $94    "           "   "   "  ,     "      "    " 
; $95    "           "   "   "  ,     "      "    "
; $96    "           "   "   "  ,     "      "    "
; $97    "           "   "   "  ,     "      "    "
; $A4  decremented when go right
; $A5
; $A8
; $A9
; $AA
; $AB
; $AC
; $AD
; $AE
; $AF
; $B8
; $B9









 
 

;FUNCTIONS:
; $2D83      DO_MAP_ALL_SCREEN  
; $2E70      COPY_SCREEN1_TO_SCREEN2
; $2E90  (+) DO_MAP_SCROLLING
; $2EBB      DO_MAP_LEFT
; $2F13      DO_MAP_RIGHT
; $2F5F      DO_MAP_UP
; $2F95      DO_MAP_DOWN
; $2FCB      VAR_
; $2FCC      VAR_
; $2FCD      VAR_
; $2FCE      INIT_SCROLL_VARIABLES
; $302F      FLIP_SCREENBUFFER_POINTERS
; $
; $3072      SET_SCOREBOARD_POINTERS1 - SELF_SOURCE_PTR = $3FFF(407f)/$43FF, SELF_DESTINATION_PTR = $4400/$4000
; $30b5      SET_SCOREBOARD_POINTERS2 - SELF_SOURCE_PTR = $4028(40A8)/$4428, SELF_DESTINATION_PTR = $4400/$4000
; $30f8      SET_SCOREBOARD_POINTERS3 - SELF_SOURCE_PTR = $3FD8(4058)/$43D8, SELF_DESTINATION_PTR = $4400/$4000  (when up)
; $313B      INC_8B_DUMP_SCOREBOARD inc $8b + DUMP_SCOREBOARD,
; $3140      DUMP_SCOREBOARD
; $3190      COLOUR_SCROLL_RIGHT
; $3230      READ_MAP_IN_RIGHT_BUFFER
; $32B6      DUMP_RIGHT_BORDER
; $330f      COLOUR_SCROLL_LEFT    
; $33A7      DUMP_MAP_LEFT_BORDER
; $341A      DUMP_LEFT_BORDER
; $3473      COLOUR_SCROLL_UP
; $3595      READ_MAP_IN_UP_BUFFER
; $3607      DUMP_UPPER_BORDER

; $3628      COLOUR_SCROLL_DOWN
; $3727      READ_MAP_IN_BOTTOM_BUFFER
; $37B3      DUMP_BOTTOM_BORDER

; $37D4      INCREMENT_HORIZONTAL
; $37EF      DECREMENT_HORIZONTAL
; $380C      INCREMENT_VERTICAL
; $3827      DECREMENT_VERTICAL

; $3840-$3854  RIGHT_BUFFER (size: #20)
; $385E-$3872  LEFT_BUFFER (size: #20)
; $3878-$38A0  UPPER_BUFFER (size: #40)
; $38A0-$38C8  BOTTOM_BUFFER (size: #40)


;-------------------------------------------------------
; input: $63, $64
;
;
;.org $2d83
 
DO_MAP_ALL_SCREEN:
FUNC_2D83:
                     LDA #$C8
                     STA @SELF_TARGET_PTR+1
                     LDA #$40
                     STA @SELF_TARGET_PTR+2 ; $40C8

                     LDA #$00
                     STA @VAR_2E58
                  
@LROW:
                     LDA #$00
                     STA @VAR_2E57

                     LDA $63
                     STA $58
                     LDA $64
                     STA $59
                     LDA #$00
                     CLC
                     ADC $58
                     STA @SELF_SOURCE_MAP_PTR+1
                     LDA #$90  ; #>MAP
                     ADC $59
                     STA @SELF_SOURCE_MAP_PTR+2
@L0:
                     LDA #$00
                     STA BLOCK_PTR+1
                     LDX @VAR_2E58
@SELF_SOURCE_MAP_PTR:
                     LDA $ffff,X
                     ASL A
                     ROL BLOCK_PTR+1
                     ASL A
                     ROL BLOCK_PTR+1
                     ASL A
                     ROL BLOCK_PTR+1
                     ASL A
                     ROL BLOCK_PTR+1
                     CLC

                     ;2dc5
                     ADC #$00
                     STA BLOCK_PTR
                     LDA BLOCK_PTR+1
                     ADC #$80 ; #>BLOCKS
                     STA BLOCK_PTR+1 ; $29 (BLOCK_PTR) = $8000
                     JMP @N1
@L1:;2dd2
                     LDA @SELF_TARGET_PTR+1
                     CLC
                     ADC #$04 ; tile size
                     STA @SELF_TARGET_PTR+1
                     LDA @SELF_TARGET_PTR+2
                     ADC #$00
                     STA @SELF_TARGET_PTR+2
                  
                     LDA @SELF_SOURCE_MAP_PTR+1
                     CLC
                     ADC #MAP_HEIGHT
                     STA @SELF_SOURCE_MAP_PTR+1
                     LDA @SELF_SOURCE_MAP_PTR+2
                     ADC #$00
                     STA @SELF_SOURCE_MAP_PTR+2

                     INC @VAR_2E57
                     LDA @VAR_2E57
                     CMP #$0A ; tiles per row
                     BNE @L0

                     LDA @SELF_TARGET_PTR+1
                     CLC
                     ADC #$78
                     STA @SELF_TARGET_PTR+1
                     LDA @SELF_TARGET_PTR+2
                     ADC #$00
                     STA @SELF_TARGET_PTR+2
                     INC @VAR_2E58
                     LDA @VAR_2E58
                     CMP #$05
                     BEQ @EXIT
                     JMP @LROW
@EXIT:
                     JMP COPY_SCREEN1_TO_SCREEN2
@N1:
                     LDA @SELF_TARGET_PTR+1
                     STA @SELF_COLOR_PTR+1
                     LDA @SELF_TARGET_PTR+2
                     CLC
                     ADC #$98
                     STA @SELF_COLOR_PTR+2
                     LDY #$00
                     LDX #$00
@L2:
                     STY @VAR_2E5B
                     LDA (BLOCK_PTR),Y
@SELF_TARGET_PTR:
                     STA $43E8,X
                     TAY
                     LDA CHARSET_COLORS,Y
@SELF_COLOR_PTR:
                     STA $DB6C,X
                     LDY @VAR_2E5B
                     INY
                     INX
                     TXA
                     AND #$03
                     BNE @L2
                     TXA
                     CLC
                     ADC #$24
                     TAX
                     CPY #$10
                     BNE @L2
                     JMP @L1       ;
@VAR_2E57:
.BYTE $00
@VAR_2E58:
.BYTE $00
@VAR_2E5B:
.BYTE $00


COPY_SCREEN1_TO_SCREEN2:
FUNC_2E70:
                     LDX #$F9
@L1:                 LDA $4000,X
                     STA $4400,X
                     LDA $40FA,X
                     STA $44FA,X
                     LDA $41F4,X
                     STA $45F4,X
                     LDA $42EE,X
                     STA $46EE,X
                     DEX   
                     CPX #$FF
                     BNE @L1
                     RTS

;--------------------------------------------------------------------------------------------------
; if ( VAR_2FCB == 00 and VAR_2FCC == $FF and VAR_2FCD == 00 )  : DO_MAP_DOWN
; if ( VAR_2FCB == 00 and VAR_2FCC == $01 and VAR_2FCD == 00 )  : DO_MAP_UP
; if ( VAR_2FCB == 01 and VAR_2FCC == $00 and VAR_2FCD == 00 )  : DO_MAP_LEFT
; if ( VAR_2FCB == FF and VAR_2FCC == $00 and VAR_2FCD == 00 )  : DO_MAP_RIGHT
DO_MAP_SCROLLING:
FUNC_2E90:
                     LDA $BD24
                     CMP #$02
                     BCS @EXIT
                     LDA $5E
                     STA $60
                     LDA VAR_2FCD
                     BEQ @N1
                     JSR FUNC_2FCE
@N1:                 LDA VAR_2FCB
                     BEQ @N2
                     BMI DO_MAP_RIGHT  ; happens when scroll down
                     JMP DO_MAP_LEFT
@N2:                 LDA VAR_2FCC
                     BEQ @EXIT
                     BMI @N3
                     JMP DO_MAP_UP
@N3:                 JMP DO_MAP_DOWN
@EXIT:               RTS

DO_MAP_LEFT:
FUNC_2EBB:
                     LDA SMOOTH_Y
                     CMP #$04
                     BNE @EXIT

                     LDA SMOOTH_X
                     CMP #$04
                     BNE @N1

                     LDA WORLD_X
                     CMP #$11
                     BEQ @EXIT

@N1:                 LDA $90
                     CLC
                     ADC #$01
                     STA $90

                     LDA VAR_0200
                     ADC #$00
                     STA VAR_0200
                     LDA $A4
                     CLC
                     ADC #$01
                     STA $A4
                     
                     LDA VAR_0214
                     ADC #$00
                     STA VAR_0214
                     
                     INC $93
                     INC VAR_2A0F
                     INC $94
                     INC $95
                     INC $96
                     INC $97
                     LDA SMOOTH_X
                     CLC
                     ADC #$01
                     AND #$07
                     STA SMOOTH_X
                     ASL A
                     TAX
                     LDA JUMP_TABLE_LEFT_DIRECTION,X
                     STA @SELF_JMP_TASK+1
                     LDA JUMP_TABLE_LEFT_DIRECTION+1,X
                     STA @SELF_JMP_TASK+2
@SELF_JMP_TASK:
                     JMP $330F
@EXIT:               RTS



DO_MAP_RIGHT:
FUNC_2F13:
                     LDA SMOOTH_Y
                     CMP #$04
                     BNE FUNC_RTS

                     LDA $90
                     SEC
                     SBC #$01
                     STA $90

                     LDA VAR_0200
                     SBC #$00
                     STA VAR_0200

                     LDA $A4
                     SEC
                     SBC #$01
                     STA $A4

                     LDA VAR_0214
                     SBC #$00
                     STA VAR_0214

                     DEC $93
                     DEC VAR_2A0F
                     DEC $94
                     DEC $95
                     DEC $96
                     DEC $97

                     LDA SMOOTH_X
                     SEC
                     SBC #$01
                     AND #$07
                     STA SMOOTH_X

                     ASL A
                     TAX
                     LDA JUMP_TABLE_RIGHT_DIRECTION,X  ; 2f4f
                     STA @SELF_JMP_TASK+1
                     LDA JUMP_TABLE_RIGHT_DIRECTION+1,X
                     STA @SELF_JMP_TASK+2
@SELF_JMP_TASK:
                     JMP FUNC_RTS
@EXIT:               RTS

FUNC_RTS:
                     RTS

DO_MAP_UP:
FUNC_2F5F:
                     LDA SMOOTH_X
                     CMP #$04
                     BNE @EXIT
               
                     INC $B9
                     INC $A5
                     INC $A8
                     INC $A9
                     INC $AA
                     INC $AB
                     INC $AC
                     INC $AD
                     INC $AE
                     INC $AF
                     INC $B8

                     LDA SMOOTH_Y
                     CLC
                     ADC #$01
                     AND #$07
                     STA SMOOTH_Y   ; INC SMOOTH_Y

                     ASL A
                     TAX
                     LDA JUMP_TABLE_UP_DIRECTION,X
                     STA @SELF_JMP_TASK+1
                     LDA JUMP_TABLE_UP_DIRECTION+1,X
                     STA @SELF_JMP_TASK+2
@SELF_JMP_TASK:
                     JMP @EXIT
@EXIT:               RTS


DO_MAP_DOWN:
FUNC_2F95:
                     LDA SMOOTH_X ; SMOOTH_X
                     CMP #$04
                     BNE @EXIT ; fast FUNC_2F95-1 

                     DEC $B9
                     DEC $A5
                     DEC $A8
                     DEC $A9
                     DEC $AA
                     DEC $AB
                     DEC $AC
                     DEC $AD
                     DEC $AE
                     DEC $AF
                     DEC $B8
                     LDA SMOOTH_Y
                     SEC
                     SBC #$01
                     AND #$07
                     STA SMOOTH_Y ; $50 
                     ASL A
                     TAX
                     LDA JUMP_TABLE_BOTTOM_DIRECTION,X  ; JUMP_TABLE_300F
                     STA @SELF_JUMP+1
                     LDA JUMP_TABLE_BOTTOM_DIRECTION+1,X
                     STA @SELF_JUMP+2
@SELF_JUMP:
                     JMP @EXIT
@EXIT:
                     RTS

;-------------------------------------------------------------------------
; if (SMOOTH_X!=4 and SMOOTH_Y!=4):
;
INIT_SCROLL_VARIABLES:
FUNC_2FCE:
                     LDA SMOOTH_X
                     CMP #$04
                     BNE @N1

                     LDA SMOOTH_Y
                     CMP #$04
                     BNE @N1

                     LDA #$00
                     STA VAR_2FCB
                     STA VAR_2FCC
                     STA VAR_2FCD
                     STA VAR_1FAF
                     RTS
@N1:                 LDA #$01
                     STA VAR_2FCD
                     RTS

JUMP_TABLE_RIGHT_DIRECTION:
JUMP_TABLE_2FEF:
;.BYTE 40 31 40 31  40 31 40 31  5e 2f b6 32  30 32 90 31
 
;3140 ; DUMP_SCOREBOARD
;3140 ; DUMP_SCOREBOARD
;3140 ; DUMP_SCOREBOARD
;3140 ; DUMP_SCOREBOARD
;2f5e ; RTS
;32b6 ; DUMP_RIGHT_BORDER
;3230 ; READ_MAP_IN_RIGHT_BUFFER
;3190 ; COLOUR_SCROLL_RIGHT

.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD
.BYTE <FUNC_RTS, >FUNC_RTS
.BYTE <DUMP_RIGHT_BORDER, >DUMP_RIGHT_BORDER
.BYTE <READ_MAP_IN_RIGHT_BUFFER, >READ_MAP_IN_RIGHT_BUFFER
.BYTE <COLOUR_SCROLL_RIGHT, >COLOUR_SCROLL_RIGHT
 
JUMP_TABLE_LEFT_DIRECTION:
JUMP_TABLE_2FFF:
;>C:2fff  0f 33 a7 33  5e 2f 5e 2f  5e 2f 40 31  3b 31 40 31

;330F ; COLOUR_SCROLL_LEFT
;33A7 ; DUMP_MAP_LEFT_BORDER
;2F5E ; RTS
;2F5E ; RTS
;2F5E ; RTS
;3140 ; DUMP_SCOREBOARD
;313B ; INC_8B_DUMP_SCOREBOARD
;3140 ; DUMP_SCOREBOARD

.BYTE <COLOUR_SCROLL_LEFT, >COLOUR_SCROLL_LEFT  
.BYTE <DUMP_MAP_LEFT_BORDER, >DUMP_MAP_LEFT_BORDER  
.BYTE <FUNC_RTS, >FUNC_RTS  
.BYTE <FUNC_RTS, >FUNC_RTS  
.BYTE <FUNC_RTS, >FUNC_RTS  
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD  
.BYTE <INC_8B_DUMP_SCOREBOARD, >INC_8B_DUMP_SCOREBOARD  
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD  


JUMP_TABLE_BOTTOM_DIRECTION:
JUMP_TABLE_300F:
;>C:300f  40 31 40 31  40 31 40 31  5e 2f b3 37  27 37 28 36
;3140 ; DUMP_SCOREBOARD
;3140 ; DUMP_SCOREBOARD
;3140 ; DUMP_SCOREBOARD
;3140 ; DUMP_SCOREBOARD
;2f5e ; RTS
;37b3 ; DUMP_BOTTOM_BORDER
;3727 ; READ_MAP_IN_BOTTOM_BUFFER
;3628 ; COLOUR_SCROLL_DOWN

.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD                     ; when SMOOTH_Y=0
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD                     ; when SMOOTH_Y=1
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD                     ; when SMOOTH_Y=2
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD                     ; when SMOOTH_Y=3
.BYTE <FUNC_RTS, >FUNC_RTS                       ; when SMOOTH_Y=4
.BYTE <DUMP_BOTTOM_BORDER, >DUMP_BOTTOM_BORDER               ; when SMOOTH_Y=5
.BYTE <READ_MAP_IN_BOTTOM_BUFFER, >READ_MAP_IN_BOTTOM_BUFFER ; when SMOOTH_Y=6
.BYTE <COLOUR_SCROLL_DOWN, >COLOUR_SCROLL_DOWN               ; when SMOOTH_Y=7

JUMP_TABLE_UP_DIRECTION:
JUMP_TABLE_301F:
;>C:301f  73 34 95 35  07 36 5e 2f  5e 2f 40 31  3b 31 40 31
;3473 ; COLOUR_SCROLL_UP
;3595 ; READ_MAP_IN_UP_BUFFER
;3607 ; DUMP_UPPER_BORDER
;2f5e ; RTS
;2f5e ; RTS
;3140 ; DUMP_SCOREBOARD
;313b ; INC_8B_DUMP_SCOREBOARD
;3140 ; DUMP_SCOREBOARD

.BYTE <COLOUR_SCROLL_UP, >COLOUR_SCROLL_UP                    
.BYTE <READ_MAP_IN_UP_BUFFER, >READ_MAP_IN_UP_BUFFER                    
.BYTE <DUMP_UPPER_BORDER, >DUMP_UPPER_BORDER                    
.BYTE <FUNC_RTS, >FUNC_RTS                    
.BYTE <FUNC_RTS, >FUNC_RTS                      
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD              
.BYTE <INC_8B_DUMP_SCOREBOARD, >INC_8B_DUMP_SCOREBOARD
.BYTE <DUMP_SCOREBOARD, >DUMP_SCOREBOARD              

;------------------------------------------------------------------------------
; adjust SELF_SCREEN_PTR & SELF_DESTINATION_PTR from function ´´
;    $4F == #04 && $50 == #04 don't swap
;    $50 = $04, don´t swap
;    set VAR_318f = $00 if enter
;    set VAR_2FCB = $ff if enter

;    SELF_SOURCE_PTR is 317B
;    SELF_DESTINATION_PTR is 317E
FLIP_SCREENBUFFER_POINTERS:
FUNC_302F:
                     LDA SMOOTH_X
                     CMP #$04
                     BNE @EXIT_1
                     
                     LDA SMOOTH_Y
                     CMP #$04
                     BNE @EXIT_1
                     
                     LDA #$00
                     STA VAR_318F
                     LDA #$FF
                     STA VAR_2FCB ; when $5f   = !$00 => [SELF_SCREEN_PTR = $4000, SELF_DESTINATION_PTR = $43ff]
                                  ;               $00 => [SELF_SOURCE_PTR = $4400, SELF_DESTINATION_PTR = $3fff]
                     LDA #$00
                     STA SELF_SOURCE_PTR+1
                     LDA #$40
                     STA SELF_SOURCE_PTR+2  ; @SELF_SCREEN_PTR = $4000
                     
                     LDA #$FF
                     STA SELF_DESTINATION_PTR+1
                     LDA #$43
                     STA SELF_DESTINATION_PTR+2 ; SELF_DESTINATION_PTR = $43ff

                     LDA $5F
                     BEQ @EXIT_1

                     LDA #$00
                     STA SELF_SOURCE_PTR+1
                     LDA #$44
                     STA SELF_SOURCE_PTR+2  ; SELF_SOURCE_PTR = $4400

                     LDA #$FF
                     STA SELF_DESTINATION_PTR+1
                     LDA #$3F
                     STA SELF_DESTINATION_PTR+2   ; SELF_DESTINATION_PTR = $ 3fff
@EXIT_1:
                     RTS


;------------------------------------------------------
; if ( $4F == #04 and $50 == #04 )
; SELF_SOURCE_PTR = $3FFF/$43FF, SELF_DESTINATION_PTR = $4400/$4000
RESET_POINTERS1:   
FUNC_3072:     
                     LDA SMOOTH_X
                     CMP #$04
                     BNE @EXIT

                     LDA SMOOTH_Y
                     CMP #$04
                     BNE @EXIT
                     
                     LDA #$00
                     STA VAR_318F

                     LDA #$01
                     STA VAR_2FCB ; to-do: investigate this var

                     LDA #$FF
                     STA SELF_SOURCE_PTR+1
                     LDA #$3F
                     STA SELF_SOURCE_PTR+2   ; * = $3FFF

                     LDA #$00
                     STA SELF_DESTINATION_PTR+1
                     LDA #$44    
                     STA SELF_DESTINATION_PTR+2   ; = $4400

                     LDA $5F
                     BEQ @EXIT

                     LDA #$FF
                     STA SELF_SOURCE_PTR+1
                     LDA #$43
                     STA SELF_SOURCE_PTR+2  ;  = $43D8

                     LDA #$00
                     STA SELF_DESTINATION_PTR+1
                     LDA #$40
                     STA SELF_DESTINATION_PTR+2 ; = $4000
@EXIT:
                     RTS

;------------------------------------------------------------------
;30b5
; SELF_SOURCE_PTR = $4028/$4428, SELF_DESTINATION_PTR = $4400/$4000 
RESET_POINTERS2:

                     LDA SMOOTH_X
                     CMP #$04
                     BNE @EXIT

                     LDA SMOOTH_Y
                     CMP #$04
                     BNE @EXIT

                     LDA #$00
                     STA VAR_318F
                   
                     LDA #$FF
                     STA VAR_2FCC
                   
                     LDA #$28
                     STA SELF_SOURCE_PTR+1
                     LDA #$40
                     STA SELF_SOURCE_PTR+2
                   
                     LDA #$00
                     STA SELF_DESTINATION_PTR+1
                     LDA #$44
                     STA SELF_DESTINATION_PTR+2

                     LDA $5F
                     BEQ @EXIT
                     
                     LDA #$28
                     STA SELF_SOURCE_PTR+1
                     LDA #$44
                     STA SELF_SOURCE_PTR+2
                     
                     LDA #$00
                     STA SELF_DESTINATION_PTR+1
                     LDA #$40
                     STA SELF_DESTINATION_PTR+2
;30f7
@EXIT:               RTS

;------------------------------------------------------------
; if ( $4F == #04 and $50 == #04 )
; SELF_SOURCE_PTR = $3FD8, SELF_DESTINATION_PTR = $4000/$4400
; CALLED FROM 1e91 (WHEN SCROLL UP)
RESET_POINTERS3:
FUNC_30F8:
                     LDA SMOOTH_X
                     CMP #$04
                     BNE @EXIT
                 
                     LDA SMOOTH_Y
                     CMP #$04
                     BNE @EXIT

                     LDA #$00
                     STA VAR_318F

                     LDA #$01
                     STA VAR_2FCC

                     LDA #$D8
                     STA SELF_SOURCE_PTR+1
                     LDA #$3F
                     STA SELF_SOURCE_PTR+2

                     LDA #$00
                     STA SELF_DESTINATION_PTR+1
                     LDA #$44
                     STA SELF_DESTINATION_PTR+2

                     LDA $5F
                     BEQ @EXIT

                     LDA #$D8
                     STA SELF_SOURCE_PTR+1
                     LDA #$43
                     STA SELF_SOURCE_PTR+2

                     LDA #$00
                     STA SELF_DESTINATION_PTR+1
                     LDA #$40
                     STA SELF_DESTINATION_PTR+2
@EXIT:               RTS

INC_8B_DUMP_SCOREBOARD:
                     INC $8B
                     JSR DUMP_SCOREBOARD
DUMP_SCOREBOARD:                
FUNC_3140:
                     INC VAR_318F
                     LDA VAR_318F
                     CMP #$05
                     BCS EXIT_DUMP_SCOREBOARD

                     LDA SELF_SOURCE_PTR+1
                     CLC
                    
                     ADC #$C8
                     STA SELF_SOURCE_PTR+1
                     STA SELF_SOURCE2_PTR+1
                     LDA SELF_SOURCE_PTR+2
                     ADC #$00
                     STA SELF_SOURCE_PTR+2
                     STA SELF_SOURCE2_PTR+2
                     LDA SELF_DESTINATION_PTR+1
                     CLC
                     ADC #$C8
                     STA SELF_DESTINATION_PTR+1
                     STA SELF_DESTINATION2_PTR+1
                     LDA SELF_DESTINATION_PTR+2
                     ADC #$00
                     STA SELF_DESTINATION_PTR+2
                     STA SELF_DESTINATION2_PTR+2
                     LDX #$80
;317a
SELF_SOURCE_PTR:
                     LDA $3FFF,X
;317d
SELF_DESTINATION_PTR:
                     STA $4400,X
                     DEX
                     BPL SELF_SOURCE_PTR

                     JMP EXIT_DUMP_SCOREBOARD
                     LDX #$C7
;3185
SELF_SOURCE2_PTR:
                     LDA $471F,X
;3188
SELF_DESTINATION2_PTR:
                     STA $4320,X
                     DEX
                     BMI SELF_SOURCE2_PTR
EXIT_DUMP_SCOREBOARD:
                     RTS
VAR_318F:
.BYTE $00

;--------------------------------------------------------------------------------------------------
;
COLOUR_SCROLL_RIGHT:
FUNC_3190:
                     INC $8B
                  
                     LDA $5F    
                     EOR #$10
                     STA $5F  ; DO_FLIP  

                     JSR INCREMENT_HORIZONTAL
                     LDX #$00
@L1:                 LDA $D8C9,X
                     STA $D8C8,X
                     LDA $D8F1,X
                     STA $D8F0,X
                     LDA $D919,X
                     STA $D918,X
                     LDA $D941,X
                     STA $D940,X
                     LDA $D969,X
                     STA $D968,X
                     INX
                     CPX #$27
                     BNE @L1
                     LDX #$00
@L2:                 LDA $D991,X
                     STA $D990,X
                     LDA $D9B9,X
                     STA $D9B8,X
                     LDA $D9E1,X
                     STA $D9E0,X
                     LDA $DA09,X
                     STA $DA08,X
                     LDA $DA31,X
                     STA $DA30,X
                     INX
                     CPX #$27
                     BNE @L2
                     LDX #$00
@L3:                 LDA $DA59,X
                     STA $DA58,X
                     LDA $DA81,X
                     STA $DA80,X
                     LDA $DAA9,X
                     STA $DAA8,X
                     LDA $DAD1,X
                     STA $DAD0,X
                     LDA $DAF9,X
                     STA $DAF8,X
                     INX
                     CPX #$27
                     BNE @L3
                     LDX #$00
@L4:                 LDA $DB21,X
                     STA $DB20,X
                     LDA $DB49,X
                     STA $DB48,X
                     LDA $DB71,X
                     STA $DB70,X
                     LDA $DB99,X
                     STA $DB98,X
                     LDA $DBC1,X
                     STA $DBC0,X
                     INX
                     CPX #$27
                     BNE @L4
                     RTS

;--------------------------------------------------------------------------------------------------
;
;
READ_MAP_IN_RIGHT_BUFFER:
FUNC_3230:
                     JSR DECREMENT_HORIZONTAL
                     LDA $64
                     STA $4A
                     LDA $63
                     STA $49
                     LDA $49
                     CLC
                     ADC #$04
                     STA $49
                     LDA $4A
                     ADC #$01
                     STA $4A
                     LDA $49
                     CLC
                     ADC #$00
                     STA $49
                     STA $4B
                     LDA $4A
                     CLC
                     ADC #>MAP_BASE
                     STA $4A
                     STA $4C
                     LDA $56
                     STA $57
                     LDX #$00
@L1:                 LDY #$00
                     LDA ($49),Y
                     STY $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     STA $49
                     LDA $49
                     CLC

                     ADC #$00
                     STA $49
                     LDA $4A
                     ADC #$80 ; probably MAP_WIDTH
                     STA $4A
                     LDA $57
                     ASL A
                     ASL A
                     CLC
                     ADC $54
                     TAY
@L2:                 LDA ($49),Y
                     STA RIGHT_BUFFER,X; RIGHT BORDER BUFFER
                     INX
                     INY
                     INY
                     INY
                     INY
                     CPY #$10
                     BCC @L2
                     LDA #$00
                     STA $57
                     CPX #$15
                     BCS @NEED_NEW_BLOCK
                     LDA $4B
                     CLC
                     ADC #$01
                     STA $4B
                     STA $49
                     LDA $4C
                     ADC #$00
                     STA $4C
                     STA $4A
                     JMP @L1
@NEED_NEW_BLOCK:     JMP INCREMENT_HORIZONTAL


;--------------------------------------------------------------------------------------------------
; copy: $3844..$3858 to 40EF (size: #20)
; func: $32b6
; DUMP_RIGHT BORDER:
DUMP_RIGHT_BORDER:
FUNC_32B6:
                  LDA #$EF   ; reset color memory pointer (rolled) to $ d8ef
                  STA @SELF_COLOR_PTR+1
                  LDA #$D8
                  STA @SELF_COLOR_PTR+2; PTR_COLOR = $D8EF
                  LDA #$EF   ; reset map area pointer (rolled) to $ 40ef
                  STA @SELF_SCREEN_PTR+1
                  LDA #$40
                  STA @SELF_SCREEN_PTR+2
                  LDA $5F
                  BEQ @N1
                  ;LDA #$EF
                  ;STA @SELF_SCREEN_PTR+1
                  LDA #$44
                  STA @SELF_SCREEN_PTR+2
@N1:
                  LDX #$00
@L1:              LDA RIGHT_BUFFER,X
@SELF_SCREEN_PTR: STA $4000 
                  TAY
                  LDA CHARSET_COLORS,Y  ; take tile color from lookup table
@SELF_COLOR_PTR:  STA $D8C8
                  LDA @SELF_SCREEN_PTR+1
                  CLC
                  ADC #$28
                  STA @SELF_SCREEN_PTR+1
                  LDA @SELF_SCREEN_PTR+2
                  ADC #$00
                  STA @SELF_SCREEN_PTR+2
                  LDA @SELF_COLOR_PTR+1
                  CLC
                  ADC #$28
                  STA @SELF_COLOR_PTR+1
                  LDA @SELF_COLOR_PTR+2
                  ADC #$00
                  STA @SELF_COLOR_PTR+2
                  INX
                  CPX #$14
                  BNE @L1
                  RTS

COLOUR_SCROLL_LEFT:
FUNC_330F:
                     INC $8B

                     LDA $5F
                     EOR #$10
                     STA $5F  ; DO_FLIP

                     JSR DECREMENT_HORIZONTAL
                     LDX #$26
@L1:                 LDA $D8C8,X
                     STA $D8C9,X
                     LDA $D8F0,X
                     STA $D8F1,X
                     LDA $D918,X
                     STA $D919,X
                     LDA $D940,X
                     STA $D941,X
                     LDA $D968,X
                     STA $D969,X
                     DEX
                     BPL @L1
                     LDX #$26
@L2:                 LDA $D990,X
                     STA $D991,X
                     LDA $D9B8,X
                     STA $D9B9,X
                     LDA $D9E0,X
                     STA $D9E1,X
                     LDA $DA08,X
                     STA $DA09,X
                     LDA $DA30,X
                     STA $DA31,X
                     DEX
                     BPL @L2
                     LDX #$26
@L3:                 LDA $DA58,X
                     STA $DA59,X
                     LDA $DA80,X
                     STA $DA81,X
                     LDA $DAA8,X
                     STA $DAA9,X
                     LDA $DAD0,X
                     STA $DAD1,X
                     LDA $DAF8,X
                     STA $DAF9,X
                     DEX
                     BPL @L3
                     LDX #$26
@L4:                 LDA $DB20,X
                     STA $DB21,X
                     LDA $DB48,X
                     STA $DB49,X
                     LDA $DB70,X
                     STA $DB71,X
                     LDA $DB98,X
                     STA $DB99,X
                     LDA $DBC0,X
                     STA $DBC1,X
                     DEX
                     BPL @L4
                     RTS
                  

DUMP_MAP_LEFT_BORDER:
FUNC_33A7:
                     LDA $64
                     STA $4A
                     LDA $63
                     STA $49
                     LDA $49
                     CLC
                     ADC #$00
                     STA $49
                     STA $4B
                     LDA $4A
                     CLC
                     ADC #$90
                     STA $4A
                     STA $4C
                     LDA $56
                     STA $57
                     LDX #$00
@L1:                 LDY #$00
                     LDA ($49),Y
                     STY $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     STA $49
                     LDA $49
                     CLC
                     ADC #$00
                     STA $49
                     LDA $4A
                     ADC #$80
                     STA $4A
                     LDA $57
                     ASL A
                     ASL A
                     CLC
                     ADC $54
                     TAY
             @L2:    LDA ($49),Y           ;READ ONE BLOCK
                     STA LEFT_BUFFER,X    ;LEFT BUFFER
                     INX
                     INY
                     INY
                     INY
                     INY
                     CPY #$10
                     BCC @L2
                     LDA #$00
                     STA $57
                     CPX #$15
                     BCS @RESET_PTR
                     LDA $4B
                     CLC
                     ADC #$01
                     STA $4B
                     STA $49
                     LDA $4C
                     ADC #$00
                     STA $4C
                     STA $4A
                     JMP @L1
;341a
@RESET_PTR:          LDA #$C8
                     STA @SELF_COLOR_PTR+1
                     LDA #$D8
                     STA @SELF_COLOR_PTR+2  ; PTR = $D8C8

                     LDA #$C8
                     STA @SELF_SCREEN_PTR+1
                     LDA #$40
                     STA @SELF_SCREEN_PTR+2

                     LDA $5F
                     BEQ @N1
                     LDA #$C8
                     STA @SELF_SCREEN_PTR+1
                     LDA #$44
                     STA @SELF_SCREEN_PTR+2

@N1:
                     LDX #$00
@L3:                 LDA LEFT_BUFFER,X
@SELF_SCREEN_PTR:
                     STA $40C8
                     TAY
                     LDA CHARSET_COLORS,Y

@SELF_COLOR_PTR:
                     STA $D8C8

                     LDA @SELF_SCREEN_PTR+1
                     CLC
                     ADC #$28
                     STA @SELF_SCREEN_PTR+1
                     LDA @SELF_SCREEN_PTR+2
                     ADC #$00
                     STA @SELF_SCREEN_PTR+2
                     LDA @SELF_COLOR_PTR+1
                     CLC
                     ADC #$28
                     STA @SELF_COLOR_PTR+1
                     LDA @SELF_COLOR_PTR+2
                     ADC #$00
                     STA @SELF_COLOR_PTR+2
                     INX
                     CPX #$14
                     BNE @L3
                     RTS
                    



;--------------------------------------------------------------------------------------------------
; copy: LEFT_BUFFER to 40C8 (size: #20)
; DUMP_LEFT_BORDER:
DUMP_LEFT_BORDER:
FUNC_341A:
                  LDA #$C8
                  STA @SELF_COLOR_PTR+1
                  LDA #$D8
                  STA @SELF_COLOR_PTR+2

                  LDA #$C8
                  STA @SELF_SCREEN_PTR+1
                  LDA #$40
                  STA @SELF_SCREEN_PTR+2

                  LDA $5F     ; PREPARE CURRENT BUFFER
                  BEQ @N1
                  LDA #$C8
                  STA @SELF_SCREEN_PTR+1
                  LDA #$44
                  STA @SELF_SCREEN_PTR+2
@N1:
                  LDX #$00
@L1:              LDA LEFT_BUFFER,X
@SELF_SCREEN_PTR: STA $FFFF
                  TAY
                  LDA CHARSET_COLORS,Y ; take tile color from lookup table
@SELF_COLOR_PTR:  STA $FFFF
                  LDA @SELF_SCREEN_PTR+1
                  CLC
                  ADC #$28
                  STA @SELF_SCREEN_PTR+1
                  LDA @SELF_SCREEN_PTR+2
                  ADC #$00
                  STA @SELF_SCREEN_PTR+2
                  LDA @SELF_COLOR_PTR+1
                  CLC
                  ADC #$28
                  STA @SELF_COLOR_PTR+1
                  LDA @SELF_COLOR_PTR+2
                  ADC #$00
                  STA @SELF_COLOR_PTR+2
                  INX
                  CPX #$14
                  BNE @L1
                  RTS

;-----------------------------------------------------------------------------------------------
;
;
COLOUR_SCROLL_UP:
FUNC_3473:
                     INC $8B

                     LDA $5F
                     EOR #$10
                     STA $5F   ; DO_FLIP  

                     JSR DECREMENT_VERTICAL
                     LDX #$13
@L1:                 LDA $DA30,X
                     STA BOTTOM_COLOR_BUFFER,X
                     LDA $DA44,X
                     STA BOTTOM_COLOR_BUFFER+20,X
                     LDA $DA08,X
                     STA $DA30,X
                     LDA $DA1C,X
                     STA $DA44,X
                     LDA $D9E0,X
                     STA $DA08,X
                     LDA $D9F4,X
                     STA $DA1C,X
                     LDA $D9B8,X
                     STA $D9E0,X
                     LDA $D9CC,X
                     STA $D9F4,X
                     LDA $D990,X
                     STA $D9B8,X
                     LDA $D9A4,X
                     STA $D9CC,X
                     LDA $D968,X
                     STA $D990,X
                     LDA $D97C,X
                     STA $D9A4,X
                     LDA $D940,X
                     STA $D968,X
                     LDA $D954,X
                     STA $D97C,X
                     LDA $D918,X
                     STA $D940,X
                     LDA $D92C,X
                     STA $D954,X
                     LDA $D8F0,X
                     STA $D918,X
                     LDA $D904,X
                     STA $D92C,X
                     LDA $D8C8,X
                     STA $D8F0,X
                     LDA $D8DC,X
                     STA $D904,X
                     DEX
                     BPL @L1
                     LDX #$13
@L2:                 LDA $DB70,X
                     STA $DB98,X
                     LDA $DB84,X
                     STA $DBAC,X
                     LDA $DB48,X
                     STA $DB70,X
                     LDA $DB5C,X
                     STA $DB84,X
                     LDA $DB20,X
                     STA $DB48,X
                     LDA $DB34,X
                     STA $DB5C,X
                     LDA $DAF8,X
                     STA $DB20,X
                     LDA $DB0C,X
                     STA $DB34,X
                     LDA $DAD0,X
                     STA $DAF8,X
                     LDA $DAE4,X
                     STA $DB0C,X
                     LDA $DAA8,X
                     STA $DAD0,X
                     LDA $DABC,X
                     STA $DAE4,X
                     LDA $DA80,X
                     STA $DAA8,X
                     LDA $DA94,X
                     STA $DABC,X
                     LDA $DA58,X
                     STA $DA80,X
                     LDA $DA6C,X
                     STA $DA94,X
                     LDA BOTTOM_COLOR_BUFFER,X
                     STA $DA58,X
                     LDA BOTTOM_COLOR_BUFFER+20,X
                     STA $DA6C,X
                     DEX
                     BPL @L2
                     RTS

BOTTOM_COLOR_BUFFER:
_356d:
.BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.BYTE $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;-----------------------------------------------------------------------
;
;
READ_MAP_IN_UP_BUFFER:
FUNC_3595:
                     LDA $64
                     STA $4A
                     LDA $63
                     STA $49
                     LDA $49
                     CLC
                     ADC #$00
                     STA $49
                     STA $4B
                     LDA $4A
                     CLC
                     ADC #$90
                     STA $4A
                     STA $4C
                     LDA $54
                     STA $55
                     LDX #$00
@L1:                 LDY #$00
                     LDA ($49),Y ; READ BLOCK MAP
                     STY $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     STA $49
                     LDA $49
                     CLC
                     ADC #$00
                     STA $49
                     LDA $4A
                     ADC #$80
                     STA $4A
                     LDA $56
                     ASL A
                     ASL A
                     CLC
                     ADC $55
                     TAY
@L2:                 LDA ($49),Y ; DECODE BLOCK IN CHARS
                     STA UPPER_BUFFER,X
                     INX
                     INY
                     TYA
                     AND #$03
                     BNE @L2
                     LDA #$00
                     STA $55
                     CPX #$28
                     BCS @EXIT
                     LDA $4B
                     CLC
                     ADC #MAP_HEIGHT
                     STA $4B
                     STA $49
                     LDA $4C
                     ADC #$00
                     STA $4C
                     STA $4A
                     JMP @L1
@EXIT:               RTS

;-----------------------------------------------------------------------
DUMP_UPPER_BORDER:
FUNC_3607:
                     LDA #$40
                     STA @SELF_SCREEN_PTR+2

                     LDA $5F ; which buffer?
                     BEQ @N1

                     LDA #$44
                     STA @SELF_SCREEN_PTR+2
@N1:
                     LDX #$27
@L1:                 LDA UPPER_BUFFER,X
@SELF_SCREEN_PTR:
                     STA $40C8,X
                     TAY
                     LDA CHARSET_COLORS,Y
                     STA $D8C8,X
                     DEX
                     BPL @L1
                     RTS

;-----------------------------------------------------------------------
;
;
COLOUR_SCROLL_DOWN:
FUNC_3628:
                     INC $8B

                     LDA $5F
                     EOR #$10
                     STA $5F  ; SWOP BUFFER

                     JSR INCREMENT_VERTICAL

                     LDX #$13
@L1:                 LDA $D8F0,x
                     STA $D8C8,x
                     LDA $D904,x
                     STA $D8DC,x
                     LDA $D918,x
                     STA $D8F0,x
                     LDA $D92C,x
                     STA $D904,x
                     LDA $D940,x
                     STA $D918,x
                     LDA $D954,x
                     STA $D92C,x
                     LDA $D968,x
                     STA $D940,x
                     LDA $D97C,x
                     STA $D954,x
                     LDA $D990,x
                     STA $D968,x
                     LDA $D9A4,x
                     STA $D97C,x
                     LDA $D9B8,x
                     STA $D990,x
                     LDA $D9CC,x
                     STA $D9A4,x
                     LDA $D9E0,x
                     STA $D9B8,x
                     LDA $D9F4,x
                     STA $D9CC,x
                     LDA $DA08,x
                     STA $D9E0,x
                     LDA $DA1C,x
                     STA $D9F4,x
                     LDA $DA30,x
                     STA $DA08,x
                     LDA $DA44,x
                     STA $DA1C,x
                     LDA $DA58,x
                     STA $DA30,x
                     LDA $DA6C,x
                     STA $DA44,x
                     DEX
                     BPL @L1
                     LDX #$13
 @L2:                LDA $DA80,X
                     STA $DA58,x
                     LDA $DA94,x
                     STA $DA6C,x
                     LDA $DAA8,x
                     STA $DA80,x
                     LDA $DABC,x
                     STA $DA94,x
                     LDA $DAD0,x
                     STA $DAA8,x
                     LDA $DAE4,x
                     STA $DABC,x
                     LDA $DAF8,x
                     STA $DAD0,x
                     LDA $DB0C,x
                     STA $DAE4,x
                     LDA $DB20,x
                     STA $DAF8,x
                     LDA $DB34,x
                     STA $DB0C,x
                     LDA $DB48,x
                     STA $DB20,x
                     LDA $DB5C,x
                     STA $DB34,x
                     LDA $DB70,x
                     STA $DB48,x
                     LDA $DB84,x
                     STA $DB5C,x
                     LDA $DB98,x
                     STA $DB70,x
                     LDA $DBAC,x
                     STA $DB84,x
                     LDA $DBC0,x
                     STA $DB98,x
                     LDA $DBD4,x
                     STA $DBAC,x
                     DEX
                     BPL @L2
@L3:                 DEY
                     DEY
                     DEX
                     BPL @L3
                     RTS

;-----------------------------------------------------------------------
;
;
READ_MAP_IN_BOTTOM_BUFFER:
FUNC_3727:
                     JSR DECREMENT_VERTICAL
                     JSR DECREMENT_VERTICAL
                     LDA $64
                     STA $4A
                     LDA $63
                     STA $49
                     STA $4B
                     LDA $49 ;copy $63 -> $49
                     CLC
                     ADC #$05
                     STA $49
                     LDA $4A
                     ADC #$00
                     STA $4A
                     LDA $49
                     CLC
                     ADC #$00
                     STA $49
                     STA $4B
                     LDA $4A
                     CLC
                     ADC #$90 ; #<MAP
                     STA $4A
                     STA $4C
                     LDA $54
                     STA $55
                     LDX #$00
@L1:                 LDY #$00
                     LDA ($49),Y ; READ MAP
                     STY $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     ASL A
                     ROL $4A
                     STA $49
                     LDA $49
                     CLC
                     ADC #$00
                     STA $49
                     LDA $4A
                     ADC #$80  ; #<BLOCK_BYTES
                     STA $4A
                     LDA $56
                     ASL A
                     ASL A
                     CLC
                     ADC $55
                     TAY
@L2:                 LDA ($49),Y
                     STA BOTTOM_BUFFER,X ;BOTTOM BUFFER
                     INX
                     INY
                     TYA
                     AND #$03
                     BNE @L2
                     LDA #$00
                     STA $55
                     CPX #$28
                     BCS @EXIT
                     LDA $4B
                     CLC
                     ADC #MAP_HEIGHT
                     STA $4B
                     STA $49
                     LDA $4C
                     ADC #$00
                     STA $4C
                     STA $4A
                     JMP @L1
@EXIT:
                     JSR INCREMENT_VERTICAL
                     JMP INCREMENT_VERTICAL ; AND EXIT

;-----------------------------------------------------------------------
;
;
; copy: $38A0..$38C7 to 4300/4700 (size: #40)
DUMP_BOTTOM_BORDER:
FUNC_37B3:
                     LDA #$43
                     STA @SELF_BOTTOM_BUFFER_PTR+2
                     LDA $5F
                     BEQ @N1
                     LDA #$47
                     STA @SELF_BOTTOM_BUFFER_PTR+2

@N1:                 LDX #$27
@L1:                 LDA $38A0,X
@SELF_BOTTOM_BUFFER_PTR:
                     STA $4398,X
                     TAY
                     LDA CHARSET_COLORS,Y ; tile color from lookup
                     STA $DB98,X
                     DEX
                     BPL @L1
                     RTS


INCREMENT_HORIZONTAL:
FUNC_37D4:
                     LDA $54
                     CLC
                     ADC #$01
                     AND #$03
                     STA $54
                     BNE @EXIT
                     LDA $63
                     CLC
                     ADC #MAP_HEIGHT ; MAP_HEIGHT
                     STA $63
                     LDA $64
                     ADC #$00
                     STA $64
                     INC WORLD_X
@EXIT:
                     RTS

DECREMENT_HORIZONTAL:
FUNC_37EF:                  
                     LDA $54
                     SEC
                     SBC #$01
                     AND #$03
                     STA $54
                     CMP #$03
                     BNE @EXIT
                     LDA $63
                     SEC
                     SBC #MAP_HEIGHT
                     STA $63
                     LDA $64
                     SBC #$00
                     STA $64
                     DEC WORLD_X
@EXIT:
                     RTS


INCREMENT_VERTICAL:
FUNC_380C:                LDA $56
                          CLC
                          ADC #$01
                          AND #$03
                          STA $56
                          BNE @EXIT
                          LDA $63
                          CLC
                          ADC #$01
                          STA $63
                          LDA $64
                          ADC #$00
                          STA $64
                          INC WORLD_Y
@EXIT:                    RTS

DECREMENT_VERTICAL:
FUNC_3827:                LDA $56
                          SEC
                          SBC #$01
                          AND #$03
                          STA $56
                          CMP #$03
                          BNE @EXIT
                          LDA $63
                          SEC
                          SBC #$01
                          STA $63
                          LDA $64
                          SBC #$00
                          STA $64
                          DEC WORLD_Y
 @EXIT:                   RTS

;.org $3844
RIGHT_BUFFER:
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00


;.org $385E
LEFT_BUFFER:
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00

;.org $3878
UPPER_BUFFER:
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;38A0  buffer
;.org $38A0
BOTTOM_BUFFER:
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
            .BYTE $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 

SCROLL_DOWN_COLOR_RAM:
      LDX #$26
@L1:  LDA $D8C8,x
      STA $D8C9,x
      LDA $D8F0,x
      STA $D8F1,x
      LDA $D918,x
      STA $D919,x
      LDA $D940,x
      STA $D941,x
      LDA $D968,x
      STA $D969,x
      DEX
      BPL @L1
      LDX #$26
@L2:  LDA $D990,x
      STA $D991,x
      LDA $D9B8,x
      STA $D9B9,x
      LDA $D9E0,x
      STA $D9E1,x
      LDA $DA08,x
      STA $DA09,x
      LDA $DA30,x
      STA $DA31,x
      DEX
      BPL @L2
      LDX #$26
@L3:  LDA $DA58,x
      STA $DA59,x
      LDA $DA80,x
      STA $DA81,x
      LDA $DAA8,x
      STA $DAA9,x
      LDA $DAD0,x
      STA $DAD1,x
      LDA $DAF8,x
      STA $DAF9,x
      DEX
      BPL @L3
      LDX #$26
@L4:  LDA $DB20,x
      STA $DB21,x
      LDA $DB48,x
      STA $DB49,x
      LDA $DB70,x
      STA $DB71,x
      LDA $DB98,x
      STA $DB99,x
      LDA $DBC0,x
      STA $DBC1,x
      DEX
      BPL @L4
      RTS

SCROLL_UP_COLOR_RAM:
      LDX #$00
@L1:
      LDA $D8C9,x ; 5 ROWS
      STA $D8C8,x
      LDA $D8F1,x
      STA $D8F0,x
      LDA $D919,x
      STA $D918,x
      LDA $D941,x
      STA $D940,x
      LDA $D969,x
      STA $D968,x
      INX
      CPX #$27
      BNE @L1
      LDX #$00
@L2:
      LDA $D991,x ; 10 ROWS
      STA $D990,x
      LDA $D9B9,x
      STA $D9B8,x
      LDA $D9E1,x
      STA $D9E0,x
      LDA $DA09,x
      STA $DA08,x
      LDA $DA31,x
      STA $DA30,x
      INX
      CPX #$27
      BNE @L2
      LDX #$00
@L3:
      LDA $DA59,x  ; 15 ROWS
      STA $DA58,x
      LDA $DA81,x
      STA $DA80,x
      LDA $DAA9,x
      STA $DAA8,x
      LDA $DAD1,x
      STA $DAD0,x
      LDA $DAF9,x
      STA $DAF8,x
      INX
      CPX #$27
      BNE @L3
      LDX #$00
@L4:
      LDA $DB21,x
      STA $DB20,x
      LDA $DB49,x
      STA $DB48,x
      LDA $DB71,x
      STA $DB70,x
      LDA $DB99,x
      STA $DB98,x
      LDA $DBC1,x
      STA $DBC0,x
      INX
      CPX #$27
      BNE @L4
      RTS


SET_COLORS:
               LDA #0  ;BLACK
               STA $D020

               LDA #0  ;
               STA $D021
             
               LDA #6 ;BLUE
               STA $D022
                
               LDA #14 ;LBLUE
               STA $D023

               LDA #3  ;CYAN
               STA $D024
               RTS

;.org $2FCB
VAR_2FCB:
.BYTE $00

VAR_2FCC:
.BYTE $00

VAR_2FCD:
.BYTE $00