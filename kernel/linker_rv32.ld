/* OUTPUT_ARCH(riscv) */
ENTRY(_start)

/* OpenSBI transfer control to this address */
BASE_ADDRESS = 0x80200000;

SECTIONS
{
    . = BASE_ADDRESS;

    .text : {
        PROVIDE(__kernel_text_start = .);
        KEEP(*(.text.boot));
        *(.text .text.*);
        PROVIDE(__kernel_text_end = .);
    }

    .rodata : ALIGN(4) {
        *(.rodata .rodata.*);
    }

    .data : ALIGN(4) {
        *(.data .data.*);
    }

    .bss : ALIGN(4) {
        *(.bss .bss.* .sbss .sbss.*);
    }

    . = ALIGN(4);
    . += 128 * 1024; /* 128KB */
    __stack_top = .;
  
    PROVIDE(__kernel_size_of_text = SIZEOF(.text));
}
