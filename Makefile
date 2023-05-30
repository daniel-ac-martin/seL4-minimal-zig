AS ?= nasm
CC ?= gcc
LD ?= ld

arch ?= x86_64
plat ?= pc99

arch_family_x86_64 = x86
arch_family_x86 = x86
word_size_x86_64 = 64
word_size_x86 = 32

CFLAGS_x86_64 ?= -m64 -march=nehalem
qemu_flags_x86_64 ?= -machine pcspk-audiodev=snd0 -cpu Nehalem,-vme,+pdpe1gb,-xsave,-xsaveopt,-xsavec,-fsgsbase,-invpcid,+syscall,+lm,enforce -serial mon:stdio -m size=512M -audiodev pa,id=snd0

arch_family = $(arch_family_$(arch))
word_size = $(word_size_$(arch))

CFLAGS ?= -g -ffreestanding -Wall -Wextra -fno-exceptions -std=gnu11 $(CFLAGS_$(CFLAGS_x86_64))
LDFLAGS ?= 

qemu ?= qemu-system-$(arch)
qemu_flags ?= $(qemu_flags_$(arch))
#qemu_flags ?= -machine pcspk-audiodev=snd0,accel=kvm -cpu host -serial mon:stdio -m size=512M -audiodev pa,id=snd0

INCLUDE = deps/seL4/seL4/libsel4/arch_include/$(arch_family)/ \
	  deps/seL4/seL4/libsel4/include/ \
	  deps/seL4/seL4/libsel4/mode_include/$(word_size)/ \
	  deps/seL4/seL4/libsel4/sel4_arch_include/$(arch)/ \
	  deps/seL4/seL4/libsel4/sel4_plat_include/$(plat)/ \
	  build/$(arch)-$(plat)/deps/seL4/seL4/gen_config/ \
	  build/$(arch)-$(plat)/deps/seL4/seL4/libsel4/arch_include/$(arch_family)/ \
	  build/$(arch)-$(plat)/deps/seL4/seL4/libsel4/autoconf/ \
	  build/$(arch)-$(plat)/deps/seL4/seL4/libsel4/gen_config/ \
	  build/$(arch)-$(plat)/deps/seL4/seL4/libsel4/include/ \
	  build/$(arch)-$(plat)/deps/seL4/seL4/libsel4/sel4_arch_include/$(arch)/

ASM_SRC = $(shell find src -name '*.asm')
SOURCES = $(shell find src -name '*.c')
HEADERS = $(shell find src -name '*.h')
OBJ = ${SOURCES:%.c=build/$(arch)-$(plat)/%.o} ${ASM_SRC:%.asm=build/$(arch)-$(plat)/%.o}

.PHONY: all clean initrd kernel run

all: kernel initrd

clean:
	rm -rf build/

initrd: build/$(arch)-$(plat)/initrd.img
kernel: build/$(arch)-$(plat)/kernel.img

run: build/$(arch)-$(plat)/kernel.img build/$(arch)-$(plat)/initrd.img
	#$(qemu) $(qemu_flags) -kernel $(<) -initrd ../seL4-os/build/os
	$(qemu) $(qemu_flags) -kernel $(<) -initrd build/$(arch)-$(plat)/initrd.img

build/$(arch)-$(plat)/kernel.img: build/$(arch)-$(plat)/deps/seL4/seL4/kernel.elf
	mkdir -p $(@D)
	objcopy -O elf32-i386 $(<) $(@)

build/$(arch)-$(plat)/initrd.img: build/$(arch)-$(plat)/src/roottask.elf
	mkdir -p $(@D)
	cp $(<) $(@)

build/$(arch)-$(plat)/deps/seL4/seL4/build.ninja: deps/seL4/seL4/CMakeLists.txt
	mkdir -p $(@D)
	cd $(@D) && cmake \
		-DCROSS_COMPILER_PREFIX= \
		-DCMAKE_TOOLCHAIN_FILE=../../../../../$(<D)/gcc.cmake \
		-G Ninja \
		-C ../../../../../seL4/$(arch)-$(plat).cmake \
		../../../../../$(<D)

build/$(arch)-$(plat)/deps/seL4/seL4/kernel.elf: build/$(arch)-$(plat)/deps/seL4/seL4/build.ninja
	mkdir -p $(@D)
	#cd $(@D) && ninja kernel.elf # This doesn't give us all of the include files
	cd $(@D) && ninja

build/$(arch)-$(plat)/src/roottask.elf: $(OBJ)
	mkdir -p $(@D)
	$(LD) $(LDFLAGS) -o $(@) $(^)

build/$(arch)-$(plat)/src/%.o: src/%.c $(HEADERS) $(INCLUDE)
	mkdir -p $(@D)
	$(CC) $(CFLAGS) $(INCLUDE:%=-I %) -c $(<) -o $(@)

build/$(arch)-$(plat)/src/%.o: src/%.asm
	mkdir -p $(@D)
	$(ASM) $(<) -f elf64 -o $(@)

