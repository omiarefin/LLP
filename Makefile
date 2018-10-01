# Example Makefile
#
# Exercise 1, TDT4258

LD=arm-none-eabi-gcc
AS=arm-none-eabi-as
OBJCOPY=arm-none-eabi-objcopy

LDFLAGS=-nostdlib
ASFLAGS=-mcpu=cortex-m3 -mthumb -g

LINKERSCRIPT=efm32gg.ld

base: ex1pollen.bin

improved: ex1improved.bin

ex1pollen.bin : ex1pollen.elf
	${OBJCOPY} -j .text -O binary $< $@

ex1pollen.elf : ex1pollen.o 
	${LD} -T ${LINKERSCRIPT} $^ -o $@ ${LDFLAGS} 

ex1pollen.o : ex1pollen.s
	${AS} ${ASFLAGS} $< -o $@
	
	
ex1improved.bin : ex1improved.elf
	${OBJCOPY} -j .text -O binary $< $@

ex1improved.elf : ex1improved.o 
	${LD} -T ${LINKERSCRIPT} $^ -o $@ ${LDFLAGS} 

ex1improved.o : ex1improved.s
	${AS} ${ASFLAGS} $< -o $@

.PHONY : upload
uploadbase :
	-eACommander.sh -r --address 0x00000000 -f "ex1pollen.bin" -r

uploadimproved :
	-eACommander.sh -r --address 0x00000000 -f "ex1improved.bin" -r
	
.PHONY : clean
clean :
	-rm -rf *.o *.elf *.bin *.hex
