AS=nasm
ASFLAGS=-f elf64 -g
LD=ld
LDFLAGS=
SRCS=$(wildcard *.asm)
OBJS=$(patsubst %.asm, obj/%.o, $(SRCS))
BIN=$(patsubst %.asm, bin/%, $(SRCS))

all: prep $(BIN)

prep:
	mkdir -p bin
	mkdir -p obj

bin/%: obj/%.o
	$(LD) $(LDFLAGS) $^ -o $@

obj/%.o: %.asm
	$(AS) $(ASFLAGS) $^ -o $@

clean:
	rm -rf bin