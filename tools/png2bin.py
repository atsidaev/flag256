import sys
import png
import struct

r=png.Reader(file=open(sys.argv[1]))
pixels = list(r.read()[2])

if len(pixels) != 8:
	raise Error("Should be 8 rows, but found " + len(pixels))

wave_data = []

width = 48

for i in range(0, width):
	b = ""
	for j in range(0, 8):
		b += "1" if pixels[j][i] != 0 else "0"
	bt = int(b, 2) & 0x7F
	if i%(width / 4) == 0:
		bt = bt | 0x80
	wave_data.append(bt)

newFile = open(sys.argv[1] + ".bin", "wb")
newFile.write(struct.pack(str(width) + 'B', *wave_data))
