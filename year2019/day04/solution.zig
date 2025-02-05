const std = @import("std");

fn meetCriteria(num: u32) bool {
    var left = num;
    var base: u32 = 100000;
    var prev_d: u32 = 0;
    var eq: u32 = 0;

    while (base > 0) {
        const d = left / base;

        if (d < prev_d) return false;
        if (d == prev_d) eq += 1;

        left %= base;
        base /= 10;
        prev_d = d;
    }

    return eq >= 1;
}

fn meetCriteria2(num: u32) bool {
    var left = num;
    var base: u32 = 100000;
    var prev_d: u32 = 0;
    var dup: [10]u8 = undefined;
    @memset(&dup, 0);

    while (base > 0) {
        const d = left / base;

        if (d < prev_d) return false;
        dup[@intCast(d)] += 1;

        left %= base;
        base /= 10;
        prev_d = d;
    }

    for (dup) |d| {
        if (d == 2) return true;
    }
    return false;
}

pub fn countPasswords(input_file: []const u8) u32 {
    _ = input_file;

    var count: u32 = 0;

    const from: u32 = 265275;
    const to: u32 = 781584 + 1;
    for (from..to) |_input| {
        const input: u32 = @intCast(_input);
        if (meetCriteria(input)) count += 1;
    }

    return count;
}

pub fn countPasswords2(input_file: []const u8) u32 {
    _ = input_file;

    var count: u32 = 0;

    const from: u32 = 265275;
    const to: u32 = 781584 + 1;
    for (from..to) |_input| {
        const input: u32 = @intCast(_input);
        if (meetCriteria2(input)) count += 1;
    }

    return count;
}

const testing = std.testing;

test "meetCriteria" {
    const TestCase = struct {
        input: u32,
        expect: bool,
    };

    const test_cases = [_]TestCase{
        .{ .input = 111111, .expect = true },
        .{ .input = 223450, .expect = false },
        .{ .input = 123789, .expect = false },
    };

    for (test_cases) |tt| {
        const got = meetCriteria(tt.input);
        try testing.expectEqual(tt.expect, got);
    }
}

test "meetCriteria2" {
    const TestCase = struct {
        input: u32,
        expect: bool,
    };

    const test_cases = [_]TestCase{
        .{ .input = 112233, .expect = true },
        .{ .input = 123444, .expect = false },
        .{ .input = 111122, .expect = true },
    };

    for (test_cases) |tt| {
        const got = meetCriteria2(tt.input);
        try testing.expectEqual(tt.expect, got);
    }
}
