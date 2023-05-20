/*
	flashcard-bootstrap
	By lifehackerhansol

	SPDX-License-Identifier: 0BSD
*/

#include <nds.h>
#include <fat.h>
#include <nds/arm9/dldi.h>

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
	fifoSendValue32(FIFO_USER_01, 1); // turn off ARM7
	return 0;
}

int main(void) {
	if (!fatInitDefault()) return fail("FAT init failed!\n");
	if(io_dldi_data->driverSize > 0xE) return fail("DLDI driver too large!\nPlease update your kernel.");
	int err = runNdsFile("/BOOT.nds", 0, NULL);
	char message[20];
	sprintf(message, "Error code: %d", err);
	return fail(message);
}
