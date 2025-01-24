// RISC-V ISA related code

pub inline fn wfi() void {
    asm volatile ("wfi");
}
