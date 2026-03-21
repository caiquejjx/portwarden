const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("portwarden", .{
        .root_source_file = b.path("core/ports.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "portwarden",
        .root_module = b.createModule(.{
            .root_source_file = b.path("core/ports.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "portwarden", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    const lib = b.addLibrary(.{
        .name = "ports",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("core/ports.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const header = lib.getEmittedH();

    const install_lib = b.addInstallArtifact(lib, .{
        .dest_dir = .{
            .override = .{ .custom = "../macos/portwarden" },
        },
    });

    const install_header = b.addInstallFile(
        header,
        "../macos/portwarden/ports.h",
    );
    b.getInstallStep().dependOn(&install_lib.step);
    b.getInstallStep().dependOn(&install_header.step);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    // A run step that will run the second test executable.
    const run_exe_tests = b.addRunArtifact(exe_tests);

    // A top level step for running all tests. dependOn can be called multiple
    // times and since the two run steps do not depend on one another, this will
    // make the two of them run in parallel.
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
