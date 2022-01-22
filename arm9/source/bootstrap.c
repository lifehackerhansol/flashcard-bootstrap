/*-----------------------------------------------------------------

 Copyright (C) 2010  Dave "WinterMute" Murphy

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

------------------------------------------------------------------*/

#include <nds.h>
#include <nds/arm9/dldi.h>
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
	if(io_dldi_data->driverSize > 0xE) return fail("DLDI driver too large.\nPlease update your kernel.");
	int err = runNdsFile("/BOOT.nds", 0, NULL);
	char* message = "Error code: ";
	sprintf(message, message, err);
	return fail(message);
}
