const std = @import("std");
const Allocator = std.mem.Allocator;

const Dir = enum(u8) {
    up,
    right,
    down,
    left,

    const Self = @This();

    fn dirs() [4]Dir {
        return .{ .up, .right, .down, .left };
    }
};

const Position = struct {
    x: usize,
    y: usize,

    const Self = @This();

    fn isEqual(self: Self, other: Self) bool {
        return self.x == other.x and self.y == other.y;
    }
};

const Portal = struct {
    id: u16,

    const Self = @This();

    fn from(str: []const u8) Self {
        std.debug.assert(str.len == 2);
        const id = (@as(u16, @intCast(str[1])) << 8) | str[0];
        return .{ .id = id };
    }

    fn stringify(self: Self) [2]u8 {
        return std.mem.toBytes(self.id);
    }
};

const PP = struct {
    pos: Position,
    portal: Portal,
};

const State = struct {
    pp: PP,
    level: u32,
};

const Slot = union(enum) {
    wall: void,
    passage: void,
    empty: void,
    portal: Portal,

    const Self = @This();
};

const Edge = struct {
    from: PP,
    to: PP,
    steps: u32,
    level_diff: i8,

    const Self = @This();

    fn debug(self: Self) void {
        std.debug.print("Edge({s}[{},{}]=>{s}[{},{}],{},{})\n", .{
            self.from.portal.stringify(),
            self.from.pos.x,
            self.from.pos.y,
            self.to.portal.stringify(),
            self.to.pos.x,
            self.to.pos.y,
            self.steps,
            self.level_diff,
        });
    }
};

const Graph = struct {
    allocator: Allocator,
    edges: Edges,
    maze: Maze,

    const Edges = std.AutoHashMap(PP, std.ArrayList(Edge));
    const Self = @This();

    fn init(allocator: Allocator, maze: Maze) Self {
        return .{
            .allocator = allocator,
            .edges = Edges.init(allocator),
            .maze = maze,
        };
    }

    fn deinit(self: *Self) void {
        var it = self.edges.iterator();
        while (it.next()) |e| {
            e.value_ptr.*.deinit();
        }
        self.edges.deinit();
    }

    fn addEdge(self: *Self, edge: Edge) !void {
        const gop = try self.edges.getOrPut(edge.from);
        if (!gop.found_existing) {
            gop.value_ptr.* = std.ArrayList(Edge).init(self.allocator);
        }
        try gop.value_ptr.*.append(edge);
    }

    fn getEdges(self: Self, pp: PP) []Edge {
        if (self.edges.get(pp)) |list| {
            return list.items;
        } else {
            return &[_]Edge{};
        }
    }

    fn findPP(self: Self, str: []const u8) PP {
        const id = Portal.from(str).id;

        var it = self.edges.iterator();
        while (it.next()) |e| {
            if (e.key_ptr.portal.id == id) {
                return e.key_ptr.*;
            }
        }

        unreachable;
    }

    fn findMapping(self: Self, pp: PP) PP {
        const positions: [2]?Position = self.maze.portal_mapping.get(pp.portal).?;
        std.debug.assert(positions[0] != null);

        if (positions[0].?.isEqual(pp.pos)) {
            if (positions[1]) |p| {
                return .{
                    .portal = pp.portal,
                    .pos = p,
                };
            }
        }

        if (positions[1]) |p| {
            std.debug.assert(p.isEqual(pp.pos));
            return .{
                .portal = pp.portal,
                .pos = positions[0].?,
            };
        }

        return pp;
    }

    fn fewestSteps(self: Self) !u32 {
        const ps = self.findPP("AA");
        const pe = self.findPP("ZZ");

        const origin_state = State{ .pp = ps, .level = 0 };

        var pq = PriorityQueue.init(self.allocator);
        defer pq.deinit();
        try pq.add(origin_state);

        var cache = std.AutoHashMap(State, u32).init(self.allocator);
        defer cache.deinit();
        try cache.put(origin_state, 0);

        while (pq.count() > 0) {
            const state: State = pq.remove();
            var steps: u32 = cache.get(state).?;

            if (state.pp.portal.id == pe.portal.id) {
                std.debug.assert(state.level == 0);
                return steps;
            }

            const mapped_pp = self.findMapping(state.pp);
            if (!mapped_pp.pos.isEqual(state.pp.pos)) {
                steps += 1;
            }
            var level = state.level;
            if (self.maze.isOutterPortal(state.pp.pos)) {
                level -|= 1;
            } else {
                level += 1;
            }
            for (self.getEdges(mapped_pp)) |e| {
                if (level == 0 and
                    e.level_diff == -1 and e.to.portal.id != pe.portal.id and e.to.portal.id != ps.portal.id) continue;
                if (level > 0 and (e.to.portal.id == pe.portal.id or e.to.portal.id == ps.portal.id)) continue;

                const next_steps = steps + e.steps;
                const next_state = State{
                    .pp = e.to,
                    .level = level,
                };
                const gop = try cache.getOrPut(next_state);
                if (!gop.found_existing or gop.value_ptr.* > next_steps) {
                    try pq.add(next_state);
                    gop.value_ptr.* = next_steps;
                }
            }
        }

        unreachable;
    }

    fn debug(self: Self) void {
        var it = self.edges.iterator();
        while (it.next()) |e| {
            for (e.value_ptr.items) |item| {
                item.debug();
            }
        }
    }
};

const PortalMapping = std.AutoHashMap(Portal, [2]?Position);

const Maze = struct {
    data: []Slot,
    width: usize,
    height: usize,
    portal_mapping: PortalMapping,

    const Self = @This();

    fn init(allocator: Allocator, input_file: []const u8) !Self {
        const file = try std.fs.cwd().openFile(input_file, .{});
        defer file.close();
        const reader = file.reader();

        var buf: [256]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        const writer = fbs.writer();

        var rows: usize = 0;
        var cols: usize = 0;
        while (true) {
            fbs.reset();
            if (reader.streamUntilDelimiter(writer, '\n', null)) |_| {
                cols = fbs.getWritten().len;
                rows += 1;
            } else |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            }
        }

        const raw_data = try allocator.alloc(u8, rows * cols);
        defer allocator.free(raw_data);

        const width = cols - 4;
        const height = rows - 4;
        const data = try allocator.alloc(Slot, width * height);
        errdefer allocator.free(data);
        var portal_mapping = PortalMapping.init(allocator);
        errdefer portal_mapping.deinit();

        try file.seekTo(0);
        var idx: usize = 0;
        while (true) {
            fbs.reset();
            if (reader.streamUntilDelimiter(writer, '\n', null)) |_| {
                @memcpy(raw_data[idx * cols .. (idx + 1) * cols], fbs.getWritten());
                idx += 1;
            } else |err| switch (err) {
                error.EndOfStream => break,
                else => return err,
            }
        }

        for (2..(rows - 2)) |y| {
            for (2..(cols - 2)) |x| {
                const i = y * cols + x;
                const j = (y - 2) * width + (x - 2);
                const char = raw_data[i];
                if (char == '#') {
                    data[j] = Slot.wall;
                } else if (std.ascii.isUpper(char) or char == ' ') {
                    data[j] = Slot.empty;
                } else if (std.ascii.isUpper(raw_data[y * cols + x - 1])) {
                    // left portal
                    data[j] = Slot{ .portal = Portal.from(raw_data[y * cols + x - 2 .. y * cols + x]) };
                    try updatePortalMapping(&portal_mapping, data[j].portal, x, y);
                } else if (std.ascii.isUpper(raw_data[y * cols + x + 1])) {
                    // right portal
                    data[j] = Slot{ .portal = Portal.from(raw_data[y * cols + x + 1 .. y * cols + x + 3]) };
                    try updatePortalMapping(&portal_mapping, data[j].portal, x, y);
                } else if (std.ascii.isUpper(raw_data[(y - 1) * cols + x])) {
                    // up portal
                    data[j] = Slot{ .portal = Portal.from(&[_]u8{
                        raw_data[(y - 2) * cols + x],
                        raw_data[(y - 1) * cols + x],
                    }) };
                    try updatePortalMapping(&portal_mapping, data[j].portal, x, y);
                } else if (std.ascii.isUpper(raw_data[(y + 1) * cols + x])) {
                    // down portal
                    data[j] = Slot{ .portal = Portal.from(&[_]u8{
                        raw_data[(y + 1) * cols + x],
                        raw_data[(y + 2) * cols + x],
                    }) };
                    try updatePortalMapping(&portal_mapping, data[j].portal, x, y);
                } else {
                    data[j] = Slot.passage;
                }
            }
        }

        return .{
            .data = data,
            .width = width,
            .height = height,
            .portal_mapping = portal_mapping,
        };
    }

    fn deinit(self: *Self, allocator: Allocator) void {
        allocator.free(self.data);
        self.portal_mapping.deinit();
    }

    fn updatePortalMapping(portal_mapping: *PortalMapping, portal: Portal, x: usize, y: usize) !void {
        const gop = try portal_mapping.getOrPut(portal);
        if (gop.found_existing) {
            std.debug.assert(gop.value_ptr.*[0] != null);
            std.debug.assert(gop.value_ptr.*[1] == null);
            gop.value_ptr.*[1] = Position{ .x = x - 2, .y = y - 2 };
        } else {
            gop.value_ptr.* = [_]?Position{
                .{ .x = x - 2, .y = y - 2 },
                null,
            };
        }
    }

    fn findPortal(self: Self, str: []const u8) Position {
        const target = Portal.from(str);
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const idx = y * self.width + x;
                switch (self.data[idx]) {
                    .portal => |p| {
                        if (p.id == target.id) {
                            return .{ .x = x, .y = y };
                        }
                    },
                    else => continue,
                }
            }
        }
        unreachable;
    }

    fn slotAt(self: Self, p: Position) Slot {
        const idx = p.y * self.width + p.x;
        return self.data[idx];
    }

    fn tryTeleport(self: Self, p: Position) ?Position {
        switch (self.slotAt(p)) {
            .portal => |portal| {
                const pos = self.portal_mapping.get(portal).?;
                std.debug.assert(pos[0] != null);

                if (pos[1] == null) {
                    return null;
                }
                if (pos[0].?.isEqual(p)) {
                    return pos[1];
                }
                if (pos[1].?.isEqual(p)) {
                    return pos[0];
                }
            },
            else => return null,
        }
        return null;
    }

    fn next(self: Self, p: Position, dir: Dir) ?Position {
        var dx: isize = 0;
        var dy: isize = 0;
        switch (dir) {
            .up => dy = -1,
            .right => dx = 1,
            .down => dy = 1,
            .left => dx = -1,
        }

        const x = @as(isize, @intCast(p.x)) + dx;
        const y = @as(isize, @intCast(p.y)) + dy;

        if (x < 0 or x >= self.width) return null;
        if (y < 0 or y >= self.height) return null;

        return .{ .x = @intCast(x), .y = @intCast(y) };
    }

    fn fewestSteps(self: Self, allocator: Allocator) !u32 {
        const dirs = Dir.dirs();
        const from = self.findPortal("AA");
        const end = self.findPortal("ZZ");

        var q = try Queue(Position).init(allocator);
        defer q.deinit();
        try q.add(from);

        var cache = Cache.init(allocator);
        defer cache.deinit();
        try cache.put(from, 0);

        var steps: u32 = 0;

        while (q.count() > 0) {
            steps += 1;
            const size = q.count();
            for (0..size) |_| {
                const p = q.remove().?;

                if (p.isEqual(end)) {
                    return steps - 1;
                }

                if (self.tryTeleport(p)) |next_pos| {
                    const gop = try cache.getOrPut(next_pos);
                    if (!gop.found_existing or gop.value_ptr.* > steps) {
                        gop.value_ptr.* = steps;
                        try q.add(next_pos);
                    }
                }

                for (dirs) |dir| {
                    if (self.next(p, dir)) |next_pos| {
                        switch (self.slotAt(next_pos)) {
                            .wall, .empty => continue,
                            else => {
                                const gop = try cache.getOrPut(next_pos);
                                if (!gop.found_existing or gop.value_ptr.* > steps) {
                                    gop.value_ptr.* = steps;
                                    try q.add(next_pos);
                                }
                            },
                        }
                    }
                }
            }
        }

        unreachable;
    }

    fn buildGraph(self: Self, allocator: Allocator) !Graph {
        var graph = Graph.init(allocator, self);
        errdefer graph.deinit();

        var queue = try Queue(Position).init(allocator);
        defer queue.deinit();

        var visited = Cache.init(allocator);
        defer visited.deinit();

        var it = self.portal_mapping.iterator();
        while (it.next()) |e| {
            const portal = e.key_ptr.*;
            for (e.value_ptr.*) |maybe_pos| {
                if (maybe_pos) |pos| {
                    try self.findEdges(&graph, &queue, &visited, portal, pos);
                }
            }
        }

        return graph;
    }

    fn findEdges(
        self: Self,
        graph: *Graph,
        queue: *Queue(Position),
        visited: *Cache,
        from_portal: Portal,
        from_position: Position,
    ) !void {
        const dirs = Dir.dirs();
        queue.reset();
        visited.clearRetainingCapacity();

        try queue.add(from_position);
        try visited.put(from_position, 0);

        var steps: u32 = 0;
        while (queue.count() > 0) {
            steps += 1;
            const size = queue.count();
            for (0..size) |_| {
                const pos = queue.remove().?;
                for (dirs) |dir| {
                    if (self.next(pos, dir)) |next_pos| {
                        if (visited.get(next_pos)) |_| {
                            continue;
                        }
                        try visited.put(next_pos, steps);
                        switch (self.slotAt(next_pos)) {
                            .empty => continue,
                            .wall => continue,
                            .passage => try queue.add(next_pos),
                            .portal => |to_portal| {
                                const edge = Edge{
                                    .from = .{
                                        .pos = from_position,
                                        .portal = from_portal,
                                    },
                                    .to = .{
                                        .pos = next_pos,
                                        .portal = to_portal,
                                    },
                                    .steps = steps,
                                    .level_diff = if (self.isOutterPortal(next_pos)) -1 else 1,
                                };
                                try graph.addEdge(edge);
                            },
                        }
                    }
                }
            }
        }
    }

    fn isOutterPortal(self: Self, position: Position) bool {
        return position.x == 0 or
            position.x == self.width - 1 or
            position.y == 0 or
            position.y == self.height - 1;
    }

    fn debug(self: Self) void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const char: u8 = switch (self.data[y * self.width + x]) {
                    .wall => '#',
                    .passage => '.',
                    .empty => ' ',
                    .portal => 'o',
                };
                std.debug.print("{c}", .{char});
            }
            std.debug.print("\n", .{});
        }
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                switch (self.data[y * self.width + x]) {
                    .portal => |p| {
                        std.debug.print("portal ({},{}) {s}\n", .{ x, y, p.stringify() });
                    },
                    else => continue,
                }
            }
        }
        var it = self.portal_mapping.iterator();
        while (it.next()) |e| {
            std.debug.print("{s} => {any}\n", .{ e.key_ptr.*.stringify(), e.value_ptr });
        }
    }
};

const Cache = std.AutoHashMap(Position, u32);

const PriorityQueue = struct {
    pq: PQ,

    const PQ = std.PriorityQueue(State, void, struct {
        fn compareFn(context: void, a: State, b: State) std.math.Order {
            _ = context;
            return std.math.order(a.level, b.level);
        }
    }.compareFn);
    const Self = @This();

    fn init(allocator: Allocator) Self {
        return .{
            .pq = PQ.init(allocator, {}),
        };
    }

    fn deinit(self: *Self) void {
        self.pq.deinit();
    }

    fn add(self: *Self, s: State) !void {
        try self.pq.add(s);
    }

    fn remove(self: *Self) State {
        return self.pq.remove();
    }

    fn count(self: Self) usize {
        return self.pq.count();
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

        fn reset(self: *Self) void {
            self.list = std.DoublyLinkedList(T){};
            _ = self.pool.reset(.retain_capacity);
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

fn doFewestSteps(input_file: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var m = try Maze.init(allocator, input_file);
    defer m.deinit(allocator);

    return try m.fewestSteps(allocator);
}

fn doRecursionFewestSteps(input_file: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var m = try Maze.init(allocator, input_file);
    defer m.deinit(allocator);

    var g = try m.buildGraph(allocator);
    defer g.deinit();

    return try g.fewestSteps();
}

pub fn fewestSteps(input_file: []const u8) u32 {
    return doFewestSteps(input_file) catch unreachable;
}

pub fn recursionFewestSteps(input_file: []const u8) u32 {
    return doRecursionFewestSteps(input_file) catch unreachable;
}

const testing = std.testing;

test "fewestSteps" {
    const TestCase = struct {
        input_file: []const u8,
        expect: u32,
    };

    const test_cases = [_]TestCase{
        .{ .input_file = "day20/example.txt", .expect = 23 },
        .{ .input_file = "day20/example2.txt", .expect = 58 },
    };

    for (test_cases) |tt| {
        var m = try Maze.init(testing.allocator, tt.input_file);
        defer m.deinit(testing.allocator);
        const got = try m.fewestSteps(testing.allocator);
        try testing.expectEqual(tt.expect, got);
    }
}

test "recursion fewestSteps" {
    var m = try Maze.init(testing.allocator, "day20/example3.txt");
    defer m.deinit(testing.allocator);

    var g = try m.buildGraph(testing.allocator);
    defer g.deinit();

    const got = try g.fewestSteps();
    try testing.expectEqual(396, got);
}
