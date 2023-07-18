LD ?= ld

arch ?= x86_64
plat ?= pc99

arch_family_x86_64 = x86
arch_family_x86 = x86
word_size_x86_64 = 64
word_size_x86 = 32

qemu_flags_x86_64 ?= -machine pcspk-audiodev=snd0 -cpu Nehalem,-vme,+pdpe1gb,-xsave,-xsaveopt,-xsavec,-fsgsbase,-invpcid,+syscall,+lm,enforce -serial mon:stdio -m size=512M -audiodev pa,id=snd0

arch_family = $(arch_family_$(arch))
word_size = $(word_size_$(arch))

qemu ?= qemu-system-$(arch)
qemu_flags ?= $(qemu_flags_$(arch))

SOURCES = $(shell find src -name '*.zig')

.PHONY: all clean initrd kernel run run-kernel run-alt

all: kernel initrd

clean:
	rm -rf build/

initrd: build/$(arch)-$(plat)/initrd.img
kernel: build/$(arch)-$(plat)/kernel.img

run-kernel: build/$(arch)-$(plat)/kernel.img
	$(qemu) $(qemu_flags) -kernel $(<)

run: build/$(arch)-$(plat)/kernel.img build/$(arch)-$(plat)/initrd.img
	$(qemu) $(qemu_flags) -kernel $(<) -initrd build/$(arch)-$(plat)/initrd.img

run-alt: build/$(arch)-$(plat)/kernel.img build/$(arch)-$(plat)/bin/roottask
	$(qemu) $(qemu_flags) -kernel $(<) -initrd build/$(arch)-$(plat)/bin/roottask

build/$(arch)-$(plat)/kernel.img: build/$(arch)-$(plat)/deps/seL4/seL4/kernel.elf
	mkdir -p $(@D)
	objcopy -O elf32-i386 $(<) $(@)

build/$(arch)-$(plat)/initrd.img: build/$(arch)-$(plat)/roottask.elf
#build/$(arch)-$(plat)/initrd.img: build/$(arch)-$(plat)/bin/roottask
	mkdir -p $(@D)
	cp $(<) $(@)

build/$(arch)-$(plat)/deps/seL4/seL4/build.ninja: deps/seL4/seL4/CMakeLists.txt seL4/$(arch)-$(plat).cmake
	mkdir -p $(@D)
	cd $(@D) && cmake \
		-DCROSS_COMPILER_PREFIX= \
		-DCMAKE_TOOLCHAIN_FILE=../../../../../$(<D)/gcc.cmake \
		-G Ninja \
		-C ../../../../../seL4/$(arch)-$(plat).cmake \
		../../../../../$(<D)

build/$(arch)-$(plat)/deps/seL4/seL4/kernel.elf: build/$(arch)-$(plat)/deps/seL4/seL4/build.ninja
	mkdir -p $(@D)
	cd $(@D) && ninja kernel.elf

build/$(arch)-$(plat)/roottask.elf: build/$(arch)-$(plat)/lib/libroottask.a
	mkdir -p $(@D)
	$(LD) -m elf_x86_64 -nostdlib -static -z max-page-size=0x1000 --require-defined _start -o $(@) $(^)

build/$(arch)-$(plat)/lib/libroottask.a: $(SOURCES)
	zig build -p $(@D)/../

build/$(arch)-$(plat)/bin/roottask: $(SOURCES)
	zig build -p $(@D)/../
