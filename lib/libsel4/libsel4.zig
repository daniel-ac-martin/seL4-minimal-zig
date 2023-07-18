pub const seL4_Int8 = i8;
pub const seL4_Uint8 = u8;
pub const seL4_Int16 = c_short;
pub const seL4_Uint16 = c_ushort;
pub const seL4_Int32 = c_int;
pub const seL4_Uint32 = c_uint;
pub const seL4_Int64 = c_long;
pub const seL4_Uint64 = c_ulong;
pub const seL4_Bool = seL4_Int8;
pub const seL4_Word = seL4_Uint64;
pub const seL4_CPtr = seL4_Word;

pub const seL4_SysCall: seL4_Int64 = -1;
pub const seL4_SysReplyRecv: seL4_Int64 = -2;
pub const seL4_SysSend: seL4_Int64 = -3;
pub const seL4_SysNBSend: seL4_Int64 = -4;
pub const seL4_SysRecv: seL4_Int64 = -5;
pub const seL4_SysReply: seL4_Int64 = -6;
pub const seL4_SysYield: seL4_Int64 = -7;
pub const seL4_SysNBRecv: seL4_Int64 = -8;
pub const seL4_SysDebugPutChar: seL4_Int64 = -9;
pub const seL4_SysDebugDumpScheduler: seL4_Int64 = -10;
pub const seL4_SysDebugHalt: seL4_Int64 = -11;
pub const seL4_SysDebugCapIdentify: seL4_Int64 = -12;
pub const seL4_SysDebugSnapshot: seL4_Int64 = -13;
pub const seL4_SysDebugNameThread: seL4_Int64 = -14;
pub const seL4_SysSetTLSBase: seL4_Int64 = -29;

inline fn x64_sys_send_recv(sys: seL4_Word, dest: seL4_Word, out_dest: *seL4_Word, info: seL4_Word, out_info: *seL4_Word, in_out_mr0: *seL4_Word, in_out_mr1: *seL4_Word, in_out_mr2: *seL4_Word, in_out_mr3: *seL4_Word, reply: seL4_Word) void {
    var dst: seL4_Word = 0;
    var inf: seL4_Word = 0;
    var mr0: seL4_Word = in_out_mr0.*;
    var mr1: seL4_Word = in_out_mr1.*;
    var mr2: seL4_Word = in_out_mr2.*;
    var mr3: seL4_Word = in_out_mr3.*;

    asm volatile (
        \\movq   %%rsp, %%rbx
        \\syscall
        \\movq   %%rbx, %%rsp
        : [inf] "={rsi}" (inf),
          [o_mr0] "={r10}" (mr0),
          [o_mr1] "={r8}" (mr1),
          [o_mr2] "={r9}" (mr2),
          [o_mr3] "={r15}" (mr3),
          [dst] "={rdi}" (dst),
        : [sys] "{rdx}" (sys),
          [dest] "{rdi}" (dest),
          [info] "{rsi}" (info),
          [mr0] "{r10}" (mr0),
          [mr1] "{r8}" (mr1),
          [mr2] "{r9}" (mr2),
          [mr3] "{r15}" (mr3),
          [reply] "{r12}" (reply),
        : "%rcx", "%rbx", "r11", "memory"
    );

    out_dest.* = dst;
    out_info.* = inf;
    in_out_mr0.* = mr0;
    in_out_mr1.* = mr1;
    in_out_mr2.* = mr2;
    in_out_mr3.* = mr3;
}

pub inline fn debugPutChar(arg_c: u8) void {
    var c = arg_c;
    var unused0: seL4_Word = 0;
    var unused1: seL4_Word = 0;
    var unused2: seL4_Word = 0;
    var unused3: seL4_Word = 0;
    var unused4: seL4_Word = 0;
    var unused5: seL4_Word = 0;

    x64_sys_send_recv(@bitCast(seL4_SysDebugPutChar), c, &unused0, 0, &unused1, &unused2, &unused3, &unused4, &unused5, 0);
}
