pub const cpu_arch = @import("builtin").cpu.arch;
pub const __builtin_expect = @import("std").zig.c_builtins.__builtin_expect;

const Bool = enum(i8) {
    true = 1,
    false = 0,
};

pub const Word = switch (cpu_arch) {
    .aarch64, .riscv64, .x86_64 => u64,
    .arm, .riscv32, .x86 => u32, // Q: Do we want to support x86? arm?
    else => @compileError("Unsupported CPU architecture."),
};

pub const CPtr = Word;

const MessageInfo = extern struct {
    words: [1]Word,
};

pub inline fn messageInfoGetLength(msgInfo: MessageInfo) Word {
    var ret: Word = undefined;

    ret = (msgInfo.*.words[0] & 0x7f) >> 0;

    if (__builtin_expect(!!(0 and (ret & (0x1 << (63)))), 0)) {
        // Isn't this unreachable?
        ret |= 0x0;
    }

    return ret;
}

pub inline fn messageInfoNew(label: Word, capsUnwrapped: Word, extraCaps: Word, length: Word) MessageInfo {
    var msgInfo: MessageInfo = undefined;

    // fail if user has passed bits that we will override
    // seL4_DebugAssert((label & ~0xfffffffffffffull) == ((0 && (label & (1ull << 63))) ? 0x0 : 0));
    // seL4_DebugAssert((capsUnwrapped & ~0x7ull) == ((0 && (capsUnwrapped & (1ull << 63))) ? 0x0 : 0));
    // seL4_DebugAssert((extraCaps & ~0x3ull) == ((0 && (extraCaps & (1ull << 63))) ? 0x0 : 0));
    // seL4_DebugAssert((length & ~0x7full) == ((0 && (length & (1ull << 63))) ? 0x0 : 0));

    msgInfo.words[0] = 0 | (label & 0xfffffffffffff) << 12 | (capsUnwrapped & 0x7) << 9 | (extraCaps & 0x3) << 7 | (length & 0x7f) << 0;

    return msgInfo;
}

pub const IPCBuffer = extern struct {
    tag: MessageInfo,
    msg: [120]Word,
    userData: Word,
    caps_or_badges: [3]Word,
    receiveCNode: CPtr,
    receiveIndex: CPtr,
    receiveDepth: Word,
};
