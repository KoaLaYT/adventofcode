const std = @import("std");
const Allocator = std.mem.Allocator;

const Program = std.ArrayList(i64);

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
    origin_program: Program,
    program: Program,
    inputs: std.ArrayList(i64),
    outputs: std.ArrayList(i64),
    memory: Memory,

    const Self = @This();

    fn init(allocator: Allocator, program: Program) !Self {
        return .{
            .pc = 0,
            .rel_base = 0,
            .origin_program = program,
            .program = try program.clone(),
            .inputs = std.ArrayList(i64).init(allocator),
            .outputs = std.ArrayList(i64).init(allocator),
            .memory = Memory.init(allocator),
        };
    }

    fn deinit(self: *Self) void {
        self.origin_program.deinit();
        self.program.deinit();
        self.inputs.deinit();
        self.outputs.deinit();
        self.memory.deinit();
    }

    fn reset(self: *Self) void {
        self.program.clearRetainingCapacity();
        self.program.appendSliceAssumeCapacity(self.origin_program.items);
        self.inputs.clearRetainingCapacity();
        self.outputs.clearRetainingCapacity();
        self.memory.clearRetainingCapacity();
        self.pc = 0;
        self.rel_base = 0;
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

fn doCountAffected(allocator: Allocator, program: std.ArrayList(i64), size: usize) !u32 {
    var c = try IntcodeComputer.init(allocator, program);
    defer c.deinit();

    var affected: u32 = 0;

    for (0..size) |x| {
        for (0..size) |y| {
            c.reset();
            c.addInput(@intCast(x));
            c.addInput(@intCast(y));
            std.debug.assert(c.run());
            const v = c.lastOutput();
            if (v == 1) {
                affected += 1;
            } else {
                std.debug.assert(v == 0);
            }
        }
    }

    return affected;
}

const Beam = struct {
    begin_at: usize,
    width: usize,

    const Self = @This();

    fn canFit(self: Self, other: Self) bool {
        if (self.width < 100 or other.width < 100) return false;

        if (other.begin_at > self.begin_at) return false;
        if (other.begin_at + other.width - 1 < self.begin_at) return false;

        if (other.begin_at > self.begin_at + 99) return false;
        if (other.begin_at + other.width - 1 < self.begin_at + 99) return false;

        return true;
    }
};

fn binarySearchWidth(c: *IntcodeComputer, y: usize, begin_at: usize) usize {
    var lo: usize = begin_at;
    var hi: usize = begin_at + 500;

    while (lo < hi) {
        const mi = lo + (hi - lo) / 2;
        c.reset();
        c.addInput(@intCast(mi));
        c.addInput(@intCast(y));
        std.debug.assert(c.run());
        const v = c.lastOutput();

        if (v == 0) {
            hi = mi - 1;
        } else if (v == 1) {
            lo = mi + 1;
        } else {
            unreachable;
        }
    }

    hi -= 3;
    while (true) {
        c.reset();
        c.addInput(@intCast(hi));
        c.addInput(@intCast(y));
        std.debug.assert(c.run());
        const v = c.lastOutput();
        if (v == 0) {
            return hi - begin_at;
        }
        hi += 1;
    }
    unreachable;
}

fn binarySearchBegin(c: *IntcodeComputer, y: usize) usize {
    var lo: usize = 0;
    var hi: usize = 500;

    while (lo < hi) {
        const mi = lo + (hi - lo) / 2;
        c.reset();
        c.addInput(@intCast(mi));
        c.addInput(@intCast(y));
        std.debug.assert(c.run());
        const v = c.lastOutput();

        if (v == 1) {
            hi = mi - 1;
        } else if (v == 0) {
            lo = mi + 1;
        } else {
            unreachable;
        }
    }

    hi -= 3;
    while (true) {
        c.reset();
        c.addInput(@intCast(hi));
        c.addInput(@intCast(y));
        std.debug.assert(c.run());
        const v = c.lastOutput();
        if (v == 1) {
            return hi;
        }
        hi += 1;
    }
    unreachable;
}

fn doDetectBeam(c: *IntcodeComputer, y: usize) !Beam {
    const begin_at = binarySearchBegin(c, y);
    const width = binarySearchWidth(c, y, begin_at);
    return .{ .begin_at = begin_at, .width = width };
}

fn doFindShip(allocator: Allocator, program: std.ArrayList(i64)) !usize {
    var c = try IntcodeComputer.init(allocator, program);
    defer c.deinit();

    var lo: usize = 500;
    var hi: usize = 2000;
    while (lo < hi) {
        const mi = lo + (hi - lo) / 2;
        const b1 = try doDetectBeam(&c, mi);
        const b2 = try doDetectBeam(&c, mi - 99);
        const canFit = b1.canFit(b2);
        if (canFit) {
            hi = mi - 1;
        } else {
            lo = mi + 1;
        }
    }

    hi -= 3;
    while (true) {
        const b1 = try doDetectBeam(&c, hi);
        const b2 = try doDetectBeam(&c, hi - 99);
        const canFit = b1.canFit(b2);
        if (canFit) {
            return b1.begin_at * 10000 + hi - 99;
        } else {
            hi += 1;
        }
    }

    unreachable;
}

pub fn countAffected(input_file: []const u8) u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const program = parseInput(allocator, input_file) catch unreachable;
    return doCountAffected(allocator, program, 50) catch unreachable;
}

pub fn findShip(input_file: []const u8) usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const program = parseInput(allocator, input_file) catch unreachable;
    defer program.deinit();

    return doFindShip(allocator, program) catch unreachable;
}
