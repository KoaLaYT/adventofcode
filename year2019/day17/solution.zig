const std = @import("std");
const Allocator = std.mem.Allocator;

const Dir = enum(u8) {
    up,
    right,
    down,
    left,

    const Self = @This();

    fn toDxy(self: Self) struct { isize, isize } {
        var dx: isize = 0;
        var dy: isize = 0;

        switch (self) {
            .up => dy = -1,
            .right => dx = 1,
            .down => dy = 1,
            .left => dx = -1,
        }

        return .{ dx, dy };
    }

    fn turnLeft(self: Self) Self {
        return switch (self) {
            .up => .left,
            .right => .up,
            .down => .right,
            .left => .down,
        };
    }

    fn turnRight(self: Self) Self {
        return switch (self) {
            .up => .right,
            .right => .down,
            .down => .left,
            .left => .up,
        };
    }

    fn from(c: u8) !Self {
        return switch (c) {
            '^' => .up,
            '>' => .right,
            'v' => .down,
            '<' => .left,
            else => error.Unknown,
        };
    }
};

const Robot = struct {
    x: usize,
    y: usize,
    dir: Dir,

    const Self = @This();

    fn init(map: Map) Self {
        for (0..map.height) |y| {
            for (0..map.width) |x| {
                const char = map.charAt(@intCast(x), @intCast(y));
                if (Dir.from(char)) |dir| {
                    return .{
                        .x = x,
                        .y = y,
                        .dir = dir,
                    };
                } else |_| continue;
            }
        }
        unreachable();
    }

    fn next(self: Self, dir: Dir, map: Map) u8 {
        const dx, const dy = dir.toDxy();
        const next_x = @as(isize, @intCast(self.x)) + dx;
        const next_y = @as(isize, @intCast(self.y)) + dy;
        return map.charAt(next_x, next_y);
    }

    fn move(self: *Self) void {
        const dx, const dy = self.dir.toDxy();

        const new_x = @as(isize, @intCast(self.x)) + dx;
        const new_y = @as(isize, @intCast(self.y)) + dy;

        self.x = @intCast(new_x);
        self.y = @intCast(new_y);
    }

    fn goStraight(self: *Self, map: Map, buf: []u8, idx: usize) !usize {
        var n: usize = 0;
        while (true) {
            if (self.next(self.dir, map) == '#') {
                self.move();
                n += 1;
            } else {
                break;
            }
        }
        if (n > 0) {
            const written = try std.fmt.bufPrint(buf[idx..], "{},", .{n});
            return idx + written.len;
        }
        return idx;
    }

    fn tryTurn(self: *Self, map: Map, buf: []u8, idx: usize) !struct { usize, bool } {
        if (self.next(self.dir.turnLeft(), map) == '#') {
            self.dir = self.dir.turnLeft();
            const written = try std.fmt.bufPrint(buf[idx..], "L,", .{});
            return .{ idx + written.len, false };
        }
        if (self.next(self.dir.turnRight(), map) == '#') {
            self.dir = self.dir.turnRight();
            const written = try std.fmt.bufPrint(buf[idx..], "R,", .{});
            return .{ idx + written.len, false };
        }
        return .{ idx, true };
    }
};

const Map = struct {
    width: usize,
    height: usize,
    data: []u8,

    const Self = @This();

    fn init(allocator: Allocator, outputs: []i64) !Self {
        var width: usize = 0;
        var height: usize = 0;
        var i: usize = 0;
        for (outputs) |v| {
            const char: u8 = @intCast(v);
            if (char == '\n' and i > 0) {
                height += 1;
                width = i;
                i = 0;
            } else {
                i += 1;
            }
        }

        var data = try allocator.alloc(u8, width * height);
        i = 0;
        for (0..height) |y| {
            for (0..width) |x| {
                const idx = y * width + x;
                data[idx] = @intCast(outputs[i]);
                i += 1;
            }
            i += 1;
        }

        return .{
            .width = width,
            .height = height,
            .data = data,
        };
    }

    fn deinit(self: Self, allocator: Allocator) void {
        allocator.free(self.data);
    }

    fn genPath(self: Self, allocator: Allocator) ![]u8 {
        const buf = try allocator.alloc(u8, 1024);
        var idx: usize = 0;

        var robot = Robot.init(self);
        var is_end = false;
        while (!is_end) {
            idx = try robot.goStraight(self, buf, idx);
            idx, is_end = try robot.tryTurn(self, buf, idx);
        }

        return try allocator.realloc(buf, idx);
    }

    fn sumOfAlignmentParams(self: Self) u32 {
        var sum: usize = 0;
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                if (self.isIntersection(@intCast(x), @intCast(y))) {
                    sum += x * y;
                }
            }
        }
        return @intCast(sum);
    }

    fn charAt(self: Self, x: isize, y: isize) u8 {
        if (x < 0 or x >= self.width) return 0;
        if (y < 0 or y >= self.height) return 0;
        const idx = @as(usize, @intCast(y)) * self.width + @as(usize, @intCast(x));
        return self.data[idx];
    }

    fn isScaffold(self: Self, x: isize, y: isize) bool {
        const char = self.charAt(x, y);
        return char == '#' or
            char == '^' or
            char == '<' or
            char == '>' or
            char == 'v';
    }

    fn isIntersection(self: Self, x: isize, y: isize) bool {
        return self.isScaffold(x, y) and
            self.isScaffold(x - 1, y) and
            self.isScaffold(x + 1, y) and
            self.isScaffold(x, y - 1) and
            self.isScaffold(x, y + 1);
    }

    fn print(self: Self) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const idx = y * self.width + x;
                std.debug.print("{c}", .{self.data[idx]});
            }
            std.debug.print("\n", .{});
        }
    }
};

const Memory = std.AutoHashMap(usize, i64);

const Mode = enum(u8) {
    position,
    immediate,
    relative,
};

const Opcode = enum(u8) {
    add = 1,
    mul,
    saveInput,
    output,
    jumpTrue,
    jumpFalse,
    lessThan,
    equal,
    adjustRelBase,
    halt = 99,
};

const IntcodeComputer = struct {
    pc: usize,
    rel_base: isize,
    program: std.ArrayList(i64),
    inputs: std.ArrayList(i64),
    outputs: std.ArrayList(i64),
    memory: Memory,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, program: std.ArrayList(i64)) Self {
        return .{
            .pc = 0,
            .rel_base = 0,
            .program = program,
            .inputs = std.ArrayList(i64).init(allocator),
            .outputs = std.ArrayList(i64).init(allocator),
            .memory = Memory.init(allocator),
        };
    }

    fn deinit(self: *Self) void {
        self.program.deinit();
        self.inputs.deinit();
        self.outputs.deinit();
        self.memory.deinit();
    }

    fn addInput(self: *Self, input: i64) void {
        self.inputs.insert(0, input) catch unreachable;
    }

    fn lastOutput(self: Self) i64 {
        std.debug.assert(self.outputs.items.len > 0);
        return self.outputs.items[self.outputs.items.len - 1];
    }
    fn clearOutput(self: *Self) void {
        self.outputs.clearRetainingCapacity();
    }

    fn getAddressAt(self: *Self, p: usize) *i64 {
        if (p < self.program.items.len) {
            return &self.program.items[p];
        }

        const result = self.memory.getOrPut(p) catch unreachable;
        if (!result.found_existing) result.value_ptr.* = 0;
        return result.value_ptr;
    }

    fn getAddressAtBy(self: *Self, mode: Mode, v: i64) *i64 {
        switch (mode) {
            .position => {
                const p = @as(usize, @intCast(v));
                return self.getAddressAt(p);
            },
            .relative => {
                const ip: isize = self.rel_base + @as(isize, @intCast(v));
                const up = @as(usize, @intCast(ip));
                return self.getAddressAt(up);
            },
            .immediate => unreachable,
        }
    }

    fn getParamBy(self: *Self, mode: Mode, v: i64) i64 {
        if (mode == .immediate) return v;
        return self.getAddressAtBy(mode, v).*;
    }

    fn runOpSaveInput(self: *Self, mode: [3]Mode) bool {
        const v = self.program.items[self.pc + 1];
        const ptr = self.getAddressAtBy(mode[0], v);
        ptr.* = self.inputs.pop() orelse return false;
        self.pc += 2;
        return true;
    }

    fn runOpOutput(self: *Self, mode: [3]Mode) void {
        const v = self.program.items[self.pc + 1];
        const output = self.getParamBy(mode[0], v);
        self.outputs.append(output) catch unreachable;
        self.pc += 2;
    }

    fn runOpAdd(self: *Self, mode: [3]Mode) void {
        const v1 = self.program.items[self.pc + 1];
        const v2 = self.program.items[self.pc + 2];
        const v3 = self.program.items[self.pc + 3];

        const p1 = self.getParamBy(mode[0], v1);
        const p2 = self.getParamBy(mode[1], v2);
        const ptr = self.getAddressAtBy(mode[2], v3);
        ptr.* = p1 + p2;
        self.pc += 4;
    }

    fn runOpMul(self: *Self, mode: [3]Mode) void {
        const v1 = self.program.items[self.pc + 1];
        const v2 = self.program.items[self.pc + 2];
        const v3 = self.program.items[self.pc + 3];

        const p1 = self.getParamBy(mode[0], v1);
        const p2 = self.getParamBy(mode[1], v2);
        const ptr = self.getAddressAtBy(mode[2], v3);
        ptr.* = p1 * p2;
        self.pc += 4;
    }

    fn runOpJumpTrue(self: *Self, mode: [3]Mode) void {
        const v1 = self.program.items[self.pc + 1];
        const v2 = self.program.items[self.pc + 2];

        const p1 = self.getParamBy(mode[0], v1);
        const p2 = self.getParamBy(mode[1], v2);

        if (p1 != 0) {
            self.pc = @intCast(p2);
        } else {
            self.pc += 3;
        }
    }

    fn runOpJumpFalse(self: *Self, mode: [3]Mode) void {
        const v1 = self.program.items[self.pc + 1];
        const v2 = self.program.items[self.pc + 2];

        const p1 = self.getParamBy(mode[0], v1);
        const p2 = self.getParamBy(mode[1], v2);

        if (p1 == 0) {
            self.pc = @intCast(p2);
        } else {
            self.pc += 3;
        }
    }

    fn runOpLessThan(self: *Self, mode: [3]Mode) void {
        const v1 = self.program.items[self.pc + 1];
        const v2 = self.program.items[self.pc + 2];
        const v3 = self.program.items[self.pc + 3];

        const p1 = self.getParamBy(mode[0], v1);
        const p2 = self.getParamBy(mode[1], v2);
        const ptr = self.getAddressAtBy(mode[2], v3);

        ptr.* = if (p1 < p2) 1 else 0;
        self.pc += 4;
    }

    fn runOpEqual(self: *Self, mode: [3]Mode) void {
        const v1 = self.program.items[self.pc + 1];
        const v2 = self.program.items[self.pc + 2];
        const v3 = self.program.items[self.pc + 3];

        const p1 = self.getParamBy(mode[0], v1);
        const p2 = self.getParamBy(mode[1], v2);
        const ptr = self.getAddressAtBy(mode[2], v3);

        ptr.* = if (p1 == p2) 1 else 0;
        self.pc += 4;
    }

    fn runOpAdjustRelBase(self: *Self, mode: [3]Mode) void {
        const v = self.program.items[self.pc + 1];
        const p = self.getParamBy(mode[0], v);
        self.rel_base += @as(isize, @intCast(p));
        self.pc += 2;
    }

    fn run(self: *Self) bool {
        while (self.pc < self.program.items.len) {
            const v = self.program.items[self.pc];
            const opcode: Opcode = @enumFromInt(@rem(v, 100));
            const mode = parseMode(@divFloor(v, 100));

            switch (opcode) {
                .add => self.runOpAdd(mode),
                .mul => self.runOpMul(mode),
                .saveInput => {
                    const can_continue = self.runOpSaveInput(mode);
                    if (!can_continue) return false;
                },
                .output => self.runOpOutput(mode),
                .jumpTrue => self.runOpJumpTrue(mode),
                .jumpFalse => self.runOpJumpFalse(mode),
                .lessThan => self.runOpLessThan(mode),
                .equal => self.runOpEqual(mode),
                .adjustRelBase => self.runOpAdjustRelBase(mode),
                .halt => return true,
            }
        }

        unreachable;
    }
};

fn parseMode(raw: i64) [3]Mode {
    var num = raw;
    var mode: [3]Mode = undefined;

    for (0..mode.len) |i| {
        const d = num - @divFloor(num, 10) * 10;
        mode[i] = @enumFromInt(d);

        num = @divFloor(num, 10);
    }

    return mode;
}

fn parseInput(allocator: std.mem.Allocator, input_file: []const u8) !std.ArrayList(i64) {
    const f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();
    const r = f.reader();

    var buf: [256]u8 = undefined;
    var bs = std.io.fixedBufferStream(buf[0..]);
    const w = bs.writer();

    var list = std.ArrayList(i64).init(allocator);
    while (true) {
        bs.reset();
        if (r.streamUntilDelimiter(w, ',', null)) |_| {
            const v = try std.fmt.parseInt(i64, bs.getWritten(), 10);
            try list.append(v);
        } else |err| switch (err) {
            error.EndOfStream => {
                const left = std.mem.trimRight(u8, bs.getWritten(), "\n");
                if (left.len > 0) {
                    const v = try std.fmt.parseInt(i64, left, 10);
                    try list.append(v);
                }
                break;
            },
            else => unreachable,
        }
    }
    return list;
}

fn doSumOfAlignmentParams(input_file: []const u8) !u32 {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const program = try parseInput(allocator, input_file);
    var c = IntcodeComputer.init(allocator, program);
    defer c.deinit();

    const halt = c.run();
    std.debug.assert(halt);

    const map = try Map.init(allocator, c.outputs.items);
    defer map.deinit(allocator);

    return map.sumOfAlignmentParams();
}

pub fn sumOfAlignmentParams(input_file: []const u8) u32 {
    return doSumOfAlignmentParams(input_file) catch unreachable;
}

fn isEqual(path: []const u8, idx: usize, split: []const u8) bool {
    if (idx + split.len > path.len) return false;

    for (0..split.len) |i| {
        if (path[idx + i] != split[i]) {
            return false;
        }
    }

    return true;
}

fn hasEqualSplit(path: []const u8, idx: usize, splits: [][]const u8, found: usize) struct { bool, usize, usize } {
    for (0..found) |i| {
        const s = splits[i];
        if (isEqual(path, idx, s)) {
            return .{ true, s.len, i };
        }
    }
    return .{ false, 0, 0 };
}

fn checkValidity(path: []const u8, splits: [][]const u8) bool {
    for (splits) |s| {
        if (s.len > 20) return false;
    }

    var i: usize = 0;
    while (i < path.len) {
        const has_equal, const len, _ = hasEqualSplit(path, i, splits, 3);
        if (has_equal) {
            i += len;
        } else {
            return false;
        }
    }

    return true;
}

fn doReplace(w: std.io.AnyWriter, path: []const u8, splits: [][]const u8) !void {
    var i: usize = 0;
    while (i < path.len) {
        const has_equal, const len, const idx = hasEqualSplit(path, i, splits, 3);
        std.debug.assert(has_equal);
        i += len;
        if (idx == 0) {
            try w.writeByte('A');
        }
        if (idx == 1) {
            try w.writeByte('B');
        }
        if (idx == 2) {
            try w.writeByte('C');
        }
        if (i < path.len) {
            try w.writeByte(',');
        }
    }
    try w.writeByte('\n');
}

fn findRoutines(w: std.io.AnyWriter, path: []const u8, splits: [][]const u8, found: usize, idx: usize) !void {
    if (found == 3) {
        if (checkValidity(path, splits)) {
            try doReplace(w, path, splits);
            for (splits) |s| {
                try w.writeAll(s[0 .. s.len - 1]); // omit last ,
                try w.writeByte('\n');
            }
        }
        return;
    }

    var index = idx;
    while (true) {
        const has_equal, const len, _ = hasEqualSplit(path, index, splits, found);
        if (!has_equal) break;
        index += len;
    }

    var count: usize = 0;
    for (index..path.len) |i| {
        if (path[i] == ',') {
            count += 1;
            if (count % 2 == 0) {
                splits[found] = path[index .. i + 1];
                try findRoutines(w, path, splits, found + 1, i + 1);
            }
        }
    }
}

fn genPath(allocator: Allocator, program: std.ArrayList(i64)) ![]u8 {
    var c = IntcodeComputer.init(allocator, program);
    defer c.deinit();

    const halt = c.run();
    std.debug.assert(halt);

    const map = try Map.init(allocator, c.outputs.items);
    defer map.deinit(allocator);

    return try map.genPath(allocator);
}

fn doCollectedDust(input_file: []const u8) !i64 {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const program = try parseInput(allocator, input_file);
    var c = IntcodeComputer.init(allocator, try program.clone());
    defer c.deinit();

    const path = try genPath(allocator, program);
    defer allocator.free(path);

    var splits: [3][]const u8 = undefined;
    var buf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(buf[0..]);
    const w = fbs.writer();
    try findRoutines(w.any(), path, &splits, 0, 0);

    for (fbs.getWritten()) |b| {
        c.addInput(@intCast(b));
    }
    c.addInput('n');
    c.addInput('\n');

    c.getAddressAt(0).* = 2;
    const halt = c.run();
    std.debug.assert(halt);

    return c.lastOutput();
}

pub fn collectedDust(input_file: []const u8) i64 {
    return doCollectedDust(input_file) catch unreachable;
}

const testing = std.testing;

test "sumOfAlignmentParams" {
    const outputs =
        \\..#..........
        \\..#..........
        \\#######...###
        \\#.#...#...#.#
        \\#############
        \\..#...#...#..
        \\..#####...^..
        \\
    ;

    var list = std.ArrayList(i64).init(testing.allocator);
    defer list.deinit();

    for (outputs) |v| {
        try list.append(@intCast(v));
    }

    const map = try Map.init(testing.allocator, list.items);
    defer map.deinit(testing.allocator);

    const got = map.sumOfAlignmentParams();
    try testing.expectEqual(76, got);
}
