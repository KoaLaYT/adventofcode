const std = @import("std");

fn parseInput(allocator: std.mem.Allocator, inputFile: []const u8) !std.ArrayList(u32) {
    var f = try std.fs.cwd().openFile(inputFile, .{});
    defer f.close();
    var bf = std.io.bufferedReader(f.reader());
    const r = bf.reader();

    var buf: [64]u8 = undefined;
    var ws = std.io.fixedBufferStream(buf[0..]);
    const w = ws.writer();

    var list = std.ArrayList(u32).init(allocator);

    while (true) {
        ws.reset();
        if (r.streamUntilDelimiter(w, '\n', null)) |_| {
            const v = try std.fmt.parseInt(u32, ws.getWritten(), 10);
            try list.append(v);
        } else |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        }
    }

    return list;
}

fn fuelRequired(mass: u32) u32 {
    const v = mass / 3;
    if (v < 2) return 0;
    return v - 2;
}

fn fuelTotalRequired(mass: u32) u32 {
    var v = mass;
    var sum: u32 = 0;

    while (v > 0) {
        v = fuelRequired(v);
        sum += v;
    }

    return sum;
}

pub fn sumOfFuelRequirements(inputFile: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = parseInput(allocator, inputFile) catch |err| {
        @panic(@errorName(err));
    };
    defer list.deinit();

    var sum: u32 = 0;
    for (list.items) |mass| {
        sum += fuelRequired(mass);
    }
    return sum;
}

pub fn sumOfFuelTotalRequirements(inputFile: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = parseInput(allocator, inputFile) catch |err| {
        @panic(@errorName(err));
    };
    defer list.deinit();

    var sum: u32 = 0;
    for (list.items) |mass| {
        sum += fuelTotalRequired(mass);
    }
    return sum;
}

const testing = std.testing;
test "fuelRequired" {
    const TestCase = struct {
        input: u32,
        expect: u32,
    };

    const testCases = [_]TestCase{
        .{ .input = 12, .expect = 2 },
        .{ .input = 14, .expect = 2 },
        .{ .input = 1969, .expect = 654 },
        .{ .input = 100756, .expect = 33583 },
    };

    for (testCases) |tt| {
        const got = fuelRequired(tt.input);
        try testing.expectEqual(tt.expect, got);
    }
}

test "fuelTotalRequired" {
    const TestCase = struct {
        input: u32,
        expect: u32,
    };

    const testCases = [_]TestCase{
        .{ .input = 14, .expect = 2 },
        .{ .input = 1969, .expect = 966 },
        .{ .input = 100756, .expect = 50346 },
    };

    for (testCases) |tt| {
        const got = fuelTotalRequired(tt.input);
        try testing.expectEqual(tt.expect, got);
    }
}
