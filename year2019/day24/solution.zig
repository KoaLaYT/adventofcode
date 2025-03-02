const std = @import("std");
const Allocator = std.mem.Allocator;

const pow_twos: [25]u32 = blk: {
    var arr: [25]u32 = undefined;

    for (0..25) |i| {
        arr[i] = std.math.pow(u32, 2, i);
    }

    break :blk arr;
};

const Eris = struct {
    layout: [25]u8,
    buffer: [25]u8,

    const Self = @This();

    fn init(input_file: []const u8) !Self {
        const f = try std.fs.cwd().openFile(input_file, .{});
        defer f.close();

        var buf: [64]u8 = undefined;
        const n = try f.readAll(&buf);

        var layout: [25]u8 = undefined;
        var i: usize = 0;

        for (0..n) |j| {
            if (buf[j] == '\n') continue;
            layout[i] = buf[j];
            i += 1;
        }

        return .{ .layout = layout, .buffer = undefined };
    }

    fn tick(self: *Self) void {
        for (0..5) |y| {
            for (0..5) |x| {
                self.update(x, y);
            }
        }
        std.mem.swap([25]u8, &self.layout, &self.buffer);
    }

    fn charAt(self: Self, x: isize, y: isize) u8 {
        if (x < 0 or x >= 5) return '.';
        if (y < 0 or y >= 5) return '.';

        const idx = y * 5 + x;
        return self.layout[@intCast(idx)];
    }

    fn update(self: *Self, x: usize, y: usize) void {
        const ix: isize = @intCast(x);
        const iy: isize = @intCast(y);
        const up = self.charAt(ix, iy - 1);
        const right = self.charAt(ix + 1, iy);
        const down = self.charAt(ix, iy + 1);
        const left = self.charAt(ix - 1, iy);

        var bugs: usize = 0;
        if (up == '#') bugs += 1;
        if (right == '#') bugs += 1;
        if (down == '#') bugs += 1;
        if (left == '#') bugs += 1;

        var next: u8 = undefined;
        switch (self.charAt(ix, iy)) {
            '#' => {
                if (bugs == 1) {
                    next = '#';
                } else {
                    next = '.';
                }
            },
            '.' => {
                if (bugs == 1 or bugs == 2) {
                    next = '#';
                } else {
                    next = '.';
                }
            },
            else => unreachable,
        }

        self.buffer[y * 5 + x] = next;
    }

    fn biodiversity(self: Self) u32 {
        var result: u32 = 0;

        for (self.layout, 0..) |v, i| {
            if (v == '#') {
                result += pow_twos[i];
            }
        }

        return result;
    }

    fn debug(self: Self) void {
        for (0..5) |i| {
            std.debug.print("{s}\n", .{self.layout[i * 5 ..][0..5]});
        }
        std.debug.print("\n", .{});
    }
};

fn doDetechLoop(allocator: Allocator, eris: *Eris) !void {
    var states = std.AutoHashMap([25]u8, bool).init(allocator);
    defer states.deinit();

    try states.put(eris.layout, true);

    while (true) {
        eris.tick();
        const gop = try states.getOrPut(eris.layout);
        if (gop.found_existing) {
            break;
        } else {
            gop.value_ptr.* = true;
        }
    }
}

pub fn detechLoop(input_file: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var eris = Eris.init(input_file) catch unreachable;
    doDetechLoop(allocator, &eris) catch unreachable;
    return eris.biodiversity();
}

const PackedLayout = std.bit_set.IntegerBitSet(25);

const Level = struct {
    curr: PackedLayout,
    prev: PackedLayout,

    const Self = @This();

    fn initEmpty() Self {
        return .{
            .curr = PackedLayout.initEmpty(),
            .prev = PackedLayout.initEmpty(),
        };
    }

    fn init(input_file: []const u8) !Self {
        const f = try std.fs.cwd().openFile(input_file, .{});
        defer f.close();

        var buf: [64]u8 = undefined;
        const n = try f.readAll(&buf);

        var curr = PackedLayout.initEmpty();
        var prev = PackedLayout.initEmpty();
        var i: usize = 0;
        for (0..n) |j| {
            if (buf[j] == '\n') continue;
            if (buf[j] == '#') {
                curr.set(i);
                prev.set(i);
            }
            i += 1;
        }
        std.debug.assert(i == 25);

        return .{
            .curr = curr,
            .prev = prev,
        };
    }

    fn update(self: *Self, outer: PackedLayout, inner: PackedLayout) void {
        self.prev = self.curr;
        for (0..PackedLayout.bit_length) |i| {
            const bugs = self.countBugs(i, outer, inner);
            if (self.curr.isSet(i) and bugs != 1) {
                self.curr.unset(i);
            } else if (!self.curr.isSet(i) and (bugs == 1 or bugs == 2)) {
                self.curr.set(i);
            }
        }
    }

    fn countBugs(self: Self, i: usize, outer: PackedLayout, inner: PackedLayout) u32 {
        var bugs: u32 = 0;
        switch (i) {
            // top left
            0 => {
                bugs += detectBug(outer, 7); // up
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(self.prev, i + 5); // down
                bugs += detectBug(outer, 11); // left
            },
            // top right
            4 => {
                bugs += detectBug(outer, 7); // up
                bugs += detectBug(outer, 13); // right
                bugs += detectBug(self.prev, i + 5); // down
                bugs += detectBug(self.prev, i - 1); // left
            },
            // bottom left
            20 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(outer, 17); // down
                bugs += detectBug(outer, 11); // left
            },
            // bottom right
            24 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(outer, 13); // right
                bugs += detectBug(outer, 17); // down
                bugs += detectBug(self.prev, i - 1); // left
            },
            // first row
            1, 2, 3 => {
                bugs += detectBug(outer, 7); // up
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(self.prev, i + 5); // down
                bugs += detectBug(self.prev, i - 1); // left
            },
            // last row
            21, 22, 23 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(outer, 17); // down
                bugs += detectBug(self.prev, i - 1); // left
            },
            // first col
            5, 10, 15 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(self.prev, i + 5); // down
                bugs += detectBug(outer, 11); // left
            },
            // last col
            9, 14, 19 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(outer, 13); // right
                bugs += detectBug(self.prev, i + 5); // down
                bugs += detectBug(self.prev, i - 1); // left
            },
            // normal 4
            6, 8, 16, 18 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(self.prev, i + 5); // down
                bugs += detectBug(self.prev, i - 1); // left
            },
            7 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(self.prev, i - 1); // left
                // inner top
                bugs += detectBug(inner, 0);
                bugs += detectBug(inner, 1);
                bugs += detectBug(inner, 2);
                bugs += detectBug(inner, 3);
                bugs += detectBug(inner, 4);
            },
            11 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(self.prev, i + 5); // down
                bugs += detectBug(self.prev, i - 1); // left
                // inner left
                bugs += detectBug(inner, 0);
                bugs += detectBug(inner, 5);
                bugs += detectBug(inner, 10);
                bugs += detectBug(inner, 15);
                bugs += detectBug(inner, 20);
            },
            13 => {
                bugs += detectBug(self.prev, i - 5); // up
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(self.prev, i + 5); // down
                // inner right
                bugs += detectBug(inner, 4);
                bugs += detectBug(inner, 9);
                bugs += detectBug(inner, 14);
                bugs += detectBug(inner, 19);
                bugs += detectBug(inner, 24);
            },
            17 => {
                bugs += detectBug(self.prev, i + 1); // right
                bugs += detectBug(self.prev, i + 5); // down
                bugs += detectBug(self.prev, i - 1); // left
                // inner bottom
                bugs += detectBug(inner, 20);
                bugs += detectBug(inner, 21);
                bugs += detectBug(inner, 22);
                bugs += detectBug(inner, 23);
                bugs += detectBug(inner, 24);
            },
            // center
            12 => {},
            else => unreachable,
        }
        return bugs;
    }

    fn detectBug(layout: PackedLayout, i: usize) u32 {
        std.debug.assert(i < PackedLayout.bit_length);
        if (layout.isSet(i)) {
            return 1;
        } else {
            return 0;
        }
    }

    fn debug(self: Self) void {
        for (0..PackedLayout.bit_length) |i| {
            const char: u8 = if (self.curr.isSet(i)) '#' else '.';
            std.debug.print("{c}", .{char});
            if (i % 5 == 4) {
                std.debug.print("\n", .{});
            }
        }
    }
};

const RecursiveEris = struct {
    levels: Levels,
    min_level: i32,
    max_level: i32,

    const Levels = std.AutoHashMap(i32, Level);
    const Self = @This();

    fn init(allocator: Allocator, level: Level) !Self {
        var levels = Levels.init(allocator);
        try levels.put(0, level);
        return .{
            .levels = levels,
            .min_level = 0,
            .max_level = 0,
        };
    }

    fn deinit(self: *Self) void {
        self.levels.deinit();
    }

    fn getLevelPtr(self: *Self, lv: i32) !*Level {
        const gop = try self.levels.getOrPut(lv);
        if (!gop.found_existing) {
            gop.value_ptr.* = Level.initEmpty();
        }
        return gop.value_ptr;
    }

    fn tick(self: *Self) !void {
        var lv = self.min_level - 1;
        while (lv <= self.max_level + 1) : (lv += 1) {
            const outer = (try self.getLevelPtr(lv - 1)).prev;
            const inner = (try self.getLevelPtr(lv + 1)).curr;
            const curr = try self.getLevelPtr(lv);
            curr.update(outer, inner);
        }

        if ((try self.getLevelPtr(self.min_level - 1)).curr.mask != 0) {
            self.min_level -= 1;
        }

        if ((try self.getLevelPtr(self.max_level + 1)).curr.mask != 0) {
            self.max_level += 1;
        }
    }

    fn totalBugs(self: Self) usize {
        var total: usize = 0;

        var i: i32 = self.min_level;
        while (i <= self.max_level) : (i += 1) {
            const level: Level = self.levels.get(i).?;
            total += level.curr.count();
        }

        return total;
    }

    fn debug(self: *Self) !void {
        var i = self.min_level;
        while (i <= self.max_level) : (i += 1) {
            const level = try self.getLevelPtr(i);
            std.debug.print("depth: {}\n", .{i});
            level.debug();
        }
    }
};

fn doCountBugs(input_file: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const level = try Level.init(input_file);
    var eris = try RecursiveEris.init(allocator, level);
    defer eris.deinit();

    for (0..200) |_| {
        try eris.tick();
    }
    return eris.totalBugs();
}

pub fn countBugs(input_file: []const u8) usize {
    return doCountBugs(input_file) catch unreachable;
}

const testing = std.testing;

test "doDetechLoop" {
    var eris = try Eris.init("day24/example.txt");
    try doDetechLoop(testing.allocator, &eris);

    const got = eris.biodiversity();
    try testing.expectEqual(2129920, got);
}

test "RecursiveEris" {
    const level = try Level.init("day24/example.txt");
    var eris = try RecursiveEris.init(testing.allocator, level);
    defer eris.deinit();

    for (0..10) |_| {
        try eris.tick();
    }
    const got = eris.totalBugs();
    try testing.expectEqual(99, got);
}
