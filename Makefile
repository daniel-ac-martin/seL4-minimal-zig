ZIG ?= zig

arch ?= x86_64
plat ?= pc99

SOURCES = $(shell find {src,deps/daniel-ac-martin/seL4.zig} -name '*.zig')

ninja_files = build/%/seL4/simulate \
              build/%/seL4/kernel/kernel.elf \
              build/%/seL4/libsel4/libsel4.a \
              build/%/seL4/musllibc/build-temp/lib/libc.a \
              build/%/seL4/include/sel4/sel4.h

.PHONY: all clean clean-initrd initrd kernel run
.SECONDARY: $(build/%/seL4/build.ninja)

all: kernel initrd

clean:
	rm -rf build/

clean-initrd:
	rm -rf build/$(arch)-$(plat)/bin/ build/$(arch)-$(plat)/images/initrd.img

initrd: build/$(arch)-$(plat)/images/initrd.img
kernel: build/$(arch)-$(plat)/images/kernel.img

run: build/$(arch)-$(plat)/simulate initrd kernel
	cd "$(<D)" && ./simulate \
		--graphic="" \
		--extra-qemu-args="-audiodev pa,id=snd0" \
		--machine="pcspk-audiodev=snd0"

build/%/simulate: build/%/seL4/simulate
	mkdir -p "$(@D)"
	tac "$(<)" | tail -n +4 | tac > "$(@)"
	sed -i -E "s/images\/kernel-[^\"]+/images\/kernel.img/" "$(@)"
	sed -i -E "s/images\/roottask-image-[^\"]+/images\/initrd.img/" "$(@)"
	chmod +x "$(@)"

$(ninja_files): build/%/seL4/build.ninja
	cd "$(<D)" && ninja

build/%/seL4/build.ninja: seL4/%.cmake seL4/CMakeLists.txt
	mkdir -p "$(@D)"
	cd "$(@D)" && cmake \
		-C "../../../$(<)" \
		-G Ninja \
		"../../../$(<D)"

build/%/images/kernel.img: build/%/seL4/kernel/kernel.elf
	mkdir -p "$(@D)"
	/usr/bin/objcopy -O elf32-i386 "$(<)" "$(@)"

build/%/images/initrd.img: build/%/bin/roottask
	mkdir -p "$(@D)"
	cp "$(<)" "$(@)"

build/%/bin/roottask: $(SOURCES) build/%/seL4/include/sel4/sel4.h build/%/seL4/libsel4/libsel4.a build/%/seL4/musllibc/build-temp/lib/libc.a
	$(ZIG) build \
		-p "$(@D)/../" \
		-Dinclude="$(@D)/../seL4/include" \
		-Dlibsel4="$(@D)/../seL4/libsel4/libsel4.a" \
		-Dlibc="$(@D)/../seL4/musllibc/build-temp/lib/libc.a" \
