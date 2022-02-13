// CC0 public domain, by lifehackerhansol

#include <nds.h>
#include <fat.h>

#include <stdio.h>

#include "nds_loader_arm9.h"

int fail(char* error){
	consoleDemoInit();
	iprintf("Bootstrap fail:\n");
	iprintf("%s\n\n", error);
	iprintf("Press START to power off.");
	while(1) {
		swiWaitForVBlank();
		scanKeys();
		int pressed = keysDown();
		if(pressed & KEY_START) break;
	}
	return 0;
}

int main(void) {
	if (!fatInitDefault()) return fail("FAT init failed!\n");
	int err = runNdsFile("/BOOT.nds", 0, NULL);
	char message[128];
	sprintf(message, "Error code: %d", err);
	return fail(message);
}
