all: build/main


build/main:	build/print_num.o main.c
	gcc -no-pie -o $@ $^

build/print_num.o: print_num.asm | build
	nasm -f elf64 -o $@ $<

build:
	mkdir -p build

clean:
	rm -rf build

.PHONY: all clean

