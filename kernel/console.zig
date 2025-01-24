const std = @import("std");
const sbi = @import("sbi.zig");

pub const Console = struct {
    pub fn init() Console {
        return .{};
    }

    pub fn write(con: *Console, comptime fmt: []const u8, args: anytype) void {
        const ArgsType = @TypeOf(args);
        const args_type_info = @typeInfo(ArgsType);
        if (args_type_info != .@"struct") {
            @compileError("expected tuple or struct argument, found " ++ @typeName(ArgsType));
        }

        const args_fields = args_type_info.@"struct".fields.len;
        comptime var args_index = 0;

        comptime var i = 0;
        inline while (i < fmt.len) : (i += 1) {
            switch (fmt[i]) {
                '{' => {
                    if (i >= fmt.len - 2 or fmt[i + 2] != '}') {
                        @compileError("missing closing }");
                    }
                    if (args_index == args_fields) {
                        @compileError("too few arguments for format '" ++ fmt ++ "'");
                    }
                    const arg_field = args_type_info.@"struct".fields[args_index];
                    const arg_value = @field(args, arg_field.name);
                    switch (fmt[i + 1]) {
                        's' => {
                            con.write_bytes(arg_value);
                        },
                        'd' => {
                            var b: [32]u8 = undefined;
                            const arg_value_d = std.fmt.bufPrint(&b, "{d}", .{arg_value}) catch {
                                unreachable;
                            };
                            con.write_bytes(arg_value_d);
                        },
                        else => @compileError("unsupported format specifier"),
                    }
                    i += 2;
                    args_index += 1;
                },
                else => con.write_byte(fmt[i]),
            }
        }

        if (args_index != args_fields) {
            @compileError("unused argument in '" ++ fmt ++ "'");
        }
    }

    pub inline fn write_bytes(con: *Console, bytes: []const u8) void {
        _ = con;
        var n: usize = bytes.len;
        var s: usize = 0;
        while (n > 0) {
            const w = sbi.sbi_debug_console_write(bytes[s..]) catch {
                return;
            };
            s += w;
            n -= w;
        }
    }

    pub inline fn write_byte(con: *Console, byte: u8) void {
        _ = con;
        _ = sbi.sbi_debug_console_write_byte(byte) catch {
            return;
        };
    }
};
