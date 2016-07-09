	device zxspectrum48
START	EQU #9c40

COLOR_W EQU #40 + 9 * #7
COLOR_B EQU #40 + 9 * #1
COLOR_R EQU #40 + 9 * #2

COLOR_K EQU 0 ; black
COLOR_FLAGSHTOK EQU 9 * #7

	ORG START
	
	di
	LD SP, #FFFF

	; black border
	XOR A
	LD (23624), A ; BORDCR <- black border

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
	LD A, (WAVE_DATA)
	AND #80
	CALL NZ, PLAY_MUSIC

; pause (HALT makes much longer delay) 
	LD BC, 700
PAUSE_LOOP:
	DEC BC
	LD A, B
	OR C
	JR NZ, PAUSE_LOOP

	CALL SCROLL_WAVE
	JR MAIN_LOOP

; Print 8 wave rows
WAVE:
	LD B, #40 ; mask

WAVE_LINE_LOOP:
	 ; filling "flag holder" column
	LD (HL), COLOR_FLAGSHTOK
	INC HL

	; painting the flag itself
	LD DE, FLAG_DATA
	LD C, 31 ; 32 minus flag holder width
WAVE_CHAR_LOOP:
	; filling last 7 columns with black since too big flag looks bad
	LD A, C
	SUB 6
	LD A, COLOR_K ; needed only if jumpin' (size optimization) 
	JP S, PUT_COLOR ; print black if columns 27..32
	
	LD A, (DE)
	AND B
	JR Z, PUT_COLOR2
	
PUT_COLOR1:
	LD A, (IY)
	JR PUT_COLOR
PUT_COLOR2:
	LD A, (IY+1)

PUT_COLOR:
	LD (HL), A

PUT_COLOR_END:
; going to the next char if line is not over
	INC DE
	INC HL
	DEC C
	JR NZ, WAVE_CHAR_LOOP

; going to the next line until all 8 rows are printed
	LD A, #FE
	SRL B
	AND B
	JR NZ, WAVE_LINE_LOOP

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
	LD DE, WAVE_DATA ; first byte of head

; first flag column is constant
; second flag column is in intermediate position between waving part and the constant part
INTERPOLATE_HEAD:
	LD A, (DE) ; first byte of tail
	
	CP #70 ; center position, no additional shit is required
	JR Z, SET_HEAD_POS

	AND #0F
	LD A, (DE) ; doing it here since this does not change any flags
	JR NZ, FLAG_WENT_DOWN:
FLAG_WENT_UP:
	SRL A
	SET 6, A ; we need 6 bit to be 1 always. Kinda SRA for 7-bit bytes
	JR SET_HEAD_POS
FLAG_WENT_DOWN:
	SLA A

SET_HEAD_POS;
	DEC DE ; DE now is first last byte of head
	LD (DE), A
	
	RET

PLAY_MUSIC:
	LD BC, (MUSIC_POS)
	XOR A
	LD D, A
	LD H, A
	LD A, (BC)
	LD L, A
	INC BC
	LD A, (BC)
	BIT 7, A
	JR Z, L1
	INC H
	AND #7F
L1	LD E, A
	PUSH BC
	call #03b5
	POP BC
	INC BC
	LD A, (BC)
	CP COLOR_K ; check that music is over and we pointing to COLORS array
	JR NZ, L2
	LD BC, MUSIC
L2:
	LD (MUSIC_POS), BC
	RET

FLAG_DATA:
	DB #F0
	DB 0
WAVE_DATA:
	INCBIN "wave.png.bin"
WAVE_DATA_END:

WAVE_DATA_LENGTH EQU (WAVE_DATA_END - WAVE_DATA)

MUSIC:
	DB #f9, #1e ; g3
	DB #b3, #29 ; c4
	DB #f9, #1e ; g3
	DB #da, #22 ; a3
	DB #bf, #27 ; b3
	DB #2e, #99 ; e3
	DB #2e, #99 ; e3 
	DB #da, #22 ; a3
	DB #f9, #1e ; g3
	DB #1b, #9b ; f3
	DB #f9, #1e ; g3
	DB #84, #94 ; c3

COLORS: DB COLOR_K, COLOR_W, COLOR_B, COLOR_R, COLOR_K

MUSIC_POS	DW MUSIC

	SAVEBIN "main.bin", START, $-START
	EMPTYTRD "main.trd"
	SAVETRD "main.trd", "flag.C", START, $-START
	SAVESNA "main.sna", START
