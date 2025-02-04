const std = @import("std");

fn parseInput(allocator: std.mem.Allocator, inputFile: []const u8) !std.ArrayList(u32) {
    const f = try std.fs.cwd().openFile(inputFile, .{});
    defer f.close();

    var buf: [1024]u8 = undefined;
    @memset(buf[0..], 0);
    const i = try f.readAll(buf[0..]);

    const trimmed = std.mem.trim(u8, buf[0..i], "\n ");
    var parts = std.mem.splitScalar(u8, trimmed, ',');

    var list = std.ArrayList(u32).init(allocator);
    while (parts.next()) |part| {
        const v = try std.fmt.parseInt(u32, part, 10);
        try list.append(v);
    }
    return list;
}

fn runProgram(list: std.ArrayList(u32)) void {
    var i: usize = 0;
    while (list.items[i] != 99) {
        const opcode = list.items[i];
        const p1 = list.items[i + 1];
        const p2 = list.items[i + 2];
        const p3 = list.items[i + 3];

        switch (opcode) {
            1 => list.items[p3] = list.items[p1] + list.items[p2],
            2 => list.items[p3] = list.items[p1] * list.items[p2],
            99 => continue,
            else => {
                std.debug.print("unknown opcode {} at idx {}\n", .{ opcode, i });
                unreachable;
            },
        }

        i += 4;
    }
}

pub fn restoreGravityAssistProgram(inputFile: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list = parseInput(allocator, inputFile) catch unreachable;
    defer list.deinit();

    list.items[1] = 12;
    list.items[2] = 2;
    runProgram(list);

    return list.items[0];
}

fn resetProgram(dst: std.ArrayList(u32), src: std.ArrayList(u32)) void {
    std.debug.assert(dst.items.len == src.items.len);
    for (dst.items, 0..) |_, i| {
        dst.items[i] = src.items[i];
    }
}

pub fn nounAndVerbToProduceOutput(inputFile: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var templ = parseInput(allocator, inputFile) catch |err| {
        @panic(@errorName(err));
    };
    defer templ.deinit();

    var list = templ.clone() catch unreachable;

    for (0..100) |_noun| {
        for (0..100) |_verb| {
            const noun: u32 = @intCast(_noun);
            const verb: u32 = @intCast(_verb);

            resetProgram(list, templ);
            list.items[1] = noun;
            list.items[2] = verb;
            runProgram(list);
            if (list.items[0] == 19690720) {
                return 100 * noun + verb;
            }
        }
    }

    unreachable;
}

const testing = std.testing;
test "runProgram" {
    const allocator = testing.allocator;

    var list = std.ArrayList(u32).init(allocator);
    defer list.deinit();

    const TestCase = struct {
        input: []const u32,
        expect: []const u32,
    };

    const testCases = [_]TestCase{
        .{
            .input = &[_]u32{ 1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50 },
            .expect = &[_]u32{ 3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50 },
        },
        .{
            .input = &[_]u32{ 1, 0, 0, 0, 99 },
            .expect = &[_]u32{ 2, 0, 0, 0, 99 },
        },
        .{
            .input = &[_]u32{ 2, 3, 0, 3, 99 },
            .expect = &[_]u32{ 2, 3, 0, 6, 99 },
        },
        .{
            .input = &[_]u32{ 2, 4, 4, 5, 99, 0 },
            .expect = &[_]u32{ 2, 4, 4, 5, 99, 9801 },
        },
        .{
            .input = &[_]u32{ 1, 1, 1, 4, 99, 5, 6, 0, 99 },
            .expect = &[_]u32{ 30, 1, 1, 4, 2, 5, 6, 0, 99 },
        },
    };

    for (testCases) |tt| {
        list.clearRetainingCapacity();
        try list.appendSlice(tt.input[0..]);
        runProgram(list);
        try testing.expectEqualSlices(u32, tt.expect[0..], list.items[0..]);
    }
}
