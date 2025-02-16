const std = @import("std");
const Allocator = std.mem.Allocator;

const Material = struct {
    amount: u32,
    chemical_id: u64,

    const Self = @This();

    fn init(str: []const u8) !Self {
        const trimmed = std.mem.trim(u8, str, " ");
        var it = std.mem.splitScalar(u8, trimmed, ' ');
        const amount = it.next().?;
        const chemical = it.next().?;
        return .{
            .amount = try std.fmt.parseInt(u32, amount, 10),
            .chemical_id = chemicalID(chemical),
        };
    }
};

const Reaction = struct {
    inputs: []Material,
    output: Material,
    depth: u32,

    const Self = @This();

    // Parse receipt:
    // 7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
    fn init(allocator: Allocator, receipt: []const u8) !Self {
        var parts = std.mem.splitSequence(u8, receipt, " => ");
        const input_materials = parts.next().?;
        const output_material = parts.next().?;

        var it = std.mem.splitSequence(u8, input_materials, ", ");
        var inputs_size: usize = 0;
        while (it.next()) |_| {
            inputs_size += 1;
        }
        it.reset();

        var inputs = try allocator.alloc(Material, inputs_size);
        var i: usize = 0;
        while (it.next()) |material| {
            inputs[i] = try Material.init(material);
            i += 1;
        }

        return .{
            .inputs = inputs,
            .output = try Material.init(output_material),
            .depth = 0,
        };
    }
};

// chemicalID -> Reaction
const Reactions = std.AutoHashMap(u64, Reaction);
// chemicalID -> amount
const TodoChemicals = std.AutoHashMap(u64, u64);

fn chemicalID(str: []const u8) u64 {
    var id: u64 = 0;
    for (str) |c| {
        std.debug.assert(c >= 'A' and c <= 'Z');
        id = id * 27 + (c - 'A' + 1);
    }
    return id;
}

fn parseReactions(allocator: Allocator, input_file: []const u8) !Reactions {
    var reactions = Reactions.init(allocator);

    const f = try std.fs.cwd().openFile(input_file, .{});
    defer f.close();
    const r = f.reader();

    var buf: [256]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buf);
    const w = fbs.writer();

    while (true) {
        fbs.reset();
        r.streamUntilDelimiter(w, '\n', null) catch |err| switch (err) {
            error.EndOfStream => {
                std.debug.assert(try fbs.getPos() == 0);
                break;
            },
            else => return err,
        };
        const reaction = try Reaction.init(allocator, fbs.getWritten());
        try reactions.put(reaction.output.chemical_id, reaction);
    }

    return reactions;
}

fn determineReactionDepth(reactions: Reactions, id: u64) u32 {
    if (id == chemicalID("ORE")) return 0;

    const reaction = reactions.get(id).?;
    var max_depth: u32 = 0;
    for (reaction.inputs) |m| {
        max_depth = @max(max_depth, determineReactionDepth(reactions, m.chemical_id));
    }
    return max_depth + 1;
}

fn determineReactionsDepth(reactions: *Reactions) void {
    var it = reactions.iterator();
    while (it.next()) |e| {
        const vp = e.value_ptr;
        vp.depth = determineReactionDepth(reactions.*, e.key_ptr.*);
    }
}

fn buildReactions(allocator: Allocator, input_file: []const u8) !Reactions {
    var reactions = try parseReactions(allocator, input_file);
    determineReactionsDepth(&reactions);
    return reactions;
}

fn doFindMinORE(reactions: Reactions, amount: u64, todo: *TodoChemicals) u64 {
    const fuel_id = chemicalID("FUEL");
    const ore_id = chemicalID("ORE");
    todo.clearRetainingCapacity();
    todo.putAssumeCapacity(fuel_id, amount);

    while (true) {
        std.debug.assert(todo.count() <= todo.capacity());

        var it = todo.iterator();
        var max_depth: u32 = 0;
        var next_id: u64 = 0;
        while (it.next()) |e| {
            if (e.key_ptr.* == ore_id) continue;
            if (e.value_ptr.* == 0) continue;

            const reaction = reactions.get(e.key_ptr.*).?;
            if (reaction.depth > max_depth) {
                max_depth = reaction.depth;
                next_id = e.key_ptr.*;
            }
        }

        if (max_depth == 0) break;

        const reaction = reactions.get(next_id).?;
        const required_amount_ptr = todo.getPtr(next_id).?;
        var units = @divFloor(required_amount_ptr.*, reaction.output.amount);
        if (@rem(required_amount_ptr.*, reaction.output.amount) != 0) {
            units += 1;
        }
        required_amount_ptr.* = 0;

        for (reaction.inputs) |m| {
            const ptr = todo.getOrPutAssumeCapacity(m.chemical_id);
            if (!ptr.found_existing) {
                ptr.value_ptr.* = 0;
            }
            ptr.value_ptr.* += units * m.amount;
        }
    }

    return todo.getPtr(ore_id).?.*;
}

pub fn produceFuel(input_file: []const u8) u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const reactions = buildReactions(allocator, input_file) catch unreachable;
    var todo = TodoChemicals.init(allocator);
    todo.ensureTotalCapacity(1024) catch unreachable;

    const ore = doFindMinORE(reactions, 1, &todo);
    const ore_amount: u64 = 1000000000000;

    var min_fuel = @divFloor(ore_amount, ore);
    var max_fuel: u64 = @intFromFloat(@as(f64, @floatFromInt(min_fuel)) * 1.1);
    while (true) {
        const amount = doFindMinORE(reactions, max_fuel, &todo);
        if (amount > ore_amount) {
            break;
        }
        max_fuel = @intFromFloat(@as(f64, @floatFromInt(max_fuel)) * 1.1);
    }

    while (min_fuel < max_fuel) {
        const mid = min_fuel + (max_fuel - min_fuel) / 2;
        const amount = doFindMinORE(reactions, mid, &todo);
        if (amount == ore_amount) {
            return mid;
        } else if (amount > ore_amount) {
            max_fuel = mid - 1;
        } else {
            min_fuel = mid + 1;
        }
    }

    std.debug.assert(min_fuel >= max_fuel);

    for (max_fuel - 5..max_fuel + 5) |fuel| {
        const amount = doFindMinORE(reactions, fuel, &todo);
        if (amount == ore_amount) {
            return fuel;
        }
        if (amount > ore_amount) {
            return fuel - 1;
        }
    }

    unreachable();
}

pub fn findMinORE(input_file: []const u8) u64 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var todo = TodoChemicals.init(allocator);
    todo.ensureTotalCapacity(1024) catch unreachable;
    const reactions = buildReactions(allocator, input_file) catch unreachable;

    return doFindMinORE(reactions, 1, &todo);
}

const testing = std.testing;

test "Reaction init" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const receipt = "7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL";
    const got = try Reaction.init(allocator, receipt);
    try testing.expectEqual(7, got.inputs.len);
}

test "doFindMinORE" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const TestCase = struct {
        input_file: []const u8,
        expect: u32,
    };

    const test_cases = [_]TestCase{
        .{ .input_file = "day14/example.txt", .expect = 31 },
        .{ .input_file = "day14/example1.txt", .expect = 165 },
        .{ .input_file = "day14/example2.txt", .expect = 13312 },
        .{ .input_file = "day14/example3.txt", .expect = 180697 },
        .{ .input_file = "day14/example4.txt", .expect = 2210736 },
    };

    for (test_cases) |tt| {
        _ = arena.reset(.free_all);
        const reactions = try buildReactions(allocator, tt.input_file);
        var todo = TodoChemicals.init(allocator);
        todo.ensureTotalCapacity(1024) catch unreachable;
        const got = doFindMinORE(reactions, 1, &todo);
        try testing.expectEqual(tt.expect, got);
    }
}

test "produceFuel" {
    const TestCase = struct {
        input_file: []const u8,
        expect: u32,
    };

    const test_cases = [_]TestCase{
        .{ .input_file = "day14/example2.txt", .expect = 82892753 },
        .{ .input_file = "day14/example3.txt", .expect = 5586022 },
        .{ .input_file = "day14/example4.txt", .expect = 460664 },
    };

    for (test_cases) |tt| {
        const got = produceFuel(tt.input_file);
        try testing.expectEqual(tt.expect, got);
    }
}
