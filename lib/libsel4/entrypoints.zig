const seL4 = @import("./common.zig");
const bi = @import("./bootinfo.zig");

// Entry-points into seL4 applications
// The root-task needs a special entry point and should be linked with `-e _boot`.
// This is inspired by sel4runtime: https://github.com/seL4/sel4runtime

// We expect all tasks to have a user-defined `main()` function.
extern fn main() void;

// Define a stack for the roottask. (FIXME: Can we avoid defining this for normal tasks?)
//export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;

// Entry-point for root-tasks
export fn _boot() callconv(.Naked) noreturn {
    //const stack_bytes_slice = stack_bytes[0..];

    //const boot_info: *u8 = undefined;
    //@asyncCall(.{ .stack = stack_bytes_slice }, {}, main, .{});

    // Set-up stack (do we actually just need to put something in RSP? )
    // asm volatile (
    //     \\movq %rsp, %rbp
    //     \\subq $0x8, %rsp
    //     :
    //     : [stack_bytes_slice] "{rsp}" (stack_bytes_slice),
    //     : "rsp", "rbp", "memory"
    // );
    // Grab boot info
    //@export(stack_bytes_slice, .{ .name = "__stack_top" });
    //@export(boot, .{ .name = "__sel4_start_root" });
    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (
            \\ldr x19, =__stack_top
            \\add sp, x19, #0
            \\bl __boot
            ::: "x19", "sp", "memory"),
        .arm => asm volatile (
            \\ldr sp, =__stack_top
            \\bl __boot
            ::: "sp", "memory"),
        .riscv32, .riscv64 => asm volatile (
            \\la sp, __stack_top
            \\jal __boot
            ::: "sp", "memory"),
        .x86_64 => asm volatile (
            \\leaq __stack_top, %%rsp
            \\movq %%rsp, %%rbp
            \\subq $0x8, %%rsp
            \\push %%rbp
            \\call __boot
            ::: "rsp", "rbp", "memory"),
        else => @compileError("Unsupported CPU architecture."),
    }

    while (true) {}
}

export fn __boot(boot_info: *bi.BootInfo) callconv(.C) void {
    bi.setBootInfo(boot_info);
    main();
}

// Entry-point for standard tasks
export fn _start() callconv(.Naked) noreturn {
    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (
            \\mov fp, #0
            \\mov lr, #0
            \\
            \\mov x0, sp
            \\bl __start
            ::: "fp", "lr", "x0", "memory"),
        .arm => asm volatile (
            \\mov fp, 0
            \\mov lr, 0
            \\
            \\mov a1, sp
            \\bl __start
            ::: "fp", "lr", "a1", "memory"),
        .riscv32, .riscv64 => asm volatile (
            \\addi  a0, sp, 0
            \\la x5, __start
            \\jalr ra, x5, 0
            ::: "x5", "ra", "memory"),
        .x86_64 => asm volatile (
            \\movq %%rsp, %%rbp
            \\movq %%rsp, %%rdi
            \\
            \\subq $0x8, %%rsp
            \\push %%rbp
            \\call __start
            ::: "rdi", "rsp", "rbp", "memory"),
        else => @compileError("Unsupported CPU architecture."),
    }

    while (true) {}
}

// FIXME: This probably needs some arguments!
export fn __start() callconv(.C) void {
    main();
}
