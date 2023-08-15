#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

ifneq (,$(shell which python3))
PYTHON	:= python3
else ifneq (,$(shell which python2))
PYTHON	:= python2
else ifneq (,$(shell which python))
PYTHON	:= python
else
$(error "Python not found in PATH, please install it.")
endif

include $(DEVKITARM)/ds_rules

export TARGET		:=	bootstrap
export TOPDIR		:=	$(CURDIR)
export DATA			:=	$(TOPDIR)/data

export LIBNDS32	:= $(TOPDIR)/libnds32/

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
			bootme.nds \
			r4i.sys \
			ismat.dat \
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

dist	:	all
	@mkdir -p bootstrap/M3R_iTDS_R4RTS/_system_/_sys_data
	@mkdir -p bootstrap/DSOneSDHC_DSOnei
	@mkdir -p bootstrap/N5
	@mkdir -p bootstrap/G003/system
	@cp -r README.md _ds_menu.dat ez5sys.bin ttmenu.dat r4.dat _boot_mp.nds bootme.nds ismat.dat akmenu4.nds _dsmenu.dat dsedgei.dat scfw.sc bootstrap
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

_ds_menu.dat:	$(TARGET).nds
	@echo "Make original R4"
	@dlditool "DLDI/r4tfv3.dldi" $<
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

bootme.nds: $(TARGET).nds
	@echo "Make Games n Music"
	@cp $< $@
	@dlditool DLDI/gmtf.dldi $<

ACEP/_ds_menu.dat:	$(TARGET).nds
	@echo "Make Ace3DS+"
	@[ -d ACEP ] || mkdir -p ACEP
	@dlditool DLDI/ace3ds_sd.dldi $<
	@r4denc --key 0x4002 $< $@

scfw.sc:	$(TARGET)_dsone.nds
	@echo "Make SuperCard DSONE"
	@cp $< $@
	@dlditool DLDI/scds3.dldi $<

akmenu4.nds:	$(TARGET)_ak2.nds
	@echo "Make AK2"
	@cp $< $@
	@dlditool DLDI/ak2_sd.dldi $@

ttmenu.dat:		$(TARGET)_ak2.nds
	@echo "Make DSTT"
	@cp $< $@
	@dlditool DLDI/ttio_sdhc.dldi $@

DSOneSDHC_DSOnei/ttmenu.dat:	$(TARGET)_ak2.nds
	@echo "Make DSONE SDHC"
	@[ -d DSOneSDHC_DSOnei ] || mkdir -p DSOneSDHC_DSOnei
	@cp $< $@
	@dlditool DLDI/scdssdhc2.dldi $@

# Hack TTMenu.dat to bypass signature checks
r4.dat: 	ttmenu.dat
	@echo "Make R4i-SDHC"
	@ndstool -x $< -9 arm9.bin -7 arm7.bin -t banner.bin -h header.bin
	@$(PYTHON) resource/r4isdhc/r4isdhc.py arm9.bin new9.bin
	@ndstool -c $@ -9 new9.bin -7 arm7.bin -t banner.bin -h header.bin -r9 0x02000000
	@rm -rf arm9.bin new9.bin arm7.bin banner.bin header.bin

_dsmenu.dat:	$(TARGET)_r4idsn.nds
	@echo "Make R4iDSN"
	@cp $< $@
	@dlditool DLDI/r4idsn_sd.dldi $@

dsedgei.dat:	$(TARGET)_r4ids.cn.nds
	@echo "Make EDGEi"
	@cp $< $@
	@dlditool DLDI/ak2_sd.dldi $@

MAZE/_ds_menu.dat:	$(TARGET)_r4idsn.nds
	@echo "Make Amaze3DS/R4igold.cc Wood"
	@[ -d MAZE ] || mkdir -p MAZE
	@cp $< $@
	@dlditool DLDI/ak2_sd.dldi $@

r4ids.cn/_ds_menu.dat:	$(TARGET)_r4ids.cn.nds
	@echo "Make r4ids.cn"
	@[ -d r4ids.cn ] || mkdir -p r4ids.cn
	@cp $< $@
	@dlditool DLDI/ak2_sd.dldi $@

R4iLS/_dsmenu.dat:	$(TARGET)_r4ils.nds
	@echo "Make R4iLS"
	@[ -d R4iLS ] || mkdir -p R4iLS
	@dlditool DLDI/ace3ds_sd.dldi $<
	@r4denc --key 0x4002 $< $@

Gateway/_dsmenu.dat:	$(TARGET)_gateway.nds
	@echo "Make GW"
	@[ -d Gateway ] || mkdir -p Gateway
	@dlditool DLDI/ace3ds_sd.dldi $<
	@r4denc --key 0x4002 $< $@

G003/g003menu.eng:	$(TARGET)_r4idsn.nds
	@echo "Make GMP-Z003"
	@[ -d G003 ] || mkdir -p G003
	@dlditool DLDI/g003.dldi $<
	@./resource/dsbize/dsbize $< $@ 0x12

#---------------------------------------------------------------------------------
# Default entry address
$(TARGET).nds	:	$(TARGET).elf $(TARGET).arm7.elf
	@ndstool	-h 0x200 -c $@ -9 $(TARGET).elf -7 $(TARGET).arm7.elf

# Default entry address with header change for DSONE
$(TARGET)_dsone.nds	:	$(TARGET).elf $(TARGET).arm7.elf
	@ndstool	-h 0x200 -g "ENG0" -c $@ -9 $(TARGET).elf -7 $(TARGET).arm7.elf

# Default entry address with header change for R4iLS
$(TARGET)_r4ils.nds	:	$(TARGET).elf $(TARGET).arm7.elf
	@ndstool	-h 0x200 -g "####" "##" "R4XX" -c $@ -9 $(TARGET).elf -7 $(TARGET).arm7.elf

# Default entry address with header change for Gateway / R4 Infinity
$(TARGET)_gateway.nds	:	$(TARGET).elf $(TARGET).arm7.elf
	@ndstool	-h 0x200 -g "####" "##" "R4IT" -c $@ -9 $(TARGET).elf -7 $(TARGET).arm7.elf

# 0x02000450
$(TARGET)_ak2.nds	:	$(TARGET)_ak2.elf $(TARGET).arm7.elf
	@ndstool	-h 0x200 -c $@ -9 $(TARGET)_ak2.elf -7 $(TARGET).arm7.elf

# 0x02000800
$(TARGET)_r4ids.cn.nds	:	$(TARGET)_r4ids.cn.elf $(TARGET).arm7.elf
	@ndstool	-h 0x200 -c $@ -9 $(TARGET)_r4ids.cn.elf -7 $(TARGET).arm7.elf

# 0x02000000
$(TARGET)_r4idsn.nds	:	$(TARGET)_r4idsn.elf $(TARGET).arm7.elf
	@ndstool	-h 0x200 -c $@ -9 $(TARGET)_r4idsn.elf -7 $(TARGET).arm7.elf

data:
	@mkdir -p $@

bootloader: data
	@$(MAKE) -C bootloader LOADBIN=$(DATA)/load.bin

#---------------------------------------------------------------------------------
$(TARGET).elf: bootloader bootstub
	@$(MAKE) -C arm9
	@cp arm9/$(TARGET).elf $@

$(TARGET).arm7.elf:
	@$(MAKE) -C arm7
	@cp arm7/$(TARGET).elf $@

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
	$(MAKE) -C arm7 clean
	$(MAKE) -C arm9 clean
	$(MAKE) -C arm9_r4ids.cn clean
	$(MAKE) -C arm9_crt0set clean
	$(MAKE) -C bootloader clean
	@rm -rf arm*/data
	@rm -rf $(TARGET)*.nds $(TARGET)*.elf
	@rm -rf _ds_menu.dat _dsmenu.dat ez5sys.bin akmenu4.nds ttmenu.dat bootme.nds _boot_mp.nds ismat.dat r4i.sys scfw.sc ACEP R4iLS MAZE N5 Gateway DSOneSDHC_DSOnei r4ids.cn r4.dat G003/
	@rm -rf data bootstrap bootstrap.zip
