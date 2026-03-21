charsin.exe: charsin.o
	gcc charsin.o -o charsin.exe -no-pie
charsin.o: charsin.asm
	nasm -f elf64 -g -F dwarf charsin.asm
