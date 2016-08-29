all: flag.tap

main.sna: main.asm wave.png.bin
	c:\\zx\\sjasm\\sjasmplus.exe main.asm

wave.png.bin: wave.png
	python tools/png2bin.py $<

flag.tap: monoloader.bas main.sna main.bin tools/tapcrc
	zmakebas -nFLAG -a 10 -o $@ $<
	dd conv=notrunc if=main.bin of=$@ bs=1 seek=29 count=256 
	tools/tapcrc
