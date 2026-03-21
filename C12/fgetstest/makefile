fgetstest.exe: fgetstest.o
	gcc fgetstest.o -o fgetstest.exe -no-pie
fgetstest.o: fgetstest.asm
	nasm -f elf64 -g -F dwarf fgetstest.asm
