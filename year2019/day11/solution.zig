const std = @import("std");

const Position = struct {
    x: i64,
    y: i64,

    const Self = @This();

    fn go(self: Self, dir: Dir) Self {
        var dx: i64 = 0;
        var dy: i64 = 0;

        switch (dir) {
            .up => dy = 1,
            .right => dx = 1,
            .down => dy = -1,
            .left => dx = -1,
        }

        return .{
            .x = self.x + dx,
            .y = self.y + dy,
        };
    }
};

const Dir = enum {
    up,
    right,
    down,
    left,

    const Self = @This();

    fn turn(self: Self, v: i64) Self {
        return switch (v) {
            0 => self.turnLeft(),
            1 => self.turnRight(),
            else => unreachable,
        };
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
        ptr.* = self.inputs.popOrNull() orelse return false;
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

pub fn paintedPanels(input_file: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const program = parseInput(gpa.allocator(), input_file) catch unreachable;
    var c = IntcodeComputer.init(gpa.allocator(), program);
    defer c.deinit();

    var map = std.AutoHashMap(Position, i64).init(gpa.allocator());
    defer map.deinit();

    var pos = Position{ .x = 0, .y = 0 };
    var dir = Dir.up;

    while (true) {
        const input = map.get(pos) orelse 0;
        c.addInput(input);
        const halt = c.run();

        std.debug.assert(c.outputs.items.len == 2);
        const color = c.outputs.items[0];
        const turn = c.outputs.items[1];

        map.put(pos, color) catch unreachable;
        dir = dir.turn(turn);
        pos = pos.go(dir);

        if (halt) break;
        c.clearOutput();
    }

    return map.count();
}

pub fn paintedLetters(input_file: []const u8, buf: []u8) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const program = parseInput(gpa.allocator(), input_file) catch unreachable;
    var c = IntcodeComputer.init(gpa.allocator(), program);
    defer c.deinit();

    var map = std.AutoHashMap(Position, i64).init(gpa.allocator());
    defer map.deinit();

    var pos = Position{ .x = 0, .y = 0 };
    var dir = Dir.up;
    map.put(pos, 1) catch unreachable;

    var min_x: i64 = std.math.maxInt(i64);
    var max_x: i64 = std.math.minInt(i64);
    var min_y: i64 = std.math.maxInt(i64);
    var max_y: i64 = std.math.minInt(i64);
    while (true) {
        min_x = @min(min_x, pos.x);
        max_x = @max(max_x, pos.x);
        min_y = @min(min_y, pos.y);
        max_y = @max(max_y, pos.y);

        const input = map.get(pos) orelse 0;
        c.addInput(input);
        const halt = c.run();

        std.debug.assert(c.outputs.items.len == 2);
        const color = c.outputs.items[0];
        const turn = c.outputs.items[1];

        map.put(pos, color) catch unreachable;
        dir = dir.turn(turn);
        pos = pos.go(dir);

        if (halt) break;
        c.clearOutput();
    }

    const width = @as(usize, @intCast(max_x - min_x + 1));
    const height = @as(usize, @intCast(max_y - min_y + 1));
    var temp = gpa.allocator().alloc(u8, width * height) catch unreachable;
    defer gpa.allocator().free(temp);

    for (0..height) |y| {
        for (0..width) |x| {
            const position = Position{
                .x = @as(isize, @intCast(x)) + min_x,
                .y = @as(isize, @intCast(y)) + min_y,
            };
            const color = map.get(position) orelse 0;
            const idx = (height - y - 1) * width + x;
            temp[idx] = if (color == 0) ' ' else '#';
        }
    }

    var fbs = std.io.fixedBufferStream(buf);
    const w = fbs.writer();

    w.writeByte('\n') catch unreachable;
    for (0..height) |y| {
        for (0..width) |x| {
            const idx = y * width + x;
            w.writeByte(temp[idx]) catch unreachable;
        }
        w.writeByte('\n') catch unreachable;
    }
    w.writeByte(0) catch unreachable;
}
