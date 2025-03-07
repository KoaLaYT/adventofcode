const std = @import("std");
const Allocator = std.mem.Allocator;

fn keepOnesDigit(v: i32) i8 {
    const n = @abs(v);
    return @intCast(n % 10);
}

fn sliceFromStr(allocator: Allocator, str: []const u8) ![]i8 {
    var buf = try allocator.alloc(i8, str.len);
    for (str, 0..) |c, i| {
        buf[i] = @intCast(c - '0');
    }
    return buf;
}

fn buildPatterns(pattern: []i8, offset: usize) void {
    const base_pattern = [4]i8{ 0, 1, 0, -1 };
    var j: usize = 0;
    var reset = offset;
    for (0..pattern.len) |i| {
        pattern[i] = base_pattern[j];
        if (reset == 0) {
            reset = offset;
            j = (j + 1) % base_pattern.len;
        } else {
            reset -= 1;
        }
    }
}

fn fft(allocator: Allocator, input: []i8, phase: usize) !void {
    const buf = try allocator.alloc(i8, input.len);
    const pattern = try allocator.alloc(i8, input.len + 1);
    defer allocator.free(buf);
    defer allocator.free(pattern);

    for (0..phase) |_| {
        for (0..input.len) |i| {
            buildPatterns(pattern, i);
            var v: i32 = 0;
            for (0..input.len) |j| {
                v += input[j] * pattern[j + 1];
            }
            buf[i] = keepOnesDigit(v);
        }
        @memcpy(input, buf[0..]);
    }
}

// ensure patterns are always
// - 1 1 1 ...
// - 0 1 1 ...
// - 0 0 1 ...
fn fft2(input: []i8, phase: usize) void {
    for (0..phase) |_| {
        var sum: i32 = 0;
        for (input) |v| {
            sum += v;
        }
        for (0..input.len) |i| {
            const next_sum = sum - input[i];
            input[i] = keepOnesDigit(sum);
            sum = next_sum;
        }
    }
}

fn doFirstEightOfFFT(input_file: []const u8, output: []u8) !void {
    const f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();

    var buf: [4096]u8 = undefined;
    const n = try f.readAll(buf[0..]);
    std.debug.assert(n == try f.getEndPos());
    std.debug.assert(buf[n - 1] == '\n');

    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const input = try sliceFromStr(allocator, buf[0 .. n - 1]);
    defer allocator.free(input);
    try fft(allocator, input, 100);

    for (0..8) |i| {
        output[i] = @intCast(input[i] + '0');
    }
}

fn toOffset(input: []i8) usize {
    var v: i32 = 0;
    for (input) |n| {
        v = 10 * v + n;
    }
    return @intCast(v);
}

fn largeFFT(allocator: Allocator, input: []i8, phase: usize) !void {
    var repeated_input = try allocator.alloc(i8, 10000 * input.len);
    defer allocator.free(repeated_input);

    for (0..10000) |i| {
        @memcpy(repeated_input[i * input.len .. (i + 1) * input.len], input);
    }

    const offset = toOffset(repeated_input[0..7]);
    const offset_input = repeated_input[offset..];

    std.debug.assert(offset_input.len < offset);
    fft2(offset_input, phase);
    @memcpy(input[0..8], offset_input[0..8]);
}

fn doRealSignal(input_file: []const u8, output: []u8) !void {
    const f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();

    var buf: [4096]u8 = undefined;
    const n = try f.readAll(buf[0..]);
    std.debug.assert(n == try f.getEndPos());
    std.debug.assert(buf[n - 1] == '\n');

    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const input = try sliceFromStr(allocator, buf[0 .. n - 1]);
    defer allocator.free(input);
    try largeFFT(allocator, input, 100);

    for (0..8) |i| {
        output[i] = @intCast(input[i] + '0');
    }
}

pub fn firstEightOfFFT(input_file: []const u8, output: []u8) void {
    doFirstEightOfFFT(input_file, output) catch unreachable;
}

pub fn realSignal(input_file: []const u8, output: []u8) void {
    doRealSignal(input_file, output) catch unreachable;
}

const testing = std.testing;

test "fft" {
    const TestCase = struct {
        input: []const u8,
        phase: usize,
        expect: []const i8,
    };

    const test_cases = [_]TestCase{
        .{
            .input = "12345678",
            .phase = 4,
            .expect = &[_]i8{ 0, 1, 0, 2, 9, 4, 9, 8 },
        },
        .{
            .input = "80871224585914546619083218645595",
            .phase = 100,
            .expect = &[_]i8{ 2, 4, 1, 7, 6, 1, 7, 6 },
        },
        .{
            .input = "19617804207202209144916044189917",
            .phase = 100,
            .expect = &[_]i8{ 7, 3, 7, 4, 5, 4, 1, 8 },
        },
        .{
            .input = "69317163492948606335995924319873",
            .phase = 100,
            .expect = &[_]i8{ 5, 2, 4, 3, 2, 1, 3, 3 },
        },
    };

    for (test_cases) |tt| {
        const buf = try sliceFromStr(testing.allocator, tt.input);
        defer testing.allocator.free(buf);
        try fft(testing.allocator, buf, tt.phase);
        try testing.expectEqualSlices(i8, tt.expect, buf[0..tt.expect.len]);
    }
}

test "largeFFT" {
    const TestCase = struct {
        input: []const u8,
        phase: usize,
        expect: []const i8,
    };

    const test_cases = [_]TestCase{
        .{
            .input = "03036732577212944063491565474664",
            .phase = 100,
            .expect = &[_]i8{ 8, 4, 4, 6, 2, 0, 2, 6 },
        },
        .{
            .input = "02935109699940807407585447034323",
            .phase = 100,
            .expect = &[_]i8{ 7, 8, 7, 2, 5, 2, 7, 0 },
        },
        .{
            .input = "03081770884921959731165446850517",
            .phase = 100,
            .expect = &[_]i8{ 5, 3, 5, 5, 3, 7, 3, 1 },
        },
    };

    for (test_cases) |tt| {
        const buf = try sliceFromStr(testing.allocator, tt.input);
        defer testing.allocator.free(buf);
        try largeFFT(testing.allocator, buf, tt.phase);
        try testing.expectEqualSlices(i8, tt.expect, buf[0..tt.expect.len]);
    }
}
