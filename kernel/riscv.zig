// RISC-V 32/64-bit ISA related functions
const builtin = @import("builtin");

// Control and Status Registers (CSRs)
pub inline fn csr_read(comptime register: []const u8) usize {
    return asm volatile ("csrr %[value], " ++ register
        : [value] "=r" (-> usize),
    );
}

pub inline fn csr_write(comptime register: []const u8, value: usize) void {
    asm volatile ("csrw " ++ register ++ ", %[value]"
        :
        : [value] "r" (value),
    );
}

// Wait for Interrupt
pub inline fn wfi() void {
    asm volatile ("wfi");
}
