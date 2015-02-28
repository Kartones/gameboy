

; GAMEBOY SYSTEM CONSTANTS
; the hardware registers for the Game Boy begin at address $FF00
; All the 8 bit register addresses below are offsets relative to $FF00
; List from "Game Boy test 4" from Doug Lanford (opus@dnai.com)
JOYPAD_REGISTER			equ		$00		; joypad
PAD_PORT_DPAD			equ		%00100000	; select d-pad buttons
PAD_PORT_BUTTONS		equ		%00010000	; select other buttons
PAD_OUTPUT_MASK			equ		%00001111	; mask for the output buttons
DPAD_DOWN				equ		7
DPAD_UP					equ		6
DPAD_LEFT				equ		5
DPAD_RIGHT				equ		4
START_BUTTON			equ		3
SELECT_BUTTON			equ		2
B_BUTTON				equ		1
A_BUTTON				equ		0
DPAD_DOWN_MASK			equ		%10000000
DPAD_UP_MASK			equ		%01000000
DPAD_LEFT_MASK			equ		%00100000
DPAD_RIGHT_MASK			equ		%00010000
START_BUTTON_MASK		equ		%00001000
SELECT_BUTTON_MASK		equ		%00000100
B_BUTTON_MASK			equ		%00000010
A_BUTTON_MASK			equ		%00000001

DIV_REGISTER			equ		$04		; divide timer... read to get time, write to reset it to 0
TIMA_REGISTER			equ		$05		; main timer... freq is set in TAC reg, generates interupt when overflows
TMA_REGISTER			equ		$06		; Timer Modulo... main timer loaded with this value after it overflows
TAC_REGISTER			equ		$07		; Timer Control
TIMER_STOP				equ		%00000100	; timer halt flag... 0=stop, 1=run
TIMER_FREQ_MASK			equ		%00000011	; mask for timer frequency bits
TIMER_FREQ_4KHz			equ		%00000000	; main timer runs at 4.096 KHz
TIMER_FREQ_262KHz		equ		%00000001	; main timer runs at 262.144 KHz
TIMER_FREQ_65KHZ		equ		%00000010	; main timer runs at 65.536 KHz
TIMER_FREQ_16KHz		equ		%00000011	; main timer runs at 15.384 KHz

IRQ_FLAG_REGISTER		equ		$0F		; Interrupt Flag
VBLANK_INT				equ		%00000001	; bit 0 = vblank interrupt on/off
LCDC_INT				equ		%00000010	; bit 1 = LCDC interrupt on/off
TIMER_INT				equ		%00000100	; bit 2 = Timer Overflow interrupt on/off
SERIAL_INT				equ		%00001000	; bit 3 = Serial I/O Transfer Completion interrupt on/off
CONTROLLER_INT			equ		%00010000	; bit 4 = ??

LCDC_CONTROL			equ		$40		; LCD (Graphics) Control
BKG_DISP_FLAG			equ		%00000001	; bit 0 = background tile map is on if set
SPRITE_DISP_FLAG		equ		%00000010	; bit 1 = sprites are on if set
SPRITE_DISP_SIZE		equ		%00000100	; bit 2 = sprite size (0=8x8 pixels, 1=16x8)
BKG_MAP_LOC				equ		%00001000	; bit 3 = background tile map location (0=$9800-$9bff, 1=$9c00-$9fff)
TILES_LOC				equ		%00010000	; bit 4 = tile data location (0=$8800-$97ff, 1=$8000-$8fff)
WINDOW_DISP_FLAG		equ		%00100000	; bit 5 = window tile map is on if set
WINDOW_MAP_LOC			equ		%01000000	; bit 6 = window tile map location (0=$9800-$9bff, 1=$9c00-9fff)
DISPLAY_FLAG			equ		%10000000	; bit 7 = LCD display on if set

LCDC_STATUS				equ		$41		; LCDC Status
DISP_CYCLE_MODE			equ		%00000011	; mask for the display cycle mode bits
VBLANK_MODE				equ		%00000000	; system is in vertical blanking interval
HBLANK_MODE				equ		%00000001	; system is in a horizontal blanking interval
SPRITE_MODE				equ		%00000010	; system is reading sprite RAM
LCD_TRANSFER			equ		%00000011	; system is transfering data to the LCD driver

SCROLL_BKG_Y			equ		$42		; vertical scroll position of background tile map
SCROLL_BKG_X			equ		$43		; horizontal scroll position of background tile map

LCDC_LY_COUNTER			equ		$44		; increments every scan line (0..143 = display, 144-153 = vblank)
LY_COMPARE				equ		$45		; ??

DMA_REGISTER			equ		$46		; DMA Transfer and Start Address

PALETTE_BKG				equ		$47		; palette data for background tile map
PALETTE_SPRITE_0		equ		$48		; sprite palette 0 data
PALETTE_SPRITE_1		equ		$49		; sprite palette 1 data

POS_WINDOW_Y			equ		$4A		; window tile map Y position
POS_WINDOW_X			equ		$4B		; window tile map X position

INTERRUPT_ENABLE		equ		$ff		; Interrupt Enable

; $ff80 to $fffe is 128 bytes of internal RAM
STACK_TOP								equ		$fff4		; put the stack here

; video ram display locations
TILES_MEM_LOC_0					equ		$8800		; tile map tiles only
TILES_MEM_LOC_1					equ		$8000		; tile maps and sprite tiles

MAP_MEM_LOC_0						equ		$9800		; background and window tile maps
MAP_MEM_LOC_1						equ		$9c00		; (select which uses what mem loc in LCDC_CONTROL register)

SPRITE_ATTRIB_MEM_LOC		equ		$fe00		; OAM memory (sprite attributes)

; Sprite attribute flags
SPRITE_FLAGS_PAL				equ		%00010000	; palette (0=sprite pal 0, 1=sprite pal 1)
SPRITE_FLAGS_XFLIP			equ		%00100000	; sprite is horizontal flipped
SPRITE_FLAGS_YFLIP			equ		%01000000	; sprite is vertical flipped
SPRITE_FLAGS_PRIORITY		equ		%10000000	; sprite display priority (0=on top bkg & win, 1=behind bkg & win)

; Start of the ROM
;-------------------------------------------------------------------------
SECTION	"ROM_Start",HOME[$0000]

; NOTE: the hardware requires the interrupt jumps to be at these addresses

; Vertical Blanking interrupt
SECTION	"VBlank_IRQ_Jump",HOME[$0040]
	jp	VBlankFunc

; LCDC Status interrupt (can be set for H-Blanking interrupt)
SECTION	"LCDC_IRQ_Jump",HOME[$0048]
	reti

; Main Timer Overflow interrupt
SECTION	"Timer_Overflow_IRQ_Jump",HOME[$0050]
	reti

; Serial Transfer Completion interrupt
SECTION	"Serial_IRQ_Jump",HOME[$0058]
	reti

; Joypad Button Interrupt?????
SECTION	"Joypad_IRQ_Jump",HOME[$0060]
	reti

SECTION	"GameBoy_Header_Start", HOME[$0100]
; begining of Game Boy game header
	nop
	jp 		$150         ; goto beginning of game code

; Game Boy standard header... Don't touch
db $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
db $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
db $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

db "Freakend        "	; game name (must be 16 bytes)
db $00,$00,$00				; Color GameBoy compatibility code, License Code & GameBoy indicator ($00 - GameBoy)
db $00								; Cartridge type ($00 - ROM Only)
db $00								; ROM Size ($00 - 256Kbit = 32Kbyte = 2 banks)
db $00								; RAM Size ($00 - None)
db $00,$00						; maker ID
db $00								; Mask ROM version (handled by RGBFIX)
db $00								; Complement check (handled by RGBFIX)
db $00,$00						; Cartridge checksum (handled by RGBFIX)


; Real code starts here
; ---------------------
SECTION	"Game_Code_Start", HOME[$0150]
start::
	; init the stack pointer
	ld		sp, STACK_TOP

	; enable only vblank interrupts
	ld		A, VBLANK_INT					; set vblank interrupt bit
	ldh		[INTERRUPT_ENABLE], A	; load it to the hardware register

	; standard inits
	sub		A									;	a = 0
	ldh		[LCDC_STATUS], A	; init status
	ldh		[LCDC_CONTROL], A	; init LCD to everything off

	ld		A, 0
	ld		[vblank_flag], A

	; Custom variable inits
	ld 		A, 0
	ld 		[current_slide], A

	; ------------------------------------------
	LD 		A, 10 								; Total slides. Real slides count - 1 (zero-index)
	LD 		[total_slides], A
	; ------------------------------------------

	call	LOAD_TILES
	call 	LOAD_MAP
	call	INIT_PALETTES

	; set display to on, background on, window off, sprites on, sprite size 8x8
	;	tiles at $8000, background map at $9800, window map at $9C00
	ld		a, DISPLAY_FLAG | BKG_DISP_FLAG | SPRITE_DISP_FLAG | TILES_LOC | WINDOW_MAP_LOC
	ldh		[LCDC_CONTROL], a

	; allow interrupts to start occuring
	ei

Game_Loop::
	; don't do a frame update unless we have had a vblank
	ld		a, [vblank_flag]
	cp		0
	jp		z, .end_game_loop

	call	READ_INPUT
	call	HANDLE_INPUT

	; reset vblank flag
	ld		a, 0
	ld		[vblank_flag], a

.end_game_loop
	jp		Game_Loop


INIT_PALETTES::
	ld		a, %11100100	; dark -> light
	; load it to all the palettes
	ldh		[PALETTE_BKG], a
	ldh		[PALETTE_SPRITE_0], a
	ldh		[PALETTE_SPRITE_1], a
	ret

LOAD_TILES::
	LD		HL, 	TILESET_DATA
	LD		DE, 	TILES_MEM_LOC_1
	LD		BC,		77*16		; 77 tiles x 16 bytes each
LOAD_TILES_LOOP::
	ldh		a, [LCDC_STATUS]	; get the status
	and		SPRITE_MODE			; don't write during sprite and transfer modes
	JP		nz, LOAD_TILES_LOOP
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
	JP 		NZ, .SELECT_LOAD_SLIDE_01

	LD		HL, 	INTRO_SLIDE_DATA
	JP 		.LOAD_SLIDE_DATA

.SELECT_LOAD_SLIDE_01
	SUB 	1
	JP 		NZ, .SELECT_LOAD_SLIDE_02

	LD		HL, 	SLIDE_01_DATA
	JP 		.LOAD_SLIDE_DATA

.SELECT_LOAD_SLIDE_02
	SUB 	1
	JP 		NZ, .SELECT_LOAD_SLIDE_03

	LD		HL, 	SLIDE_02_DATA
	JP 		.LOAD_SLIDE_DATA

.SELECT_LOAD_SLIDE_03
	SUB 	1
	JP 		NZ, .SELECT_LOAD_SLIDE_04

	LD		HL, 	SLIDE_03_DATA
	JP 		.LOAD_SLIDE_DATA

.SELECT_LOAD_SLIDE_04
	SUB 	1
	JP 		NZ, .SELECT_LOAD_SLIDE_05

	LD		HL, 	SLIDE_04_DATA
	JP 		.LOAD_SLIDE_DATA

.SELECT_LOAD_SLIDE_05
	SUB 	1
	JP 		NZ, .SELECT_LOAD_SLIDE_06

	LD		HL, 	SLIDE_05_DATA
	JP 		.LOAD_SLIDE_DATA

.SELECT_LOAD_SLIDE_06
	SUB 	1
	JP 		NZ, .SELECT_LOAD_SLIDE_99

	LD		HL, 	SLIDE_06_DATA
	JP 		.LOAD_SLIDE_DATA

.SELECT_LOAD_SLIDE_99
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
	ld		a, PAD_PORT_DPAD		; select d-pad
	ldh		[JOYPAD_REGISTER], a	; send it to the joypad
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]	; get the result back (takes a few cycles)
	cpl			; bit-flip the result
	and		PAD_OUTPUT_MASK		; mask out the output bits
	swap	a					; put the d-pad button results to top nibble
	ld		b, a				; and store it

	; get A / B / SELECT / START buttons
	ld		a, PAD_PORT_BUTTONS		; select buttons
	ldh		[JOYPAD_REGISTER], a	; send it to the joypad
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]
	ldh		a, [JOYPAD_REGISTER]	; get the result back (takes even more cycles?)
	cpl			; bit-flip the result
	and		PAD_OUTPUT_MASK		; mask out the output bits
	or		b					; add it to the other button bits
	ld		b, a			; put it back in c

	; calculate the buttons that went down since last joypad read
	ld		a, [joypad_held]	; grab last button bits
	cpl							; invert them
	and		b					; combine the bits with current bits
	ld		[joypad_down], a	; store just-went-down button bits

	ld		a, b
	ld      [joypad_held], a	; store the held down button bits

	ld		a, $30       ; reset joypad
  ldh		[JOYPAD_REGISTER], A

	ret


; vblank routine - do all graphical changes here while the display is not drawing
; Code from "Game Boy test 4" from Doug Lanford (opus@dnai.com)
;--------------------------------------------------------------------------------
VBlankFunc::
	di		; disable interrupts
	push	af

	; is it time to scroll yet?
	and		%00000001
	jr		nz, .vblank_sprite_DMA	; only scroll ever other vblank

; load the sprite attrib table to OAM memory
.vblank_sprite_DMA
	; Unused but left as sample of how update a sprite
	;ld		a, $c0				; dma from $c000 (where I have my local copy of the attrib table)
	;ldh		[DMA_REGISTER], a	; start the dma

	ld		a, $28		; wait for 160 microsec (using a loop)
.vblank_dma_wait
	dec		a
	jr		nz, .vblank_dma_wait

	ld		hl, SPRITE_ATTRIB_MEM_LOC

	; set the vblank occured flag
	ld		a, 1
	ld		[vblank_flag], a

	pop af
	ei		; enable interrupts
	reti	; and done


HANDLE_INPUT::
	push	af

;.check_a_button
	ld		a, [joypad_down]
	bit		A_BUTTON, a
	jr		z, .check_b_button

	; a button down - previous slide
	ld		A, [current_slide]
	SUB 	0
	JP 		Z, .check_b_button 		; Already were at first slide, don't go back more
	DEC 	A
	ld		[current_slide], A
	CALL 	LOAD_MAP

.check_b_button
	ld		a, [joypad_down]
	bit		B_BUTTON, a
	jr		z, .done_checking_joypad

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
ds		1		; what buttons are currently held
joypad_down:
ds		1		; what buttons went down since last joypad read

vblank_flag:
ds		1		; set if a vblank occured since last pass through game loop

total_slides:
ds 		1

current_slide:
ds 		1

map_mem_position:
ds 		1