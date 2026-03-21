randtest.exe: randtest.o
	gcc randtest.o -o randtest.exe -no-pie
randtest.o: randtest.asm
	nasm -f elf64 -F dwarf randtest.asm
