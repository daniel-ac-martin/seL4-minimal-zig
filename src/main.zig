const seL4 = @import("seL4");

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

    seL4.debugPutString(
        \\
        \\Going to sleep...
        \\
    );
    _ = seL4.capabilities.tCBSuspend(@intFromEnum(seL4.capabilities.Caps.capInitThreadTCB));
}
