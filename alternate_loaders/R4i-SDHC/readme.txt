R4i Christmas hbmenu bootstub v1.0
==================================

This hack is copyleft (>) 2010 fincs.
This hack contains the hbmenu bootloader which is under
 the GPLv2 (see source/bootloader/COPYING for information).

1. Contents of the package
--------------------------

R4.dat       - Main hbmenu loader payload
_DS_MENU.DAT - Stripped down mystery file (it previously contained
               code ripped off commercial ROMs that wasn't even read)
_BOOT_DS.NDS - HomebrewMenu (from devkitPro.org)
ttio.dldi    - TTDSi DLDI driver (this card is based on it)

Source structure:

source/bootloader   - hbmenu bootloader (see top for copyright)
source/loadarm7     - ARM7 payload source code
source/loadarm9     - ARM9 payload source code
source/bootload.bin - precompiled hbmenu bootloader
source/inject.c     - payload injector source code
source/inject.exe   - precompiled payload injector for Windows
source/R4.dat       - original R4i menu file (make a backup of it!)

2. How to use
-------------

- Format the SD card.
- Copy the _DS_MENU.DAT and R4.dat files to the SD card.
- Get the latest hbmenu and copy the _BOOT_DS.NDS file to the SD card.
   Alternatively you can use the provided one.
- Place some homebrew applications in the SD card.
- Enjoy your piracy-free R4i knockoff!

3. DLDI
-------

This card is based on the TTDSi hardware.
If you ever need a DLDI driver for this card you can use
the standard TTDS DLDI driver (provided in this package).

4. How to build from source
---------------------------

- Build source/loadarm9 and source/loadarm7.
- Run inject.exe (don't forget to backup R4.dat!)
- That's it.

4.1 Bootloader
--------------

If you ever need to edit the bootloader you also have
to perform the following additional steps:

- DLDI patch the bootloader using ttio.dldi.
- Divide its size in bytes by 506, ceil it and write it down.
- Edit inject.c line 55 and recompile:
  for(i = 0; i < PLACENUMBERHERE; i ++)
- Edit loadarm9.s line 11 and rebuild:
  num_sect: .word PLACENUMBERHERE

5.0 Todo list
-------------

- Make this hack compatible with DS phat/DS lite
- Figure out _DS_MENU.DAT
- Get rid of R4.dat alltogether
