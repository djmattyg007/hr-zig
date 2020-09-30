const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    const allocator = std.heap.page_allocator;

    const mode = b.standardReleaseOptions();

    const exePath = [_][]const u8{"src", "main.zig"};
    const exe = b.addExecutable("hr", try std.fs.path.join(allocator, &exePath));
    exe.setBuildMode(mode);
    exe.single_threaded = true;
    exe.linkSystemLibrary("c");
    if (mode != .Debug) {
        exe.strip = true;
    }
    if (mode == .ReleaseSafe) {
        exe.force_pic = true;
    }
    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);

    const runCmd = exe.run();
    const runStep = b.step("run", "Run hr");
    runStep.dependOn(&runCmd.step);
}
