const ioctl = @cImport(@cInclude("sys/ioctl.h"));
const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var lines: u64 = 1;
    var allocator = std.heap.page_allocator;

    var args = std.process.args();
    _ = args.skip();

    while (args.next(allocator)) |argItem| {
        const arg = argItem catch std.process.exit(1);
        lines = std.fmt.parseUnsigned(u64, arg, 10) catch |err| {
            std.process.exit(1);
        };
        break;
    }

    var term: ioctl.winsize = undefined;
    _ = ioctl.ioctl(0, ioctl.TIOCGWINSZ, &term);
    var cols: u32 = 80;
    if (term.ws_col > 0) {
        cols = term.ws_col;
    }

    const char = '#';
    var buf = try allocator.alloc(u8, cols);
    var i: u32 = 0;
    while (i < cols) {
        buf[i] = char;
        i += 1;
    }

    var x: u64 = 0;
    while (x < lines) {
        try stdout.print("{s}\n", .{buf});
        x += 1;
    }
}
