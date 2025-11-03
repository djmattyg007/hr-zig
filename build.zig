const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_termsize = b.dependency("termsize", .{
        .target = target,
        .optimize = optimize,
    }).module("termsize");

    const exe = b.addExecutable(.{
        .name = "hr",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/hr.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.addImport("termsize", dep_termsize);

    b.installArtifact(exe);
}
