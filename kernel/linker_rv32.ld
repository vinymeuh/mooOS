OUTPUT_ARCH(riscv)
ENTRY(_start)

/* OpenSBI transfer control to this address */
BASE_ADDRESS = 0x80200000;

SECTIONS
{
    . = BASE_ADDRESS;

    .text : {
        KEEP(*(.text.boot));
        *(.text .text.*);
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

    . = ALIGN(4096); /* aligned to a 4KB boundary */
    __free_ram_start = .;
  
    PROVIDE(__kernel_size_of_text = SIZEOF(.text));
    PROVIDE(__kernel_size_of_data = SIZEOF(.data));
    PROVIDE(__kernel_size_of_rodata = SIZEOF(.rodata));
    PROVIDE(__kernel_size_of_bss = SIZEOF(.bss));
}
