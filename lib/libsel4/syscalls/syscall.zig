const seL4 = @import("../common.zig");

// Low level, ASM code for making system calls

// System call codes
const SysCallID = enum(i64) {
    call = -1,
    replyRecv = -2,
    nBSendRecv = -3,
    nBSendWait = -4,
    send = -5,
    nBSend = -6,
    recv = -7,
    nBRecv = -8,
    wait = -9,
    nBWait = -10,
    yield = -11,
    debugPutChar = -12,
    debugDumpScheduler = -13,
    debugHalt = -14,
    debugCapIdentify = -15,
    debugSnapshot = -16,
    debugNameThread = -17,
    debugSendIPI = -18,
    debugRun = -19,
    benchmarkFlushCaches = -20,
    benchmarkResetLog = -21,
    benchmarkFinalizeLog = -22,
    benchmarkSetLogBuffer = -23,
    benchmarkNullSyscall = -24,
    benchmarkGetThreadUtilisation = -25,
    benchmarkResetThreadUtilisation = -26,
    benchmarkDumpAllThreadsUtilisation = -27,
    benchmarkResetAllThreadsUtilisation = -28,
    x86DangerousWRMSR = -29,
    x86DangerousRDMSR = -30,
    vMEnter = -31,
    setTLSBase = -32,
};

// const SysCallIDNoMCS = enum(i64) {
//     call = -1,
//     replyRecv = -2,
//     send = -3,
//     nBSend = -4,
//     recv = -5,
//     reply = -6,
//     yield = -7,
//     nBRecv = -8,
//     debugPutChar = -9,
//     debugDumpScheduler = -10,
//     debugHalt = -11,
//     debugCapIdentify = -12,
//     debugSnapshot = -13,
//     debugNameThread = -14,
//     setTLSBase = -29,
// };

const assembler_template = switch (seL4.cpu_arch) {
    .aarch64 => "svc #0",
    .arm => "swi #0",
    .riscv32, .riscv64 => "ecall",
    .x86_64 => (
        \\movq   %%rsp, %%rbx
        \\syscall
        \\movq   %%rbx, %%rsp
    ),
    else => @compileError("Unsupported CPU architecture."),
};

pub inline fn sendNull(syscall: SysCallID, dest: seL4.Word, info: seL4.Word) void {
    const sys: seL4.Word = @bitCast(@intFromEnum(syscall));

    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (assembler_template
            : [i_inf] "+{x1}" (info),
              [destn] "+{x0}" (dest),
            : [sysid] "{x7}" (sys),
        ),
        .arm => asm volatile (assembler_template
            : [i_inf] "+{r1}" (info),
              [destn] "+{r0}" (dest),
            : [sysid] "{r7}" (sys),
        ),
        .riscv32, .riscv64 => asm volatile (assembler_template
            : [i_inf] "+{a1}" (info),
              [destn] "+{a0}" (dest),
            : [sysid] "{a7}" (sys),
        ),
        .x86_64 => asm volatile (assembler_template
            :
            : [sysid] "{rdx}" (sys),
              [destn] "{rdi}" (dest),
              [i_inf] "{rsi}" (info),
            : "rbx", "rcx", "r11"
        ),
        else => @compileError("Unsupported CPU architecture."),
    }
}

pub inline fn send(syscall: SysCallID, dest: seL4.Word, info: seL4.Word, mr0: seL4.Word, mr1: seL4.Word, mr2: seL4.Word, mr3: seL4.Word) void {
    const sys: seL4.Word = @bitCast(@intFromEnum(syscall));

    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (assembler_template
            : [i_inf] "+{x1}" (info),
              [destn] "+{x0}" (dest),
              [i_mr0] "+{x2}" (mr0),
              [i_mr1] "+{x3}" (mr1),
              [i_mr2] "+{x4}" (mr2),
              [i_mr3] "+{x5}" (mr3),
            : [sysid] "{x7}" (sys),
        ),
        .arm => asm volatile (assembler_template
            : [i_inf] "+{r1}" (info),
              [destn] "+{r0}" (dest),
              [i_mr0] "+{r2}" (mr0),
              [i_mr1] "+{r3}" (mr1),
              [i_mr2] "+{r4}" (mr2),
              [i_mr3] "+{r5}" (mr3),
            : [sysid] "{r7}" (sys),
        ),
        .riscv32, .riscv64 => asm volatile (assembler_template
            : [i_inf] "+{a1}" (info),
              [destn] "+{a0}" (dest),
              [i_mr0] "+{a2}" (mr0),
              [i_mr1] "+{a3}" (mr1),
              [i_mr2] "+{a4}" (mr2),
              [i_mr3] "+{a5}" (mr3),
            : [sysid] "{a7}" (sys),
        ),
        .x86_64 => asm volatile (assembler_template
            :
            : [sysid] "{rdx}" (sys),
              [destn] "{rdi}" (dest),
              [i_inf] "{rsi}" (info),
              [i_mr0] "{r10}" (mr0),
              [i_mr1] "{r8}" (mr1),
              [i_mr2] "{r9}" (mr2),
              [i_mr3] "{r15}" (mr3),
            : "rbx", "rcx", "r11"
        ),
        else => @compileError("Unsupported CPU architecture."),
    }
}

// Not for MCS
pub inline fn sendReply(syscall: SysCallID, info: seL4.Word, mr0: seL4.Word, mr1: seL4.Word, mr2: seL4.Word, mr3: seL4.Word) void {
    const sys: seL4.Word = @bitCast(@intFromEnum(syscall));

    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (assembler_template
            : [i_inf] "+{x1}" (info),
              [i_mr0] "+{x2}" (mr0),
              [i_mr1] "+{x3}" (mr1),
              [i_mr2] "+{x4}" (mr2),
              [i_mr3] "+{x5}" (mr3),
            : [sysid] "{x7}" (sys),
        ),
        .arm => asm volatile (assembler_template
            : [i_inf] "+{r1}" (info),
              [i_mr0] "+{r2}" (mr0),
              [i_mr1] "+{r3}" (mr1),
              [i_mr2] "+{r4}" (mr2),
              [i_mr3] "+{r5}" (mr3),
            : [sysid] "{r7}" (sys),
        ),
        .riscv32, .riscv64 => asm volatile (assembler_template
            : [i_inf] "+{a1}" (info),
              [i_mr0] "+{a2}" (mr0),
              [i_mr1] "+{a3}" (mr1),
              [i_mr2] "+{a4}" (mr2),
              [i_mr3] "+{a5}" (mr3),
            : [sysid] "{a7}" (sys),
        ),
        .x86_64 => asm volatile (assembler_template
            :
            : [sysid] "{rdx}" (sys),
              [i_inf] "{rsi}" (info),
              [i_mr0] "{r10}" (mr0),
              [i_mr1] "{r8}" (mr1),
              [i_mr2] "{r9}" (mr2),
              [i_mr3] "{r15}" (mr3),
            : "rbx", "rcx", "r11"
        ),
        else => @compileError("Unsupported CPU architecture."),
    }
}

pub inline fn recv(syscall: SysCallID, src: seL4.Word, out_badge: *seL4.Word, out_info: *seL4.Word, out_mr0: *seL4.Word, out_mr1: *seL4.Word, out_mr2: *seL4.Word, out_mr3: *seL4.Word, reply: seL4.Word) void {
    const sys: seL4.Word = @bitCast(@intFromEnum(syscall));
    var src_and_bdg: seL4.Word = src;
    var inf: seL4.Word = 0;
    var mr0: seL4.Word = out_mr0.*;
    var mr1: seL4.Word = out_mr1.*;
    var mr2: seL4.Word = out_mr2.*;
    var mr3: seL4.Word = out_mr3.*;

    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (assembler_template
            : [o_inf] "={x1}" (inf),
              [badge] "={x0}" (src_and_bdg),
              [o_mr0] "={x2}" (mr0),
              [o_mr1] "={x3}" (mr1),
              [o_mr2] "={x4}" (mr2),
              [o_mr3] "={x5}" (mr3),
            : [sysid] "{x7}" (sys),
              [reply] "{x6}" (reply),
            : "memory"
        ),
        .arm => asm volatile (assembler_template
            : [o_inf] "={r1}" (inf),
              [badge] "={r0}" (src_and_bdg),
              [o_mr0] "={r2}" (mr0),
              [o_mr1] "={r3}" (mr1),
              [o_mr2] "={r4}" (mr2),
              [o_mr3] "={r5}" (mr3),
            : [sysid] "{r7}" (sys),
              [reply] "{r6}" (reply),
            : "memory"
        ),
        .riscv32, .riscv64 => asm volatile (assembler_template
            : [o_inf] "={a1}" (inf),
              [badge] "={a0}" (src_and_bdg),
              [o_mr0] "={a2}" (mr0),
              [o_mr1] "={a3}" (mr1),
              [o_mr2] "={a4}" (mr2),
              [o_mr3] "={a5}" (mr3),
            : [sysid] "{a7}" (sys),
              [reply] "{a6}" (reply),
            : "memory"
        ),
        .x86_64 => asm volatile (assembler_template
            : [o_inf] "={rsi}" (inf),
              [badge] "={rdi}" (src_and_bdg),
              [o_mr0] "={r10}" (mr0),
              [o_mr1] "={r8}" (mr1),
              [o_mr2] "={r9}" (mr2),
              [o_mr3] "={r15}" (mr3),
            : [sysid] "{rdx}" (sys),
              [sourc] "{rdi}" (src_and_bdg),
              [reply] "{r12}" (reply),
            : "rbx", "rcx", "r11", "memory"
        ),
        else => @compileError("Unsupported CPU architecture."),
    }

    out_badge.* = src_and_bdg;
    out_info.* = inf;
    out_mr0.* = mr0;
    out_mr1.* = mr1;
    out_mr2.* = mr2;
    out_mr3.* = mr3;
}

pub inline fn sendRecv(syscall: SysCallID, dest: seL4.Word, out_badge: *seL4.Word, info: seL4.Word, out_info: *seL4.Word, in_out_mr0: *seL4.Word, in_out_mr1: *seL4.Word, in_out_mr2: *seL4.Word, in_out_mr3: *seL4.Word, reply: seL4.Word) void {
    const sys: seL4.Word = @bitCast(@intFromEnum(syscall));
    var dest_and_bdg: seL4.Word = dest;
    var inf: seL4.Word = info;
    var mr0: seL4.Word = in_out_mr0.*;
    var mr1: seL4.Word = in_out_mr1.*;
    var mr2: seL4.Word = in_out_mr2.*;
    var mr3: seL4.Word = in_out_mr3.*;

    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (assembler_template
            : [o_inf] "+{x1}" (inf),
              [badge] "+{x0}" (dest_and_bdg),
              [o_mr0] "+{x2}" (mr0),
              [o_mr1] "+{x3}" (mr1),
              [o_mr2] "+{x4}" (mr2),
              [o_mr3] "+{x5}" (mr3),
            : [sysid] "{x7}" (sys),
              [reply] "{x6}" (reply),
            : "memory"
        ),
        .arm => asm volatile (assembler_template
            : [o_inf] "+{r1}" (inf),
              [badge] "+{r0}" (dest_and_bdg),
              [o_mr0] "+{r2}" (mr0),
              [o_mr1] "+{r3}" (mr1),
              [o_mr2] "+{r4}" (mr2),
              [o_mr3] "+{r5}" (mr3),
            : [sysid] "{r7}" (sys),
              [reply] "{r6}" (reply),
            : "memory"
        ),
        .riscv32, .riscv64 => asm volatile (assembler_template
            : [o_inf] "+{a1}" (inf),
              [badge] "+{a0}" (dest_and_bdg),
              [o_mr0] "+{a2}" (mr0),
              [o_mr1] "+{a3}" (mr1),
              [o_mr2] "+{a4}" (mr2),
              [o_mr3] "+{a5}" (mr3),
            : [sysid] "{a7}" (sys),
              [reply] "{a6}" (reply),
            : "memory"
        ),
        .x86_64 => asm volatile (assembler_template
            : [o_inf] "={rsi}" (inf),
              [badge] "={rdi}" (dest_and_bdg),
              [o_mr0] "={r10}" (mr0),
              [o_mr1] "={r8}" (mr1),
              [o_mr2] "={r9}" (mr2),
              [o_mr3] "={r15}" (mr3),
            : [sysid] "{rdx}" (sys),
              [destn] "{rdi}" (dest_and_bdg),
              [i_inf] "{rsi}" (inf),
              [i_mr0] "{r10}" (mr0),
              [i_mr1] "{r8}" (mr1),
              [i_mr2] "{r9}" (mr2),
              [i_mr3] "{r15}" (mr3),
              [reply] "{r12}" (reply),
            : "rbx", "rcx", "r11", "memory"
        ),
        else => @compileError("Unsupported CPU architecture."),
    }

    out_badge.* = dest_and_bdg;
    out_info.* = inf;
    in_out_mr0.* = mr0;
    in_out_mr1.* = mr1;
    in_out_mr2.* = mr2;
    in_out_mr3.* = mr3;
}

// MCS only
pub inline fn nBSendRecv(syscall: SysCallID, dest: seL4.Word, src: seL4.Word, out_badge: *seL4.Word, info: seL4.Word, out_info: *seL4.Word, in_out_mr0: *seL4.Word, in_out_mr1: *seL4.Word, in_out_mr2: *seL4.Word, in_out_mr3: *seL4.Word, reply: seL4.Word) void {
    const sys: seL4.Word = @bitCast(@intFromEnum(syscall));
    var src_and_bdg: seL4.Word = src;
    var inf: seL4.Word = info;
    var mr0: seL4.Word = in_out_mr0.*;
    var mr1: seL4.Word = in_out_mr1.*;
    var mr2: seL4.Word = in_out_mr2.*;
    var mr3: seL4.Word = in_out_mr3.*;

    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (assembler_template
            : [o_inf] "+{x1}" (inf),
              [badge] "+{x0}" (src_and_bdg),
              [o_mr0] "+{x2}" (mr0),
              [o_mr1] "+{x3}" (mr1),
              [o_mr2] "+{x4}" (mr2),
              [o_mr3] "+{x5}" (mr3),
            : [sysid] "{x7}" (sys),
              [reply] "{x6}" (reply),
              [destn] "{x8}" (dest),
            : "memory"
        ),
        .arm => asm volatile (assembler_template
            : [o_inf] "+{r1}" (inf),
              [badge] "+{r0}" (src_and_bdg),
              [o_mr0] "+{r2}" (mr0),
              [o_mr1] "+{r3}" (mr1),
              [o_mr2] "+{r4}" (mr2),
              [o_mr3] "+{r5}" (mr3),
            : [sysid] "{r7}" (sys),
              [reply] "{r6}" (reply),
              [destn] "{r8}" (dest),
            : "memory"
        ),
        .riscv32, .riscv64 => asm volatile (assembler_template
            : [o_inf] "+{a1}" (inf),
              [badge] "+{a0}" (src_and_bdg),
              [o_mr0] "+{a2}" (mr0),
              [o_mr1] "+{a3}" (mr1),
              [o_mr2] "+{a4}" (mr2),
              [o_mr3] "+{a5}" (mr3),
            : [sysid] "{a7}" (sys),
              [reply] "{a6}" (reply),
              [destn] "{t0}" (dest),
            : "memory"
        ),
        .x86_64 => asm volatile (assembler_template
            : [o_inf] "={rsi}" (inf),
              [badge] "={rdi}" (src_and_bdg),
              [o_mr0] "={r10}" (mr0),
              [o_mr1] "={r8}" (mr1),
              [o_mr2] "={r9}" (mr2),
              [o_mr3] "={r15}" (mr3),
            : [sysid] "{rdx}" (sys),
              [sourc] "{rdi}" (src_and_bdg),
              [i_inf] "{rsi}" (inf),
              [i_mr0] "{r10}" (mr0),
              [i_mr1] "{r8}" (mr1),
              [i_mr2] "{r9}" (mr2),
              [i_mr3] "{r15}" (mr3),
              [reply] "{r12}" (reply),
              [destn] "{r13}" (dest),
            : "rbx", "rcx", "r11", "memory"
        ),
        else => @compileError("Unsupported CPU architecture."),
    }

    out_badge.* = src_and_bdg;
    out_info.* = inf;
    in_out_mr0.* = mr0;
    in_out_mr1.* = mr1;
    in_out_mr2.* = mr2;
    in_out_mr3.* = mr3;
}

pub inline fn nullCall(syscall: SysCallID) void {
    const sys: seL4.Word = @bitCast(@intFromEnum(syscall));

    switch (seL4.cpu_arch) {
        .aarch64 => asm volatile (assembler_template
            :
            : [sysid] "{x7}" (sys),
            : "memory"
        ),
        .arm => asm volatile (assembler_template
            :
            : [sysid] "{r7}" (sys),
            : "memory"
        ),
        .riscv32, .riscv64 => asm volatile (assembler_template
            :
            : [sysid] "{a7}" (sys),
            : "memory"
        ),
        .x86_64 => asm volatile (assembler_template
            :
            : [sysid] "{rdx}" (sys),
            : "rbx", "rcx", "r11", "rsi", "rdi"
        ),
        else => @compileError("Unsupported CPU architecture."),
    }
}
