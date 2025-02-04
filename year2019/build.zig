const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_source_file = b.path("lib/helper.zig");
    const lib_mod = b.addModule("helper", .{ .root_source_file = root_source_file });

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var dir = try std.fs.cwd().openDir(".", .{ .iterate = true });
    defer dir.close();
    var it = dir.iterate();
    while (try it.next()) |entry| {
        const isDay = std.mem.startsWith(u8, entry.name, "day");
        if (!isDay) continue;

        const desc = try std.fmt.allocPrint(allocator, "Run {s}", .{entry.name});
        defer allocator.free(desc);
        const source = try std.fmt.allocPrint(allocator, "{s}/main.zig", .{entry.name});
        defer allocator.free(source);
        const arg = try std.fmt.allocPrint(allocator, "{s}/input.txt", .{entry.name});
        defer allocator.free(arg);

        const day_step = b.step(entry.name, desc);
        const day = b.addExecutable(.{
            .name = entry.name,
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path(source),
        });
        day.root_module.addImport("helper", lib_mod);

        const example_run = b.addRunArtifact(day);
        const args = [_][]const u8{arg};
        example_run.addArgs(&args);
        day_step.dependOn(&example_run.step);
    }
}
