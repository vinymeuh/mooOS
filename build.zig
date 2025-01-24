const std = @import("std");

pub fn build(b: *std.Build) !void {
    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = b.path("kernel/main.zig"),
        .optimize = .Debug, // can not change because of boot.s ?
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .riscv32,
            .os_tag = .freestanding,
            .abi = .none,
            .cpu_features_add = std.Target.riscv.featureSet(&.{.zihintpause}),
        }),
        .strip = false,
    });
    kernel.addAssemblyFile(b.path("kernel/boot.s"));
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
