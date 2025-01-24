const std = @import("std");

const riscv = @import("riscv.zig");
const Console = @import("console.zig").Console;

var console: Console = undefined;

// we jump here in supervisor mode
export fn kmain(boot_hartid: usize, dtb_addr: usize) noreturn {
    _ = boot_hartid;
    _ = dtb_addr;

    console = Console.init();
    console.write("mooOS version {s}\n", .{"0.0.0"});

    while (true) {
        riscv.wfi();
    }
}

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    @branchHint(.cold);
    console.write("KERNEL PANIC: {s}\n", .{msg});
    while (true) {
        riscv.wfi();
    }
}
