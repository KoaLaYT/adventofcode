const std = @import("std");

const Angle = struct {
    x: i32,
    y: i32,

    const Self = @This();

    fn lessThan(ctx: void, a1: Angle, a2: Angle) bool {
        _ = ctx;

        if (a1.y == 0) return true;
        if (a1.x == 0) return false;
        return a1.degree() < a2.degree();
    }

    fn degree(self: Self) f64 {
        std.debug.assert(self.x > 0 and self.y > 0);
        const fx: f64 = @floatFromInt(self.x);
        const fy: f64 = @floatFromInt(self.y);
        return fy / fx;
    }

    fn all(allocator: std.mem.Allocator, width: usize, height: usize) !std.ArrayList(Angle) {
        var list = std.ArrayList(Angle).init(allocator);

        var quarter = std.ArrayList(Angle).init(allocator);
        defer quarter.deinit();
        var dups = try std.ArrayList(bool).initCapacity(allocator, 2 * width * height);
        defer dups.deinit();

        for (0..2 * width * height) |_| {
            try dups.append(false);
        }

        for (1..width + 1) |dx| {
            for (1..height + 1) |dy| {
                const g = gcd(usize, dx, dy);
                const x = @as(i32, @intCast(dx / g));
                const y = @as(i32, @intCast(dy / g));
                const idx = @as(usize, @intCast(y)) * width + @as(usize, @intCast(x));
                if (!dups.items[idx]) {
                    dups.items[idx] = true;
                    try quarter.append(.{ .x = x, .y = y });
                }
            }
        }

        std.sort.pdq(Angle, quarter.items, {}, Self.lessThan);

        var idx: usize = undefined;
        // 1st quarter
        idx = quarter.items.len - 1;
        try list.append(.{ .x = 0, .y = -1 });
        while (true) : (idx -= 1) {
            try list.append(quarter.items[idx].xAxisSymmetry());
            if (idx == 0) break;
        }
        // 2nd quarter
        idx = 0;
        try list.append(.{ .x = 1, .y = 0 });
        while (idx < quarter.items.len) : (idx += 1) {
            try list.append(quarter.items[idx]);
        }
        // 3rd quarter
        idx = quarter.items.len - 1;
        try list.append(.{ .x = 0, .y = 1 });
        while (true) : (idx -= 1) {
            try list.append(quarter.items[idx].yAxisSymmetry());
            if (idx == 0) break;
        }
        // 4th quarter
        idx = 0;
        try list.append(.{ .x = -1, .y = 0 });
        while (idx < quarter.items.len) : (idx += 1) {
            try list.append(quarter.items[idx].symmetry());
        }

        return list;
    }

    fn xAxisSymmetry(self: Self) Self {
        return .{ .x = self.x, .y = -self.y };
    }

    fn yAxisSymmetry(self: Self) Self {
        return .{ .x = -self.x, .y = self.y };
    }

    fn symmetry(self: Self) Self {
        return .{ .x = -self.x, .y = -self.y };
    }
};

const Map = struct {
    data: []u8,
    width: usize,
    height: usize,
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, input_file: []const u8) !Map {
        var f = try std.fs.cwd().openFile(input_file, .{});
        defer f.close();

        const max_bytes = try f.getEndPos();
        const bytes = try f.readToEndAlloc(allocator, max_bytes);
        defer allocator.free(bytes);

        var it = std.mem.splitScalar(u8, bytes[0 .. max_bytes - 1], '\n');
        var width: usize = 0;
        var height: usize = 0;
        while (it.next()) |row| {
            height += 1;
            width = row.len;
        }

        var data = try allocator.alloc(u8, width * height);
        it.reset();
        height = 0;
        while (it.next()) |row| {
            @memcpy(data[height * width .. (height + 1) * width], row);
            height += 1;
        }

        return .{
            .data = data,
            .width = width,
            .height = height,
            .allocator = allocator,
        };
    }

    fn deinit(self: Self) void {
        self.allocator.free(self.data);
    }

    fn charAt(self: Self, x: i32, y: i32) u8 {
        const optional_ptr = self.charAtPtr(x, y);
        if (optional_ptr) |ptr| {
            return ptr.*;
        } else {
            return 0;
        }
    }

    fn charAtPtr(self: Self, x: i32, y: i32) ?*u8 {
        if (x < 0 or x >= self.width) return null;
        if (y < 0 or y >= self.height) return null;

        const xx = @as(usize, @intCast(x));
        const yy = @as(usize, @intCast(y));
        const idx = yy * self.height + xx;
        return &self.data[idx];
    }

    fn canDetectAsteroidAt(self: Self, x: i32, y: i32, angle: Angle) u32 {
        var xx = x;
        var yy = y;

        while (true) {
            xx += angle.x;
            yy += angle.y;

            switch (self.charAt(xx, yy)) {
                0 => return 0,
                '#' => return 1,
                '.' => continue,
                else => unreachable,
            }
        }
    }

    fn countDetectedAsteroidsAt(self: Self, x: usize, y: usize, angles: []const Angle) u32 {
        const xx = @as(i32, @intCast(x));
        const yy = @as(i32, @intCast(y));

        if (self.charAt(xx, yy) == '.') return 0;

        var count: u32 = 0;

        for (angles) |angle| {
            count += self.canDetectAsteroidAt(xx, yy, angle);
        }

        return count;
    }

    fn maxDetectedAsteroids(self: Self, all_angles: []const Angle) struct { u32, usize, usize } {
        var max: u32 = 0;
        var xx: usize = 0;
        var yy: usize = 0;

        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const v = self.countDetectedAsteroidsAt(x, y, all_angles);
                if (v > max) {
                    max = v;
                    xx = x;
                    yy = y;
                }
            }
        }
        return .{ max, xx, yy };
    }

    fn vaporizeAt(self: *Self, x: usize, y: usize, angle: Angle) struct { bool, i32, i32 } {
        var xx = @as(i32, @intCast(x));
        var yy = @as(i32, @intCast(y));

        while (true) {
            xx += angle.x;
            yy += angle.y;

            switch (self.charAt(xx, yy)) {
                0 => return .{ false, 0, 0 },
                '#' => {
                    self.charAtPtr(xx, yy).?.* = '.';
                    return .{ true, xx, yy };
                },
                '.' => continue,
                else => unreachable,
            }
        }
    }

    fn vaporizeTill(self: *Self, x: usize, y: usize, nth: usize, all_angles: []const Angle) struct { i32, i32 } {
        var idx: usize = 0;
        var vaporized: u32 = 0;

        while (true) {
            const ok, const xx, const yy = self.vaporizeAt(x, y, all_angles[idx]);
            if (ok) {
                vaporized += 1;
            }
            if (vaporized == nth) {
                return .{ xx, yy };
            }
            idx = (idx + 1) % all_angles.len;
        }
    }
};

fn gcd(comptime T: anytype, a: T, b: T) T {
    std.debug.assert(a != 0 and b != 0);

    var va = a;
    var vb = b;
    while (va != vb) {
        if (va > vb) {
            va = va - vb;
        } else {
            vb = vb - va;
        }
    }
    return va;
}

pub fn maxDetectedAsteroids(input_file: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const m = Map.init(gpa.allocator(), input_file) catch unreachable;
    defer m.deinit();

    const all_angles = Angle.all(gpa.allocator(), m.width, m.height) catch unreachable;
    defer all_angles.deinit();

    const max, _, _ = m.maxDetectedAsteroids(all_angles.items);
    return max;
}

pub fn vaporizeTill(input_file: []const u8) i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var m = Map.init(gpa.allocator(), input_file) catch unreachable;
    defer m.deinit();

    const all_angles = Angle.all(gpa.allocator(), m.width, m.height) catch unreachable;
    defer all_angles.deinit();

    _, const x, const y = m.maxDetectedAsteroids(all_angles.items);
    const xx, const yy = m.vaporizeTill(x, y, 200, all_angles.items);
    return 100 * xx + yy;
}

const testing = std.testing;

test "maxDetectedAsteroids" {
    const TestCase = struct {
        input_file: []const u8,
        expect: struct { u32, usize, usize },
    };

    const test_cases = [_]TestCase{
        .{ .input_file = "day10/example.txt", .expect = .{ 8, 3, 4 } },
        .{ .input_file = "day10/example2.txt", .expect = .{ 33, 5, 8 } },
        .{ .input_file = "day10/example3.txt", .expect = .{ 35, 1, 2 } },
        .{ .input_file = "day10/example4.txt", .expect = .{ 41, 6, 3 } },
        .{ .input_file = "day10/example5.txt", .expect = .{ 210, 11, 13 } },
    };

    for (test_cases) |tt| {
        const m = try Map.init(testing.allocator, tt.input_file);
        defer m.deinit();

        const all_angles = Angle.all(testing.allocator, m.width, m.height) catch unreachable;
        defer all_angles.deinit();

        const max, const x, const y = m.maxDetectedAsteroids(all_angles.items);

        try testing.expectEqual(tt.expect[0], max);
        try testing.expectEqual(tt.expect[1], x);
        try testing.expectEqual(tt.expect[2], y);
    }
}

test "vaporizeTill" {
    const TestCase = struct {
        input: usize,
        expect: struct { i32, i32 },
    };

    const test_cases = [_]TestCase{
        .{ .input = 1, .expect = .{ 11, 12 } },
        .{ .input = 2, .expect = .{ 12, 1 } },
        .{ .input = 200, .expect = .{ 8, 2 } },
        .{ .input = 299, .expect = .{ 11, 1 } },
    };

    for (test_cases) |tt| {
        var m = try Map.init(testing.allocator, "day10/example5.txt");
        defer m.deinit();

        const all_angles = Angle.all(testing.allocator, m.width, m.height) catch unreachable;
        defer all_angles.deinit();

        _, const x, const y = m.maxDetectedAsteroids(all_angles.items);
        const xx, const yy = m.vaporizeTill(x, y, tt.input, all_angles.items);

        try testing.expectEqual(tt.expect[0], xx);
        try testing.expectEqual(tt.expect[1], yy);
    }
}
