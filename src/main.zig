const seL4 = @import("seL4");

const ColourCode = enum(u8) { Black = 0x0, Blue = 0x1, Green = 0x2, Cyan = 0x3, Red = 0x4, Purple = 0x5, Brown = 0x6, Grey = 0x7, DarkGrey = 0x8, LightBlue = 0x9, LightGreen = 0xA, LightCyan = 0xB, LightRed = 0xC, LightPurple = 0xD, Yellow = 0xE, White = 0xF };

const VGAAttr = u8;
const VGAChar = extern struct {
    character: u8,
    attribute: VGAAttr,
};
const VGABuffer = [25][80]VGAChar;

const vga_vaddr: u64 = 0xA000000000;
//const vga_vaddr: u64 = 0xB8000;
const vga_colour: *VGABuffer = @ptrFromInt(vga_vaddr);

fn vgaCharAttribute(fg: ColourCode, bg: ColourCode) VGAAttr {
    return (@intFromEnum(bg) << 4) | @intFromEnum(fg);
}

fn print(s: []const u8, fg: ColourCode, bg: ColourCode) void {
    const attribute = vgaCharAttribute(fg, bg);

    for (s, 0..) |v, i| {
        const vga_char: VGAChar = .{
            .character = v,
            .attribute = attribute,
        };

        vga_colour[0][i] = vga_char;
    }
}

fn allocSlot(boot_info: *seL4.BootInfo) seL4.CPtr {
    const ret = boot_info.empty.start;
    seL4.debugPrint("Allocating slot: {}\n", .{ret});

    boot_info.empty.start += 1;

    return ret;
}

fn allocObject(boot_info: *seL4.BootInfo, ctype: seL4.CPtr, size: u64) seL4.CPtr {
    const ret: seL4.CPtr = allocSlot(boot_info);

    _ = seL4.capabilities.untypedRetype(98, // the untyped capability to retype
        ctype, // type
        0, //size
        @intFromEnum(seL4.capabilities.Caps.capInitThreadCNode), // root
        0, // node_index
        0, // node_depth
        ret, // node_offset
        1 // num_caps
    );

    _ = size;

    return ret;
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
    seL4.debugPrintBootInfo(boot_info);

    seL4.debugPutString(
        \\
        \\Scheduler:
        \\
    );
    seL4.debugDumpScheduler();

    seL4.debugPutString("Trying to re-type untypeds...\n");

    const pdpt: seL4.CPtr = allocObject(boot_info, @intFromEnum(seL4.capabilities.ObjectType.x86PDPTObject), 0);
    const pd: seL4.CPtr = allocObject(boot_info, @intFromEnum(seL4.capabilities.ObjectType.x86PageDirectoryObject), 0);
    const pt: seL4.CPtr = allocObject(boot_info, @intFromEnum(seL4.capabilities.ObjectType.x86PageTableObject), 0);
    const frame: seL4.CPtr = allocObject(boot_info, @intFromEnum(seL4.capabilities.ObjectType.x864K), 0);

    seL4.debugPutString("Trying to map virtual address...\n");

    const cap = @intFromEnum(seL4.capabilities.Caps.capInitThreadVSpace);
    const attrs = seL4.capabilities.X86VMAttributes.cacheDisabled;
    var err: seL4.Error = undefined;

    err = seL4.capabilities.x86PDPTMap(pdpt, cap, vga_vaddr, attrs);
    if (err != .noError) {
        seL4.debugPrint("Failed to map PDPT ({})\n", .{err});
    }
    err = seL4.capabilities.x86PageDirectoryMap(pd, cap, vga_vaddr, attrs);
    if (err != .noError) {
        seL4.debugPrint("Failed to map PageDirectory ({})\n", .{err});
    }
    err = seL4.capabilities.x86PageTableMap(pt, cap, vga_vaddr, attrs);
    if (err != .noError) {
        seL4.debugPrint("Failed to map PageTable ({})\n", .{err});
    }
    err = seL4.capabilities.x86PageMap(frame, cap, vga_vaddr, seL4.capabilities.readWrite, attrs);

    // if (err == seL4.FailedLookup) {
    //     seL4.debugPrint("Missing intermediate paging structure at level {}\n", seL4.Errors.mappingFailedLookupLevel());
    // }

    if (err != .noError) {
        seL4.debugPrint("Failed to map page ({})\n", .{err});
    }

    seL4.debugPutString("Trying to write to memory...\n");

    print("Hello, World!", .White, .Green); // This will fail until we are able to write to the relevant memory

    seL4.debugPutString("<END_OF_LINE>");

    _ = seL4.capabilities.tCBSuspend(@intFromEnum(seL4.capabilities.Caps.capInitThreadTCB));
}
