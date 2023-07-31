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

    seL4.debugPutString("extraLen: ");
    seL4.debugPutString(&word2string(boot_info.*.extraLen));
    seL4.debugPutString(";\n");

    seL4.debugPutString("nodeID: ");
    seL4.debugPutString(&word2string(boot_info.*.nodeID));
    seL4.debugPutString(";\n");

    seL4.debugPutString("numNodes: ");
    seL4.debugPutString(&word2string(boot_info.*.numNodes));
    seL4.debugPutString(";\n");

    seL4.debugPutString("numIOPTLevels: ");
    seL4.debugPutString(&word2string(boot_info.*.numIOPTLevels));
    seL4.debugPutString(";\n");

    seL4.debugPutString("initThreadCNodeSizeBits: ");
    seL4.debugPutString(&word2string(boot_info.*.initThreadCNodeSizeBits));
    seL4.debugPutString(";\n");

    seL4.debugPutString("initThreadDomain: ");
    seL4.debugPutString(&word2string(boot_info.*.initThreadDomain));
    seL4.debugPutString(";\n");

    seL4.debugDumpScheduler();
}
