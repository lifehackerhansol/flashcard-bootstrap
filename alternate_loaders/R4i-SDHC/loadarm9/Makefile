export	PATH	:=	$(DEVKITARM)/bin:$(PATH)

TARGET	:=	loadarm9
	
../$(TARGET).bin: $(TARGET).elf
	arm-eabi-objcopy -O binary $< $@

$(TARGET).elf: $(TARGET).s Makefile	
	arm-eabi-gcc -Ttext=0x02000000 -x assembler-with-cpp -nostartfiles -nostdlib $(TARGET).s -o $@


clean:
	rm -f $(TARGET).elf $(TARGET).bin