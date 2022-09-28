SOURCE=mandelbrot.s
EMU=mednafen

mandelbrot: binary.o 
	v810-ld -nostdlib binary.o -o mandelbrot.linked
	v810-objcopy  mandelbrot.linked -O binary mandelbrot

binary.o: $(SOURCE)  pal64.dat border_pal.dat
	v810-as -al $(SOURCE) -o binary.o > list.s
	
cd: mandelbrot.cue

mandelbrot.cue: cdlink.txt mandelbrot
	pcfx-cdlink cdlink.txt mandelbrot_priorart
	
run: mandelbrot.cue
	$(EMU) mandelbrot.cue

dump: binary.o
	v810-objdump -d binary.o
	
