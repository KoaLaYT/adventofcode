const std = @import("std");
const Allocator = std.mem.Allocator;

const Dir = enum(u8) {
    north = 1,
    south,
    west,
    east,

    const Self = @This();

    fn opposite(self: Self) Self {
        return switch (self) {
            .north => .south,
            .south => .north,
            .west => .east,
            .east => .west,
        };
    }
};

const State = enum(u8) {
    wall = 0,
    valid,
    found,
    void,
    origin,

    const Self = @This();

    fn toChar(self: Self) u8 {
        return switch (self) {
            .wall => '#',
            .valid => '.',
            .found => '!',
            .void => ' ',
            .origin => 'X',
        };
    }
};

const Position = struct {
    x: i32,
    y: i32,

    const Self = @This();

    fn next(self: Self, dir: Dir) Self {
        var dx: i32 = 0;
        var dy: i32 = 0;
        switch (dir) {
            .north => dy = 1,
            .south => dy = -1,
            .west => dx = -1,
            .east => dx = 1,
        }
        return .{ .x = self.x + dx, .y = self.y + dy };
    }
};

const Queue = std.DoublyLinkedList(Position);

const Area = struct {
    map: Map,

    const Self = @This();
    const Map = std.AutoHashMap(Position, State);

    fn init(allocator: Allocator, c: *IntcodeComputer) !Self {
        var map = std.AutoHashMap(Position, State).init(allocator);

        const origin = Position{ .x = 0, .y = 0 };
        try map.put(origin, .valid);

        doDetect(origin, c, &map);

        return .{
            .map = map,
        };
    }

    fn deinit(self: *Self) void {
        self.map.deinit();
    }

    fn doDetect(pos: Position, c: *IntcodeComputer, map: *Map) void {
        const dirs = [_]Dir{ .north, .south, .west, .east };
        for (dirs) |dir| {
            const next_pos = pos.next(dir);
            if (map.get(next_pos) != null) continue;

            // query droid
            c.addInput(@intFromEnum(dir));
            const halt = c.run();
            std.debug.assert(!halt);
            const state: State = @enumFromInt(c.lastOutput());
            c.clearOutput();

            map.put(next_pos, state) catch unreachable;

            var need_go_back = true;
            switch (state) {
                .wall => need_go_back = false,
                .valid => doDetect(next_pos, c, map),
                .found => {},
                else => unreachable,
            }

            // go back
            if (need_go_back) {
                c.addInput(@intFromEnum(dir.opposite()));
                _ = c.run();
                std.debug.assert(c.outputs.items.len == 1);
                c.clearOutput();
            }
        }
    }

    fn shortestPath(self: Self, allocator: Allocator) !u32 {
        var queue = Queue{};
        var node_pool = std.heap.MemoryPool(Queue.Node).init(allocator);
        defer node_pool.deinit();
        var visited = std.AutoHashMap(Position, bool).init(allocator);
        defer visited.deinit();

        const origin = Position{ .x = 0, .y = 0 };
        const node: *Queue.Node = try node_pool.create();
        node.data = origin;
        queue.append(node);
        try visited.put(origin, true);

        var steps: u32 = 0;
        while (queue.len > 0) {
            steps += 1;

            for (0..queue.len) |_| {
                const head = queue.popFirst().?.data;

                const dirs = [_]Dir{ .north, .south, .west, .east };
                for (dirs) |dir| {
                    const next_pos = head.next(dir);
                    const state = self.map.get(next_pos) orelse .void;
                    if (state == .found) {
                        return steps;
                    }
                    if (state == .valid and visited.get(next_pos) == null) {
                        const next_node: *Queue.Node = try node_pool.create();
                        next_node.data = next_pos;
                        queue.append(next_node);
                        try visited.put(next_pos, true);
                    }
                }
            }
        }

        unreachable();
    }

    fn findPosition(self: Self, state: State) Position {
        var it = self.map.iterator();
        while (it.next()) |e| {
            if (e.value_ptr.* == state) {
                return e.key_ptr.*;
            }
        }
        unreachable();
    }

    fn fillOxygen(self: Self, allocator: Allocator) !u32 {
        var queue = Queue{};
        var node_pool = std.heap.MemoryPool(Queue.Node).init(allocator);
        defer node_pool.deinit();
        var visited = std.AutoHashMap(Position, bool).init(allocator);
        defer visited.deinit();

        const start = self.findPosition(.found);
        const node: *Queue.Node = try node_pool.create();
        node.data = start;
        queue.append(node);
        try visited.put(start, true);

        const dirs = [_]Dir{ .north, .south, .west, .east };
        var steps: u32 = 0;
        while (queue.len > 0) {
            for (0..queue.len) |_| {
                const head = queue.popFirst().?.data;
                for (dirs) |dir| {
                    const next_pos = head.next(dir);
                    const state = self.map.get(next_pos) orelse .void;
                    if ((state == .valid or state == .origin) and visited.get(next_pos) == null) {
                        const next_node: *Queue.Node = try node_pool.create();
                        next_node.data = next_pos;
                        queue.append(next_node);
                        try visited.put(next_pos, true);
                    }
                }
            }
            if (queue.len > 0) {
                steps += 1;
            }
        }

        return steps;
    }

    fn draw(self: Self, allocator: Allocator) !void {
        var it1 = self.map.iterator();
        var min_x: i32 = std.math.maxInt(i32);
        var max_x: i32 = std.math.minInt(i32);
        var min_y: i32 = std.math.maxInt(i32);
        var max_y: i32 = std.math.minInt(i32);

        while (it1.next()) |e| {
            min_x = @min(min_x, e.key_ptr.x);
            max_x = @max(max_x, e.key_ptr.x);
            min_y = @min(min_y, e.key_ptr.y);
            max_y = @max(max_y, e.key_ptr.y);
        }

        const width: usize = @as(usize, @intCast(max_x - min_x + 1));
        const height: usize = @as(usize, @intCast(max_y - min_y + 1));

        var buf = try allocator.alloc(State, width * height);
        defer allocator.free(buf);
        @memset(buf, .void);

        var it2 = self.map.iterator();
        while (it2.next()) |e| {
            var v = e.value_ptr.*;
            if (e.key_ptr.x == 0 and e.key_ptr.y == 0) {
                v = .origin;
            }
            const x = @as(usize, @intCast(e.key_ptr.x - min_x));
            const y = @as(usize, @intCast(e.key_ptr.y - min_y));
            const idx = y * width + x;
            buf[idx] = v;
        }

        for (0..height) |y| {
            for (0..width) |x| {
                const idx = y * width + x;
                std.debug.print("{c}", .{buf[idx].toChar()});
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

fn doFewestCommands(input_file: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const program = try parseInput(allocator, input_file);
    var c = IntcodeComputer.init(allocator, program);
    defer c.deinit();

    var area = try Area.init(allocator, &c);
    defer area.deinit();

    // try area.draw(allocator);

    return try area.shortestPath(allocator);
}

fn doFillOxygen(input_file: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const program = try parseInput(allocator, input_file);
    var c = IntcodeComputer.init(allocator, program);
    defer c.deinit();

    var area = try Area.init(allocator, &c);
    defer area.deinit();

    return try area.fillOxygen(allocator);
}

pub fn fewestCommands(input_file: []const u8) u32 {
    return doFewestCommands(input_file) catch unreachable;
}

pub fn fillOxygen(input_file: []const u8) u32 {
    return doFillOxygen(input_file) catch unreachable;
}
