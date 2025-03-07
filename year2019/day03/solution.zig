const std = @import("std");

const Position = struct {
    x: i32,
    y: i32,

    const origin: Position = .{
        .x = 0,
        .y = 0,
    };

    fn distance(self: Position) u32 {
        return @abs(self.x) + @abs(self.y);
    }
};

const Range = struct {
    from: i32,
    to: i32,

    const Self = @This();

    fn fromPathY(path: Path) Range {
        return .{
            .from = @min(path.start.y, path.end.y),
            .to = @max(path.start.y, path.end.y),
        };
    }

    fn fromPathX(path: Path) Range {
        return .{
            .from = @min(path.start.x, path.end.x),
            .to = @max(path.start.x, path.end.x),
        };
    }

    fn includes(self: Self, v: i32) bool {
        return self.from <= v and v <= self.to;
    }

    fn closestIntersectAt(self: Self, other: Self) ?i32 {
        const from = @max(self.from, other.from);
        const to = @min(self.to, other.to);

        if (from > to) return null;

        if (@abs(from) < @abs(to)) {
            return from;
        } else {
            return to;
        }
    }
};

const Path = struct {
    start: Position,
    end: Position,
    steps: u32,

    const Self = @This();

    fn from(input: []const u8, start: Position, steps: u32) Self {
        var dx: i32 = 0;
        var dy: i32 = 0;
        switch (input[0]) {
            'U' => dy = 1,
            'R' => dx = 1,
            'D' => dy = -1,
            'L' => dx = -1,
            else => unreachable,
        }

        const dist = std.fmt.parseInt(i32, input[1..], 10) catch unreachable;

        return .{
            .start = start,
            .end = .{
                .x = start.x + dx * dist,
                .y = start.y + dy * dist,
            },
            .steps = steps + @as(u32, @intCast(dist)),
        };
    }

    fn closestIntersectAt(self: Self, other: Self) ?Position {
        // 1. both vertical
        if (self.start.x == self.end.x and
            other.start.x == other.end.x and
            self.start.x == other.start.x)
        {
            const y = Range.fromPathY(self).closestIntersectAt(Range.fromPathY(other)) orelse return null;
            return .{ .x = self.start.x, .y = y };
        }

        // 2. both horizontal
        if (self.start.y == self.end.y and
            other.start.y == other.end.y and
            self.start.y == other.start.y)
        {
            const x = Range.fromPathX(self).closestIntersectAt(Range.fromPathX(other)) orelse return null;
            return .{ .x = x, .y = self.start.y };
        }

        // 3. vertical self cross other
        if (self.start.x == self.end.x and
            other.start.y == other.end.y and
            Range.fromPathX(other).includes(self.start.x) and
            Range.fromPathY(self).includes(other.start.y))
        {
            return .{ .x = self.start.x, .y = other.start.y };
        }

        // 4. horizontal self cross other
        if (self.start.y == self.end.y and
            other.start.x == other.end.x and
            Range.fromPathY(other).includes(self.start.y) and
            Range.fromPathX(self).includes(other.start.x))
        {
            return .{ .x = other.start.x, .y = self.start.y };
        }

        return null;
    }
};

fn parsePaths(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Path) {
    var list = std.ArrayList(Path).init(allocator);
    var splits = std.mem.splitScalar(u8, input, ',');
    var curr = Position.origin;
    var steps: u32 = 0;

    while (splits.next()) |part| {
        const path = Path.from(part, curr, steps);
        try list.append(path);
        curr = path.end;
        steps = path.steps;
    }

    return list;
}

fn doClosestIntersectAt(paths1: std.ArrayList(Path), paths2: std.ArrayList(Path)) u32 {
    var min: u32 = std.math.maxInt(u32);

    for (paths1.items) |path1| {
        for (paths2.items) |path2| {
            if (path1.closestIntersectAt(path2)) |at| {
                const d = at.distance();
                if (d > 0) {
                    min = @min(min, d);
                }
            }
        }
    }

    return min;
}

fn doFewestSteps(paths1: std.ArrayList(Path), paths2: std.ArrayList(Path)) u32 {
    var min: u32 = std.math.maxInt(u32);

    for (paths1.items) |path1| {
        for (paths2.items) |path2| {
            if (path1.closestIntersectAt(path2)) |at| {
                if (at.x == 0 and at.y == 0) continue;
                if (path1.start.x == at.x and
                    path1.end.x == at.x and
                    path2.start.y == at.y and
                    path2.start.y == at.y)
                {
                    const steps = path1.steps - @as(u32, @intCast(@abs(path1.end.y - at.y))) +
                        path2.steps - @as(u32, @intCast(@abs(path2.end.x - at.x)));
                    min = @min(min, steps);
                }
                if (path1.start.y == at.y and
                    path1.end.y == at.y and
                    path2.start.x == at.x and
                    path2.start.x == at.x)
                {
                    const steps = path1.steps - @as(u32, @intCast(@abs(path1.end.x - at.x))) +
                        path2.steps - @as(u32, @intCast(@abs(path2.end.y - at.y)));
                    min = @min(min, steps);
                }
            }
        }
    }

    return min;
}

fn parseInput(allocator: std.mem.Allocator, input_file: []const u8) ![2]std.ArrayList(Path) {
    var f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();

    var buf: [2048]u8 = undefined;
    var bs = std.io.fixedBufferStream(buf[0..]);
    const w = bs.writer();

    var result: [2]std.ArrayList(Path) = undefined;
    for (0..2) |i| {
        try f.reader().streamUntilDelimiter(w, '\n', null);
        result[i] = try parsePaths(allocator, bs.getWritten());
        bs.reset();
    }
    return result;
}

pub fn closestIntersectAt(input_file: []const u8) u32 {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const results = parseInput(allocator, input_file) catch unreachable;
    const paths1 = results[0];
    defer paths1.deinit();
    const paths2 = results[1];
    defer paths2.deinit();

    return doClosestIntersectAt(paths1, paths2);
}

pub fn fewestSteps(input_file: []const u8) u32 {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const results = parseInput(allocator, input_file) catch unreachable;
    const paths1 = results[0];
    defer paths1.deinit();
    const paths2 = results[1];
    defer paths2.deinit();

    return doFewestSteps(paths1, paths2);
}

const testing = std.testing;
test "doClosestIntersectAt" {
    const TestCase = struct {
        input1: []const u8,
        input2: []const u8,
        expect: u32,
    };

    const test_cases = [_]TestCase{
        .{
            .input1 = "R8,U5,L5,D3",
            .input2 = "U7,R6,D4,L4",
            .expect = 6,
        },
        .{
            .input1 = "R75,D30,R83,U83,L12,D49,R71,U7,L72",
            .input2 = "U62,R66,U55,R34,D71,R55,D58,R83",
            .expect = 159,
        },
        .{
            .input1 = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
            .input2 = "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7",
            .expect = 135,
        },
    };

    const allocator = testing.allocator;
    for (test_cases) |tt| {
        const paths1 = try parsePaths(allocator, tt.input1);
        defer paths1.deinit();
        const paths2 = try parsePaths(allocator, tt.input2);
        defer paths2.deinit();

        const got = doClosestIntersectAt(paths1, paths2);
        try testing.expectEqual(tt.expect, got);
    }
}

test "doFewestSteps" {
    const TestCase = struct {
        input1: []const u8,
        input2: []const u8,
        expect: u32,
    };

    const test_cases = [_]TestCase{
        .{
            .input1 = "R8,U5,L5,D3",
            .input2 = "U7,R6,D4,L4",
            .expect = 30,
        },
        .{
            .input1 = "R75,D30,R83,U83,L12,D49,R71,U7,L72",
            .input2 = "U62,R66,U55,R34,D71,R55,D58,R83",
            .expect = 610,
        },
        .{
            .input1 = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
            .input2 = "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7",
            .expect = 410,
        },
    };

    const allocator = testing.allocator;
    for (test_cases) |tt| {
        const paths1 = try parsePaths(allocator, tt.input1);
        defer paths1.deinit();
        const paths2 = try parsePaths(allocator, tt.input2);
        defer paths2.deinit();

        const got = doFewestSteps(paths1, paths2);
        try testing.expectEqual(tt.expect, got);
    }
}
