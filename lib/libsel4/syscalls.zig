const seL4 = @import("./common.zig");
const sys = @import("./syscalls/syscall.zig");
const thread = @import("./thread.zig");

// This file provides the seL4 system call API

pub inline fn call(dest: seL4.CPtr, msgInfo: seL4.MessageInfo) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var mr0: seL4.Word = thread.getMR(0);
    var mr1: seL4.Word = thread.getMR(1);
    var mr2: seL4.Word = thread.getMR(2);
    var mr3: seL4.Word = thread.getMR(3);

    sys.sendRecv(.call, dest, &dest, msgInfo.words[0], &info.words[0], &mr0, &mr1, &mr2, &mr3, 0);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    return info;
}

pub inline fn callWithMRs(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var msg0: seL4.Word = 0;
    var msg1: seL4.Word = 0;
    var msg2: seL4.Word = 0;
    var msg3: seL4.Word = 0;

    if ((mr0 != null) and (seL4.messageInfoGetLength(msgInfo) > 0)) {
        msg0 = mr0.*;
    }
    if ((mr1 != null) and (seL4.messageInfoGetLength(msgInfo) > 1)) {
        msg1 = mr1.*;
    }
    if ((mr2 != null) and (seL4.messageInfoGetLength(msgInfo) > 2)) {
        msg2 = mr2.*;
    }
    if ((mr3 != null) and (seL4.messageInfoGetLength(msgInfo) > 3)) {
        msg3 = mr3.*;
    }

    sys.sendRecv(.call, dest, &dest, msgInfo.words[0], &info.words[0], &msg0, &msg1, &msg2, &msg3, 0);

    if (mr0 != null) {
        mr0.* = msg0;
    }
    if (mr1 != null) {
        mr1.* = msg1;
    }
    if (mr2 != null) {
        mr2.* = msg2;
    }
    if (mr3 != null) {
        mr3.* = msg3;
    }

    return info;
}

// Not for MCS, AKA 'seL4_Reply' in libsel4
pub inline fn sendReply(msgInfo: seL4.MessageInfo) void {
    sys.sendReply(.reply, msgInfo.words[0], thread.getMR(0), thread.getMR(1), thread.getMR(2), thread.getMR(3));
}

// Not for MCS, AKA 'seL4_ReplyWithMRs' in libsel4
pub inline fn sendReplyWithMRs(msgInfo: seL4.MessageInfo, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word) void {
    sys.sendReply(.reply, msgInfo.words[0], if (mr0 != null) mr0.* else 0, if (mr1 != null) mr1.* else 0, if (mr2 != null) mr2.* else 0, if (mr3 != null) mr3.* else 0);
}

// Send: "Basically not useful. It's there mostly for historical purposes." - G. Heiser
pub inline fn send(dest: seL4.CPtr, msgInfo: seL4.MessageInfo) void {
    sys.send(.send, dest, msgInfo.words[0], thread.getMR(0), thread.getMR(1), thread.getMR(2), thread.getMR(3));
}

pub inline fn sendWithMRs(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word) void {
    sys.send(.send, dest, msgInfo.words[0], if (mr0 != null) mr0.* else 0, if (mr1 != null) mr1.* else 0, if (mr2 != null) mr2.* else 0, if (mr3 != null) mr3.* else 0);
}

// Non-blocking send. Will silently fail if receiver is not ready!
// Used more for notifications rather than endpoints.
pub inline fn nBSend(dest: seL4.CPtr, msgInfo: seL4.MessageInfo) void {
    sys.send(.nBSend, dest, msgInfo.words[0], thread.getMR(0), thread.getMR(1), thread.getMR(2), thread.getMR(3));
}

pub inline fn nBSendWithMRs(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word) void {
    sys.send(.nBsend, dest, msgInfo.words[0], if (mr0 != null) mr0.* else 0, if (mr1 != null) mr1.* else 0, if (mr2 != null) mr2.* else 0, if (mr3 != null) mr3.* else 0);
}

pub inline fn recv(src: seL4.CPtr, sender: *seL4.Word, reply: seL4.CPtr) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var mr0: seL4.Word = undefined;
    var mr1: seL4.Word = undefined;
    var mr2: seL4.Word = undefined;
    var mr3: seL4.Word = undefined;

    sys.recv(.recv, src, &badge, &info.words[0], &mr0, &mr1, &mr2, &mr3, reply);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn recvWithMRs(src: seL4.CPtr, sender: *seL4.Word, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word, reply: seL4.CPtr) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var msg0: seL4.Word = undefined;
    var msg1: seL4.Word = undefined;
    var msg2: seL4.Word = undefined;
    var msg3: seL4.Word = undefined;

    sys.recv(.recv, src, &badge, &info.words[0], &msg0, &msg1, &msg2, &msg3, reply);

    if (mr0 != null) {
        mr0.* = msg0;
    }
    if (mr1 != null) {
        mr1.* = msg1;
    }
    if (mr2 != null) {
        mr2.* = msg2;
    }
    if (mr3 != null) {
        mr3.* = msg3;
    }

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn nBRecv(src: seL4.CPtr, sender: *seL4.Word, reply: seL4.CPtr) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var mr0: seL4.Word = undefined;
    var mr1: seL4.Word = undefined;
    var mr2: seL4.Word = undefined;
    var mr3: seL4.Word = undefined;

    sys.recv(.nBRecv, src, &badge, &info.words[0], &mr0, &mr1, &mr2, &mr3, reply);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn replyRecv(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, sender: *seL4.Word, reply: seL4.CPtr) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var mr0: seL4.Word = thread.getMR(0);
    var mr1: seL4.Word = thread.getMR(1);
    var mr2: seL4.Word = thread.getMR(2);
    var mr3: seL4.Word = thread.getMR(3);

    sys.sendRecv(.replyRecv, dest, &badge, msgInfo.words[0], &info.words[0], &mr0, &mr1, &mr2, &mr3, reply);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn replyRecvWithMRs(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, sender: *seL4.Word, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word, reply: seL4.CPtr) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var msg0: seL4.Word = 0;
    var msg1: seL4.Word = 0;
    var msg2: seL4.Word = 0;
    var msg3: seL4.Word = 0;

    if ((mr0 != null) and (seL4.messageInfoGetLength(msgInfo) > 0)) {
        msg0 = mr0.*;
    }
    if ((mr1 != null) and (seL4.messageInfoGetLength(msgInfo) > 1)) {
        msg1 = mr1.*;
    }
    if ((mr2 != null) and (seL4.messageInfoGetLength(msgInfo) > 2)) {
        msg2 = mr2.*;
    }
    if ((mr3 != null) and (seL4.messageInfoGetLength(msgInfo) > 3)) {
        msg3 = mr3.*;
    }

    sys.sendRecv(.replyRecv, dest, &badge, msgInfo.words[0], &info.words[0], &msg0, &msg1, &msg2, &msg3, reply);

    if (mr0 != null) {
        mr0.* = msg0;
    }
    if (mr1 != null) {
        mr1.* = msg1;
    }
    if (mr2 != null) {
        mr2.* = msg2;
    }
    if (mr3 != null) {
        mr3.* = msg3;
    }

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn nBSendRecv(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, src: seL4.CPtr, sender: *seL4.Word, reply: seL4.CPtr) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var mr0: seL4.Word = thread.getMR(0);
    var mr1: seL4.Word = thread.getMR(1);
    var mr2: seL4.Word = thread.getMR(2);
    var mr3: seL4.Word = thread.getMR(3);

    sys.nBSendRecv(.nBSendRecv, dest, src, &badge, msgInfo.words[0], &info.words[0], &mr0, &mr1, &mr2, &mr3, reply);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn nBSendRecvWithMRs(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, src: seL4.CPtr, sender: *seL4.Word, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word, reply: seL4.CPtr) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var msg0: seL4.Word = 0;
    var msg1: seL4.Word = 0;
    var msg2: seL4.Word = 0;
    var msg3: seL4.Word = 0;

    if ((mr0 != null) and (seL4.messageInfoGetLength(msgInfo) > 0)) {
        msg0 = mr0.*;
    }
    if ((mr1 != null) and (seL4.messageInfoGetLength(msgInfo) > 1)) {
        msg1 = mr1.*;
    }
    if ((mr2 != null) and (seL4.messageInfoGetLength(msgInfo) > 2)) {
        msg2 = mr2.*;
    }
    if ((mr3 != null) and (seL4.messageInfoGetLength(msgInfo) > 3)) {
        msg3 = mr3.*;
    }

    sys.nBSendRecv(.nBSendRecv, dest, src, &badge, msgInfo.words[0], &info.words[0], &msg0, &msg1, &msg2, &msg3, reply);

    if (mr0 != null) {
        mr0.* = msg0;
    }
    if (mr1 != null) {
        mr1.* = msg1;
    }
    if (mr2 != null) {
        mr2.* = msg2;
    }
    if (mr3 != null) {
        mr3.* = msg3;
    }

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn nBSendWait(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, src: seL4.CPtr, sender: *seL4.Word) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var mr0: seL4.Word = thread.getMR(0);
    var mr1: seL4.Word = thread.getMR(1);
    var mr2: seL4.Word = thread.getMR(2);
    var mr3: seL4.Word = thread.getMR(3);

    sys.nBSendRecv(.nBSendWait, 0, src, &badge, msgInfo.words[0], &info.words[0], &mr0, &mr1, &mr2, &mr3, dest);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn nBSendWaitWithMRs(dest: seL4.CPtr, msgInfo: seL4.MessageInfo, src: seL4.CPtr, sender: *seL4.Word, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var msg0: seL4.Word = 0;
    var msg1: seL4.Word = 0;
    var msg2: seL4.Word = 0;
    var msg3: seL4.Word = 0;

    // Ignore src argument
    _ = @TypeOf(src);

    if ((mr0 != null) and (seL4.MessageInfo_get_length(msgInfo) > 0)) {
        msg0 = mr0.*;
    }
    if ((mr1 != null) and (seL4.MessageInfo_get_length(msgInfo) > 1)) {
        msg1 = mr1.*;
    }
    if ((mr2 != null) and (seL4.MessageInfo_get_length(msgInfo) > 2)) {
        msg2 = mr2.*;
    }
    if ((mr3 != null) and (seL4.MessageInfo_get_length(msgInfo) > 3)) {
        msg3 = mr3.*;
    }

    sys.sendRecv(.replyRecv, dest, &badge, msgInfo.words[0], &info.words[0], &mr0, &mr1, &mr2, &mr3, dest);

    if (mr0 != null) {
        mr0.* = msg0;
    }
    if (mr1 != null) {
        mr1.* = msg1;
    }
    if (mr2 != null) {
        mr2.* = msg2;
    }
    if (mr3 != null) {
        mr3.* = msg3;
    }

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn yield() void {
    sys.nullCall(.yield);
    asm volatile ("" ::: "memory");
}

pub inline fn signal(dest: seL4.CPtr) void {
    sys.sendNull(.send, dest, seL4.messageInfoNew(0, 0, 0, 1).words[0]);
}

pub inline fn wait(src: seL4.CPtr, sender: *seL4.Word) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var mr0: seL4.Word = undefined;
    var mr1: seL4.Word = undefined;
    var mr2: seL4.Word = undefined;
    var mr3: seL4.Word = undefined;

    sys.recv(.wait, src, &badge, &info.words[0], &mr0, &mr1, &mr2, &mr3, 0);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn waitWithMRs(src: seL4.CPtr, sender: *seL4.Word, mr0: *seL4.Word, mr1: *seL4.Word, mr2: *seL4.Word, mr3: *seL4.Word) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var msg0: seL4.Word = undefined;
    var msg1: seL4.Word = undefined;
    var msg2: seL4.Word = undefined;
    var msg3: seL4.Word = undefined;

    sys.recv(.wait, src, &badge, &info.words[0], &msg0, &msg1, &msg2, &msg3, 0);

    if (mr0 != null) {
        mr0.* = msg0;
    }
    if (mr1 != null) {
        mr1.* = msg1;
    }
    if (mr2 != null) {
        mr2.* = msg2;
    }
    if (mr3 != null) {
        mr3.* = msg3;
    }

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn nBWait(src: seL4.CPtr, sender: *seL4.Word) seL4.MessageInfo {
    var info: seL4.MessageInfo = undefined;
    var badge: seL4.Word = undefined;
    var mr0: seL4.Word = undefined;
    var mr1: seL4.Word = undefined;
    var mr2: seL4.Word = undefined;
    var mr3: seL4.Word = undefined;

    sys.recv(.nBWait, src, &badge, &info.words[0], &mr0, &mr1, &mr2, &mr3, 0);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    if (sender != null) {
        sender.* = badge;
    }

    return info;
}

pub inline fn poll(src: seL4.CPtr, sender: *seL4.Word) seL4.MessageInfo {
    return nBWait(src, sender);
}

pub inline fn vMEnter(sender: *seL4.Word) seL4.Word {
    var fault: seL4.Word = undefined;
    var badge: seL4.Word = undefined;
    var mr0: seL4.Word = thread.getMR(0);
    var mr1: seL4.Word = thread.getMR(1);
    var mr2: seL4.Word = thread.getMR(2);
    var mr3: seL4.Word = thread.getMR(3);

    sys.sendRecv(.vMEnter, 0, &badge, 0, &fault, &mr0, &mr1, &mr2, &mr3, 0);

    thread.setMR(0, mr0);
    thread.setMR(1, mr1);
    thread.setMR(2, mr2);
    thread.setMR(3, mr3);

    if (!fault and (sender != null)) {
        sender.* = badge;
    }

    return fault;
}

pub inline fn debugPutChar(c: u8) void {
    var unused0: seL4.Word = 0;
    var unused1: seL4.Word = 0;
    var unused2: seL4.Word = 0;
    var unused3: seL4.Word = 0;
    var unused4: seL4.Word = 0;
    var unused5: seL4.Word = 0;

    sys.sendRecv(.debugPutChar, c, &unused0, 0, &unused1, &unused2, &unused3, &unused4, &unused5, 0);
}

pub inline fn debugPutString(s: []const u8) void {
    for (s) |c| {
        debugPutChar(c);
    }
}

pub inline fn debugDumpScheduler() void {
    var unused0: seL4.Word = 0;
    var unused1: seL4.Word = 0;
    var unused2: seL4.Word = 0;
    var unused3: seL4.Word = 0;
    var unused4: seL4.Word = 0;
    var unused5: seL4.Word = 0;

    sys.sendRecv(.debugDumpScheduler, 0, &unused0, 0, &unused1, &unused2, &unused3, &unused4, &unused5, 0);
}

pub inline fn debugHalt() void {
    sys.nullCall(.debugHalt);
    asm volatile ("" ::: "memory");
}

pub inline fn debugSnapshot() void {
    sys.nullCall(.debugSnapshot);
    asm volatile ("" ::: "memory");
}

pub inline fn debugCapIdentify(cap: seL4.CPtr) u32 {
    var unused0: seL4.Word = 0;
    var unused1: seL4.Word = 0;
    var unused2: seL4.Word = 0;
    var unused3: seL4.Word = 0;
    var unused4: seL4.Word = 0;

    sys.sendRecv(.debugCapIdentify, cap, &cap, 0, &unused0, &unused1, &unused2, &unused3, &unused4, 0);

    return @truncate(cap);
}

pub inline fn debugNameThread(tcb: seL4.CPtr, name: []const u8) void {
    var unused0: seL4.Word = 0;
    var unused1: seL4.Word = 0;
    var unused2: seL4.Word = 0;
    var unused3: seL4.Word = 0;
    var unused4: seL4.Word = 0;
    var unused5: seL4.Word = 0;

    @memcpy(@as([]u8, thread.getIPCBuffer().*.msg), name); // Is this safe? Does it even work?
    sys.sendRecv(.debugNameThread, tcb, &unused0, 0, &unused1, &unused2, &unused3, &unused4, &unused5, 0);
}
