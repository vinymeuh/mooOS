.global _start

.section .text.boot
_start: 
        li a7, 0x4442434E
        li a6, 0x00
        li a0, 11
        lla a1, boot_msg
        li a2, 0
        ecall
        la sp, boot_stack_top   // set up stack pointer (the stack grows downwards)
        j kmain               // jump to Zig

.section .rodata
boot_msg:
        .string "Booting...\n"

.section .bss.stack
boot_stack:
        .space 1 * 1024
boot_stack_top:
