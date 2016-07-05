	device zxspectrum48
START	EQU #9c40

	ORG START
	XOR A
	OUT (#FE), A
;W
	ld hl, 16384 + 6144
	ld de, 16384 + 6144 + 1
	ld bc, 192
	ld (hl), #40 + 8 * #7
	ldir
;B
	ld (hl), #40 + 8 * #1
	ld bc, 384
	ldir
;R
	ld (hl), #40 + 8 * #2
	ld bc, 191
	ldir
	
	di
	halt

	SAVESNA "main.sna", START
