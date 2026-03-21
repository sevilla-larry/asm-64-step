timetest.exe: timetest.o
	gcc timetest.o -o timetest.exe -no-pie
timetest.o: timetest.asm
	nasm -f elf64 -g -F dwarf timetest.asm
