	device zxspectrum48
START	EQU #9c40

COLOR_W EQU #40 + 8 * #7
COLOR_B EQU #40 + 8 * #1
COLOR_R EQU #40 + 8 * #2

COLOR_K EQU 0 ; black

	ORG START
	
	LD A, 2
	CALL #1601
	
	LD A, 'A'
	RST #10
	
	;ld	hl, #060C
	;ld	de, #0114
	;call	#03b5
	;JP START
	
	di
	LD SP, #FFFF

	; black border
	XOR A
	OUT (#FE), A

MAIN_LOOP:
	; point HL to attributes start
	ld hl, 16384 + 6144
	
	; drawing flag stripes
	LD IY, COLORS
	CALL WAVE ;BLACK/WHITE
	CALL WAVE ;WHITE/BLUE
	CALL WAVE ;BLUE/RED
	CALL WAVE ;RED/BLACK

; halt (may be replaced with real HALT)
	LD BC, 700
PAUSE_LOOP:
	DEC BC
	LD A, B
	OR C
	JP NZ, PAUSE_LOOP

	CALL SCROLL_WAVE
	JP MAIN_LOOP

; Print 8 wave rows
WAVE:
	LD IXH, #40

WAVE_LINE_LOOP:
	LD DE, FLAG_DATA
	LD C, 24
	INC HL
WAVE_CHAR_LOOP:
	LD A, (DE)
	AND IXH
	JR Z, PUT_COLOR2
	
PUT_COLOR1:
	LD A, (IY)
	JR PUT_COLOR
PUT_COLOR2:
	LD A, (IY+1)

PUT_COLOR:
	LD (HL), A

; going to the next char if line is not over
	INC DE
	INC HL
	DEC C
	JP NZ, WAVE_CHAR_LOOP

	DUP 7
	INC DE
	INC HL
	EDUP

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
	
	; Switching to the next color pair
	INC IY
	
	RET

SCROLL_WAVE:
	; scrolling flag tail
	LD HL, WAVE_DATA + WAVE_DATA_LENGTH - 2
	LD DE, WAVE_DATA + WAVE_DATA_LENGTH - 1
	LD A, (DE)
	LD BC, WAVE_DATA_LENGTH - 1
	LDDR
SCROLL_WAVE_END:
	; restoring first affected byte of scrolled array
	LD (DE), A
	
	; calculating flag head
	LD HL, WAVE_DATA - 1 ; last byte of head
	LD DE, WAVE_DATA

; first flag column is constant
; second flag column is in intermediate position between waving part and the constant part
INTERPOLATE_HEAD:
	LD A, (DE) ; first byte of tail
	
	CP #F0 ; center position, no additional shit is required
	JP Z, SET_HEAD_POS
	CP #71 ; center position, no additional shit is required
	JP Z, SET_HEAD_POS
	CP #E0 ; center position, no additional shit is required
	JP Z, SET_HEAD_POS

	AND #0F
	LD A, (DE) ; doing it here since this does not change any flags
	JP NZ, FLAG_WENT_DOWN:
FLAG_WENT_UP:
	SRA A
	JP SET_HEAD_POS
FLAG_WENT_DOWN:
	SLA A

SET_HEAD_POS;
	LD (HL), A
	
	RET

COLORS: DB COLOR_K, COLOR_W, COLOR_B, COLOR_R, COLOR_K
FLAG_DATA:
	DB #F0
	DB 0
WAVE_DATA:
	INCBIN "wave.png.bin"
WAVE_DATA_END:

WAVE_DATA_LENGTH EQU (WAVE_DATA_END - WAVE_DATA)

	SAVESNA "main.sna", START
