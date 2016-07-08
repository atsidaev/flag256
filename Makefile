main.sna: main.asm wave.png.bin
	c:\\zx\\sjasm\\sjasmplus.exe main.asm

wave.png.bin: wave.png
	python tools/png2bin.py $<
