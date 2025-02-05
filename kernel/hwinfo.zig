const std = @import("std");

pub const ram_size: usize = 128 * 1024 * 1024;
pub const dram_base: usize = 0x80000000; // see Firmware base in QEMU output
