const std = @import("std");

const Cursor = struct {
    fn hide() void {
        std.debug.print("\x1b[?25l", .{});
    }

    fn show() void {
        std.debug.print("\x1b[?25h", .{});
    }

    fn save() void {
        std.debug.print("\x1b[s", .{});
    }

    fn restore() void {
        std.debug.print("\x1b[u", .{});
    }

    fn moveUp(n: usize) void {
        std.debug.print("\x1b[{}A", .{n});
    }

    fn moveDown(n: usize) void {
        std.debug.print("\x1b[{}B", .{n});
    }

    fn moveRight(n: usize) void {
        std.debug.print("\x1b[{}C", .{n});
    }

    fn moveLeft(n: usize) void {
        std.debug.print("\x1b[{}D", .{n});
    }
};

const Tile = enum(u8) {
    empty = 0,
    wall,
    block,
    paddle,
    ball,

    const Self = @This();

    fn toChar(self: Self) u8 {
        return switch (self) {
            .empty => '.',
            .wall => '#',
            .block => '*',
            .paddle => '_',
            .ball => 'O',
        };
    }
};

const Grid = struct {
    width: usize,
    height: usize,
    data: []u8, // .len = width * height
    score: i64,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, outputs: []i64) !Self {
        var width: usize = 0;
        var height: usize = 0;
        var i: usize = 0;

        while (i < outputs.len) {
            if (outputs[i] == -1) break;
            const x = @as(usize, @intCast(outputs[i]));
            const y = @as(usize, @intCast(outputs[i + 1]));
            i += 3;
            width = @max(width, x + 1);
            height = @max(height, y + 1);
        }

        i = 0;
        var data = try allocator.alloc(u8, width * height);
        while (i < outputs.len) {
            if (outputs[i] == -1) break;
            const x = @as(usize, @intCast(outputs[i]));
            const y = @as(usize, @intCast(outputs[i + 1]));
            const t = @as(u8, @intCast(outputs[i + 2]));
            const idx = y * width + x;
            data[idx] = @as(Tile, @enumFromInt(t)).toChar();
            i += 3;
        }

        std.debug.assert(outputs[i] == -1 and outputs[i + 1] == 0);
        const score = outputs[i + 2];

        std.debug.assert(i + 3 == outputs.len);

        return .{
            .width = width,
            .height = height,
            .data = data,
            .score = score,
        };
    }

    fn deinit(self: Self, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    fn update(self: *Self, outputs: []i64) void {
        var i: usize = 0;
        while (i < outputs.len) {
            if (outputs[i] == -1) {
                std.debug.assert(outputs[i + 1] == 0);
                self.score = outputs[i + 2];
            } else {
                const x = @as(usize, @intCast(outputs[i]));
                const y = @as(usize, @intCast(outputs[i + 1]));
                const t = @as(u8, @intCast(outputs[i + 2]));
                const idx = y * self.width + x;
                self.data[idx] = @as(Tile, @enumFromInt(t)).toChar();
                Cursor.save();
                Cursor.moveDown(y);
                Cursor.moveRight(x);
                std.debug.print("{c}", .{self.data[idx]});
                Cursor.restore();
            }

            i += 3;
        }
    }

    fn print(self: Self) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const idx = y * self.width + x;
                std.debug.print("{c}", .{self.data[idx]});
            }
            std.debug.print("\n", .{});
        }
        Cursor.moveUp(self.height);
        Cursor.moveLeft(self.width);
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

pub fn countBlockTiles(input_file: []const u8) u32 {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const program = parseInput(allocator, input_file) catch unreachable;
    var c = IntcodeComputer.init(allocator, program);
    defer c.deinit();

    const halt = c.run();
    std.debug.assert(halt);

    var count: u32 = 0;
    for (c.outputs.items, 0..) |o, i| {
        if (i % 3 == 2 and o == 2) {
            count += 1;
        }
    }
    return count;
}

// solve it by cheating:
// change the input file, so that the last row is all walls.
pub fn play(input_file: []const u8) u32 {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const program = parseInput(allocator, input_file) catch unreachable;
    var c = IntcodeComputer.init(allocator, program);
    defer c.deinit();

    Cursor.hide();
    defer Cursor.show();

    c.getAddressAt(0).* = 2;
    _ = c.run();
    var g = Grid.init(allocator, c.outputs.items) catch unreachable;
    defer g.deinit(allocator);
    c.clearOutput();
    g.print();

    while (true) {
        // increase the delay to watch the play
        std.time.sleep(1e5); // 0.1ms
        c.addInput(0);
        const halt = c.run();
        g.update(c.outputs.items);
        c.clearOutput();

        if (halt) break;
    }
    Cursor.moveDown(g.height);

    return @intCast(g.score);
}
