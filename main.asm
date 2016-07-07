	device zxspectrum48
START	EQU #9c40

COLOR_W EQU #40 + 8 * #7
COLOR_B EQU #40 + 8 * #1
COLOR_R EQU #40 + 8 * #2

COLOR_K EQU 0 ; black

	ORG START
;	di
	LD SP, #FFFF
	XOR A
	OUT (#FE), A
	ld hl, 16384 + 6144
;BLACK/WHITE
	LD A, COLOR_K
	LD (WAVE_COLOR_1), A
	LD A, COLOR_W
	LD (WAVE_COLOR_2), A
	CALL WAVE
;WHITE/BLUE
	LD A, COLOR_W
	LD (WAVE_COLOR_1), A
	LD A, COLOR_B
	LD (WAVE_COLOR_2), A
	CALL WAVE
;BLUE/RED
	LD A, COLOR_B
	LD (WAVE_COLOR_1), A
	LD A, COLOR_R
	LD (WAVE_COLOR_2), A
	CALL WAVE
;RED/BLACK
	LD A, COLOR_R
	LD (WAVE_COLOR_1), A
	LD A, COLOR_K
	LD (WAVE_COLOR_2), A
	CALL WAVE
	
	halt
	halt

	CALL SCROLL_WAVE
	JP START
	


; Print 8 wave rows
WAVE_COLOR_1 DB 0
WAVE_COLOR_2 DB 0
WAVE:
	LD IXH, #40

WAVE_LINE_LOOP:
	LD DE, FLAG_DATA
	LD C, 31
	INC HL
WAVE_CHAR_LOOP:
	LD A, (DE)
	AND IXH
	JR Z, PUT_COLOR2
	
PUT_COLOR1:
	LD A, (WAVE_COLOR_1)
	JR PUT_COLOR
PUT_COLOR2:
	LD A, (WAVE_COLOR_2)

PUT_COLOR:
	LD (HL), A

; going to the next char if line is not over
	INC DE
	INC HL
	DEC C
	JP NZ, WAVE_CHAR_LOOP

; going to the next line until all 8 rows are printed
	LD A, IXH
	SRL A
	AND #FE
	LD IXH, A
	JP NZ, WAVE_LINE_LOOP

; all done, so restore DE to the HL + 1
	LD E, L
	LD D, H
	INC DE
	
	RET

CHANGE_SCROLL_DIRECTION:
	LD A, (SCROLL_DIRECTION)
	XOR #FF
	LD (SCROLL_DIRECTION), A
	RET

SCROLL_WAVE:
	; scrolling flag tail
	
	; first check if we need to change scroll direction
	; next byte from ROM
	INC IY
	LD A, IYH
	AND #7F
	LD IYH, A
	LD A, (IY)
	AND #03
	CP 2
	CALL Z, CHANGE_SCROLL_DIRECTION
	LD A, (SCROLL_DIRECTION)
	AND 1
	JP Z, SCROLL_WAVE_LEFT
SCROLL_WAVE_RIGHT:
	LD HL, WAVE_DATA + 62
	LD DE, WAVE_DATA + 63
	LD A, (DE)
	LD BC, 63
	LDDR

	JR SCROLL_WAVE_END
SCROLL_WAVE_LEFT:
	LD HL, WAVE_DATA + 1
	LD DE, WAVE_DATA
	LD A, (DE)
	LD BC, 63
	LDIR

SCROLL_WAVE_END:
	; restoring first affected byte of scrolled array
	LD (DE), A
	
	; calculating flag head
	LD C, 1 ; two passes since we have 2 stabilizing columns
	LD HL, WAVE_DATA - 1 ; last byte of head
	LD DE, WAVE_DATA

INTERPOLATE_HEAD:
	LD A, (DE) ; first byte of tail
	
	CP #F0 ; center position, no additional shit is required
	JP Z, SET_HEAD_POS
	CP #71 ; center position, no additional shit is required
	JP Z, SET_HEAD_POS
	CP #E0 ; center position, no additional shit is required
	JP Z, SET_HEAD_POS

	AND #0F
	LD A, (DE) ; doing here since it does not change any flags
	JP NZ, FLAG_WENT_DOWN:
FLAG_WENT_UP:
	SRA A
	JP SET_HEAD_POS
FLAG_WENT_DOWN:
	SLA A

SET_HEAD_POS;
	LD (HL), A
	
	DEC C
	RET Z

	DEC HL
	DEC DE

	JP INTERPOLATE_HEAD

SCROLL_DIRECTION: DB 0
FLAG_DATA:
	DB #F0
	DB 0
WAVE_DATA:
	INCBIN "wave.png.bin"

	SAVESNA "main.sna", START
