//const seL4 = @import("../lib/libsel4/libsel4.zig");
const seL4 = @import("libsel4");

pub export fn _start() callconv(.Naked) void {
    seL4.debugPutChar('\r');
    seL4.debugPutChar('\n');
    seL4.debugPutChar('H');
    seL4.debugPutChar('e');
    seL4.debugPutChar('l');
    seL4.debugPutChar('l');
    seL4.debugPutChar('o');
    seL4.debugPutChar(',');
    seL4.debugPutChar(' ');
    seL4.debugPutChar('w');
    seL4.debugPutChar('o');
    seL4.debugPutChar('r');
    seL4.debugPutChar('l');
    seL4.debugPutChar('d');
    seL4.debugPutChar('!');
    seL4.debugPutChar('\r');
    seL4.debugPutChar('\n');
    while (true) {}
    //return;
}

//pub export fn main(argc: c_int, argv: [*c][*c]u8) callconv(.C) c_int {
//_ = argc;
//_ = argv;
////_ = c.seL4_DebugPutChar(@as(u8, 'H'));
//while (true) {}
//return 0;
//}
