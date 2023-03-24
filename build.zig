const std = @import("std");

const CrossTarget = std.zig.CrossTarget;
const Mode = std.builtin.Mode;
const CompileStep = std.build.CompileStep;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zigrepro",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Add misclib library dependency
    exe.addAnonymousModule("misclib", .{ .source_file = .{ .path = "src/misclib/main.zig" } });
    exe.linkLibrary(misclib(b, target, optimize));

    // THIS HERE is required or else compilation of src/misclib/main.zig fails
    // on the import line as it can't find the misc.h header file.
    exe.addIncludePath("src/misclib");

    exe.install();

    const run_cmd = exe.run();

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn misclib(b: *std.Build, target: CrossTarget, optimize: Mode) *CompileStep {
    const lib = b.addStaticLibrary(.{
        .name = "misclib",
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibC();
    lib.addCSourceFile("src/misclib/misc.c", &.{});
    lib.addIncludePath("src/misclib");
    return lib;
}
