; TODO: Check why this code fails. From slide 3 onwards BGs are not drawn correctly
; Suspects are either some interrupt or VBlank messing up

LOAD_MAP::
	; Idea is jump to [INTRO_SLIDE_DATA + 20*20 * [current_slide] ]
	; and then do map load

	LD 		A, 		[current_slide]
	INC 	A 		; because loop will substract 1
	PUSH 	AF

	LD		HL, 	INTRO_SLIDE_DATA	; Initial slide position

.SLIDE_LOOP
	POP 	AF
	SUB 	1 		; A--
	JP 		Z, 		.LOAD_SLIDE_DATA 	; No more loop passes
	PUSH 	AF

	; Advance to memory position of next slide (Map)
	LD		C, 		18			; do 18 times
.COL_LOOP
	LD  	B, 		20 			; 20 steps each time
.ROW_LOOP
	INC 	HL

	DEC 	B
	JP		NZ,		.ROW_LOOP

	DEC 	C
	JP 		NZ, 	.COL_LOOP

	JP 		.SLIDE_LOOP


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