// RISC-V 32-bit specific code

// This functions handles CPU traps in kernel mode.
pub export fn kernel_trap_vector() align(4) callconv(.Naked) void {
    asm volatile (
    // save the caller-saved registers on the stack
        \\addi sp, sp, -4 * 16
        \\sw ra, 4 * 0(sp)
        \\sw t0, 4 * 1(sp)
        \\sw t1, 4 * 2(sp)
        \\sw t2, 4 * 3(sp)
        \\sw a0, 4 * 4(sp)
        \\sw a1, 4 * 5(sp)
        \\sw a2, 4 * 6(sp)
        \\sw a3, 4 * 7(sp)
        \\sw a4, 4 * 8(sp)
        \\sw a5, 4 * 9(sp)
        \\sw a6, 4 * 10(sp)
        \\sw a7, 4 * 11(sp)
        \\sw t3, 4 * 12(sp)
        \\sw t4, 4 * 13(sp)
        \\sw t5, 4 * 14(sp)
        \\sw t6, 4 * 15(sp)
        // call the Zig trap handler
        \\  call trap_handler
        // restore registers
        \\lw ra, 4 * 0(sp)
        \\lw t0, 4 * 1(sp)
        \\lw t1, 4 * 2(sp)
        \\lw t2, 4 * 3(sp)
        \\lw a0, 4 * 4(sp)
        \\lw a1, 4 * 5(sp)
        \\lw a2, 4 * 6(sp)
        \\lw a3, 4 * 7(sp)
        \\lw a4, 4 * 8(sp)
        \\lw a5, 4 * 9(sp)
        \\lw a6, 4 * 10(sp)
        \\lw a7, 4 * 11(sp)
        \\lw t3, 4 * 12(sp)
        \\lw t4, 4 * 13(sp)
        \\lw t5, 4 * 14(sp)
        \\lw t6, 4 * 15(sp)
        \\addi sp, sp, 4 * 16
        // return
        \\sret
    );
}
