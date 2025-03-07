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

    fn addStr(self: *Self, line: []const u8) void {
        for (line) |b| {
            self.addInput(b);
        }
    }

    fn addLine(self: *Self, line: []const u8) void {
        self.addStr(line);
        self.addInput('\n');
    }

    fn lastOutput(self: Self) i64 {
        std.debug.assert(self.outputs.items.len > 0);
        return self.outputs.items[self.outputs.items.len - 1];
    }

    fn clearOutput(self: *Self) void {
        self.outputs.clearRetainingCapacity();
    }

    fn printOutputAsAscii(self: Self) void {
        for (self.outputs.items) |item| {
            if (item < std.math.maxInt(u8)) {
                const byte: u8 = @intCast(item);
                std.debug.print("{c}", .{byte});
            } else {
                std.debug.print("{}\n", .{item});
            }
        }
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

fn parseInput(allocator: std.mem.Allocator, input_file: []const u8) !Program {
    const f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();
    const r = f.reader();

    var buf: [256]u8 = undefined;
    var bs = std.io.fixedBufferStream(buf[0..]);
    const w = bs.writer();

    var list = Program.init(allocator);
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

const Dir = enum {
    north,
    south,
    west,
    east,
};

fn doFindPassword(input_file: []const u8) !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const program = try parseInput(allocator, input_file);
    var c = try IntcodeComputer.init(allocator, program);
    defer c.deinit();

    // pick up all items
    // and go to security
    c.addLine("south");
    c.addLine("south");
    c.addLine("take tambourine");
    c.addLine("north");
    c.addLine("north");
    c.addLine("west");
    c.addLine("south");
    c.addLine("take polygon");
    c.addLine("north");
    c.addLine("east");
    c.addLine("north");
    c.addLine("west");
    c.addLine("take boulder");
    c.addLine("east");
    c.addLine("north");
    c.addLine("take manifold");
    c.addLine("west");
    c.addLine("take fuel cell");
    c.addLine("south");
    c.addLine("east");
    c.addLine("south");
    c.addLine("take fixed point");
    c.addLine("north");
    c.addLine("west");
    c.addLine("north");
    c.addLine("north");
    c.addLine("take wreath");
    c.addLine("south");
    c.addLine("east");
    c.addLine("north");
    c.addLine("take hologram");
    c.addLine("south");
    c.addLine("west");
    c.addLine("north");
    c.addLine("east");
    c.addLine("east");

    const items = [_][]const u8{
        "tambourine",
        "hologram",
        "fuel cell",
        "wreath",
        "boulder",
        "fixed point",
        "manifold",
        "polygon",
    };
    for (items) |item| {
        c.addStr("drop ");
        c.addLine(item);
    }

    _ = c.run();

    outer: inline for (1..items.len) |n| {
        const combs = try genCombinationsOfN(n, allocator, &items);
        defer combs.deinit();

        for (combs.items) |comb| {
            for (comb) |item| {
                c.addStr("take ");
                c.addLine(item);
            }
            c.addLine("north");

            const halt = c.run();
            if (halt) {
                c.printOutputAsAscii();
            }

            if (halt) break :outer;

            for (comb) |item| {
                c.addStr("drop ");
                c.addLine(item);
            }
            _ = c.run();
            c.clearOutput();
        }
    }
}

fn genCombinationsOfN(comptime N: usize, allocator: Allocator, items: []const []const u8) !std.ArrayList([N][]const u8) {
    var collects = std.ArrayList([N][]const u8).init(allocator);
    errdefer collects.deinit();

    try collects.ensureTotalCapacity(1024);

    const result: [N][]const u8 = undefined;

    genCombinations(N, items, 0, N, result, &collects);

    return collects;
}

fn genCombinations(
    comptime N: usize,
    items: []const []const u8,
    idx: usize,
    left: usize,
    result: [N][]const u8,
    collects: *std.ArrayList([N][]const u8),
) void {
    if (left == 0) {
        collects.appendAssumeCapacity(result);
        return;
    }

    for (idx..items.len) |j| {
        var copy = result;
        copy[result.len - left] = items[j];
        genCombinations(N, items, j + 1, left - 1, copy, collects);
    }
}

pub fn findPassword(input_file: []const u8) void {
    doFindPassword(input_file) catch unreachable;
}
