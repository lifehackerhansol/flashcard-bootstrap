#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

export TARGET		:=	bootstrap
export TOPDIR		:=	$(CURDIR)


.PHONY: checkarm7 checkarm9

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
all: checkarm7 checkarm9 _DS_MENU.DAT ismat.dat ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS ACEP/_DS_MENU.DAT R4iLS/_DSMENU.DAT Gateway/_DSMENU.DAT menu.xx

_DS_MENU.DAT	:	$(TARGET).nds DLDI/r4tfv2.dldi
	@dlditool DLDI/r4tfv2.dldi $<
	@r4denc $< $@

ez5sys.bin	:	$(TARGET).nds DLDI/EZ5V2.dldi
	@cp $< $@
	@dlditool DLDI/EZ5V2.dldi $@

akmenu4.nds	:	$(TARGET).nds  DLDI/ak2_sd.dldi
	@cp $< $@
	@dlditool DLDI/ak2_sd.dldi $@

TTMENU.DAT	:	$(TARGET).nds  DLDI/DSTTDLDIboyakkeyver.dldi
	@cp $< $@
	@dlditool DLDI/DSTTDLDIboyakkeyver.dldi $@

_BOOT_MP.NDS	:	$(TARGET).nds DLDI/mpcf.dldi
	@cp $< $@
	@dlditool DLDI/mpcf.dldi $@

ismat.dat	:	$(TARGET).nds DLDI/mati.dldi
	@cp $< $@
	@dlditool DLDI/mati.dldi $@

ACEP/_DS_MENU.DAT	:	$(TARGET).nds DLDI/EX4DS_R4iLS.dldi
	@[ -d ACEP ] || mkdir -p ACEP
	@dlditool DLDI/EX4DS_R4iLS.dldi $<
	@r4denc --key 0x4002 $< $@
	
R4iLS/_DSMENU.DAT	:	$(TARGET).nds DLDI/EX4DS_R4iLS.dldi
	@[ -d R4iLS ] || mkdir -p R4iLS
	@dlditool DLDI/EX4DS_R4iLS.dldi $<
	@ndstool -x $< -9 arm9.bin -7 arm7.bin -t banner.bin
	@cp ../resource/r4isdhc.com.cn_header.bin header.bin
	@ndstool -c $< -9 arm9.bin -7 arm7.bin -t banner.bin -h header.bin
	@r4denc --key 0x4002 $< $@
	@rm arm9.bin arm7.bin banner.bin header.bin
	
Gateway/_DSMENU.DAT	:	$(TARGET).nds DLDI/EX4DS_R4iLS.dldi
	@[ -d Gateway ] || mkdir -p Gateway
	@dlditool DLDI/EX4DS_R4iLS.dldi $<
	@ndstool -x $< -9 arm9.bin -7 arm7.bin -t banner.bin
	@cp ../resource/Gateway_Blue_header.bin header.bin
	@ndstool -c $< -9 arm9.bin -7 arm7.bin -t banner.bin -h header.bin
	@r4denc --key 0x4002 $< $@
	@rm arm9.bin arm7.bin banner.bin header.bin
	
menu.xx	:	$(TARGET).nds DLDI/M3DSReal.dldi
	@cp $< BOOTSTRAP_M3.nds
	@dlditool DLDI/M3DSReal.dldi BOOTSTRAP_M3.nds
	@../tools/dsbize BOOTSTRAP_M3.nds $@ 0x12
	@rm BOOTSTRAP_M3.nds

# _DS_MENU_ULTRA.DAT	:	$(TARGET).nds r4ultra.dldi
#	@cp $< $@
#	@dlditool DLDI/r4ultra.dldi $@

#---------------------------------------------------------------------------------
$(TARGET).nds	:	$(TARGET).arm7.elf $(TARGET).arm9.elf
	ndstool	-h 0x200 -c $(TARGET).nds -7 $(TARGET).arm7.elf -9 $(TARGET).arm9.elf

checkarm7:
	$(MAKE) -C arm7

checkarm9:
	$(MAKE) -C arm9

#---------------------------------------------------------------------------------
$(TARGET).arm7.elf:
	$(MAKE) -C arm7
	
#---------------------------------------------------------------------------------
$(TARGET).arm9.elf:
	$(MAKE) -C arm9


#---------------------------------------------------------------------------------
clean:
	$(MAKE) -C arm9 clean
	$(MAKE) -C arm7 clean
	rm -rf $(TARGET).nds $(TARGET).arm7.elf $(TARGET).arm9.elf _DS_MENU.DAT ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS ACEP R4iLS Gateway ismat.dat _DS_MENU_ULTRA.DAT menu.xx 
	rm -f $(TARGET).arm9i.elf

