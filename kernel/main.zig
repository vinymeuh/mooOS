const std = @import("std");
const builtin = @import("builtin");

const hwinfo = @import("hwinfo.zig");
const kerneltrap = @import("kerneltrap.zig");
const pma = @import("pma.zig");
const riscv = @import("riscv.zig");
const Console = @import("console.zig").Console;

var console: Console = undefined;
var pma_allocator: pma.BumpAllocator = undefined;

const mooOS_version = std.SemanticVersion{ .major = 0, .minor = 0, .patch = 0 };

// const values from linker script symbols
const kernel_size_of_text = @extern([*]u8, .{ .name = "__kernel_size_of_text" });
const kernel_size_of_data = @extern([*]u8, .{ .name = "__kernel_size_of_data" });
const kernel_size_of_rodata = @extern([*]u8, .{ .name = "__kernel_size_of_rodata" });
const kernel_size_of_bss = @extern([*]u8, .{ .name = "__kernel_size_of_bss" });
const free_ram_start = @extern([*]u8, .{ .name = "__free_ram_start" });

comptime {
    asm (
        \\.global _start
        \\.section .text.boot
        \\_start: 
        \\  li a7, 0x4442434E
        \\  li a6, 0x00
        \\  li a0, 11
        \\  lla a1, boot_msg
        \\  li a2, 0
        \\  ecall
        \\  la sp, __stack_top // see linker_rv32.ld
        \\  j kmain               
        \\.section .rodata
        \\boot_msg:
        \\  .string "Booting...\n"
    );
}

// we jump here in supervisor mode
export fn kmain(boot_hartid: usize, dtb_addr: usize) noreturn {
    _ = boot_hartid;
    _ = dtb_addr;

    console = Console.init();
    console.write("mooOS version {d}.{d}.{d} (zig {s}, optimize={s})\n", .{
        mooOS_version.major,
        mooOS_version.minor,
        mooOS_version.patch,
        builtin.zig_version_string,
        std.enums.tagName(std.builtin.OptimizeMode, builtin.mode).?,
    });

    // Kernel Trap Handler
    kerneltrap.init_hart();
    // asm volatile ("unimp");

    // Physical Memory Allocator
    const ram_available: usize = hwinfo.ram_size - (@intFromPtr(free_ram_start) - hwinfo.dram_base);
    console.write("Memory: {d}K/{d}K available ({d}K kernel code, {d}K data, {d}K rodata, {d}K bss)\n", .{
        ram_available / 1024,
        hwinfo.ram_size / 1024,
        @intFromPtr(kernel_size_of_text) / 1024,
        @intFromPtr(kernel_size_of_data) / 1024,
        @intFromPtr(kernel_size_of_rodata) / 1024,
        @intFromPtr(kernel_size_of_bss) / 1024,
    });

    pma_allocator = pma.BumpAllocator.init(free_ram_start, ram_available);
    console.write("Free RAM start at 0x{x} with {d} pages available\n", .{
        @intFromPtr(pma_allocator.heap_start),
        pma_allocator.pages_total(),
    });

    const alloc1 = pma_allocator.allocPages(1);
    console.write("alloc1.ptr=0x{x}, alloc1.len={d}\n", .{ @intFromPtr(alloc1.ptr), alloc1.len });
    const alloc2 = pma_allocator.allocPages(10);
    console.write("alloc2.ptr=0x{x}, alloc2.len={d}\n", .{ @intFromPtr(alloc2.ptr), alloc2.len });

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
