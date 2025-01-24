const std = @import("std");
const builtin = @import("builtin");

// https://github.com/riscv-non-isa/riscv-sbi-doc/blob/master/src/binary-encoding.adoc

pub const sbiret = struct {
    err: SbiErrorCode,
    val: isize,
};

pub const Error = error{
    FAILED,
    NOT_SUPPORTED,
    INVALID_PARAM,
    DENIED,
    INVALID_ADDRESS,
    ALREADY_AVAILABLE,
    ALREADY_STARTED,
    ALREADY_STOPPED,
    NO_SHMEM,
    INVALID_STATE,
    BAD_RANGE,
    TIMEOUT,
    IO,
};

pub const SbiErrorCode = enum(isize) {
    SUCCESS = 0,
    FAILED = -1,
    NOT_SUPPORTED = -2,
    INVALID_PARAM = -3,
    DENIED = -4,
    INVALID_ADDRESS = -5,
    ALREADY_AVAILABLE = -6,
    ALREADY_STARTED = -7,
    ALREADY_STOPPED = -8,
    NO_SHMEM = -9,
    INVALID_STATE = -10,
    BAD_RANGE = -11,
    TIMEOUT = -12,
    IO = -13,

    fn toError(_: SbiErrorCode) Error {
        return Error.FAILED;
    }
};

// See https://github.com/riscv-software-src/opensbi/blob/master/include/sbi/sbi_ecall_interface.h

// SBI Extension IDs
const SBI_EXT_BASE: i32 = 0x10;
const SBI_EXT_DBCN: i32 = 0x4442434E;
const SBI_EXT_SRST: i32 = 0x53525354;

// Debug Console extension (DBCN)
const SBI_EXT_DBCN_CONSOLE_WRITE: i32 = 0x0;
const SBI_EXT_DBCN_CONSOLE_READ: i32 = 0x1;
const SBI_EXT_DBCN_CONSOLE_WRITE_BYTE: i32 = 0x2;

pub fn sbi_debug_console_write(msg: []const u8) !usize {
    const ret = sbi_ecall3(SBI_EXT_DBCN, SBI_EXT_DBCN_CONSOLE_WRITE, msg.len, @intFromPtr(msg.ptr), 0);
    if (ret.err != .SUCCESS) {
        return ret.err.toError();
    }
    return @intCast(ret.val);
}

pub fn sbi_debug_console_write_byte(byte: u8) !usize {
    const ret = sbi_ecall1(SBI_EXT_DBCN, SBI_EXT_DBCN_CONSOLE_WRITE_BYTE, byte);
    if (ret.err != .SUCCESS) {
        return ret.err.toError();
    }
    return 0;
}

// System Reset extension (SRST)
const SBI_EXT_SRST_SYSTEM_RESET: i32 = 0x0;

pub const SystemResetType = enum(u32) {
    shutdown = 0,
    cold_reboot = 1,
    warn_reboot = 2,
};

pub const SystemResetReason = enum(u32) {
    no_reason = 0,
    system_failure = 1,
};

pub fn sbi_system_reset(reset_type: SystemResetType, reset_reason: SystemResetReason) !noreturn {
    const ret = sbi_ecall2(SBI_EXT_DBCN, SBI_EXT_DBCN_CONSOLE_WRITE_BYTE, @intFromEnum(reset_type), @intFromEnum(reset_reason));
    if (ret.err != .SUCCESS) {
        return ret.err.toError();
    }
    while (true) {} // for noreturn
}

// SBI ecall calling convention
//  - a7 encodes the SBI extension ID (EID)
//  - a6 encodes the SBI function ID (FID) for a given extension ID encoded in a7 for any SBI extension defined in or after SBI v0.2
//  - All registers except a0 & a1 must be preserved across an SBI call by the callee
//  - SBI functions must return a pair of values in a0 and a1 (sbiret structure), with a0 returning an error code.
inline fn sbi_ecall1(eid: i32, fid: i32, a0: usize) sbiret {
    var err: c_long = undefined;
    var val: c_long = undefined;
    asm volatile ("ecall"
        : [err] "={a0}" (err),
          [val] "={a1}" (val),
        : [eid] "{a7}" (eid),
          [fid] "{a6}" (fid),
          [a0] "{a0}" (a0),
    );
    return sbiret{ .err = @enumFromInt(err), .val = val };
}

inline fn sbi_ecall2(eid: i32, fid: i32, a0: usize, a1: usize) sbiret {
    var err: c_long = undefined;
    var val: c_long = undefined;
    asm volatile ("ecall"
        : [err] "={a0}" (err),
          [val] "={a1}" (val),
        : [eid] "{a7}" (eid),
          [fid] "{a6}" (fid),
          [a0] "{a0}" (a0),
          [a1] "{a0}" (a1),
    );
    return sbiret{ .err = @enumFromInt(err), .val = val };
}

inline fn sbi_ecall3(eid: i32, fid: i32, a0: usize, a1: usize, a2: usize) sbiret {
    var err: c_long = undefined;
    var val: c_long = undefined;
    asm volatile ("ecall"
        : [err] "={a0}" (err),
          [val] "={a1}" (val),
        : [eid] "{a7}" (eid),
          [fid] "{a6}" (fid),
          [a0] "{a0}" (a0),
          [a1] "{a1}" (a1),
          [a2] "{a2}" (a2),
    );
    return sbiret{ .err = @enumFromInt(err), .val = val };
}
