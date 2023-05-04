#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

export TARGET		:=	bootstrap
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
all		:	$(TARGET).nds \
			_ds_menu.dat \
			N5/_ds_menu.dat \
			ez5sys.bin \
			_boot_mp.nds \
			r4i.sys \
			ismat.dat \
			ACEP/_ds_menu.dat \
			akmenu4.nds \
			ttmenu.dat \
			r4.dat \
			_dsmenu.dat \
			MAZE/_ds_menu.dat \
			r4ids.cn/_ds_menu.dat \
			R4iLS/_dsmenu.dat \
			Gateway/_dsmenu.dat \
			G003/g003menu.eng \
			DSOneSDHC_DSOnei/ttmenu.dat

dist	:	all
	@mkdir -p bootstrap/M3R_iTDS_R4RTS/_system_/_sys_data
	@mkdir -p bootstrap/DSOneSDHC_DSOnei
	@mkdir -p bootstrap/N5
	@mkdir -p bootstrap/G003/system
	@cp -r _ds_menu.dat ez5sys.bin ttmenu.dat r4.dat _boot_mp.nds ismat.dat akmenu4.nds _dsmenu.dat MAZE ACEP R4iLS Gateway r4ids.cn README.md bootstrap 
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

_ds_menu.dat:	$(TARGET).nds
	@echo "Make original R4"
	@dlditool "DLDI/r4tf_sdhc.dldi" $<
	@r4denc $< $@

N5/_ds_menu.dat:	$(TARGET).nds
	echo "Make N5"
	[ -d N5 ] || mkdir -p "N5"
	cp $< $@

ez5sys.bin:	$(TARGET).nds
	@echo "Make EZ-Flash V"
	@cp $< $@
	@dlditool DLDI/ez5h.dldi $@

_boot_mp.nds:	$(TARGET).nds
	@echo "Make GBAMP"
	@cp $< $@
	@dlditool DLDI/mpcf.dldi $@

r4i.sys	:	$(TARGET).nds
	@echo "Make M3R_iTDS_R4RTS"
	@cp $< $@
	@dlditool "DLDI/m3ds.dldi" $@

ismat.dat:	$(TARGET).nds
	@echo "Make iSmart Premium"
	@cp $< $@
	@dlditool DLDI/mati.dldi $@

ACEP/_ds_menu.dat:	$(TARGET).nds
	@echo "Make Ace3DS+"
	@[ -d ACEP ] || mkdir -p ACEP
	@dlditool DLDI/ace3ds_sd.dldi $<
	@r4denc --key 0x4002 $< $@

akmenu4.nds:	$(TARGET)_ak2.elf
	@echo "Make AK2"
	@ndstool -h 0x200 -c $@ -9 $<
	@dlditool DLDI/ak2_sd.dldi $@

ttmenu.dat:		akmenu4.nds
	@echo "Make DSTT"
	@cp $< $@
	@dlditool DLDI/ttio_sdhc.dldi $@

DSOneSDHC_DSOnei/ttmenu.dat:	ttmenu.dat
	@echo "Make DSONE SDHC"
	@[ -d DSOneSDHC_DSOnei ] || mkdir -p DSOneSDHC_DSOnei
	@cp $< $@
	@dlditool DLDI/scdssdhc2.dldi $@

r4.dat: 	ttmenu.dat
	@echo "Make R4i-SDHC"
	@ndstool -x $< -9 arm9.bin -7 arm7.bin -t banner.bin -h header.bin
	@./resource/r4isdhc/r4isdhc arm9.bin new9.bin
	@ndstool -c $@ -9 new9.bin -7 arm7.bin -t banner.bin -h header.bin -r9 0x02000000
	@rm -rf arm9.bin new9.bin arm7.bin banner.bin header.bin

_dsmenu.dat:	$(TARGET)_r4idsn.elf
	@echo "Make R4iDSN"
	@ndstool -h 0x200 -c $@ -9 $<
	@dlditool DLDI/r4idsn_sd.dldi $@

MAZE/_ds_menu.dat:	_dsmenu.dat
	@echo "Make Amaze3DS/R4igold.cc Wood"
	@[ -d MAZE ] || mkdir -p MAZE
	@cp $< $@
	@dlditool DLDI/ak2_sd.dldi $@

r4ids.cn/_ds_menu.dat:	$(TARGET)_r4ids.cn.elf
	@echo "Make r4ids.cn"
	@[ -d r4ids.cn ] || mkdir -p r4ids.cn
	@ndstool	-h 0x200 -c $@ -9 $<
	@dlditool DLDI/ak2_sd.dldi $@

R4iLS/_dsmenu.dat:	$(TARGET).elf
	@echo "Make R4iLS"
	@[ -d R4iLS ] || mkdir -p R4iLS
	@ndstool -h 0x200 -g "####" "##" "R4XX" -c R4iLS/_DSMENU.nds -9 $<
	@dlditool DLDI/ace3ds_sd.dldi R4iLS/_DSMENU.nds
	@r4denc --key 0x4002 R4iLS/_DSMENU.nds $@
	@rm -rf R4iLS/_DSMENU.nds

Gateway/_dsmenu.dat:	$(TARGET).elf
	@echo "Make GW"
	@[ -d Gateway ] || mkdir -p Gateway
	@ndstool -h 0x200 -g "####" "##" "R4IT" -c Gateway/_DSMENU.nds -9 $<
	@dlditool DLDI/ace3ds_sd.dldi Gateway/_DSMENU.nds
	@r4denc --key 0x4002 Gateway/_DSMENU.nds $@
	@rm Gateway/_DSMENU.nds

G003/g003menu.eng:	_dsmenu.dat
	@echo "Make GMP-Z003"
	@[ -d G003 ] || mkdir -p G003
	@dlditool DLDI/G003.dldi $<
	@./resource/dsbize/dsbize $< $@ 0x12

#---------------------------------------------------------------------------------
$(TARGET).nds	:	$(TARGET).elf
	ndstool	-h 0x200 -c $@ -9 $<

data:
	@mkdir -p $@

bootloader: data
	@$(MAKE) -C bootloader LOADBIN=$(DATA)/load.bin

#---------------------------------------------------------------------------------
$(TARGET).elf: bootloader bootstub
	@$(MAKE) -C arm9
	@cp arm9/$(TARGET).elf $@

$(TARGET)_r4ids.cn.elf: bootloader bootstub
	@$(MAKE) -C arm9_r4ids.cn
	@cp arm9_r4ids.cn/$(TARGET).elf $@

$(TARGET)_r4idsn.elf: bootloader bootstub
	@$(MAKE) -C arm9_crt0set CRT0=0x02000000
	@cp arm9_crt0set/$(TARGET).elf $@
	@$(MAKE) -C arm9_crt0set clean

$(TARGET)_ak2.elf: bootloader bootstub
	@$(MAKE) -C arm9_crt0set CRT0=0x02000450
	@cp arm9_crt0set/$(TARGET).elf $@
	@$(MAKE) -C arm9_crt0set clean

#---------------------------------------------------------------------------------
clean:
	$(MAKE) -C arm9 clean
	$(MAKE) -C arm9_r4ids.cn clean
	$(MAKE) -C arm9_crt0set clean
	$(MAKE) -C bootloader clean
	@rm -rf $(TARGET).nds $(TARGET).elf $(TARGET)_r4ids.cn.elf $(TARGET)_r4idsn.elf $(TARGET)_ak2.elf
	@rm -rf _ds_menu.dat _dsmenu.dat ez5sys.bin akmenu4.nds ttmenu.dat _boot_mp.nds ismat.dat r4i.sys ACEP R4iLS MAZE N5 Gateway r4ids.cn r4.dat G003/
	@rm -rf data bootstrap bootstrap.zip
