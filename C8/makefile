eatsyscall: eatsyscall.o
	ld -o eatsyscall.exe eatsyscall.o
eatsyscall.o: eatsyscall.asm
	nasm -f elf64 -g -F dwarf -l eatsyscall.lst -o eatsyscall.o eatsyscall.asm
