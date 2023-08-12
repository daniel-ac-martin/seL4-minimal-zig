const seL4 = @import("seL4");

fn word2string(word: u64) [8]u8 {
    var r: [8]u8 = undefined;
    comptime var i: u6 = 0;

    inline while (i < r.len) : (i += 1) {
        const n: u8 = @truncate(((word >> (i * 8)) & 0xF));
        const a: u8 = if (n <= 9) 48 else 55;
        r[i] = n + a;
    }

    return r;
}

export fn main() void {
    const boot_info = seL4.getBootInfo();

    seL4.debugPutString(
        \\
        \\Hello, world!
        \\
    );

    seL4.debugPutString(
        \\
        \\Boot info:
        \\
    );
    seL4.debugPrintBootInfo(boot_info);

    seL4.debugPutString(
        \\
        \\Scheduler:
        \\
    );
    seL4.debugDumpScheduler();






}
