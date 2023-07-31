pub const seL4 = @import("./common.zig");

pub extern threadlocal var __sel4_ipc_buffer: *seL4.IPCBuffer;

pub fn setIPCBuffer(ipc_buffer: *seL4.IPCBuffer) void {
    __sel4_ipc_buffer = ipc_buffer;
    return;
}

pub fn getIPCBuffer() *seL4.IPCBuffer {
    return __sel4_ipc_buffer;
}

// It's not obvious to me that we need anything past this point.

pub fn getMR(i: seL4.Word) seL4.Word {
    return getIPCBuffer().*.msg[i];
}

pub fn setMR(i: seL4.Word, mr: seL4.Word) void {
    getIPCBuffer().*.msg[i] = mr;
}

pub fn getUserData() seL4.Word {
    return getIPCBuffer().*.userData;
}

pub fn setUserData(data: seL4.Word) void {
    getIPCBuffer().*.userData = data;
}

pub fn getBadge(i: seL4.Word) seL4.Word {
    return getIPCBuffer().*.caps_or_badges[i];
}

pub fn getCap(i: seL4.Word) seL4.CPtr {
    return getIPCBuffer().*.caps_or_badges[i];
}

pub fn setCap(i: seL4.Word, cptr: seL4.CPtr) void {
    getIPCBuffer().*.caps_or_badges[i] = cptr;
}

pub fn getCapReceivePath(receiveCNode: *seL4.CPtr, receiveIndex: *seL4.CPtr, receiveDepth: *seL4.Word) void {
    var ipcbuffer: *seL4.IPCBuffer = getIPCBuffer();

    if (receiveCNode != null) {
        receiveCNode.* = ipcbuffer.*.receiveCNode;
    }
    if (receiveIndex != null) {
        receiveIndex.* = ipcbuffer.*.receiveIndex;
    }
    if (receiveDepth != null) {
        receiveDepth.* = ipcbuffer.*.receiveDepth;
    }
}

pub fn setCapReceivePath(receiveCNode: seL4.CPtr, receiveIndex: seL4.CPtr, receiveDepth: seL4.Word) void {
    var ipcbuffer: *seL4.IPCBuffer = getIPCBuffer();

    ipcbuffer.*.receiveCNode = receiveCNode;
    ipcbuffer.*.receiveIndex = receiveIndex;
    ipcbuffer.*.receiveDepth = receiveDepth;
}
