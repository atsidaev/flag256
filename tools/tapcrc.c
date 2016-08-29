#include <stdio.h>
#include <stdlib.h>

void main()
{
	FILE* f1 = fopen("main.bin", "rb");
	unsigned char checksum = 0;
	unsigned char buf2[1];
	
	char* xor = "0123456789";
	int i = 0;
	while (fread(buf2, 1, 1, f1) == 1)
		checksum ^= buf2[0] ^ xor[i++ % 10];

	printf("Checksum byte will be xored with %02X\n", checksum);

	FILE* f2 = fopen("flag.tap", "r+b");
	fseek(f2, -1, SEEK_END);
	if (fread(buf2, 1, 1, f2) != 1)
	{
		printf("Could not read checksum byte\n");
		exit(1);
	}
	
	buf2[0] ^= checksum;
	printf("Checksum byte is %02X\n", buf2[0]);
	
	fseek(f2, -1, SEEK_END);
	if (fwrite(buf2, 1, 1, f2) != 1)
	{
		printf("Could not write checksum byte\n");
		exit(1);
	}
	
	exit(0);
}
