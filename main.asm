	device zxspectrum48
START	EQU #9c40

COLOR_W EQU #40 + 8 * #7
COLOR_B EQU #40 + 8 * #1
COLOR_R EQU #40 + 8 * #2

	ORG START
;	di
	LD SP, #FFFF
	XOR A
	OUT (#FE), A
;W
	ld hl, 16384 + 6144
	ld de, 16384 + 6144 + 1
	ld bc, 2 * 32
	ld (hl), COLOR_W
	ldir
	
	LD A, COLOR_W
	LD (WAVE_COLOR_1), A
	LD A, COLOR_B
	LD (WAVE_COLOR_2), A
	CALL WAVE
;B
	ld (hl), COLOR_B
	ld bc, 4 * 32
	ldir
	
	LD A, COLOR_B
	LD (WAVE_COLOR_1), A
	LD A, COLOR_R
	LD (WAVE_COLOR_2), A
	CALL WAVE
;R
	ld (hl), COLOR_R
	ld bc, 2 * 32 - 1
	ldir
	
	halt

	CALL SCROLL_WAVE
	JP START
	


; Print 8 wave rows
WAVE_COLOR_1 DB 0
WAVE_COLOR_2 DB 0
WAVE:
	LD IXH, #80

WAVE_LINE_LOOP:
	LD DE, WAVE_DATA
	LD C, 32
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
	OR 0
	LD IXH, A
	JP NZ, WAVE_LINE_LOOP

; all done, so restore DE to the HL + 1
	LD E, L
	LD D, H
	INC DE
	
	RET

SCROLL_WAVE:
	LD HL, WAVE_DATA + 1
	LD DE, WAVE_DATA
	LD A, (DE)
	LD BC, 63
	LDIR
	LD (DE), A
	RET

WAVE_DATA:
	INCBIN "wave.png.bin"

	SAVESNA "main.sna", START
