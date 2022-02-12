#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

export TARGET		:=	booter
export TOPDIR		:=	$(CURDIR)
export DATA			:=	$(TOPDIR)/data

BINFILES	:=	load.bin

export OFILES	:=	$(addsuffix .o,$(BINFILES)) \
					$(PNGFILES:.png=.o) \
					$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)

.PHONY: checkarm7 checkarm9 bootloader bootstub dist

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
all		:	$(TARGET).nds _DS_MENU.DAT ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS r4i.sys ismat.dat ACEP/_DS_MENU.DAT R4iLS/_DSMENU.DAT Gateway/_DSMENU.DAT r4ids.cn/_DS_MENU.DAT MAZE/_DS_MENU.DAT

dist	:	$(TARGET).nds _DS_MENU.DAT ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS r4i.sys ismat.dat ACEP/_DS_MENU.DAT R4iLS/_DSMENU.DAT Gateway/_DSMENU.DAT r4ids.cn/_DS_MENU.DAT MAZE/_DS_MENU.DAT
	@mkdir -p bootstrap/M3R_iTDS_R4RTS/_system_/_sys_data
	@cp -r _DS_MENU.dat ismat.dat ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS ACEP R4iLS Gateway r4ids.cn bootstrap
	@cp -r resource/M3R_iTDS_R4RTS/* bootstrap/M3R_iTDS_R4RTS/
	@cp r4i.sys bootstrap/M3R_iTDS_R4RTS/_system_/_sys_data/r4i.sys
	
	@cd bootstrap && zip -r bootstrap.zip *
	@mv bootstrap/bootstrap.zip $(TOPDIR)

_DS_MENU.DAT:	$(TARGET).nds
	@dlditool "DLDI/m3r4_r4tf.dldi" $<
	@r4denc $< $@

ez5sys.bin:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/EZ5V2.dldi $@

akmenu4.nds:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/ak2_sd.dldi $@

TTMENU.DAT:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/DSTTDLDIboyakkeyver.dldi $@

_BOOT_MP.NDS:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/mpcf.dldi $@

r4i.sys	:	$(TARGET).nds
	@cp $< $@
	@dlditool "DLDI/M3-DS_(SD_Card).dldi" $@

ismat.dat:	$(TARGET).nds
	@cp $< $@
	@dlditool DLDI/Mat.dldi $@

ACEP/_DS_MENU.DAT:	$(TARGET).nds
	@[ -d ACEP ] || mkdir -p ACEP
	@dlditool DLDI/ace3ds_sd.dldi $<
	@r4denc --key 0x4002 $< $@

r4ids.cn/_DS_MENU.DAT:	$(TARGET).nds
	@[ -d r4ids.cn ] || mkdir -p r4ids.cn
	@mv $(TARGET)_r4ids.cn.nds $@
	@dlditool DLDI/r4idsn_sd.dldi $@

R4iLS/_DSMENU.DAT:	$(TARGET).nds
	@[ -d R4iLS ] || mkdir -p R4iLS
	@ndstool -h 0x200 -g "XXXX" "XX" "R4XX" -c R4iLS/_DSMENU.nds -7 $(TARGET).arm7.elf -9 $(TARGET).arm9.elf
	@dlditool DLDI/ace3ds_sd.dldi R4iLS/_DSMENU.nds
	@r4denc --key 0x4002 R4iLS/_DSMENU.nds $@
	@rm -rf R4iLS/_DSMENU.nds

Gateway/_DSMENU.DAT:	$(TARGET).nds
	@[ -d Gateway ] || mkdir -p Gateway
	@ndstool -h 0x200 -g "XXXX" "XX" "R4IT" -c Gateway/_DSMENU.nds -7 $(TARGET).arm7.elf -9 $(TARGET).arm9.elf
	@dlditool DLDI/ace3ds_sd.dldi Gateway/_DSMENU.nds
	@r4denc --key 0x4002 Gateway/_DSMENU.nds $@
	@rm Gateway/_DSMENU.nds

MAZE/_DS_MENU.DAT:	$(TARGET).nds
	@[ -d MAZE ] || mkdir -p MAZE
	@mv $(TARGET)_MAZE.nds $@
	@dlditool DLDI/r4idsn_sd.dldi $@


#---------------------------------------------------------------------------------
$(TARGET).nds	:	$(TARGET).arm7.elf $(TARGET).arm9.elf $(TARGET)_r4ids.cn.arm9.elf $(TARGET)_r4igold.cc_wood.arm9.elf
	ndstool	-h 0x200 -c $(TARGET).nds 			-7 $(TARGET).arm7.elf -9 $(TARGET).arm9.elf
	ndstool	-h 0x200 -c $(TARGET)_r4ids.cn.nds 	-7 $(TARGET).arm7.elf -9 $(TARGET)_r4ids.cn.arm9.elf
	ndstool	-h 0x200 -c $(TARGET)_MAZE.nds 		-7 $(TARGET).arm7.elf -9 $(TARGET)_r4igold.cc_wood.arm9.elf

data:
	@mkdir -p $@

bootloader: data
	@$(MAKE) -C bootloader LOADBIN=$(DATA)/load.bin

#---------------------------------------------------------------------------------
$(TARGET).arm7.elf:
	$(MAKE) -C arm7
	
#---------------------------------------------------------------------------------
$(TARGET).arm9.elf: bootloader bootstub
	$(MAKE) -C arm9

$(TARGET)_r4ids.cn.arm9.elf: bootloader bootstub
	$(MAKE) -C arm9_r4ids.cn
	cp arm9_r4ids.cn/booter.elf $(TARGET)_r4ids.cn.arm9.elf

$(TARGET)_r4igold.cc_wood.arm9.elf: bootloader bootstub
	$(MAKE) -C arm9_r4igold.cc_wood
	cp arm9_r4igold.cc_wood/booter.elf $(TARGET)_r4igold.cc_wood.arm9.elf

#---------------------------------------------------------------------------------
clean:
	$(MAKE) -C arm9 clean
	$(MAKE) -C arm9_r4ids.cn clean
	$(MAKE) -C arm9_r4igold.cc_wood clean
	$(MAKE) -C arm7 clean
	$(MAKE) -C bootloader clean
	rm -rf $(TARGET).nds $(TARGET).arm7.elf $(TARGET).arm9.elf $(TARGET)_r4ids.cn.arm9.elf $(TARGET)_r4igold.cc_wood.arm9.elf
	rm -rf _DS_MENU.DAT ez5sys.bin akmenu4.nds TTMENU.DAT _BOOT_MP.NDS ismat.dat r4i.sys ACEP R4iLS Gateway r4ids.cn MAZE 
	rm -rf data bootstrap bootstrap.zip

