@
@	flashcard-bootstrap
@	By lifehackerhansol
@
@	SPDX-License-Identifier: 0BSD
@

@ Needed patches before the init section to workaround R4i-SDHC's weird loading scheme

    .syntax  unified
    .align  4
    .arm
    .section .r4i_sdhc_pad, "ax"

    b 0x2000450
    .space 0xEC - 0x04

    bl 0x2000218
    .space 0x450 - 0xF0

    .end
