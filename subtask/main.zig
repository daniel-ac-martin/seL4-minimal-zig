const seL4 = @import("seL4");

// Temporary hack
export const __stack_top: [*]u8 = &[0]u8{};

export fn main() void {
    _ = __stack_top;
    seL4.debug.putString(
        \\
        \\Hello, world!
        \\
    );
}
