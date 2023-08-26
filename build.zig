const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const include_path = b.option(
        []const u8,
        "include",
        "path to C include directory",
    ) orelse "";
    const libsel4_path = b.option(
        []const u8,
        "libsel4",
        "path to libsel4.a",
    ) orelse "";
    const libc_path = b.option(
        []const u8,
        "libc",
        "path to libc.a",
    ) orelse "";
    const opts = b.addOptions();
    opts.addOption([]const u8, "", include_path);
    opts.addOption([]const u8, "", libsel4_path);
    opts.addOption([]const u8, "", libc_path);

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    //const target = b.standardTargetOptions(.{});
    const nehalem = &std.Target.x86.cpu.nehalem;
    const target = .{ .os_tag = .freestanding, .abi = .eabi, .ofmt = .elf, .cpu_arch = .x86_64, .cpu_model = .{ .explicit = nehalem } };

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    //const optimize = b.standardOptimizeOption(.{});

    const seL4_path = "deps/daniel-ac-martin/seL4.zig";
    const seL4 = b.addModule("seL4", .{ .source_file = .{ .path = seL4_path ++ "/seL4.zig" } });

    const exe = b.addExecutable(.{
        .name = "roottask",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        //.optimize = optimize,
        .optimize = .ReleaseSafe,
        //.optimize = .Debug,
    });
    exe.addModule("seL4", seL4);
    exe.addIncludePath(include_path);
    exe.addObjectFile(libsel4_path);
    exe.addObjectFile(libc_path);
    exe.setLinkerScriptPath(.{ .path = seL4_path ++ "/root-task.ld" });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // const lib = b.addStaticLibrary(.{
    //     .name = "roottask",
    //     // In this case the main source file is merely a path, however, in more
    //     // complicated build scripts, this could be a generated file.
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     //.optimize = optimize,
    //     .optimize = .ReleaseSafe,
    //     //.optimize = .Debug,
    // });
    // lib.addModule("seL4", seL4);
    // lib.addIncludePath("build/x86_64-pc99/seL4/include");

    // // This declares intent for the executable to be installed into the
    // // standard location when the user invokes the "install" step (the default
    // // step when running `zig build`).
    // b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        //.optimize = optimize,
        .optimize = .Debug,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
