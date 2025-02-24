const std = @import("std");
const Allocator = std.mem.Allocator;

const Technique = union(enum) {
    new_stack: void,
    cut_n: isize,
    incr_n: usize,

    const Self = @This();

    fn parse(str: []const u8) !Self {
        if (std.mem.eql(u8, str, "deal into new stack")) {
            return .new_stack;
        }

        if (std.mem.eql(u8, str[0..4], "deal")) {
            const n = try std.fmt.parseInt(usize, str[20..], 10);
            return .{ .incr_n = n };
        }

        if (std.mem.eql(u8, str[0..3], "cut")) {
            const n = try std.fmt.parseInt(isize, str[4..], 10);
            return .{ .cut_n = n };
        }

        return error.UnknownTechnique;
    }

    fn eql(self: Self, other: Self) bool {
        return switch (self) {
            .new_stack => switch (other) {
                .new_stack => true,
                else => false,
            },
            .cut_n => |x| switch (other) {
                .cut_n => |y| x == y,
                else => false,
            },
            .incr_n => |x| switch (other) {
                .incr_n => |y| x == y,
                else => false,
            },
        };
    }

    fn merge(self: Self, other: Self, count: usize) ?Technique {
        switch (self) {
            .incr_n => |x| {
                switch (other) {
                    .incr_n => |y| {
                        const bx: u128 = @intCast(x);
                        const by: u128 = @intCast(y);
                        const rem = @rem(bx * by, @as(u128, @intCast(count)));
                        return .{ .incr_n = @intCast(rem) };
                    },
                    else => {},
                }
            },
            .cut_n => |x| {
                switch (other) {
                    .cut_n => |y| {
                        const sum = x + y;
                        const new_n = @as(usize, @intCast(sum + @as(isize, @intCast(count)))) % count;
                        return .{ .cut_n = @intCast(new_n) };
                    },
                    else => {},
                }
            },
            else => {},
        }

        return null;
    }

    fn swap(t1: Technique, t2: Technique, count: usize) struct { Technique, Technique } {
        switch (t1) {
            .cut_n => |x| {
                switch (t2) {
                    .incr_n => |y| {
                        const mul = @as(i128, @intCast(x)) * @as(i128, @intCast(y));
                        const rem = @rem(mul, @as(i128, @intCast(count)));
                        const new_cut = Technique{ .cut_n = @intCast(rem) };
                        return .{ t2, new_cut };
                    },
                    else => {},
                }
            },
            else => {},
        }

        unreachable;
    }
};

const Techniques = std.ArrayList(Technique);

fn parseTechniques(allocator: Allocator, r: anytype) !Techniques {
    var buf: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    const w = fbs.writer();

    var ts = Techniques.init(allocator);
    errdefer ts.deinit();

    while (true) {
        fbs.reset();
        if (r.streamUntilDelimiter(w, '\n', null)) |_| {
            const t = try Technique.parse(fbs.getWritten());
            try ts.append(t);
        } else |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        }
    }

    return ts;
}

const Cards = struct {
    deck: []u32,
    buf: []u32,

    const Self = @This();

    fn init(allocator: Allocator, size: usize) !Self {
        const deck = try allocator.alloc(u32, size);
        const buf = try allocator.alloc(u32, size);

        for (0..size) |i| {
            deck[i] = @intCast(i);
        }

        return .{ .deck = deck, .buf = buf };
    }

    fn deinit(self: Self, allocator: Allocator) void {
        allocator.free(self.deck);
        allocator.free(self.buf);
    }

    fn shuffle(self: *Self, ts: Techniques) void {
        for (ts.items) |t| {
            self.shuffleBy(t);
        }
    }

    fn shuffleBy(self: *Self, technique: Technique) void {
        switch (technique) {
            .new_stack => self.shuffleByNewStack(),
            .cut_n => |n| self.shuffleByCutN(n),
            .incr_n => |n| self.shuffleByIncrN(n),
        }
    }

    fn shuffleByNewStack(self: *Self) void {
        var i: usize = 0;
        var j: usize = self.deck.len - 1;

        while (i < j) {
            std.mem.swap(u32, &self.deck[i], &self.deck[j]);
            i += 1;
            j -= 1;
        }
    }

    fn shuffleByCutN(self: *Self, n: isize) void {
        if (n == 0) return;

        if (n > 0) {
            const v: usize = @intCast(n);
            std.debug.assert(v < self.deck.len);
            for (v..self.deck.len) |i| {
                self.buf[i - v] = self.deck[i];
            }
            for (0..v) |i| {
                self.buf[self.deck.len - v + i] = self.deck[i];
            }
            std.mem.swap([]u32, &self.deck, &self.buf);
        }

        if (n < 0) {
            const v: usize = @intCast(@abs(n));
            std.debug.assert(v < self.deck.len);
            for (0..self.deck.len - v) |i| {
                self.buf[i + v] = self.deck[i];
            }
            for (self.deck.len - v..self.deck.len) |i| {
                self.buf[i - (self.deck.len - v)] = self.deck[i];
            }
            std.mem.swap([]u32, &self.deck, &self.buf);
        }
    }

    fn shuffleByIncrN(self: *Self, n: usize) void {
        var i: usize = 0;
        var j: usize = 0;

        while (i < self.deck.len) {
            self.buf[j] = self.deck[i];
            i += 1;
            j = (j + n) % self.deck.len;
        }

        std.mem.swap([]u32, &self.deck, &self.buf);
    }
};

fn prepareTechniques(allocator: Allocator, input_file: []const u8) !Techniques {
    var f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();
    const r = f.reader();

    return try parseTechniques(allocator, r);
}

// replacement rules
//
// 1.
// deal into new stack
// ---
// deal with increment (count-1)
// cut 1
//
// 2.
// cut x
// cut y
// ---
// cut (x+y) % count
//
// 3.
// deal with increment x
// deal with increment y
// ---
// deal with increment (x*y) % count
//
// 4.
// cut x
// deal with increment y
// ---
// deal with increment y
// cut (x*y) % count
fn compactTechniques(ts: *Techniques, count: usize) !void {
    // 1. apply rule 1 to replace all .new_stack
    var idx: usize = 0;
    while (idx < ts.items.len) {
        switch (ts.items[idx]) {
            .new_stack => {
                ts.items[idx] = Technique{ .incr_n = count - 1 };
                try ts.insert(idx + 1, Technique{ .cut_n = 1 });
                idx += 2;
            },
            else => {
                idx += 1;
            },
        }
    }

    // 2. apply rule 2/3 to merge adj techs.
    idx = 0;
    while (idx < ts.items.len - 1) : (idx += 1) {
        const t1 = ts.items[idx];
        const t2 = ts.items[idx + 1];

        if (t1.merge(t2, count)) |new_t| {
            ts.replaceRangeAssumeCapacity(idx, 2, &.{new_t});
        }
    }

    // 3. apply rule 4 to swap cut/incr
    //    then apply rule 2/3 to do merge
    idx = 0;
    while (ts.items.len > 2) {
        const t1 = ts.items[1];
        const t2 = ts.items[2];

        const new_t1, const new_t2 = Technique.swap(t1, t2, count);

        const new_t0 = ts.items[0].merge(new_t1, count).?;
        if (ts.items.len > 3) {
            ts.replaceRangeAssumeCapacity(0, 4, &.{
                new_t0,
                new_t2.merge(ts.items[3], count).?,
            });
        } else {
            ts.replaceRangeAssumeCapacity(0, 3, &.{
                new_t0,
                new_t2,
            });
        }
    }
}

const State = struct {
    t0: Technique,
    t1: Technique,

    const Self = @This();

    fn init(ts: Techniques) Self {
        std.debug.assert(ts.items.len == 2);
        return .{
            .t0 = ts.items[0],
            .t1 = ts.items[1],
        };
    }
};

fn compactLoops(allocator: Allocator, ts: *Techniques, loop: usize, count: usize) !void {
    const exp: usize = std.math.log2(loop);

    var states = std.ArrayList(State).init(allocator);
    defer states.deinit();
    try states.append(State.init(ts.*));

    for (0..exp) |_| {
        const last: State = states.items[states.items.len - 1];
        try ts.append(last.t0);
        try ts.append(last.t1);
        try compactTechniques(ts, count);
        std.debug.assert(ts.items.len == 2);

        try states.append(State.init(ts.*));
    }

    ts.clearRetainingCapacity();
    var remain = loop;
    while (remain > 0) {
        const e: usize = std.math.log2(remain);
        try ts.append(states.items[e].t0);
        try ts.append(states.items[e].t1);
        remain -= std.math.pow(usize, 2, e);
    }
    try compactTechniques(ts, count);
}

// given a and m, how to find x,
// where: a * x === 1 mod m
fn inv(a: i128, m: i128) i128 {
    if (a <= 1) {
        return a;
    }
    return m - @divFloor(m, a) * @rem(inv(@rem(m, a), m), m);
}

fn doShuffle(input_file: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const ts = try prepareTechniques(allocator, input_file);
    defer ts.deinit();

    var c = try Cards.init(allocator, 10007);
    defer c.deinit(allocator);

    c.shuffle(ts);

    for (0..c.deck.len) |i| {
        if (c.deck[i] == 2019) {
            return i;
        }
    }

    unreachable;
}

fn doLargeShuffle(input_file: []const u8) !isize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var ts = try prepareTechniques(allocator, input_file);
    defer ts.deinit();

    const count: usize = 119315717514047;
    const loop: usize = 101741582076661;

    try compactTechniques(&ts, count);
    try compactLoops(allocator, &ts, loop, count);

    std.debug.assert(ts.items.len == 2);
    const x = inv(ts.items[0].incr_n, count);
    const cut_n = @rem(x * ts.items[1].cut_n, count);

    const iters = @rem(x * 2020, count);
    return @intCast(@rem(cut_n + iters, count));
}

pub fn shuffle(input_file: []const u8) usize {
    return doShuffle(input_file) catch unreachable;
}

pub fn largeShuffle(input_file: []const u8) isize {
    return doLargeShuffle(input_file) catch unreachable;
}

const testing = std.testing;

fn techniquesFromBytes(input: []const u8) !Techniques {
    var fbs = std.io.fixedBufferStream(input);
    const r = fbs.reader();
    return try parseTechniques(testing.allocator, r);
}

test "Technique.parse" {
    const t1 = try Technique.parse("deal with increment 7");
    try testing.expectEqual(7, t1.incr_n);

    const t2 = try Technique.parse("deal into new stack");
    try testing.expectEqual({}, t2.new_stack);

    const t3 = try Technique.parse("cut -4");
    try testing.expectEqual(-4, t3.cut_n);
}

test "parseTechniques" {
    const input =
        \\cut 6
        \\deal with increment 7
        \\deal into new stack
        \\
    ;
    var fbs = std.io.fixedBufferStream(input[0..input.len]);
    const r = fbs.reader();
    const ts = try parseTechniques(testing.allocator, r);
    defer ts.deinit();

    try testing.expectEqual(3, ts.items.len);
    try testing.expectEqual(6, ts.items[0].cut_n);
    try testing.expectEqual(7, ts.items[1].incr_n);
    try testing.expectEqual({}, ts.items[2].new_stack);
}

test "Cards.shuffle" {
    const allocator = testing.allocator;
    const TestCase = struct {
        input: []const u8,
        expect: []const u32,
    };

    const test_cases = [_]TestCase{
        .{
            .input =
            \\deal with increment 7
            \\deal into new stack
            \\deal into new stack
            \\
            ,
            .expect = &.{ 0, 3, 6, 9, 2, 5, 8, 1, 4, 7 },
        },
        .{
            .input =
            \\cut 6
            \\deal with increment 7
            \\deal into new stack
            \\
            ,
            .expect = &.{ 3, 0, 7, 4, 1, 8, 5, 2, 9, 6 },
        },
        .{
            .input =
            \\deal with increment 7
            \\deal with increment 9
            \\cut -2
            \\
            ,
            .expect = &.{ 6, 3, 0, 7, 4, 1, 8, 5, 2, 9 },
        },
        .{
            .input =
            \\deal into new stack
            \\cut -2
            \\deal with increment 7
            \\cut 8
            \\cut -4
            \\deal with increment 7
            \\cut 3
            \\deal with increment 9
            \\deal with increment 3
            \\cut -1
            \\
            ,
            .expect = &.{ 9, 2, 5, 8, 1, 4, 7, 0, 3, 6 },
        },
    };

    for (test_cases) |tt| {
        var fbs = std.io.fixedBufferStream(tt.input);
        const r = fbs.reader();
        const ts = try parseTechniques(testing.allocator, r);
        defer ts.deinit();

        var c = try Cards.init(allocator, 10);
        defer c.deinit(allocator);

        c.shuffle(ts);

        try testing.expectEqualSlices(u32, tt.expect, c.deck);
    }
}
