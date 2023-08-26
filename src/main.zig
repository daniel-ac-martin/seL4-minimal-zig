const seL4 = @import("seL4");

export fn main() void {
    seL4.seL4_DebugPutChar('H');
}
