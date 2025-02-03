const std = @import("std");
const riscv = @import("riscv.zig");
const riscv32 = @import("riscv32.zig");

pub fn init_hart() void {
    riscv.csr_write("stvec", @intFromPtr(&riscv32.kernel_trap_vector));
}

export fn trap_handler() void {
    const scause = riscv.csr_read("scause");
    const stval = riscv.csr_read("stval");
    const sepc = riscv.csr_read("sepc");
    std.debug.panic("Unexpected trap scause={x}, stval={x}, sepc={x}", .{ scause, stval, sepc });
}
