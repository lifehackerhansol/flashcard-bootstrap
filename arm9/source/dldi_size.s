@
@	flashcard-bootstrap
@	By lifehackerhansol
@
@	SPDX-License-Identifier: 0BSD
@

@ Use 32KB DLDI space, needed for legacy homebrew

.global __dldi_size
.equ __dldi_size, 32768
