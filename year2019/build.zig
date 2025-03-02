const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_source_file = b.path("lib/helper.zig");
    const lib_mod = b.addModule("helper", .{ .root_source_file = root_source_file });

    var dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    defer dir.close();
    var it = dir.iterate();
    while (try it.next()) |entry| {
        const isDay = std.mem.startsWith(u8, entry.name, "day");
        if (!isDay) continue;

        const desc = b.fmt("Run {s}", .{entry.name});
        const source = b.fmt("{s}/main.zig", .{entry.name});
        const arg = b.fmt("{s}/input.txt", .{entry.name});

        const day = b.addExecutable(.{
            .name = entry.name,
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path(source),
        });
        day.root_module.addImport("helper", lib_mod);
        b.installArtifact(day);

        const example_run = b.addRunArtifact(day);
        example_run.step.dependOn(b.getInstallStep());
        const args = [_][]const u8{arg};
        example_run.addArgs(&args);

        const day_step = b.step(entry.name, desc);
        day_step.dependOn(&example_run.step);
    }
}
