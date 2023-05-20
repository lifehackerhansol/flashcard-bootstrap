/*
	flashcard-bootstrap
	By lifehackerhansol

	SPDX-License-Identifier: 0BSD
*/

#include <nds.h>

void VblankHandler(void) {
}

int main(void) {
	ledBlink(0);

	irqInit();
	fifoInit();
	installSystemFIFO();
	irqSet(IRQ_VBLANK, VblankHandler);
	irqEnable(IRQ_VBLANK);

	while(1) {
		swiWaitForVBlank();

		if(fifoCheckValue32(FIFO_USER_01)) {
			fifoGetValue32(FIFO_USER_01);
			break;
		}
	}
	return 0;
}