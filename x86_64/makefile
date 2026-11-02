CC := nasm
CC_FLAGS := -f elf64

SOURCES := $(wildcard *.asm)
OBJECTS := $(SOURCES:.asm=.o)
# Maps binaries directly to the build folder (e.g., build/main)
BINARIES := $(patsubst %.asm,build/%,$(SOURCES))

all: $(BINARIES)

# Ensure the build directory is always created silently
build:
	@mkdir -p build

# 1. Compile step: Pattern rule to turn individual .asm files into build/*.o files
build/%.o: %.asm | build
	$(CC) $(CC_FLAGS) -o $@ $<

# 2. Link step: Pattern rule to turn build/*.o files into individual build/* executables
build/%: build/%.o
	ld -o $@ $<

clean:
	rm -rf build

.PHONY: all clean

