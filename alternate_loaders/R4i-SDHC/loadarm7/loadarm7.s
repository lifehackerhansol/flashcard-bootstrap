.arch armv4t
.global	_start

_start:
	@ Placeholder instructions
	.word 0
	.word 0
	
	@ Disable interrupts
	mov r0, #0x04000000
	str r0, [r0, #0x208]
	
chkloop1:
	@ Loop until we don't have access to VRAM_C
	ldrb r1, [r0, #0x240]
	ands r1, r1, #1
	bne chkloop1

chkloop2:
	@ Loop until we have access to VRAM_C
	ldrb r1, [r0, #0x240]
	ands r1, r1, #1
	beq chkloop2

	@ Jump to VRAM
	ldr r0, vram_ptr
	bx r0

vram_ptr:
	.word 0x06000000
