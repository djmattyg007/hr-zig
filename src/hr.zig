const std = @import("std");
const termsize = @import("termsize");

pub fn main() !void {
    const stdout_obj = std.fs.File.stdout();
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = stdout_obj.writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var lines: u64 = 1;
    var allocator = std.heap.page_allocator;

    var args = try std.process.ArgIterator.initWithAllocator(allocator);
    // Not really necessary for a program that's expected to execute so quickly,
    // but it's good practice and good habit. Probably more relevant for when
    // parsing args in a dedicated function.
    defer args.deinit();
    // Skip the executable name
    _ = args.skip();

    while (args.next()) |arg| {
        lines = std.fmt.parseUnsigned(u64, arg, 10) catch {
            std.process.exit(1);
        };
        // The CLI interface is really simple: 'hr <lines>'. Anything else is ignored.
        break;
    }

    var cols: u16 = 80;
    const term = try termsize.termSize(stdout_obj);
    if (term) |t| {
        cols = t.width;
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

    try stdout.flush();
}
