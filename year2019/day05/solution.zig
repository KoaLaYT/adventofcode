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
    program: std.ArrayList(i32),
    input: i32,
    pc: usize,
    outputs: std.ArrayList(i32),

    const Self = @This();

    fn init(allocator: std.mem.Allocator, program: std.ArrayList(i32)) Self {
        return .{
            .program = program,
            .input = 0,
            .pc = 0,
            .outputs = std.ArrayList(i32).init(allocator),
        };
    }

    fn deinit(self: Self) void {
        self.program.deinit();
        self.outputs.deinit();
    }

    fn lastOutput(self: Self) i32 {
        std.debug.assert(self.outputs.items.len > 0);
        return self.outputs.items[self.outputs.items.len - 1];
    }

    fn runOpSaveInput(self: *Self) void {
        const p: usize = @intCast(self.program.items[self.pc + 1]);
        self.program.items[p] = self.input;
        self.pc += 2;
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

    fn run(self: *Self) void {
        while (self.pc < self.program.items.len) {
            const v = self.program.items[self.pc];
            const opcode: Opcode = @enumFromInt(@rem(v, 100));
            const mode: i32 = @divFloor(v, 100);

            switch (opcode) {
                .add => self.runOpAdd(mode),
                .mul => self.runOpMul(mode),
                .saveInput => self.runOpSaveInput(),
                .output => self.runOpOutput(mode),
                .jumpTrue => self.runOpJumpTrue(mode),
                .jumpFalse => self.runOpJumpFalse(mode),
                .lessThan => self.runOpLessThan(mode),
                .equal => self.runOpEqual(mode),
                .halt => return,
            }
        }
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

pub fn diagnosticCode(input_file: []const u8) i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const list = parseInput(allocator, input_file) catch unreachable;
    var c = IntcodeComputer.init(allocator, list);
    defer c.deinit();

    c.input = 1;
    c.run();

    for (c.outputs.items, 0..) |output, i| {
        if (i < c.outputs.items.len - 1) {
            std.debug.assert(output == 0);
        } else {
            return output;
        }
    }

    unreachable;
}

pub fn diagnosticCode2(input_file: []const u8) i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const list = parseInput(allocator, input_file) catch unreachable;
    var c = IntcodeComputer.init(allocator, list);
    defer c.deinit();

    c.input = 5;
    c.run();

    return c.lastOutput();
}

const testing = std.testing;

test "Intcode Computer run" {
    const TestCase = struct {
        program: []const i32,
        input: i32,
        expect: i32,
    };

    const test_cases = [_]TestCase{
        .{
            .program = &.{ 3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8 },
            .input = 8,
            .expect = 1,
        },
        .{
            .program = &.{ 3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8 },
            .input = 7,
            .expect = 0,
        },
        .{
            .program = &.{ 3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8 },
            .input = 7,
            .expect = 1,
        },
        .{
            .program = &.{ 3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8 },
            .input = 8,
            .expect = 0,
        },
        .{
            .program = &.{ 3, 3, 1108, -1, 8, 3, 4, 3, 99 },
            .input = 8,
            .expect = 1,
        },
        .{
            .program = &.{ 3, 3, 1108, -1, 8, 3, 4, 3, 99 },
            .input = 102,
            .expect = 0,
        },
        .{
            .program = &.{ 3, 3, 1107, -1, 8, 3, 4, 3, 99 },
            .input = 1,
            .expect = 1,
        },
        .{
            .program = &.{ 3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9 },
            .input = 0,
            .expect = 0,
        },
        .{
            .program = &.{ 3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9 },
            .input = 123,
            .expect = 1,
        },
        .{
            .program = &.{ 3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1 },
            .input = 0,
            .expect = 0,
        },
        .{
            .program = &.{ 3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1 },
            .input = 1,
            .expect = 1,
        },
        .{
            .program = &.{ 3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99 },
            .input = 0,
            .expect = 999,
        },
        .{
            .program = &.{ 3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99 },
            .input = 7,
            .expect = 999,
        },
        .{
            .program = &.{ 3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99 },
            .input = 8,
            .expect = 1000,
        },
        .{
            .program = &.{ 3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99 },
            .input = 9,
            .expect = 1001,
        },
        .{
            .program = &.{ 3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36, 98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000, 1, 20, 4, 20, 1105, 1, 46, 98, 99 },
            .input = 9123,
            .expect = 1001,
        },
    };

    for (test_cases) |tt| {
        var program = std.ArrayList(i32).init(testing.allocator);
        try program.appendSlice(tt.program);

        var c = IntcodeComputer.init(testing.allocator, program);
        defer c.deinit();

        c.input = tt.input;
        c.run();
        const got = c.lastOutput();

        try testing.expectEqual(tt.expect, got);
    }
}
