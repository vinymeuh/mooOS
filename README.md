# mooOS 🐮

A toy Unix-like operating system written in Zig.

[![Static Badge](https://img.shields.io/badge/nightly-orange?logo=Zig&logoColor=Orange&label=Zig&labelColor=Orange)](https://ziglang.org/download/)
[![](https://tokei.rs/b1/github/vinymeuh/mooOS)](https://github.com/vinymeuh/mooOS)

## 🎯 Current goal

**mooOS** is a learning project aimed at creating a simple operating systems that runs on **QEMU**, targeting a **32-bit RISC-V** architecture.

To keep things simple:

* It is designed for **single processor**. 
* It assumes **128 MB** of RAM.

My first milestone is to reach **user mode** and launch a basic shell.

## 💪 Features implemented so far

* [x] Boot and switch to Zig
* [x] Write messages to consoles with OpenSBI
* [x] Kernel panic handler
* [x] Kernel trap handler (exception)
* [x] Physical memory allocator

## 📚 References and inspirations

* [xv6 RISC-V](https://github.com/mit-pdos/xv6-riscv)
* [zesty-core](https://github.com/eastonman/zesty-core)
* [Operating System in 1000 Lines of Code](https://operating-system-in-1000-lines.vercel.app/en/)
