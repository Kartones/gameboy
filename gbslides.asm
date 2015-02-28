; GameBoy Powerpoint-like slide viewer

; GAMEBOY SYSTEM CONSTANTS
; the hardware registers for the Game Boy begin at address $FF00
; All the 8 bit register addresses below are offsets relative to $FF00
; List from "Game Boy test 4" from Doug Lanford (opus@dnai.com)
JOYPAD_REGISTER					EQU		$00		; joypad
PAD_PORT_DPAD						EQU		%00100000	; select d-pad buttons
PAD_PORT_BUTTONS				EQU		%00010000	; select other buttons
PAD_OUTPUT_MASK					EQU		%00001111	; mask for the output buttons
DPAD_DOWN								EQU		7
DPAD_UP									EQU		6
DPAD_LEFT								EQU		5
DPAD_RIGHT							EQU		4
START_BUTTON						EQU		3
SELECT_BUTTON						EQU		2
B_BUTTON								EQU		1
A_BUTTON								EQU		0
DPAD_DOWN_MASK					EQU		%10000000
DPAD_UP_MASK						EQU		%01000000
DPAD_LEFT_MASK					EQU		%00100000
DPAD_RIGHT_MASK					EQU		%00010000
START_BUTTON_MASK				EQU		%00001000
SELECT_BUTTON_MASK			EQU		%00000100
B_BUTTON_MASK						EQU		%00000010
A_BUTTON_MASK						EQU		%00000001

DIV_REGISTER						EQU		$04		; divide timer... read to get time, write to reset it to 0
TIMA_REGISTER						EQU		$05		; main timer... freq is set in TAC reg, generates interupt when overflows
TMA_REGISTER						EQU		$06		; Timer Modulo... main timer loaded with this value after it overflows
TAC_REGISTER						EQU		$07		; Timer Control
TIMER_STOP							EQU		%00000100	; timer halt flag... 0=stop, 1=run
TIMER_FREQ_MASK					EQU		%00000011	; mask for timer frequency bits
TIMER_FREQ_4KHz					EQU		%00000000	; main timer runs at 4.096 KHz
TIMER_FREQ_262KHz				EQU		%00000001	; main timer runs at 262.144 KHz
TIMER_FREQ_65KHZ				EQU		%00000010	; main timer runs at 65.536 KHz
TIMER_FREQ_16KHz				EQU		%00000011	; main timer runs at 15.384 KHz

IRQ_FLAG_REGISTER				EQU		$0F		; Interrupt Flag
VBLANK_INT							EQU		%00000001	; bit 0 = vblank interrupt on/off
LCDC_INT								EQU		%00000010	; bit 1 = LCDC interrupt on/off
TIMER_INT								EQU		%00000100	; bit 2 = Timer Overflow interrupt on/off
SERIAL_INT							EQU		%00001000	; bit 3 = Serial I/O Transfer Completion interrupt on/off
CONTROLLER_INT					EQU		%00010000	; bit 4 = ??

LCDC_CONTROL						EQU		$40		; LCD (Graphics) Control
BKG_DISP_FLAG						EQU		%00000001	; bit 0 = background tile map is on if set
SPRITE_DISP_FLAG				EQU		%00000010	; bit 1 = sprites are on if set
SPRITE_DISP_SIZE				EQU		%00000100	; bit 2 = sprite size (0=8x8 pixels, 1=16x8)
BKG_MAP_LOC							EQU		%00001000	; bit 3 = background tile map location (0=$9800-$9bff, 1=$9c00-$9fff)
TILES_LOC								EQU		%00010000	; bit 4 = tile data location (0=$8800-$97ff, 1=$8000-$8fff)
WINDOW_DISP_FLAG				EQU		%00100000	; bit 5 = window tile map is on if set
WINDOW_MAP_LOC					EQU		%01000000	; bit 6 = window tile map location (0=$9800-$9bff, 1=$9c00-9fff)
DISPLAY_FLAG						EQU		%10000000	; bit 7 = LCD display on if set

LCDC_STATUS							EQU		$41		; LCDC Status
DISP_CYCLE_MODE					EQU		%00000011	; mask for the display cycle mode bits
VBLANK_MODE							EQU		%00000000	; system is in vertical blanking interval
HBLANK_MODE							EQU		%00000001	; system is in a horizontal blanking interval
SPRITE_MODE							EQU		%00000010	; system is reading sprite RAM
LCD_TRANSFER						EQU		%00000011	; system is transfering data to the LCD driver

SCROLL_BKG_Y						EQU		$42		; vertical scroll position of background tile map
SCROLL_BKG_X						EQU		$43		; horizontal scroll position of background tile map

LCDC_LY_COUNTER					EQU		$44		; increments every scan line (0..143 = display, 144-153 = vblank)
LY_COMPARE							EQU		$45		; ??

DMA_REGISTER						EQU		$46		; DMA Transfer and Start Address

PALETTE_BKG							EQU		$47		; palette data for background tile map
PALETTE_SPRITE_0				EQU		$48		; sprite palette 0 data
PALETTE_SPRITE_1				EQU		$49		; sprite palette 1 data

POS_WINDOW_Y						EQU		$4A		; window tile map Y position
POS_WINDOW_X						EQU		$4B		; window tile map X position

INTERRUPT_ENABLE				EQU		$ff		; Interrupt Enable

; $ff80 to $fffe is 128 bytes of internal RAM
STACK_TOP								EQU		$fff4		; put the stack here

; video ram display locations
TILES_MEM_LOC_0					EQU		$8800		; tile map tiles only
TILES_MEM_LOC_1					EQU		$8000		; tile maps and sprite tiles

MAP_MEM_LOC_0						EQU		$9800		; background and window tile maps
MAP_MEM_LOC_1						EQU		$9c00		; (select which uses what mem loc in LCDC_CONTROL register)

SPRITE_ATTRIB_MEM_LOC		EQU		$fe00		; OAM memory (sprite attributes)

; Sprite attribute flags
SPRITE_FLAGS_PAL				EQU		%00010000	; palette (0=sprite pal 0, 1=sprite pal 1)
SPRITE_FLAGS_XFLIP			EQU		%00100000	; sprite is horizontal flipped
SPRITE_FLAGS_YFLIP			EQU		%01000000	; sprite is vertical flipped
SPRITE_FLAGS_PRIORITY		EQU		%10000000	; sprite display priority (0=on top bkg & win, 1=behind bkg & win)

; Start of the ROM
;-------------------------------------------------------------------------
SECTION	"ROM_Start",HOME[$0000]

; NOTE: the hardware rEQUires the interrupt jumps to be at these addresses

; Vertical Blanking interrupt
SECTION	"VBlank_IRQ_Jump",HOME[$0040]
	JP	VBlankFunc

; LCDC Status interrupt (can be set for H-Blanking interrupt)
SECTION	"LCDC_IRQ_Jump",HOME[$0048]
	RETI

; Main Timer Overflow interrupt
SECTION	"Timer_Overflow_IRQ_Jump",HOME[$0050]
	RETI

; Serial Transfer Completion interrupt
SECTION	"Serial_IRQ_Jump",HOME[$0058]
	RETI

; Joypad Button Interrupt?????
SECTION	"Joypad_IRQ_Jump",HOME[$0060]
	RETI

SECTION	"GameBoy_Header_Start", HOME[$0100]
; begining of Game Boy game header
	NOP
	JP 		$150         ; goto beginning of game code

; Game Boy standard header... Don't touch
DB $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
DB $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
DB $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

DB "Freakend        "	; game name (must be 16 bytes)
DB $00,$00,$00				; Color GameBoy compatibility code, License Code & GameBoy indicator ($00 - GameBoy)
DB $00								; Cartridge type ($00 - ROM Only)
DB $00								; ROM Size ($00 - 256Kbit = 32Kbyte = 2 banks)
DB $00								; RAM Size ($00 - None)
DB $00,$00						; maker ID
DB $00								; Mask ROM version (handled by RGBFIX)
DB $00								; Complement check (handled by RGBFIX)
DB $00,$00						; Cartridge checksum (handled by RGBFIX)


; Real code starts here
; ---------------------
SECTION	"Game_Code_Start", HOME[$0150]
START::
	; init the stack pointer
	LD		SP, STACK_TOP

	; enable only vblank interrupts
	LD		A, VBLANK_INT					; set vblank interrupt bit
	LDH		[INTERRUPT_ENABLE], A	; load it to the hardware register

	; standard inits
	sub		A									;	a = 0
	LDH		[LCDC_STATUS], A	; init status
	LDH		[LCDC_CONTROL], A	; init LCD to everything off

	LD		A, 0
	LD		[vblank_flag], A

	; Custom variable inits
	LD 		A, 0
	LD 		[current_slide], A

	; ------------------------------------------
	LD 		A, 10 								; Total slides. Real slides count - 1 (zero-index)
	LD 		[total_slides], A
	; ------------------------------------------

	CALL	LOAD_TILES
	CALL 	LOAD_MAP
	CALL	INIT_PALETTES

	; set display to on, background on, window off, sprites on, sprite size 8x8
	;	tiles at $8000, background map at $9800, window map at $9C00
	LD		A, DISPLAY_FLAG | BKG_DISP_FLAG | SPRITE_DISP_FLAG | TILES_LOC | WINDOW_MAP_LOC
	LDH		[LCDC_CONTROL], A

	; allow interrupts to start occuring
	ei

Game_Loop::
	; don't do a frame update unless we have had a vblank
	LD		A, [vblank_flag]
	CP		0
	JP		Z, .end_game_loop

	CALL	READ_INPUT
	CALL	HANDLE_INPUT

	; reset vblank flag
	LD		A, 0
	LD		[vblank_flag], A

.end_game_loop
	JP		Game_Loop


INIT_PALETTES::
	LD		A, %11100100	; dark -> light
	; load it to all the palettes
	LDH		[PALETTE_BKG], A
	LDH		[PALETTE_SPRITE_0], A
	LDH		[PALETTE_SPRITE_1], A
	RET

LOAD_TILES::
	LD		HL, 	TILESET_DATA
	LD		DE, 	TILES_MEM_LOC_1
	LD		BC,		77*16		; 77 tiles x 16 bytes each
LOAD_TILES_LOOP::
	LDH		A, [LCDC_STATUS]	; get the status
	AND		SPRITE_MODE			; don't write during sprite and transfer modes
	JP		NZ, LOAD_TILES_LOOP
	LD		A, 		[HL+]		; get byte from tile data
	LD		[DE], A				; put it in VRAM
	INC		DE
	DEC		BC
	LD		A, 		B				; A = B to check B || C == 0
	OR		C
	JP		NZ,		LOAD_TILES_LOOP
	RET




LOAD_MAP::
	LD		A, [current_slide]
	SUB 	0
	JP 		NZ, SELECT_LOAD_SLIDE_01

	LD		HL, 	INTRO_SLIDE_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_01::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_02

	LD		HL, 	SLIDE_01_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_02::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_03

	LD		HL, 	SLIDE_02_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_03::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_04

	LD		HL, 	SLIDE_03_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_04::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_05

	LD		HL, 	SLIDE_04_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_05::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_06

	LD		HL, 	SLIDE_05_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_06::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_07

	LD		HL, 	SLIDE_06_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_07::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_08

	LD		HL, 	SLIDE_07_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_08::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_09

	LD		HL, 	SLIDE_08_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_09::
	SUB 	1
	JP 		NZ, SELECT_LOAD_SLIDE_99

	LD		HL, 	SLIDE_09_DATA
	JP 		.LOAD_SLIDE_DATA

SELECT_LOAD_SLIDE_99::
	LD		HL, 	SLIDE_99_DATA

.LOAD_SLIDE_DATA
	LD		DE, 	MAP_MEM_LOC_0		; where our map goes
	LD		C, 		20							; number of tiles per row
	LD  	B, 		18 							; number of rows to load

.LOAD_MAP_ROW_LOOP
	; don't write during sprite and transfer modes
	LDH		A, 		[LCDC_STATUS]
	AND		SPRITE_MODE
	JR		NZ, 	.LOAD_MAP_ROW_LOOP

	LD		A,		[HL+]						; load map tile
	LD		[DE],	A								; put it in MAP_MEM_LOC_0
	INC		DE
	DEC		C											; decrement column counter
	JR		NZ,		.LOAD_MAP_ROW_LOOP

.LOAD_MAP_COL_LOOP
	PUSH 	HL
	; Skip loading remaining 12 tiles offscreen from each row
	; All this is just to sum 12 to a 16 bit register (DE) only storing one value in the stack (HL)
	LD 		HL, 	12
	ADD 	HL, 	DE
	LD 		D, 		H
	LD  	E, 		L
	POP 	HL
	LD		C, 		20		; number of tiles per row (reset value)
	DEC 	B 					; decrement row counter
	JR 		NZ, 	.LOAD_MAP_ROW_LOOP
	RET


; Read the joypad. Loads two variables:
;	joypad_held	- what buttons are currently held
;	joypad_down	- what buttons went down since last joypad read
; Code from "Game Boy test 4" from Doug Lanford (opus@dnai.com)
;-----------------------------------------------------------------------
READ_INPUT::
	; get the d-pad buttons
	LD		A, PAD_PORT_DPAD			; select d-pad
	LDH		[JOYPAD_REGISTER], A	; send it to the joypad
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]	; get the result back (takes a few cycles)
	CPL			; bit-flip the result
	AND		PAD_OUTPUT_MASK		; mask out the output bits
	SWAP	A					; put the d-pad button results to top nibble
	LD		B, A				; and store it

	; get A / B / SELECT / START buttons
	LD		A, PAD_PORT_BUTTONS		; select buttons
	LDH		[JOYPAD_REGISTER], A	; send it to the joypad
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]
	LDH		A, [JOYPAD_REGISTER]	; get the result back (takes even more cycles?)
	CPL			; bit-flip the result
	AND		PAD_OUTPUT_MASK		; mask out the output bits
	OR		B					; add it to the other button bits
	LD		B, A			; put it back in c

	; calculate the buttons that went down since last joypad read
	LD		A, [joypad_held]	; grab last button bits
	CPL							; invert them
	AND		B					; combine the bits with current bits
	LD		[joypad_down], A	; store just-went-down button bits

	LD		A, B
	LD      [joypad_held], A	; store the held down button bits

	LD		A, $30       ; reset joypad
  LDH		[JOYPAD_REGISTER], A

	RET


; vblank routine - do all graphical changes here while the display is not drawing
; Code from "Game Boy test 4" from Doug Lanford (opus@dnai.com)
;--------------------------------------------------------------------------------
VBlankFunc::
	DI		; disable interrupts
	PUSH	AF

	; is it time to scroll yet?
	AND		%00000001
	JR		NZ, .vblank_sprite_DMA	; only scroll ever other vblank

; load the sprite attrib table to OAM memory
.vblank_sprite_DMA
	; Unused but left as sample of how update a sprite
	;LD		A, $c0				; dma from $c000 (where I have my local copy of the attrib table)
	;LDH		[DMA_REGISTER], A	; start the dma

	LD		A, $28		; wait for 160 microsec (using a loop)
.vblank_dma_wait
	DEC		A
	JR		NZ, .vblank_dma_wait

	LD		HL, SPRITE_ATTRIB_MEM_LOC

	; set the vblank occured flag
	LD		A, 1
	LD		[vblank_flag], A

	POP AF
	EI		; enable interrupts
	RETI	; and done


HANDLE_INPUT::
	PUSH	AF

;.check_a_button
	LD		A, [joypad_down]
	BIT		A_BUTTON, A
	JR		Z, .check_b_button

	; a button down - previous slide
	LD		A, [current_slide]
	SUB 	0
	JP 		Z, .check_b_button 		; Already were at first slide, don't go back more
	DEC 	A
	LD		[current_slide], A
	CALL 	LOAD_MAP

.check_b_button
	LD		A, [joypad_down]
	BIT		B_BUTTON, A
	JR		Z, .done_checking_joypad

	; b button down - next slide
	LD		A, [current_slide]
	LD 		B, A
	LD    A, [total_slides]
	SUB 	B
	JP 		Z, .done_checking_joypad	; Already were at last slide, don't advance
	LD 		A, B
	INC 	A
	LD		[current_slide], A
	CALL 	LOAD_MAP

.done_checking_joypad
	POP		AF
	RET


; Tileset
INCLUDE	"TILESET.INC"

; BG map
; - Full screen map is 20x18 8x8 tiles (160x144 pixels)
; - All my maps have a '_DATA' suffix added to the name
INCLUDE	"INTRO_SLIDE.INC"
INCLUDE	"SLIDE_01.INC"
INCLUDE	"SLIDE_02.INC"
INCLUDE	"SLIDE_03.INC"
INCLUDE	"SLIDE_04.INC"
INCLUDE	"SLIDE_05.INC"
INCLUDE	"SLIDE_06.INC"
INCLUDE	"SLIDE_07.INC"
INCLUDE	"SLIDE_08.INC"
INCLUDE	"SLIDE_09.INC"
INCLUDE	"SLIDE_99.INC"


; Internal RAM
;-------------

SECTION	"RAM_Other_Variables", BSS[$C0A0]

joypad_held:
DS		1		; what buttons are currently held
joypad_down:
DS		1		; what buttons went down since last joypad read

vblank_flag:
DS		1		; set if a vblank occured since last pass through game loop

total_slides:
DS 		1

current_slide:
DS 		1
