# SPDX-License-Identifier: CC0-1.0
#
# SPDX-FileContributor: Antonio Niño Díaz, 2023

BLOCKSDS	?= /opt/blocksds/core
BLOCKSDSEXT	?= /opt/blocksds/external

export TOPDIR := $(shell pwd $(CURDIR))

ifneq (,$(shell which python3))
PYTHON	:= python3
else ifneq (,$(shell which python2))
PYTHON	:= python2
else ifneq (,$(shell which python))
PYTHON	:= python
else
$(error "Python not found in PATH, please install it.")
endif

# User config
# ===========

NAME		:= bootstrap

GAME_TITLE	:= flashcard-bootstrap
GAME_SUBTITLE	:= kernel replacement project
GAME_AUTHOR	:= lifehackerhansol
GAME_ICON	:= icon.bmp

# DLDI and internal SD slot of DSi
# --------------------------------

# Root folder of the SD image
SDROOT		:= sdroot
# Name of the generated image it "DSi-1.sd" for no$gba in DSi mode
SDIMAGE		:= image.bin

# Source code paths
# -----------------

NITROFSDIR	:= # A single directory that is the root of NitroFS

# Tools
# -----

MAKE		:= make
RM		:= rm -rf

# Verbose flag
# ------------

ifeq ($(VERBOSE),1)
V		:=
else
V		:= @
endif

# Directories
# -----------

ARM9DIR		:= arm9
ARM7DIR		:= arm7
DATA		:= $(CURDIR)/data

# Build artfacts
# --------------

ROM		:= $(NAME).nds

ROM_R4ILS		:= $(NAME)_r4ils.nds
ROM_GATEWAY		:= $(NAME)_gateway.nds
ROM_DSONE		:= $(NAME)_dsone.nds
ROM_02000000		:= $(NAME)_02000000.nds
ROM_02000450		:= $(NAME)_02000450.nds
ROM_02000800		:= $(NAME)_02000800.nds

# Targets
# -------

.PHONY: all clean dist arm9 arm7 dldipatch sdimage

all: $(ROM) \
			_ds_menu.dat \
			N5/_ds_menu.dat \
			ez5sys.bin \
			_boot_mp.nds \
			bootme.nds \
			r4i.sys \
			ismat.dat \
			_ds_menu.nds \
			ez5isys.bin \
			ACEP/_ds_menu.dat \
			akmenu4.nds \
			ttmenu.dat \
			r4.dat \
			_dsmenu.dat \
			dsedgei.dat \
			MAZE/_ds_menu.dat \
			r4ids.cn/_ds_menu.dat \
			R4iLS/_dsmenu.dat \
			Gateway/_dsmenu.dat \
			G003/g003menu.eng \
			DSOneSDHC_DSOnei/ttmenu.dat \
			scfw.sc

clean:
	@echo "  CLEAN"
	$(V)$(MAKE) -C arm9 clean --no-print-directory
	$(V)$(MAKE) -C arm9_crt0set clean --no-print-directory
	$(V)$(MAKE) -C arm9_r4ids.cn clean --no-print-directory
	$(V)$(MAKE) -f Makefile.arm7 clean --no-print-directory
	$(V)$(RM) $(ROM) $(ROM_02000000) $(ROM_02000450) $(ROM_02000800) $(ROM_DSONE) $(ROM_R4ILS) $(ROM_GATEWAY) build $(SDIMAGE) $(DATA)
	$(V)$(RM) bootstrap  bootstrap.zip \
			_ds_menu.dat N5 ez5sys.bin _boot_mp.nds bootme.nds r4i.sys ismat.dat _ds_menu.nds ez5isys.bin ACEP akmenu4.nds \
			ttmenu.dat r4.dat _dsmenu.dat dsedgei.dat MAZE r4ids.cn R4iLS Gateway G003 DSOneSDHC_DSOnei scfw.sc

arm9:
	$(V)+$(MAKE) -C arm9 --no-print-directory

arm9_02000000:
	$(V)+$(MAKE) -C arm9_crt0set --no-print-directory CRT0=0x02000000

arm9_02000450:
	$(V)+$(MAKE) -C arm9_crt0set --no-print-directory CRT0=0x02000450

arm9_02000800:
	$(V)+$(MAKE) -C arm9_r4ids.cn --no-print-directory

arm7:
	$(V)+$(MAKE) -f Makefile.arm7 --no-print-directory

ifneq ($(strip $(NITROFSDIR)),)
# Additional arguments for ndstool
NDSTOOL_ARGS	:= -d $(NITROFSDIR)

# Make the NDS ROM depend on the filesystem only if it is needed
$(ROM): $(NITROFSDIR)
endif

# Combine the title strings
ifeq ($(strip $(GAME_SUBTITLE)),)
    GAME_FULL_TITLE := $(GAME_TITLE);$(GAME_AUTHOR)
else
    GAME_FULL_TITLE := $(GAME_TITLE);$(GAME_SUBTITLE);$(GAME_AUTHOR)
endif

$(ROM): arm9 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-h 0x200 \
		-7 build/arm7.elf -9 arm9/build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_FULL_TITLE)" \
		$(NDSTOOL_FAT)

$(ROM_GATEWAY): arm9 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-h 0x200 -g "####" "##" "R4IT" \
		-7 build/arm7.elf -9 arm9/build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_FULL_TITLE)" \
		$(NDSTOOL_FAT)

$(ROM_R4ILS): arm9 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-h 0x200 -g "####" "##" "R4XX" \
		-7 build/arm7.elf -9 arm9/build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_FULL_TITLE)" \
		$(NDSTOOL_FAT)

$(ROM_DSONE): arm9 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-h 0x200 -g "ENG0" \
		-7 build/arm7.elf -9 arm9/build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_FULL_TITLE)" \
		$(NDSTOOL_FAT)

$(ROM_02000000): arm9_02000000 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-h 0x200 \
		-7 build/arm7.elf -9 arm9_crt0set/build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_FULL_TITLE)" \
		$(NDSTOOL_FAT)
	$(V)+$(MAKE) -C arm9_crt0set clean

$(ROM_02000450): arm9_02000450 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-h 0x200 \
		-7 build/arm7.elf -9 arm9_crt0set/build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_FULL_TITLE)" \
		$(NDSTOOL_FAT)
	$(V)+$(MAKE) -C arm9_crt0set clean

$(ROM_02000800): arm9_02000800 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-h 0x200 \
		-7 build/arm7.elf -9 arm9_r4ids.cn/build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_FULL_TITLE)" \
		$(NDSTOOL_FAT)
	$(V)+$(MAKE) -C arm9_crt0set clean

sdimage:
	@echo "  MKFATIMG $(SDIMAGE) $(SDROOT)"
	$(V)$(BLOCKSDS)/tools/mkfatimg/mkfatimg -t $(SDROOT) $(SDIMAGE)

dldipatch: $(ROM)
	@echo "  DLDIPATCH $(ROM)"
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch \
		$(BLOCKSDS)/sys/dldi_r4/r4tf.dldi $(ROM)

dist	:	all
	@mkdir -p bootstrap/M3R_iTDS_R4RTS/_system_/_sys_data
	@mkdir -p bootstrap/DSOneSDHC_DSOnei
	@mkdir -p bootstrap/N5
	@mkdir -p bootstrap/G003/system
	@cp -r README.md _ds_menu.dat ez5sys.bin ttmenu.dat r4.dat _boot_mp.nds bootme.nds ismat.dat _ds_menu.nds ez5isys.bin akmenu4.nds _dsmenu.dat dsedgei.dat scfw.sc bootstrap
	@cp -r MAZE ACEP R4iLS Gateway r4ids.cn bootstrap 
	@cp -r resource/M3R_iTDS_R4RTS/* bootstrap/M3R_iTDS_R4RTS/
	@cp -r resource/DSOneSDHC_DSOnei/* bootstrap/DSOneSDHC_DSOnei/
	@cp resource/N5/_ax_menu.dat bootstrap/N5/_ax_menu.dat
	@cp -r resource/G003/* bootstrap/G003/system
	@cp G003/g003menu.eng bootstrap/G003/system
	@cp -r DSOneSDHC_DSOnei/* bootstrap/DSOneSDHC_DSOnei/
	@cp r4i.sys bootstrap/M3R_iTDS_R4RTS/_system_/_sys_data/r4i.sys
	@cp N5/_ds_menu.dat bootstrap/N5/_ds_menu.dat
	
	@cd bootstrap && zip -r bootstrap.zip *
	@mv bootstrap/bootstrap.zip $(TOPDIR)

_ds_menu.dat:	$(ROM)
	@echo "Make original R4"
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch "DLDI/r4tfv3.dldi" $<
	@./resource/r4denc/r4denc $< $@

N5/_ds_menu.dat:	$(ROM)
	@echo "Make N5"
	@[ -d N5 ] || mkdir -p "N5"
	@cp $< $@

ez5sys.bin:	$(ROM)
	@echo "Make EZ-Flash V"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ez5h.dldi $@

_boot_mp.nds:	$(ROM)
	@echo "Make GBAMP"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/mpcf.dldi $@

r4i.sys	:	$(ROM)
	@echo "Make M3R_iTDS_R4RTS"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch "DLDI/m3ds.dldi" $@

ismat.dat:	$(ROM)
	@echo "Make iSmart Premium"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/mati.dldi $@

_ds_menu.nds:	ismat.dat
	@echo "Make r4i.cn"
	@cp $< $@

ez5isys.bin:	ismat.dat
	@echo "Make EZ-Flash Vi"
	@cp $< $@

bootme.nds: $(ROM)
	@echo "Make Games n Music"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/gmtf.dldi $<

ACEP/_ds_menu.dat:	$(ROM)
	@echo "Make Ace3DS+"
	@[ -d ACEP ] || mkdir -p ACEP
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ace3ds_sd.dldi $<
	@./resource/r4denc/r4denc --key 0x4002 $< $@

scfw.sc:	$(ROM_DSONE)
	@echo "Make SuperCard DSONE"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/scds3.dldi $<

akmenu4.nds:	$(ROM_02000450)
	@echo "Make AK2"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ak2_sd.dldi $@

ttmenu.dat:		$(ROM_02000450)
	@echo "Make DSTT"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ttio_sdhc.dldi $@

DSOneSDHC_DSOnei/ttmenu.dat:	$(ROM_02000450)
	@echo "Make DSONE SDHC"
	@[ -d DSOneSDHC_DSOnei ] || mkdir -p DSOneSDHC_DSOnei
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/scdssdhc2.dldi $@

# Hack TTMenu.dat to bypass signature checks
r4.dat: 	ttmenu.dat
	@echo "Make R4i-SDHC"
	@ndstool -x $< -9 arm9.bin -7 arm7.bin -t banner.bin -h header.bin
	@$(PYTHON) resource/r4isdhc/r4isdhc.py arm9.bin new9.bin
	@ndstool -c $@ -9 new9.bin -7 arm7.bin -t banner.bin -h header.bin -r9 0x02000000
	@rm -rf arm9.bin new9.bin arm7.bin banner.bin header.bin

_dsmenu.dat:	$(ROM_02000000)
	@echo "Make R4iDSN"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/r4idsn_sd.dldi $@

dsedgei.dat:	$(ROM_02000800)
	@echo "Make EDGEi"
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ak2_sd.dldi $@

MAZE/_ds_menu.dat:	$(ROM_02000000)
	@echo "Make Amaze3DS/R4igold.cc Wood"
	@[ -d MAZE ] || mkdir -p MAZE
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ak2_sd.dldi $@

r4ids.cn/_ds_menu.dat:	$(ROM_02000800)
	@echo "Make r4ids.cn"
	@[ -d r4ids.cn ] || mkdir -p r4ids.cn
	@cp $< $@
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ak2_sd.dldi $@

R4iLS/_dsmenu.dat:	$(ROM_R4ILS)
	@echo "Make R4iLS"
	@[ -d R4iLS ] || mkdir -p R4iLS
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ace3ds_sd.dldi $<
	@./resource/r4denc/r4denc --key 0x4002 $< $@

Gateway/_dsmenu.dat:	$(ROM_GATEWAY)
	@echo "Make GW"
	@[ -d Gateway ] || mkdir -p Gateway
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/ace3ds_sd.dldi $<
	@./resource/r4denc/r4denc --key 0x4002 $< $@

G003/g003menu.eng:	$(ROM_02000000)
	@echo "Make GMP-Z003"
	@[ -d G003 ] || mkdir -p G003
	$(V)$(BLOCKSDS)/tools/dldipatch/dldipatch patch DLDI/g003.dldi $<
	@./resource/dsbize/dsbize $< $@ 0x12
