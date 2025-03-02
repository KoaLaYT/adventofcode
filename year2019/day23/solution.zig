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

    fn addLine(self: *Self, line: []const u8) void {
        for (line) |b| {
            self.addInput(b);
        }
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

const NAT = struct {
    x: i64,
    y: i64,
};

const Network = struct {
    cs: std.ArrayList(IntcodeComputer),
    nat: ?NAT,

    const Self = @This();

    fn init(allocator: Allocator, program: Program) !Self {
        var cs = std.ArrayList(IntcodeComputer).init(allocator);
        defer {}
        for (0..50) |i| {
            var c = try IntcodeComputer.init(allocator, try program.clone());
            c.addInput(@intCast(i));
            try cs.append(c);
        }

        return .{ .cs = cs, .nat = null };
    }

    fn simulateOnce(self: *Self) bool {
        var is_idle = true;

        for (0..50) |send_addr| {
            const c: *IntcodeComputer = &self.cs.items[send_addr];

            c.addInput(-1);

            _ = c.run();

            if (c.outputs.items.len == 0) continue;

            std.debug.assert(c.outputs.items.len % 3 == 0);

            var idx: usize = 0;
            while (idx < c.outputs.items.len) : (idx += 3) {
                const recv_addr: usize = @intCast(c.outputs.items[idx]);
                const x = c.outputs.items[idx + 1];
                const y = c.outputs.items[idx + 2];
                if (recv_addr == 255) {
                    self.nat = .{ .x = x, .y = y };
                } else {
                    self.cs.items[recv_addr].addInput(x);
                    self.cs.items[recv_addr].addInput(y);
                    is_idle = false;
                }
            }
            c.clearOutput();
        }

        return is_idle;
    }

    fn simulateWithNAT(self: *Self) i64 {
        var last_y: ?i64 = null;

        while (true) {
            const is_idle = self.simulateOnce();
            if (is_idle) {
                std.debug.assert(self.nat != null);
                const nat = self.nat.?;
                if (nat.y == last_y) break;
                last_y = nat.y;
                self.cs.items[0].addInput(nat.x);
                self.cs.items[0].addInput(nat.y);
            }
        }

        return last_y.?;
    }

    fn simulate(self: *Self) i64 {
        while (true) {
            _ = self.simulateOnce();
            if (self.nat) |nat| {
                return nat.y;
            }
        }
        unreachable;
    }

    fn deinit(self: *Self) void {
        for (self.cs.items) |*c| {
            c.deinit();
        }
        self.cs.deinit();
    }
};

fn doSimulateNetworks(input_file: []const u8) !i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const program = try parseInput(allocator, input_file);
    defer program.deinit();

    var network = try Network.init(allocator, program);
    defer network.deinit();

    return network.simulate();
}

fn doSimulateNetworksWithNAT(input_file: []const u8) !i64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const program = try parseInput(allocator, input_file);
    defer program.deinit();

    var network = try Network.init(allocator, program);
    defer network.deinit();

    return network.simulateWithNAT();
}

pub fn simulateNetworks(input_file: []const u8) i64 {
    return doSimulateNetworks(input_file) catch unreachable;
}

pub fn simulateNetworksWithNAT(input_file: []const u8) i64 {
    return doSimulateNetworksWithNAT(input_file) catch unreachable;
}
