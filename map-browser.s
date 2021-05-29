 

TRUE           = 1                    ;conditional control codes
FALSE          = 0
YES            = TRUE
NO             = FALSE

AT             = $80
DW             = $81
FIN            = 0

SCREEN_BASE    = $4000
MAP_BASE       = $9000

SHOW_RASTER    = YES                   ;should rasters be displayed

BLACK          = 0                    ;c64 colour codes
WHITE          = 1
RED            = 2
CYAN           = 3
PURPLE         = 4
GREEN          = 5
BLUE           = 6
YELLOW         = 7
ORANGE         = 8
BROWN          = 9
PINK           = 10
DGREY          = 11
MGREY          = 12
LGREEN         = 13
LBLUE          = 14
LGREY          = 15

VIEWPORT_WIDTH  = 10 ; WIDTH EXPRESED IN BLOCKS
VIEWPORT_HEIGHT = 5 ; HEIGHT EXPRESED IN BLOCKS
JOYSTICK_DELAY  = 2

 MAP_BORDER_TOP  = $10
 MAP_BORDER_LEFT = $12
 MAP_BORDER_RIGHT = $6A
 MAP_BORDER_BOTTOM = MAP_BORDER_TOP + MAP_HEIGHT - VIEWPORT_HEIGHT

.segment "ZEROPAGE"

VSTART:
IA: .BYTE $00
IX: .BYTE $00
IY: .BYTE $00
DELAYFLAG:   .BYTE $00; Flag to sync MAIN_LOOP to raster
JOYTEMP:     .BYTE $00
HPOS:        .BYTE $00
VPOS:        .BYTE $00
NMIA:        .BYTE $00
COLOURFLAG:  .BYTE $00
SCRBASE:     .BYTE $00
MAP_OFFSET:  .WORD $00
MAP_POS_X:   .BYTE $00
MAP_POS_Y:   .BYTE $00


BLOCK_X_COUNTER: .BYTE $00
BLOCK_Y_COUNTER: .BYTE $00

VIEWPORT_Y_COORD: .WORD $0000

TEMP:         .BYTE 0
FROM:         .WORD 0
TO:           .WORD 0
TO2:          .WORD 0

 
; VARIABLES
OLD_JOY:     .BYTE $00
FIRE_STATE:  .BYTE $00
CURSOR_COORD_X: .BYTE $00
CURSOR_COORD_Y: .BYTE $00
PRESS_COUNTER:  .BYTE $00
SELECTED_CHARSET: .BYTE $00

;.org $65
WORLD_X = $65 ; .BYTE $00
WORLD_Y = $66 ; : .BYTE $00

; exported by the linker
 
.segment "LOADADDR"
;.export __LOADADDR__ = *

.segment "MAIN"

GAME_START:   
               SEI                      ; Stop interrupts

               LDX #$FF
               TXS                      ; Reset the stack

               LDA #$35                 ; Roms out
               STA 1

               LDA #$1B                 ; Screen on
               STA $D011

               JSR SETBANK              ; Set into Display Bank #1 ($4000)
               JSR SETRAST              ; Initialise raster interrupts
               JSR SETNMI               ; Initialise Non maskable interrupts

WARMSTART:   
               JSR CLS
               JSR CLRVARS
               JSR DISPLAY_BOARD
               JSR DELAY
               JSR DELAY
               JSR DELAY
               JSR DELAY

               ;LDX #<BOARD
               ;LDY #>BOARD
               ;JSR SPRINT

               ;JSR INIT_MAP
               ;61 00 13 24  4f 00 13 12  8f 03 33 12  a1 06 51 18
               LDA #$00
               STA $56
               STA $57

               LDA #$9C
               STA $58

               LDA #$00
               STA $59
; 2d 00 11 24
               LDA #$2D
               STA $63
               LDA #$00
               STA $64
               LDA #$11
               STA WORLD_X
               LDA #$24
               STA WORLD_Y
               JSR DO_MAP_ALL_SCREEN 
               
               LDA #0
               STA $D010 ; MSB 0

               LDX CURSOR_COORD_X
               LDY CURSOR_COORD_Y
               JSR SET_BLOCK_SELECTOR

               JSR UPDATE_BOARD


               LDA #$03
               STA $BD23

               JSR INIT_SCROLL_VARIABLES
               JSR INIT_SPRITES
                
MAIN_LOOP:
@MAIN_LOOP:
               
               JSR DELAY
               JSR JOY_STICK            ;process player movement & animation
               JSR KEYBOARD
               JMP @MAIN_LOOP

KEYBOARD:

               LDA #20
               JSR KEYSCAN
               BCC @EXIT
               
               LDA SELECTED_CHARSET
               CMP #$00
               BNE @NE 
               INC SELECTED_CHARSET
               RTS
        @NE:
               LDA #$00
               STA SELECTED_CHARSET
               
@EXIT:         RTS
               
JOY_STICK:
               JSR FX19
@READ_JOY:     LDA $DC00          
               EOR #$1F
               AND #$1F
               STA FIRE_STATE

               CMP OLD_JOY
               BEQ @NO_MOVE
               STA OLD_JOY

               ;INC PRESS_COUNTER
               ;LDA PRESS_COUNTER
               ;CLC
               ;CMP #JOYSTICK_DELAY
               ;BCC @EXIT
               ;LDA OLD_JOY

               AND #1
               BEQ @NO_UP
              
               JSR PLAYER_UP
@NO_UP:        LDA OLD_JOY
               AND #2
               BEQ @NO_DOWN
               JSR PLAYER_DOWN

@NO_DOWN:      LDA OLD_JOY
               AND #4
               BEQ @NO_LEFT

               JSR PLAYER_LEFT
@NO_LEFT:      LDA OLD_JOY
               AND #8
               BEQ @NO_RIGHT
               JSR PLAYER_RIGHT

@NO_RIGHT:     RTS

@NO_MOVE:
              ; LDX #<GO_NOTHING_TEXT
              ; LDY #>GO_NOTHING_TEXT
              ; JSR SPRINT
               LDA #$00
               STA OLD_JOY
               STA PRESS_COUNTER
               LDA FIRE_STATE
               BNE @EXIT 
               ;LDX #<GO_FIRE_TEXT
               ;LDY #>GO_FIRE_TEXT
               ;JSR SPRINT

@EXIT:         RTS

PLAYER_UP:
 
               STA OLD_JOY

               LDA CURSOR_COORD_Y
               CMP #$00
               BEQ @MOVE_MAP_UP

               DEC CURSOR_COORD_Y

               LDX CURSOR_COORD_X
               LDY CURSOR_COORD_Y
               JSR SET_BLOCK_SELECTOR
               JSR UPDATE_BOARD
               RTS

    @MOVE_MAP_UP:
               JSR MOVE_UP_MAP_PTR
               JSR UPDATE_BOARD
               JSR DO_MAP_ALL_SCREEN
   @NO_MOVE:   RTS

PLAYER_DOWN:
               STA OLD_JOY
               LDA CURSOR_COORD_Y

               CMP #$04
               BEQ @MOVE_MAPDOWN

               INC CURSOR_COORD_Y  
               
               LDX CURSOR_COORD_X
               LDY CURSOR_COORD_Y
               JSR SET_BLOCK_SELECTOR
               JSR UPDATE_BOARD
               RTS
    @MOVE_MAPDOWN:
               JSR MOVE_DOWN_MAP_PTR
               JSR UPDATE_BOARD
               JSR DO_MAP_ALL_SCREEN
               RTS
PLAYER_LEFT:
               STA OLD_JOY
               LDA CURSOR_COORD_X
               CMP #0
               BEQ @MOVE_LEFT

               DEC CURSOR_COORD_X
               JMP @EXIT
    @MOVE_LEFT:  
              JSR MOVE_LEFT_MAP_PTR
              JSR DO_MAP_ALL_SCREEN         
    @EXIT:  
              LDX CURSOR_COORD_X
              LDY CURSOR_COORD_Y
              JSR SET_BLOCK_SELECTOR
              JSR UPDATE_BOARD
              RTS
PLAYER_RIGHT:
               ;JSR DO_MAP_SCROLLING
               STA OLD_JOY
               LDA CURSOR_COORD_X
               CMP #9
               BEQ @MOVE_RIGHT 
               INC CURSOR_COORD_X

               LDX CURSOR_COORD_X
               LDY CURSOR_COORD_Y
               JSR SET_BLOCK_SELECTOR
               JSR UPDATE_BOARD
               RTS   
       @MOVE_RIGHT:
               JSR MOVE_RIGHT_MAP_PTR
               LDX CURSOR_COORD_X
               LDY CURSOR_COORD_Y
               JSR SET_BLOCK_SELECTOR               
               JSR DO_MAP_ALL_SCREEN
               JSR UPDATE_BOARD
               RTS

UPDATE_BOARD:
              CLC
              LDA WORLD_X
              ADC CURSOR_COORD_X
              LDX #0
              LDY #0
              JSR HEX
              
              CLC
              LDA WORLD_Y
              ADC CURSOR_COORD_Y
              LDX #3
              LDY #0
              JSR HEX
              
              ;LDA CURSOR_COORD_X
              ;LDX #16
              ;LDY #0
              ;JSR HEX

              ;LDA CURSOR_COORD_Y
              ;LDX #19
              ;LDY #0
              ;JSR HEX


              JSR GET_CURRENT_BLOCK
              LDX #6
              LDY #1
              JSR HEX
              RTS
;
; SET A WITH THE CURRENT BLOCK
;
GET_CURRENT_BLOCK:
              LDA $63
              STA $58
              LDA $64
              STA $59
              LDA #$00
              LDX CURSOR_COORD_X
              CLC
              LDA @MULT,X
              ADC $58
              ADC CURSOR_COORD_Y
              STA @SELF_SOURCE_MAP_PTR+1
              LDA #>MAP_BASE
              ADC $59
              STA @SELF_SOURCE_MAP_PTR+2
@SELF_SOURCE_MAP_PTR:
              LDA $ffff
              RTS
@MULT:
.BYTE MAP_HEIGHT*0, MAP_HEIGHT*1, MAP_HEIGHT*2, MAP_HEIGHT*3, MAP_HEIGHT*4
.BYTE MAP_HEIGHT*5, MAP_HEIGHT*6, MAP_HEIGHT*7, MAP_HEIGHT*8, MAP_HEIGHT*9


;.segment "STDFRAMEWORK"
;.org $0A00 
DRAW_BOARD:
DISPLAY_BOARD:
              LDX #$C7
              
       @L:    LDA BOARD,x
              CLC
              CMP #$20
              BEQ @N


              CMP #$C0
              BCC @N
              SBC #$C0

     @N:      STA $4000,x
              LDA #YELLOW
              STA $D800,x
              DEX
              CPX #$FF
            ;  BMI @L
              BNE @L

              LDA #GREEN
              STA $D818
              STA $D840

              LDX #$0F
      @L2:    STA $D868,X
              DEX
              CPX #$FF
              BNE @L2 
              RTS



INIT_SPRITES:
              LDA #$00
              STA $D010
              STA $D017
              STA $D01D

              LDA #$40
              STA $43F8
              STA $47F8

              LDA #$41
              STA $43F9
              STA $47F9

              LDA #$42
              STA $43FA
              STA $47FA

              LDA #$43
              STA $43FB
              STA $47FB

              LDA #$18
              STA $D000
              LDA #$5A
              STA $D001

              LDA #$18
              STA $D002
              LDA #$65
              STA $D003

              LDA #$21
              STA $D004
              LDA #$65
              STA $D005

              LDA #$21
              STA $D006
              LDA #$5A
              STA $D007
         
              LDA #%00001111
              STA $D015
              RTS

;PARAMETERS X,Y
SET_BLOCK_SELECTOR:
              LDA BLOCK_X_LSPRITES_LOOKUP,X
              STA $D000 ; #0  x0
              STA $D002 ; #1  x1

              LDA BLOCK_X1_LSPRITES_LOOKUP,X
              STA $D004 ; #3  x2
              STA $D006 ; #4  x3

              LDA MSB_X_LOOKUP,X
              STA $D010
            
              LDA BLOCK_Y_LSPRITES_LOOKUP,Y 
              STA $D001  ; y0
              STA $D007  ; y3

              ADC #$0b
              STA $D003 ;   y1
              STA $D005 ;   y2
              RTS
MSB_X_LOOKUP:
.BYTE  $00, $00, $00, $00, $00, $00, $00, %00001100, %00001111, %00001111
BLOCK_X_LSPRITES_LOOKUP:
.BYTE  $18, $38, $58, $78, $98, $b8, $d8, $f8, $18, $38
BLOCK_X1_LSPRITES_LOOKUP:
.BYTE  $20, $40, $60, $80, $a0, $c0, $e0, $00, $20, $40

BLOCK_Y_LSPRITES_LOOKUP:
.BYTE  $5a, $7a, $9a, $ba, $da, $fa, $ff, $ff

BLINK_SPRITES:
              DEC @BLINK_DELAY
              BNE @EXIT

              LDA #$8
              STA @BLINK_DELAY

              LDA #%00001111
              STA $D015

              LDX @COLOR_PTR
              LDA @BLINK_COLOR_TABLE,X

              STA $D027
              STA $D028
              STA $D029
              STA $D02A

              DEC @COLOR_PTR
              BNE @EXIT

              LDA #$07
              STA @COLOR_PTR


@EXIT:        RTS
@BLINK_DELAY:
    .BYTE $08

@COLOR_PTR:
    .BYTE $07

@BLINK_COLOR_TABLE:
.BYTE $01,$03,$0f,$0c,$0b,$0c,$06,$01

;
;
;
;
MOVE_DOWN_MAP_PTR:
              LDA WORLD_Y
              CMP #MAP_BORDER_BOTTOM
              BCS @EXIT

              LDA $63
              CLC
              ADC #$01
              STA $63
              LDA $64
              ADC #$00 
              STA $64
              INC WORLD_Y
@EXIT:        RTS

MOVE_UP_MAP_PTR:
              CLC
              LDA WORLD_Y
              CMP #MAP_BORDER_TOP
              BCC @EXIT

              LDA $63
              SEC
              SBC #$01
              STA $63

              LDA $64
              SBC #$00
              STA $64
              DEC WORLD_Y
@EXIT:        RTS

MOVE_RIGHT_MAP_PTR:
              LDA WORLD_X
              CMP #MAP_BORDER_RIGHT
              BCS @EXIT

              CLC
              LDA $63
              ADC #MAP_HEIGHT
              STA $63

              LDA $64
              ADC #$00
              STA $64
              INC WORLD_X
  @EXIT:      RTS

MOVE_LEFT_MAP_PTR:
              LDA WORLD_X
              CMP #MAP_BORDER_LEFT
              BCC @EXIT

              LDA $63
              SEC
              SBC #MAP_HEIGHT
              STA $63
              LDA $64
              SBC #$00
              STA $64
              DEC WORLD_X
   @EXIT:     RTS


;
; SETBANK - Initialises video base address
;

SETBANK:       LDA #%11000010          ; Bank #1 ($4000)
               STA $DD00



               LDA #%00000010          ; Charset @ $4800
               STA $D018               ; Screen base @ $4000
               RTS

;
; SETRAST - Initialise raster interrupts
;

SETRAST:       SEI
               LDA #<R0
               STA $FFFE
               LDA #>R0
               STA $FFFF

               LDA #$7F
               AND $D011
               STA $D011
               STA $DC0D
               STA $DD0D
               LDA $DC0D
               LDA $DD0D

               LDX #1         ; Acknowledge any interrupts
               STX $D019
               STX $D01A

               LDA #$30
               STA $D012

               CLI
               RTS


R0:            STA IA
               STX IX
               STY IY
               CLD
               DEC $D019

               LDA #<$3800               ; Set NMI to count to middle of screen
               STA $DD04
               LDA #>$3800
               STA $DD05
               LDA #%10011001
               STA $DD0E

               INC LASTCOUNT

               LDA #BLACK
               STA $D020 
            
               LDA #BLACK
               STA $D021

               LDA #%00011011 
               STA $D011      

               LDA #%00011000
               STA $D016       ;  40 col, multicolor ON

               LDA #%00001110  ;TEXT_CHARSET Charset @ $7800, Screen @ $4000
               STA $D018 

               JSR BLINK_SPRITES

               LDA $D012
               CMP #$5A
               BCC *-3

               LDA #%00011000
               STA $D016       ;  40 col, multicolor ON
               LDA #%00001100  ;TEXT_CHARSET Charset @ $, Screen @ $4000
               STA $D018 

               LDA SELECTED_CHARSET
               BNE @N

               LDA #%00000010  ;BLOCK_CHARS Charset @ $4800, Screen @ $4000
               STA $D018 
                   
        @N:    LDA #BLACK
               STA $D021
             
               LDA #BLUE
               STA $D022
                
               LDA #LBLUE
               STA $D023

               LDA #CYAN
               STA $D024  

               LDA #RED
               STA $D020 
   
               LDA $D011
               AND #%01111111
               STA $D011

               LDA #$30 ;f0                 ; Next raster position
               STA $D012
               LDA #<R0
               STA $FFFE
               LDA #>R0
               STA $FFFF

;               LDA #$FF
;               CMP $D012
;               BNE *-3
 
               INC DELAYFLAG
@NOSYNC:   ;    LDA #$20
           ;    STA $D012

               LDA IA
               LDX IX
               LDY IY

               RTI


;
; SETNMI - Initialise game Non maskable interrupts
;

SETNMI:        LDA #<NMI1
               STA $FFFA
               LDA #>NMI1
               STA $FFFB

               LDA #$81
               STA $DD0D
               RTS


;
; NMI1 - First NMI, triggers the colour scroll & resyncs the MAIN_LOOP
;

NMI1:          STA NMIA
               LDA $DD0D

.if  SHOW_RASTER = TRUE
               LDA $D020
               PHA
               LDA #2
               STA $D020
.endif

               LDA HPOS                  ; Check for last scroll update
               CMP #7
               BNE @NOCOLSCR
 

               INC DELAYFLAG            ; Resync the main loop to the middle

@NOCOLSCR:

.if SHOW_RASTER = TRUE
               PLA
               STA $D020
.endif

               LDA NMIA
               RTI


;
; DELAY - Used to sync the MAIN_LOOP to the raster
;

DELAY:         LDA DELAYFLAG            ; Wait for a change in DELAYFLAG
               BEQ DELAY
               DEC DELAYFLAG
               RTS

;
; FX19 - Wait for frame flyback
;

FX19:          LDA LASTCOUNT
               CMP LASTVAL
               BEQ FX19
               STA LASTVAL
               RTS

LASTCOUNT:   .BYTE 0
LASTVAL:     .BYTE 0

 

CLS:      LDX #$00
@L1:      LDA #$20                 ; Clear the screen
          STA $4000,x
          STA $4100,x
          STA $4200,x
          STA $4300,x
          LDA #WHITE               ; White colour RAM
          STA $D800,x
          STA $D900,x
          STA $DA00,x
          STA $DB00,x
          INX
          BNE @L1
          RTS

CLRVARS:
         LDA #0
         STA DELAYFLAG
         RTS

;-----------------------------------------------------------------------------
;
; KEYSCAN - Key entered in A, carry SET if key is pressed
;

KEYSCAN:       STY @GOT_KEY+1            ;preserve Y
               PHA
               LSR 
               LSR 
               LSR 
               TAY
               LDA @COLUMN,Y
               STA $DC00
               PLA
               AND #7
               TAY
               LDA $DC01
               AND @ROW,Y
               BNE @NOT_PRESSED
               LDA #$FF
               STA $DC00
               LDA $DC01
               AND @ROW,Y
               BEQ @NOT_PRESSED
               SEC
               BCS @GOT_KEY              ;always
@NOT_PRESSED:  CLC
@GOT_KEY:      LDY #0                   ;modified
               LDA #$FF
               STA $DC00
               LDA #$7F
               STA $DC01
               RTS
@COLUMN:      .BYTE $FE,$FD,$FB,$F7,$EF,$DF,$BF,$7F
@ROW:         .BYTE $01,$02,$04,$08,$10,$20,$40,$80          
 
BRICK_TOP:    .byte "IBCDDEFGH"
BRICK_BOTTOM: .byte "JJJJKLMNJ"

;
; SPRINT - Print text pointed to by X & Y in single or double height
;

SPRINT:        STX FROM
               STY FROM+1

               LDY #0
@GET:          LDA (FROM),Y
               BMI @GETCOORD
               BNE @TEXT
               JMP @DONE

@TEXT:         AND #$3F
               STA (TO),Y
               LDA CULA
               STA (TO2),Y

               INC TO
               BNE @NOC2
               INC TO+1
@NOC2:         INC TO2
               BNE @NOC3
               INC TO2+1
@NOC3:         INC FROM
               BNE @GET
               INC FROM+1
               JMP @GET

@GETCOORD:
               INY                      ; Get data; X coord, Y coord, colour
               LDA (FROM),Y
               STA TEMP
               INY
               LDA (FROM),Y
               ASL
               TAX
               LDA TEMP
	           CLC
               ADC YTABLE,X
               STA TO
               STA TO2
               LDA YTABLE+1,X
               ADC #0
               STA TO+1
               ADC #$D4
               STA TO2+1
               INY
               LDA (FROM),Y
               STA CULA

               LDA FROM
	           CLC
               ADC #4
               STA FROM
               BCC @NOC
               INC FROM+1

@NOC:          LDY #0
               JMP @GET

@DONE:         RTS

CULA:          .BYTE 0
MODE_BYTE:     .BYTE 0

YTABLE:        .WORD $4000+00*40
               .WORD $4000+01*40
               .WORD $4000+02*40
               .WORD $4000+03*40
               .WORD $4000+04*40
               .WORD $4000+05*40
               .WORD $4000+06*40
               .WORD $4000+07*40
               .WORD $4000+08*40
               .WORD $4000+09*40
               .WORD $4000+10*40
               .WORD $4000+11*40
               .WORD $4000+12*40
               .WORD $4000+13*40
               .WORD $4000+14*40
               .WORD $4000+15*40
               .WORD $4000+16*40
               .WORD $4000+17*40
               .WORD $4000+18*40
               .WORD $4000+19*40
               .WORD $4000+20*40
               .WORD $4000+21*40
               .WORD $4000+22*40
               .WORD $4000+23*40
               .WORD $4000+24*40

;
; HEX - Print a hex number in A at X,Y
;

HEX:           STX IX
               STY IY
               STA IA
               TYA
               ASL
               TAY
               LDA YTABLE,Y
               STA TO
               LDA YTABLE+1,Y
               STA TO+1
               TXA
               TAY
               LDA IA
               LSR
               LSR
               LSR
               LSR
               TAX
               LDA DIGITS,X
               AND #$3F
               STA (TO),Y
               LDA IA
               AND #$0F
               TAX
               LDA DIGITS,X
               AND #$3F
               INY
               STA (TO),Y
               LDA IA
               LDX IX
               LDY IY
               RTS

DIGITS:        .BYTE "0123456789ABCDEF"
 
BOARD:
   .byte "00,00                   ", $3c, "  BATMAN   ", $46, $47, $48, $49
 
   .byte "BLOCK 23                ", $3c, "MAP UTILITY", $4a, $4b, $4c, $4d
   .byte "                        ", $4f, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41
   .byte "                                        "
   .byte "PRESS C TO SWAP CHARSET                 "


GO_UP_TEXT:
               .byte AT,35,00,07
               .byte "up   "
               .byte FIN
GO_DOWN_TEXT:
               .byte AT,35,00,07
               .byte "down "
               .byte FIN 
GO_LEFT_TEXT:
               .byte AT,35,00,07
               .byte "left "
               .byte FIN 
GO_RIGHT_TEXT:
               .byte AT,35,00,07
               .byte "right "
               .byte FIN 

GO_FIRE_TEXT:
               .byte AT,35,01,07
               .byte "fire "
               .byte FIN 

GO_NOTHING_TEXT:
               .byte AT,35,01,07
               .byte "      "
               .byte FIN 


.segment "MAP_UTILITY"
.include "map-utility.s"                          

BLOCK_CHARSET:
.segment "BLOCK_CHARS"
    .incbin "batman\charsets.bin"


TEXT_CHARSET:
.segment "TEXT_CHARSET"
    .incbin "batman\text-charset.bin"

CBM_CHARSET:
.segment "CBM_CHARSET"
    .incbin "chars-cbm.bin"

SPRITES:
.segment "SPRITES"
.include "sprites.s"  

BLOCKS_LOOKUP:
.segment "BLOCKS"
    .incbin "batman\blocks.bin"

CHARSET_COLOR_LOOKUP:
.segment "CHARSET_COLORS"
	.incbin "batman\charset-colors.bin"

MAP:
.segment "MAP"
    .incbin "batman\chemical-map.BIN"


     


 
 
