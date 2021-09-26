.arch armv5te
.global	_start

_start:
	@ Placeholder instructions
	.word 0
	.word 0
	
	b _main
	start_addr: .word 0x02000200
	num_sect:   .word 77
	
_main:
	@ Disable interrupts
	mov r0, #0x04000000
	str r0, [r0, #0x208]
	
	@ Disable PU
	ldr r1, =0x00002078
	mcr p15, 0, r1, c1, c0
	
	@ Disable caches
	mov	r1, #0
	mcr p15, 0, r1, c7, c5, 0
	mcr p15, 0, r1, c7, c6, 0
	mcr p15, 0, r1, c3, c0, 0
	
	/*
	@ Paint a screen red
	mov r1, #(1<<16)
	str r1, [r0]
	mov r1, #0x1F
	mov r2, #0x05000000
	strh r1, [r2]
	*/

	@ Open VRAM_C
	orr r0, r0, #0x240
	mov r1, #0x80
	strb r1, [r0, #2]
	
	@ Load address of VRAM_C
	mov r3, #0x06800000
	orr r3, r3, #0x40000
	
	@ Load start RAM address and number of sections
	ldr r0, start_addr
	ldr r1, num_sect
	
	@ Copy loop
copy_loop:
	@ Increment the source pointer by 6
	add r0, r0, #6
	
	@ We now have to copy 253 halfwords
	mov r2, #253
	
	@ Section copy loop
sect_copy_loop:
	@ Load and store one halfword and increment pointers
	ldrh r4, [r0], #2
	strh r4, [r3], #2
	@ Loop if we're not done yet
	subs r2, r2, #1
	bne sect_copy_loop
	
	@ Ok, the section copy is over
	@ Loop if we're not done yet
	subs r1, r1, #1
	bne copy_loop
	
	@ Copy to VRAM_C is over
	@ Give card permissions to the ARM7
	mov r0, #0x04000000
	ldr r1, [r0, #0x204]
	orr r1, r1, #0x0880
	str r1, [r0, #0x204]
	
	@ Write to the NDS header
	ldr r1, writetable+0
	ldr r2, writetable+4
	str r2, [r1]
	ldr r1, writetable+8
	ldr r2, writetable+12
	str r2, [r1]
	ldr r1, writetable+16
	ldr r2, writetable+20
	str r2, [r1]
	
	@ Give VRAM_C to the ARM7
	orr r0, r0, #0x240
	mov r1, #0x82
	strb r1, [r0, #2]
	
	@ Soft reset
	@swi 0x000000
	bx r2
	
	writetable:
	.word 0x02FFFFFC, 0
	.word 0x02FFFE04, 0xE59FF018
	.word 0x02FFFE24, 0x02FFFE04
