import sys
import png
import struct

r=png.Reader(file=open(sys.argv[1]))
pixels = list(r.read()[2])

if len(pixels) != 8:
	raise Error("Should be 8 rows, but found " + len(pixels))

wave_data = []

for i in range(0, 64):
	b = ""
	for j in range(0, 8):
		b += "1" if pixels[j][i] != 0 else "0"
	wave_data.append(b)

#newFile = open(sys.argv[1] + ".bin", "wb")
#newFile.write(struct.pack('64B', *wave_data))
print wave_data
