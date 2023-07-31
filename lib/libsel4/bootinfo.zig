const seL4 = @import("./common.zig");

const Caps = enum(u8) {
    capNull = 0,
    capInitThreadTCB = 1,
    capInitThreadCNode = 2,
    capInitThreadVSpace = 3,
    capIRQControl = 4,
    capASIDControl = 5,
    capInitThreadASIDPool = 6,
    capIOPortControl = 7,
    capIOSpace = 8,
    capBootInfoFrame = 9,
    capInitThreadIPCBuffer = 10,
    capDomain = 11,
    capSMMUSIDControl = 12,
    capSMMUCBControl = 13,
    numInitialCaps = 14,
};

const NodeId = seL4.Word;
const Domain = seL4.Word;

const SlotPos = seL4.Word;
const SlotRegion = extern struct {
    start: SlotPos,
    end: SlotPos,
};
const UntypedDesc = extern struct {
    paddr: seL4.Word,
    sizeBits: u8,
    isDevice: u8,
    padding: [6]u8,
};

pub const BootInfo = extern struct {
    extraLen: seL4.Word,
    nodeID: NodeId,
    numNodes: seL4.Word,
    numIOPTLevels: seL4.Word,
    ipcBuffer: *seL4.IPCBuffer, //[*c]IPCBuffer,
    empty: SlotRegion,
    sharedFrames: SlotRegion,
    userImageFrames: SlotRegion,
    userImagePaging: SlotRegion,
    ioSpaceCaps: SlotRegion,
    extraBIPages: SlotRegion,
    initThreadCNodeSizeBits: seL4.Word,
    initThreadDomain: Domain,
    untyped: SlotRegion,
    untypedList: [230]UntypedDesc,
};

var __sel4_boot_info: *BootInfo = undefined;

pub fn getBootInfo() *BootInfo {
    return __sel4_boot_info;
}

pub fn setBootInfo(boot_info: *BootInfo) void {
    __sel4_boot_info = boot_info;
}
