const std = @import("std");
const OrbitsMap = std.AutoHashMap(u32, u32);

fn objectID(name: []const u8) u32 {
    var id: u32 = 0;

    for (name) |char| {
        switch (char) {
            'A'...'Z' => id = id * 36 + (char - 'A') + 10,
            '0'...'9' => id = id * 36 + (char - '0'),
            else => unreachable,
        }
    }

    return id;
}

fn parseRow(row: []const u8) [2]u32 {
    var splits = std.mem.splitScalar(u8, row, ')');
    const o1 = splits.next() orelse unreachable;
    const o2 = splits.next() orelse unreachable;

    return .{ objectID(o1), objectID(o2) };
}

fn parseInput(allocator: std.mem.Allocator, input_file: []const u8) !OrbitsMap {
    var f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();
    const r = f.reader();

    var buf: [64]u8 = undefined;
    var bs = std.io.fixedBufferStream(buf[0..]);
    const w = bs.writer();

    var hm = std.AutoHashMap(u32, u32).init(allocator);
    while (true) {
        bs.reset();
        if (r.streamUntilDelimiter(w, '\n', null)) |_| {
            const ids = parseRow(bs.getWritten());
            try hm.put(ids[1], ids[0]);
        } else |err| switch (err) {
            error.EndOfStream => break,
            else => unreachable,
        }
    }
    return hm;
}

fn doCountOrbits(id: u32, orbits_map: OrbitsMap, cache: *std.AutoHashMap(u32, u32)) u32 {
    const maybe = cache.get(id);
    if (maybe) |v| return v;

    var v: u32 = 0;
    if (orbits_map.get(id)) |orbitsID| {
        v = doCountOrbits(orbitsID, orbits_map, cache) + 1;
    }
    cache.put(id, v) catch unreachable;
    return v;
}

fn doTotalOribits(allocator: std.mem.Allocator, orbits_map: OrbitsMap) u32 {
    var cache = std.AutoHashMap(u32, u32).init(allocator);
    defer cache.deinit();

    var total: u32 = 0;
    var it = orbits_map.iterator();
    while (it.next()) |entry| {
        total += doCountOrbits(entry.key_ptr.*, orbits_map, &cache);
    }
    return total;
}

fn getOribitsOf(allocator: std.mem.Allocator, name: []const u8, orbits_map: OrbitsMap) std.ArrayList(u32) {
    var id = objectID(name);
    var list = std.ArrayList(u32).init(allocator);
    while (orbits_map.get(id)) |orbital| {
        list.append(orbital) catch unreachable;
        id = orbital;
    }
    return list;
}

fn doMinimumOrbitalTransfers(allocator: std.mem.Allocator, orbits_map: OrbitsMap) u32 {
    var you = getOribitsOf(allocator, "YOU", orbits_map);
    defer you.deinit();
    var san = getOribitsOf(allocator, "SAN", orbits_map);
    defer san.deinit();

    var i: usize = you.items.len - 1;
    var j: usize = san.items.len - 1;

    while (you.items[i] == san.items[j]) {
        i -= 1;
        j -= 1;
    }

    return @as(u32, @intCast(i)) + @as(u32, @intCast(j)) + 2;
}

pub fn totalOribits(input_file: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var orbits_map = parseInput(allocator, input_file) catch unreachable;
    defer orbits_map.deinit();

    return doTotalOribits(allocator, orbits_map);
}

pub fn minimumOrbitalTransfers(input_file: []const u8) u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var orbits_map = parseInput(allocator, input_file) catch unreachable;
    defer orbits_map.deinit();

    return doMinimumOrbitalTransfers(allocator, orbits_map);
}

const testing = std.testing;

test "doTotalOribits" {
    var orbits_map = try parseInput(testing.allocator, "./day06/example.txt");
    defer orbits_map.deinit();
    try testing.expectEqual(42, doTotalOribits(testing.allocator, orbits_map));
}

test "getOribitsOf" {
    var orbits_map = try parseInput(testing.allocator, "./day06/example2.txt");
    defer orbits_map.deinit();
    {
        var list = getOribitsOf(testing.allocator, "YOU", orbits_map);
        defer list.deinit();

        const expected: []const u32 = &.{ objectID("K"), objectID("J"), objectID("E"), objectID("D"), objectID("C"), objectID("B"), objectID("COM") };
        try testing.expectEqualSlices(u32, expected, list.items);
    }

    {
        var list = getOribitsOf(testing.allocator, "SAN", orbits_map);
        defer list.deinit();

        const expected: []const u32 = &.{ objectID("I"), objectID("D"), objectID("C"), objectID("B"), objectID("COM") };
        try testing.expectEqualSlices(u32, expected, list.items);
    }
}

test "doMinimumOrbitalTransfers" {
    var orbits_map = try parseInput(testing.allocator, "./day06/example2.txt");
    defer orbits_map.deinit();

    const got = doMinimumOrbitalTransfers(testing.allocator, orbits_map);
    try testing.expectEqual(4, got);
}
