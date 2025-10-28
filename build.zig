const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "hr",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/hr.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.linkLibC();

    b.installArtifact(exe);
}
