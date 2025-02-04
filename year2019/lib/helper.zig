const std = @import("std");
const Timer = std.time.Timer;
const stdout = std.io.getStdOut().writer();

pub fn solve(comptime T: anytype, comptime tag: []const u8, f: *const fn (inputFile: []const u8) T) !void {
    var args = std.process.args();
    _ = args.next();
    const inputFile = args.next().?;

    try stdout.print(">>>> {s} <<<<\n", .{tag});
    var timer = try Timer.start();
    const result = f(inputFile);
    const elapsed: f64 = @floatFromInt(timer.read());
    try stdout.print("Answer: {}\n", .{result});
    try stdout.print("Took: {d:.3}ms\n", .{elapsed / std.time.ns_per_ms});
}
