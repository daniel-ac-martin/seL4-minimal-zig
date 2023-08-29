const seL4 = @import("seL4");

export fn main() void {
    const boot_info = seL4.getBootInfo();

    seL4.debug.putString(
        \\
        \\Hello, world!
        \\
    );

    seL4.debug.putString(
        \\
        \\Boot info:
        \\
    );
    seL4.debug.printBootInfo(boot_info);

    seL4.debug.putString(
        \\
        \\Scheduler:
        \\
    );
    seL4.debug.dumpScheduler();

    seL4.debug.putString(
        \\
        \\Going to sleep...
        \\
    );
    _ = seL4.tcb.suspendThread(seL4.cap.init_thread_tcb);
}
