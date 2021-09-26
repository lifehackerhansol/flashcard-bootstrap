export	PATH	:=	$(DEVKITARM)/bin:$(PATH)

TARGET	:=	loadarm7
	
../$(TARGET).bin: $(TARGET).elf
	arm-eabi-objcopy -O binary $< $@

$(TARGET).elf: $(TARGET).s Makefile	
	arm-eabi-gcc -Ttext=0x037F8000 -x assembler-with-cpp -nostartfiles -nostdlib $(TARGET).s -o $@


clean:
	rm -f $(TARGET).elf $(TARGET).bin