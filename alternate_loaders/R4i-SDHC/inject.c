#include <stdio.h>

int fsize(FILE* f)
{
	fseek(f, 0, SEEK_END);
	int size = ftell(f);
	rewind(f);
	return size;
}

void fcopy(FILE* out, FILE* in, int size)
{
	unsigned char c;
	int i;
	for(i = 0; i < size; i ++)
	{
		fread(&c, 1, 1, in);
		fwrite(&c, 1, 1, out);
	}
}

void copysec(FILE* out, FILE* in)
{
	char buf[512-6];
	fseek(out, 6, SEEK_CUR);
	fread(buf, 1, 512-6, in);
	fwrite(buf, 1, 512-6, out);
}

int main()
{
	printf("Hello World!\n");

	FILE* dat = fopen("R4.dat", "rb+");
	FILE* arm7 = fopen("loadarm7.bin", "rb");
	FILE* arm9 = fopen("loadarm9.bin", "rb");
	FILE* loader = fopen("bootload.bin", "rb");

	int ld_arm7 = fsize(arm7) - 8;
	int ld_arm9 = fsize(arm9) - 8;

	// ARM7
	fseek(dat, 436224+8, SEEK_SET);
	fseek(arm7, 8, SEEK_SET);
	fcopy(dat, arm7, ld_arm7);
	fclose(arm7);

	// ARM9
	fseek(dat, 512+8, SEEK_SET);
	fseek(arm9, 8, SEEK_SET);
	fcopy(dat, arm9, ld_arm9);
	fclose(arm9);

	// Loader
	fseek(dat, 512+512, SEEK_SET);
	int i;
	for(i = 0; i < 77; i ++)
		copysec(dat, loader);

	fclose(loader);
	fclose(dat);


	return 0;
}
