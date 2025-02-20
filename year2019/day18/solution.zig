const std = @import("std");

const Allocator = std.mem.Allocator;

const KeyBitSet = std.bit_set.IntegerBitSet(26);

const Area = struct {
    width: usize,
    height: usize,
    data: []u8,

    const Self = @This();

    fn init(allocator: Allocator, input_file: []const u8) !Self {
        const f = try std.fs.cwd().openFile(input_file, .{});
        defer f.close();
        const r = f.reader();

        var buf: [512]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const w = fbs.writer();

        var width: usize = 0;
        var height: usize = 0;
        while (true) {
            fbs.reset();
            if (r.streamUntilDelimiter(w, '\n', null)) |_| {
                width = fbs.getWritten().len;
                height += 1;
            } else |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            }
        }

        var data = try allocator.alloc(u8, width * height);
        var idx: usize = 0;
        try f.seekTo(0);
        while (true) {
            fbs.reset();
            if (r.streamUntilDelimiter(w, '\n', null)) |_| {
                @memcpy(data[idx .. idx + width], fbs.getWritten());
                idx += width;
            } else |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            }
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

    fn charAt(self: Self, x: isize, y: isize) u8 {
        if (x < 0 or x >= self.width) return '#';
        if (y < 0 or y >= self.height) return '#';

        const idx = @as(usize, @intCast(y)) * self.width + @as(usize, @intCast(x));
        return self.data[idx];
    }

    fn charAtPtr(self: *Self, x: usize, y: usize) *u8 {
        const idx = y * self.width + x;
        return &self.data[idx];
    }

    fn update(self: *Self) void {
        const mx = self.width / 2;
        const my = self.height / 2;
        std.debug.assert(self.charAt(@intCast(mx), @intCast(my)) == '@');

        self.charAtPtr(mx, my).* = '#';
        self.charAtPtr(mx - 1, my).* = '#';
        self.charAtPtr(mx + 1, my).* = '#';
        self.charAtPtr(mx, my - 1).* = '#';
        self.charAtPtr(mx, my + 1).* = '#';
        self.charAtPtr(mx - 1, my + 1).* = '0';
        self.charAtPtr(mx + 1, my + 1).* = '1';
        self.charAtPtr(mx - 1, my - 1).* = '2';
        self.charAtPtr(mx + 1, my - 1).* = '3';
    }

    fn totalKeys(self: Self) usize {
        var keys: usize = 0;
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const char = self.charAt(@intCast(x), @intCast(y));
                if (char >= 'a' and char <= 'z') {
                    keys += 1;
                }
            }
        }
        return keys;
    }

    fn findPath(
        self: Self,
        allocator: Allocator,
        x: usize,
        y: usize,
        visited: *Visited,
        graph: *Graph,
    ) !void {
        const from = self.charAt(@intCast(x), @intCast(y));
        if ((from >= 'A' and from <= 'Z') or from == '.' or from == '#') return;

        var q = try Queue(PositionWithKeys).init(allocator);
        defer q.deinit();

        const origin = Position.init(@intCast(x), @intCast(y));
        try q.add(.{ .position = origin, .need_keys = KeyBitSet.initEmpty() });
        visited.clearRetainingCapacity();
        try visited.put(origin, true);

        const dirs = [4][2]i32{
            .{ 0, -1 }, // up
            .{ 1, 0 }, // right
            .{ 0, 1 }, // down
            .{ -1, 0 }, // left
        };
        var steps: u32 = 0;

        while (q.count() > 0) {
            steps += 1;
            for (0..q.count()) |_| {
                const pwk = q.remove().?;
                for (dirs) |dir| {
                    const next_position = pwk.position.next(dir[0], dir[1]);

                    const gop = try visited.getOrPut(next_position);
                    if (gop.found_existing) continue;
                    gop.value_ptr.* = true;

                    const char = self.charAt(next_position.x, next_position.y);
                    if (char == '#') continue;
                    if (char >= 'a' and char <= 'z') {
                        try graph.append(from, .{
                            .to = char,
                            .need_keys = pwk.need_keys,
                            .steps = steps,
                        });
                    }

                    var need_keys = pwk.need_keys;
                    if (char >= 'A' and char <= 'Z') {
                        need_keys.set(std.ascii.toLower(char) - 'a');
                    }
                    try q.add(.{
                        .position = next_position,
                        .need_keys = need_keys,
                    });
                }
            }
        }
    }
};

fn Queue(comptime T: type) type {
    return struct {
        list: std.DoublyLinkedList(T),
        pool: std.heap.MemoryPool(Node),

        const Self = @This();
        const Node = std.DoublyLinkedList(T).Node;

        fn init(allocator: Allocator) !Self {
            return .{
                .list = std.DoublyLinkedList(T){},
                .pool = try std.heap.MemoryPool(Node).initPreheated(allocator, 1024),
            };
        }

        fn deinit(self: *Self) void {
            self.pool.deinit();
        }

        fn add(self: *Self, s: T) !void {
            const node: *Node = try self.pool.create();
            node.data = s;
            self.list.append(node);
        }

        fn remove(self: *Self) ?T {
            if (self.list.popFirst()) |node| {
                const s = node.data;
                self.pool.destroy(node);
                return s;
            } else {
                return null;
            }
        }

        fn count(self: Self) usize {
            return self.list.len;
        }
    };
}

const Position = struct {
    x: i32,
    y: i32,

    const Self = @This();

    fn init(x: i32, y: i32) Self {
        return .{
            .x = x,
            .y = y,
        };
    }

    fn next(self: Self, dx: i32, dy: i32) Self {
        return .{
            .x = self.x + dx,
            .y = self.y + dy,
        };
    }
};

const PositionWithKeys = struct {
    position: Position,
    need_keys: KeyBitSet,
};

const Edge = struct {
    to: u8,
    need_keys: KeyBitSet,
    steps: u32,
};

const State = struct {
    current_key: u8,
    carried_keys: KeyBitSet,

    const Self = @This();

    fn init(key: u8) Self {
        return .{
            .current_key = key,
            .carried_keys = KeyBitSet.initEmpty(),
        };
    }

    fn hasKey(self: Self, key: u8) bool {
        return self.carried_keys.isSet(key - 'a');
    }

    fn hasKeys(self: Self, keys: KeyBitSet) bool {
        return self.carried_keys.supersetOf(keys);
    }

    fn withKey(self: Self, key: u8) Self {
        var keys = self.carried_keys;
        keys.set(key - 'a');
        return .{
            .current_key = key,
            .carried_keys = keys,
        };
    }
};

const State4 = struct {
    current_key: [4]u8,
    carried_keys: KeyBitSet,

    const Self = @This();

    fn hasKey(self: Self, key: u8) bool {
        return self.carried_keys.isSet(key - 'a');
    }

    fn hasKeys(self: Self, keys: KeyBitSet) bool {
        return self.carried_keys.supersetOf(keys);
    }

    fn add(self: Self, key: u8) KeyBitSet {
        var keys = self.carried_keys;
        keys.set(key - 'a');
        return keys;
    }
};

fn Cache(comptime T: type) type {
    return std.AutoHashMap(T, u32);
}

const Graph = struct {
    edges: [128]std.ArrayList(Edge),

    const Self = @This();

    fn init(allocator: Allocator) !Self {
        var edges: [128]std.ArrayList(Edge) = undefined;
        for (0..edges.len) |i| {
            edges[i] = try std.ArrayList(Edge).initCapacity(allocator, 26);
        }
        return .{ .edges = edges };
    }

    fn deinit(self: Self) void {
        for (0..self.edges.len) |i| {
            self.edges[i].deinit();
        }
    }

    fn append(self: *Self, from: u8, edge: Edge) !void {
        try self.edges[from].append(edge);
    }
};

const Visited = std.AutoHashMap(Position, bool);

fn findMinSteps(allocator: Allocator, totalKeys: usize, graph: Graph) !u32 {
    var cache = std.HashMap(State, u32, struct {
        pub fn hash(self: @This(), s: State) u64 {
            _ = self;
            return @as(u64, @intCast(std.hash.uint32(s.current_key))) +
                @as(u64, @intCast(std.hash.uint32(s.carried_keys.mask)));
        }
        pub fn eql(self: @This(), s1: State, s2: State) bool {
            _ = self;
            return s1.current_key == s2.current_key and
                s1.carried_keys.mask == s2.carried_keys.mask;
        }
    }, 80).init(allocator);
    defer cache.deinit();

    var q = try Queue(State).init(allocator);
    defer q.deinit();

    const origin = State.init('@');
    try q.add(origin);
    try cache.put(origin, 0);

    var min_steps: u32 = std.math.maxInt(u32);
    while (q.count() > 0) {
        const state: State = q.remove().?;
        const steps: u32 = cache.get(state).?;

        if (state.carried_keys.count() == totalKeys) {
            min_steps = @min(min_steps, steps);
            continue;
        }

        for (graph.edges[state.current_key].items) |edge| {
            if (state.hasKey(edge.to)) continue;
            if (!state.hasKeys(edge.need_keys)) continue;
            const next_state = state.withKey(edge.to);
            const alt = edge.steps + steps;
            const gop = try cache.getOrPut(next_state);
            if (!gop.found_existing or gop.value_ptr.* > alt) {
                gop.value_ptr.* = alt;
                try q.add(next_state);
            }
        }
    }

    return min_steps;
}

fn findMinSteps4(allocator: Allocator, totalKeys: usize, graph: Graph) !u32 {
    var cache = std.HashMap(State4, u32, struct {
        pub fn hash(self: @This(), s: State4) u64 {
            _ = self;
            return @as(u64, @intCast(std.hash.uint32(@bitCast(s.current_key)))) +
                @as(u64, @intCast(std.hash.uint32(s.carried_keys.mask)));
        }
        pub fn eql(self: @This(), s1: State4, s2: State4) bool {
            _ = self;
            return @as(u32, @bitCast(s1.current_key)) == @as(u32, @bitCast(s2.current_key)) and
                s1.carried_keys.mask == s2.carried_keys.mask;
        }
    }, 80).init(allocator);
    defer cache.deinit();

    var q = try Queue(State4).init(allocator);
    defer q.deinit();

    const origin = State4{
        .current_key = .{ '0', '1', '2', '3' },
        .carried_keys = KeyBitSet.initEmpty(),
    };
    try q.add(origin);
    try cache.put(origin, 0);

    var min_steps: u32 = std.math.maxInt(u32);
    while (q.count() > 0) {
        const keys4 = q.remove().?;
        const steps = cache.get(keys4).?;

        if (keys4.carried_keys.count() == totalKeys) {
            min_steps = @min(min_steps, steps);
            continue;
        }

        for (0..4) |i| {
            const from = keys4.current_key[i];
            for (graph.edges[from].items) |edge| {
                if (keys4.hasKey(edge.to)) continue;
                if (keys4.hasKeys(edge.need_keys)) {
                    var next_state = State4{
                        .current_key = keys4.current_key,
                        .carried_keys = keys4.add(edge.to),
                    };
                    next_state.current_key[i] = edge.to;
                    const alt = edge.steps + steps;
                    const gop = try cache.getOrPut(next_state);
                    if (!gop.found_existing or gop.value_ptr.* > alt) {
                        gop.value_ptr.* = alt;
                        try q.add(next_state);
                    }
                }
            }
        }
    }

    return min_steps;
}

fn doMinSteps(input_file: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const area = try Area.init(allocator, input_file);
    defer area.deinit(allocator);
    var graph = try Graph.init(allocator);
    defer graph.deinit();
    var visited = Visited.init(allocator);
    defer visited.deinit();

    for (0..area.height) |y| {
        for (0..area.width) |x| {
            try area.findPath(allocator, x, y, &visited, &graph);
        }
    }

    return findMinSteps(allocator, area.totalKeys(), graph);
}

pub fn minSteps(input_file: []const u8) u32 {
    return doMinSteps(input_file) catch unreachable;
}

fn doMinSteps4(input_file: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var area = try Area.init(allocator, input_file);
    defer area.deinit(allocator);
    area.update();

    var graph = try Graph.init(allocator);
    defer graph.deinit();
    var visited = Visited.init(allocator);
    defer visited.deinit();

    for (0..area.height) |y| {
        for (0..area.width) |x| {
            try area.findPath(allocator, x, y, &visited, &graph);
        }
    }

    return findMinSteps4(allocator, area.totalKeys(), graph);
}

pub fn minSteps4(input_file: []const u8) u32 {
    return doMinSteps4(input_file) catch unreachable;
}

const testing = std.testing;

test "findMinSteps" {
    const TestCase = struct {
        input_file: []const u8,
        expect: u32,
    };

    const test_cases = [_]TestCase{
        .{
            .input_file = "day18/example.txt",
            .expect = 8,
        },
        .{
            .input_file = "day18/example2.txt",
            .expect = 86,
        },
        .{
            .input_file = "day18/example3.txt",
            .expect = 132,
        },
        .{
            .input_file = "day18/example4.txt",
            .expect = 136,
        },
        .{
            .input_file = "day18/example5.txt",
            .expect = 81,
        },
    };

    for (test_cases) |tt| {
        const area = try Area.init(testing.allocator, tt.input_file);
        defer area.deinit(testing.allocator);

        var graph = try Graph.init(testing.allocator);
        defer graph.deinit();
        var visited = Visited.init(testing.allocator);
        defer visited.deinit();

        for (0..area.height) |y| {
            for (0..area.width) |x| {
                try area.findPath(testing.allocator, x, y, &visited, &graph);
            }
        }

        const got = try findMinSteps(testing.allocator, area.totalKeys(), graph);
        try testing.expectEqual(tt.expect, got);
    }
}

test "findMinSteps4" {
    const TestCase = struct {
        input_file: []const u8,
        expect: u32,
    };

    const test_cases = [_]TestCase{
        .{
            .input_file = "day18/example6.txt",
            .expect = 8,
        },
        .{
            .input_file = "day18/example7.txt",
            .expect = 24,
        },
        .{
            .input_file = "day18/example8.txt",
            .expect = 32,
        },
        .{
            .input_file = "day18/example9.txt",
            .expect = 72,
        },
    };

    for (test_cases) |tt| {
        var area = try Area.init(testing.allocator, tt.input_file);
        defer area.deinit(testing.allocator);
        area.update();

        var graph = try Graph.init(testing.allocator);
        defer graph.deinit();
        var visited = Visited.init(testing.allocator);
        defer visited.deinit();

        for (0..area.height) |y| {
            for (0..area.width) |x| {
                try area.findPath(testing.allocator, x, y, &visited, &graph);
            }
        }

        const got = try findMinSteps4(testing.allocator, area.totalKeys(), graph);
        try testing.expectEqual(tt.expect, got);
    }
}
