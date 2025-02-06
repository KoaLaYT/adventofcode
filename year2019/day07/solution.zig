const std = @import("std");

const Opcode = enum(i32) {
    add = 1,
    mul,
    saveInput,
    output,
    jumpTrue,
    jumpFalse,
    lessThan,
    equal,
    halt = 99,
};

const IntcodeComputer = struct {
    initProgram: std.ArrayList(i32),
    program: std.ArrayList(i32),
    inputs: std.ArrayList(i32),
    outputs: std.ArrayList(i32),
    pc: usize,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, program: std.ArrayList(i32)) Self {
        var initProgram = std.ArrayList(i32).initCapacity(allocator, program.capacity) catch unreachable;
        initProgram.appendSliceAssumeCapacity(program.items);
        return .{
            .initProgram = initProgram,
            .program = program,
            .inputs = std.ArrayList(i32).init(allocator),
            .outputs = std.ArrayList(i32).init(allocator),
            .pc = 0,
        };
    }

    fn deinit(self: Self) void {
        self.initProgram.deinit();
        self.program.deinit();
        self.inputs.deinit();
        self.outputs.deinit();
    }

    fn reset(self: *Self) void {
        @memcpy(self.program.items[0..], self.initProgram.items);
        self.inputs.clearRetainingCapacity();
        self.outputs.clearRetainingCapacity();
        self.pc = 0;
    }

    fn addInput(self: *Self, input: i32) void {
        self.inputs.insert(0, input) catch unreachable;
    }

    fn lastOutput(self: Self) i32 {
        std.debug.assert(self.outputs.items.len > 0);
        return self.outputs.items[self.outputs.items.len - 1];
    }

    fn runOpSaveInput(self: *Self) bool {
        const p: usize = @intCast(self.program.items[self.pc + 1]);
        const maybeInput = self.inputs.popOrNull();
        if (maybeInput) |input| {
            self.program.items[p] = input;
            self.pc += 2;
            return true;
        } else {
            return false;
        }
    }

    fn runOpOutput(self: *Self, mode: i32) void {
        const p = self.program.items[self.pc + 1];
        const output = switch (mode) {
            0 => self.program.items[@as(usize, @intCast(p))],
            1 => p,
            else => unreachable,
        };
        self.outputs.append(output) catch unreachable;
        self.pc += 2;
    }

    fn getParam2(self: *Self, mode: i32) [2]i32 {
        const p1 = self.program.items[self.pc + 1];
        const p2 = self.program.items[self.pc + 2];

        var v1: i32 = undefined;
        var v2: i32 = undefined;

        switch (mode) {
            0 => {
                v1 = self.program.items[@as(usize, @intCast(p1))];
                v2 = self.program.items[@as(usize, @intCast(p2))];
            },
            1 => {
                v1 = p1;
                v2 = self.program.items[@as(usize, @intCast(p2))];
            },
            10 => {
                v1 = self.program.items[@as(usize, @intCast(p1))];
                v2 = p2;
            },
            11 => {
                v1 = p1;
                v2 = p2;
            },
            else => {
                std.debug.print("unknown mode {} of {}\n", .{ mode, v1 });
                unreachable;
            },
        }

        return [2]i32{ v1, v2 };
    }

    fn runOpAdd(self: *Self, mode: i32) void {
        const vs = self.getParam2(mode);

        const p3: usize = @intCast(self.program.items[self.pc + 3]);
        self.program.items[p3] = vs[0] + vs[1];

        self.pc += 4;
    }

    fn runOpMul(self: *Self, mode: i32) void {
        const vs = self.getParam2(mode);

        const p3: usize = @intCast(self.program.items[self.pc + 3]);
        self.program.items[p3] = vs[0] * vs[1];

        self.pc += 4;
    }

    fn runOpJumpTrue(self: *Self, mode: i32) void {
        const vs = self.getParam2(mode);
        if (vs[0] != 0) {
            self.pc = @intCast(vs[1]);
        } else {
            self.pc += 3;
        }
    }

    fn runOpJumpFalse(self: *Self, mode: i32) void {
        const vs = self.getParam2(mode);
        if (vs[0] == 0) {
            self.pc = @intCast(vs[1]);
        } else {
            self.pc += 3;
        }
    }

    fn runOpLessThan(self: *Self, mode: i32) void {
        const vs = self.getParam2(mode);
        const p3: usize = @intCast(self.program.items[self.pc + 3]);
        self.program.items[p3] = if (vs[0] < vs[1]) 1 else 0;
        self.pc += 4;
    }

    fn runOpEqual(self: *Self, mode: i32) void {
        const vs = self.getParam2(mode);
        const p3: usize = @intCast(self.program.items[self.pc + 3]);
        self.program.items[p3] = if (vs[0] == vs[1]) 1 else 0;
        self.pc += 4;
    }

    fn run(self: *Self) bool {
        while (self.pc < self.program.items.len) {
            const v = self.program.items[self.pc];
            const opcode: Opcode = @enumFromInt(@rem(v, 100));
            const mode: i32 = @divFloor(v, 100);

            switch (opcode) {
                .add => self.runOpAdd(mode),
                .mul => self.runOpMul(mode),
                .saveInput => {
                    const can_continue = self.runOpSaveInput();
                    if (!can_continue) return false;
                },
                .output => self.runOpOutput(mode),
                .jumpTrue => self.runOpJumpTrue(mode),
                .jumpFalse => self.runOpJumpFalse(mode),
                .lessThan => self.runOpLessThan(mode),
                .equal => self.runOpEqual(mode),
                .halt => return true,
            }
        }

        unreachable;
    }
};

fn parseInput(allocator: std.mem.Allocator, input_file: []const u8) !std.ArrayList(i32) {
    const f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();
    const r = f.reader();

    var buf: [256]u8 = undefined;
    var bs = std.io.fixedBufferStream(buf[0..]);
    const w = bs.writer();

    var list = std.ArrayList(i32).init(allocator);
    while (true) {
        bs.reset();
        if (r.streamUntilDelimiter(w, ',', null)) |_| {
            const v = try std.fmt.parseInt(i32, bs.getWritten(), 10);
            try list.append(v);
        } else |err| switch (err) {
            error.EndOfStream => {
                const left = std.mem.trimRight(u8, bs.getWritten(), "\n");
                if (left.len > 0) {
                    const v = try std.fmt.parseInt(i32, left, 10);
                    try list.append(v);
                }
                break;
            },
            else => unreachable,
        }
    }
    return list;
}

fn premutate(comptime N: usize, arr: []i32, idx: u32, used: []bool, list: *std.ArrayList([N]i32)) void {
    if (idx == arr.len) {
        var copy: [N]i32 = undefined;
        @memcpy(copy[0..], arr);
        list.append(copy) catch unreachable;
        return;
    }

    for (used, 0..) |used_ele, ele| {
        if (used_ele) continue;
        arr[idx] = @as(i32, @intCast(ele));
        used[ele] = true;
        premutate(N, arr, idx + 1, used, list);
        used[ele] = false;
    }
}

fn genAllPremutate(comptime N: usize, allocator: std.mem.Allocator) std.ArrayList([N]i32) {
    var list = std.ArrayList([N]i32).init(allocator);
    var arr: [N]i32 = undefined;
    var used: [N]bool = undefined;
    @memset(used[0..], false);
    premutate(N, arr[0..], 0, used[0..], &list);
    return list;
}

fn doLargestOutput(allocator: std.mem.Allocator, program: std.ArrayList(i32)) i32 {
    var c = IntcodeComputer.init(allocator, program);
    defer c.deinit();

    const perms = genAllPremutate(5, allocator);
    defer perms.deinit();

    var highest: i32 = std.math.minInt(i32);
    for (perms.items) |perm| {
        var lastOutput: i32 = 0;
        for (perm) |input| {
            c.reset();
            c.addInput(input);
            c.addInput(lastOutput);
            std.debug.assert(c.run());
            lastOutput = c.lastOutput();
        }
        highest = @max(highest, lastOutput);
    }

    return highest;
}

fn doFeedbackLoop(allocator: std.mem.Allocator, program: std.ArrayList(i32)) i32 {
    var amps: [5]IntcodeComputer = undefined;
    for (0..5) |i| {
        var copy = std.ArrayList(i32).initCapacity(allocator, program.items.len) catch unreachable;
        copy.appendSlice(program.items) catch unreachable;
        amps[i] = IntcodeComputer.init(allocator, copy);
    }
    program.deinit();
    defer {
        for (0..5) |i| {
            amps[i].deinit();
        }
    }

    const perms = genAllPremutate(5, allocator);
    defer perms.deinit();

    var highest: i32 = std.math.minInt(i32);
    for (perms.items) |perm| {
        for (0..5) |i| {
            amps[i].reset();
            amps[i].addInput(perm[i] + 5);
        }
        amps[0].addInput(0);

        var idx: usize = 0;
        while (true) {
            const halt = amps[idx].run();
            if (!halt or idx < amps.len - 1) {
                const lastOutput = amps[idx].lastOutput();
                idx = (idx + 1) % amps.len;
                amps[idx].addInput(lastOutput);
                continue;
            }

            std.debug.assert(halt and idx == amps.len - 1);
            highest = @max(highest, amps[idx].lastOutput());
            break;
        }
    }

    return highest;
}

pub fn largestOutput(input_file: []const u8) i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const program = parseInput(allocator, input_file) catch unreachable;
    return doLargestOutput(allocator, program);
}

pub fn feedbackLoop(input_file: []const u8) i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const program = parseInput(allocator, input_file) catch unreachable;
    return doFeedbackLoop(allocator, program);
}

const testing = std.testing;

test "premutate" {
    const perms = genAllPremutate(5, testing.allocator);
    defer perms.deinit();
    try testing.expectEqual(120, perms.items.len);
    try testing.expectEqualSlices(i32, &.{ 0, 1, 2, 3, 4 }, &perms.items[0]);
}

test "doLargestOutput" {
    const TestCase = struct {
        program: []const i32,
        expect: i32,
    };

    const test_cases = [_]TestCase{
        .{
            .program = &.{ 3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0 },
            .expect = 43210,
        },
        .{
            .program = &.{ 3, 23, 3, 24, 1002, 24, 10, 24, 1002, 23, -1, 23, 101, 5, 23, 23, 1, 24, 23, 23, 4, 23, 99, 0, 0 },
            .expect = 54321,
        },
        .{
            .program = &.{ 3, 31, 3, 32, 1002, 32, 10, 32, 1001, 31, -2, 31, 1007, 31, 0, 33, 1002, 33, 7, 33, 1, 33, 31, 31, 1, 32, 31, 31, 4, 31, 99, 0, 0, 0 },
            .expect = 65210,
        },
    };

    for (test_cases) |tt| {
        var program = std.ArrayList(i32).init(testing.allocator);
        try program.appendSlice(tt.program);

        const got = doLargestOutput(testing.allocator, program);
        try testing.expectEqual(tt.expect, got);
    }
}

test "doFeedbackLoop" {
    const TestCase = struct {
        program: []const i32,
        expect: i32,
    };

    const test_cases = [_]TestCase{
        .{
            .program = &.{ 3, 26, 1001, 26, -4, 26, 3, 27, 1002, 27, 2, 27, 1, 27, 26, 27, 4, 27, 1001, 28, -1, 28, 1005, 28, 6, 99, 0, 0, 5 },
            .expect = 139629729,
        },
        .{
            .program = &.{ 3, 52, 1001, 52, -5, 52, 3, 53, 1, 52, 56, 54, 1007, 54, 5, 55, 1005, 55, 26, 1001, 54, -5, 54, 1105, 1, 12, 1, 53, 54, 53, 1008, 54, 0, 55, 1001, 55, 1, 55, 2, 53, 55, 53, 4, 53, 1001, 56, -1, 56, 1005, 56, 6, 99, 0, 0, 0, 0, 10 },
            .expect = 18216,
        },
    };

    for (test_cases) |tt| {
        var program = std.ArrayList(i32).init(testing.allocator);
        try program.appendSlice(tt.program);

        const got = doFeedbackLoop(testing.allocator, program);
        try testing.expectEqual(tt.expect, got);
    }
}
