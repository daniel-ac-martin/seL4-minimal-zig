Minimal seL4 example in Zig
===========================

This repo demonstrates a minimal build of the [seL4 micro-kernel] along
with a very simple ('hello world') roottask, implemented in the [Zig]
programming language.

Rather than using seL4's wider build-system, this simply performs a
['stand-alone' build of the kernel].

The roottask (initrd) is _very_ simple and just uses seL4's debug
system call to write 'Hello, World!' to the serial console.


Motivation
----------

My hope is that this repo will provide a simple example that
demonstrates how programs written in [Zig] can be run on [seL4], and so
help anyone else that has in interest in doing this.


Pre-requisites
--------------

In order to build and run this software, you will need:
- [Git]  (to pull down the only dependency, [seL4], this is in place of
  the [Repo] tool)
- [Make]  (for the overarching build system)
- [CMake]  (to build the kernel, [seL4])
- [Ninja]  (to build the kernel, [seL4])
- [gcc] and [others]?  (to build the kernel, [seL4])
- [Python]3 and some packages (to build the kernel):
  - [setuptools]: `pip3 install --user setuptools`
  - [sel4-deps]: `pip3 install --user sel4-deps`
- [Zig] >= 0.10  (to build the roottask / root-server / initrd)
- [GNU Binutils]  (ld and objcopy; to build both, the kernel and
  roottask)
- [QEMU]  (to run / simulate in a virtual machine)


Usage
-----

First clone this repo:
```shell
git clone https://github.com/daniel-ac-martin/seL4-minimal-zig.git
```

Then pull down the dependencies:
```shell
cd seL4-minimal-zig
git submodule init
git submodule update
```

To build everything:
```shell
make
```

To build just the kernel:
```shell
make kernel
```

To build just the roottask:
```shell
make initrd
```

To run:
```shell
make run
```

To delete built files:
```shell
make clean
```


Miscellaneous notes
-------------------

- See also: https://github.com/daniel-ac-martin/seL4-minimal-asm
- This has been tested on a GNU/Linux system (Fedora 38) with Zig 0.11 (not the Fedora package which is v0.9)
- This is not currently using the [MCS kernel]  (edit [`seL4/x86_64-pc99.cmake`](seL4/x86_64-pc99.cmake) to start work on this)
- Currently the roottask is a little too simple, and so we have to be careful with how we compile it. We actually require a certain kind of optimisation in order to avoid pushing to the stack! Some sort of initialisation code should be added to avoid this problem.
- To understand the initial environment of the roottask, it's probably best to consult the C runtime: https://github.com/seL4/sel4runtime
- The system calls on x86-64 can be found here: https://github.com/seL4/seL4/blob/master/libsel4/sel4_arch_include/x86_64/sel4/sel4_arch/syscalls.h
- Thoughts / comments / ideas are welcome in the [issues]


[seL4 micro-kernel]: https://sel4.systems/
[Zig]: https://ziglang.org/
['stand-alone' build of the kernel]: https://docs.sel4.systems/projects/buildsystem/standalone.html
[Git]: https://git-scm.com/
[seL4]: https://sel4.systems/
[Repo]: https://source.android.com/docs/setup/download#repo
[Make]: https://www.gnu.org/software/make/
[CMake]: https://cmake.org/
[Ninja]: https://ninja-build.org/
[gcc]: https://gcc.gnu.org/
[others]: https://docs.sel4.systems/projects/buildsystem/host-dependencies.html#base-build-dependencies
[Python]: https://www.python.org/
[setuptools]: https://pypi.org/project/setuptools/
[sel4-deps]: https://pypi.org/project/sel4-deps/
[GNU Binutils]: https://www.gnu.org/software/binutils/
[QEMU]: https://www.qemu.org/
[MCS kernel]: https://docs.sel4.systems/Tutorials/mcs.html
[issues]: https://github.com/daniel-ac-martin/seL4-minimal-zig/issues

