override KERNEL := minima.elf

NASMFLAGS ?= -g -F dwarf

override LDFLAGS +=         \
    -nostdlib               \
    -static                 \
    -m elf_x86_64           \
    -z max-page-size=0x1000 \
    -T linker.ld

override NASMFLAGS += \
    -f elf64

override NASMFILES := $(shell find . -type f -name '*.asm' | grep -v 'limine/')
override OBJ := $(NASMFILES:.asm=.o)

.PHONY: all
all: $(KERNEL)

$(KERNEL): $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) -o $@

%.o: %.asm
	nasm $(NASMFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -rf $(KERNEL) $(OBJ)
