const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = b.path("kernel/main.zig"),
        .optimize = optimize,
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .riscv32,
            .os_tag = .freestanding,
            .abi = .none,
        }),
        .strip = false,
    });
    kernel.setLinkerScript(b.path("kernel/linker_rv32.ld"));
    b.installArtifact(kernel);

    const qemu_cmd = b.addSystemCommand(&.{
        // zig fmt: off
        "qemu-system-riscv32", "-machine", "virt",
        "-kernel", "zig-out/bin/kernel.elf",
        "-m", "size=128M",
        "-nographic",
        "-no-shutdown", "-no-reboot",
        // zig fmt: on
    });
    qemu_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the kernel in qemu");
    run_step.dependOn(&qemu_cmd.step);
}
