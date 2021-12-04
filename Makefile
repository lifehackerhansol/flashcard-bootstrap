#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

export TARGET		:=	booter
export TOPDIR		:=	$(CURDIR)
export DATA			:=	data


BINFILES	:=	load.bin


export OFILES	:=	$(addsuffix .o,$(BINFILES)) \
					$(PNGFILES:.png=.o) \
					$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)

.PHONY: checkarm7 checkarm9 bootloader bootstub dist

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
all: $(TARGET).nds _DS_MENU.DAT ismat.dat ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS ACEP/_DS_MENU.DAT R4iLS/_DSMENU.DAT Gateway/_DSMENU.DAT r4ids.cn/_DS_MENU.DAT menu.xx

dist: $(TARGET).nds _DS_MENU.DAT ismat.dat ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS ACEP/_DS_MENU.DAT R4iLS/_DSMENU.DAT Gateway/_DSMENU.DAT r4ids.cn/_DS_MENU.DAT menu.xx
	@mkdir -p bootstrap
	@cp -r _DS_MENU.dat ismat.dat ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS ACEP R4iLS Gateway r4ids.cn bootstrap
	@mkdir -p bootstrap/M3DSR/SYSTEM
	@cp -r resource/M3DSR/* bootstrap/M3DSR/SYSTEM/
	@cp menu.xx bootstrap/M3DSR/SYSTEM
	@cd bootstrap && zip -r bootstrap.zip *
	@mv bootstrap/bootstrap.zip $(TOPDIR)

_DS_MENU.DAT	:	$(TARGET).nds
	@dlditool "DLDI/R4TF_DLDI_v2_recompiled_(TY).dldi" $<
	@r4denc $< $@

ez5sys.bin	:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/EZ5V2.dldi $@

akmenu4.nds	:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/ak2_sd.dldi $@

TTMENU.DAT	:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/DSTTDLDIboyakkeyver.dldi $@

_BOOT_MP.NDS	:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/mpcf.dldi $@

ismat.dat	:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/mati.dldi $@

ACEP/_DS_MENU.DAT	:	$(TARGET).nds
	@[ -d ACEP ] || mkdir -p ACEP
	@dlditool DLDI/EX4DS_R4iLS.dldi $<
	@r4denc --key 0x4002 $< $@

r4ids.cn/_DS_MENU.DAT	:	$(TARGET).nds
	@[ -d r4ids.cn ] || mkdir -p r4ids.cn
	@cp $(TARGET)_r4ids.cn.nds $@
	@dlditool DLDI/r4idsn_sd.dldi $@

R4iLS/_DSMENU.DAT	:	$(TARGET).nds
	@[ -d R4iLS ] || mkdir -p R4iLS
	@ndstool -h 0x200 -g "XXXX" "XX" "R4XX" -c R4iLS/_DSMENU.nds -7 $(TARGET).arm7.elf -9 $(TARGET).arm9.elf
	@dlditool DLDI/EX4DS_R4iLS.dldi R4iLS/_DSMENU.nds
	@r4denc --key 0x4002 R4iLS/_DSMENU.nds $@
	@rm -rf R4iLS/_DSMENU.nds
	
Gateway/_DSMENU.DAT	:	$(TARGET).nds
	@[ -d Gateway ] || mkdir -p Gateway
	@dlditool DLDI/EX4DS_R4iLS.dldi $<
	@ndstool -h 0x200 -g "XXXX" "XX" "R4IT" -c Gateway/_DSMENU.nds -7 $(TARGET).arm7.elf -9 $(TARGET).arm9.elf
	@r4denc --key 0x4002 Gateway/_DSMENU.nds $@
	@rm Gateway/_DSMENU.nds
	
menu.xx	:	$(TARGET).nds
	@cp $< BOOTSTRAP_M3.nds
	@dlditool "DLDI/M3-DS_(SD_Card).dldi" BOOTSTRAP_M3.nds
	@./tools/dsbize/dsbize BOOTSTRAP_M3.nds $@ 0x12
	@rm BOOTSTRAP_M3.nds

#---------------------------------------------------------------------------------
$(TARGET).nds	:	$(TARGET).arm7.elf $(TARGET).arm9.elf $(TARGET).arm9_r4ids.cn.elf
	ndstool	-h 0x200 -c $(TARGET).nds -7 $(TARGET).arm7.elf -9 $(TARGET).arm9.elf
	ndstool	-h 0x200 -c $(TARGET)_r4ids.cn.nds -7 $(TARGET).arm7.elf -9 $(TARGET)_r4ids.cn.arm9.elf

data:
	@mkdir -p $@

bootloader: data
	@$(MAKE) -C bootloader LOADBIN=$(CURDIR)/data/load.bin

bootstub: data
	@$(MAKE) -C bootstub

#---------------------------------------------------------------------------------
$(TARGET).arm7.elf:
	$(MAKE) -C arm7
	
#---------------------------------------------------------------------------------
$(TARGET).arm9.elf: bootloader bootstub
	$(MAKE) -C arm9

$(TARGET).arm9_r4ids.cn.elf: bootloader bootstub
	$(MAKE) -C arm9_r4ids.cn
	cp arm9_r4ids.cn/booter.elf booter_r4ids.cn.arm9.elf

#---------------------------------------------------------------------------------
clean:
	$(MAKE) -C arm9 clean
	$(MAKE) -C arm9_r4ids.cn clean
	$(MAKE) -C arm7 clean
	$(MAKE) -C bootloader clean
	$(MAKE) -C bootstub clean
	rm -rf $(TARGET).nds $(TARGET).arm7.elf $(TARGET).arm9.elf _DS_MENU.DAT ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS ACEP R4iLS Gateway r4ids.cn ismat.dat _DS_MENU_ULTRA.DAT menu.xx
	rm -rf data bootstrap bootstrap.zip

