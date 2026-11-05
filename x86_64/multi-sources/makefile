SOURCES := $(wildcard *.asm)
OBJECTS := $(SOURCES:%.asm=build/%.o)

all: build/main

build/main: $(OBJECTS)
	ld -o $@ $^

build/%.o: %.asm | build
	nasm -f elf64 -o $@ $<

build:
	mkdir -p build

clean:
	$(RM) -r build

.PHONY: all clean

