const seL4 = @import("seL4");
// const artefacts = @import("artefacts");

// const subtask = @embedFile(artefacts.subtask);
const subtask = @embedFile("subtask");

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

    // seL4.debug.putString("Subtask is from: ");
    // seL4.debug.putString(artefacts.subtask ++ "\n");
    seL4.debug.putString("Subtask has size: ");
    seL4.debug.print("{}\n", .{subtask.len});

    seL4.debug.putString(
        \\
        \\Going to sleep...
        \\
    );
    _ = seL4.tcb.suspendThread(seL4.cap.init_thread_tcb);
}
