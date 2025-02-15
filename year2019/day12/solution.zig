const std = @import("std");

const Vec3 = struct {
    x: i32,
    y: i32,
    z: i32,

    const Self = @This();

    fn abs(self: Self) u32 {
        return @abs(self.x) + @abs(self.y) + @abs(self.z);
    }
};

const Moon = struct {
    pos: Vec3,
    vel: Vec3,

    const Self = @This();

    fn init(x: i32, y: i32, z: i32) Self {
        return .{
            .pos = .{ .x = x, .y = y, .z = z },
            .vel = .{ .x = 0, .y = 0, .z = 0 },
        };
    }

    fn applyGravity(self: *Self, other: Self) void {
        if (self.pos.x < other.pos.x) {
            self.vel.x += 1;
        } else if (self.pos.x > other.pos.x) {
            self.vel.x -= 1;
        }

        if (self.pos.y < other.pos.y) {
            self.vel.y += 1;
        } else if (self.pos.y > other.pos.y) {
            self.vel.y -= 1;
        }

        if (self.pos.z < other.pos.z) {
            self.vel.z += 1;
        } else if (self.pos.z > other.pos.z) {
            self.vel.z -= 1;
        }
    }

    fn applyVelocity(self: *Self) void {
        self.pos.x += self.vel.x;
        self.pos.y += self.vel.y;
        self.pos.z += self.vel.z;
    }

    fn totalEnergy(self: Self) u32 {
        const potential_energy = self.pos.abs();
        const kinetic_energy = self.vel.abs();
        return potential_energy * kinetic_energy;
    }
};

const Point = struct {
    p: i32,
    v: i32,

    const Self = @This();

    fn init(p: i32) Self {
        return .{ .p = p, .v = 0 };
    }

    fn applyGravity(self: *Self, other: Self) void {
        if (self.p < other.p) {
            self.v += 1;
        } else if (self.p > other.p) {
            self.v -= 1;
        }
    }

    fn applyVelocity(self: *Self) void {
        self.p += self.v;
    }
};

fn simulating(moons: []Moon, steps: usize) u32 {
    for (0..steps) |_| {
        for (0..moons.len) |i| {
            for (0..moons.len) |j| {
                moons[i].applyGravity(moons[j]);
            }
        }
        for (0..moons.len) |i| {
            moons[i].applyVelocity();
        }
    }

    var total: u32 = 0;
    for (0..moons.len) |i| {
        total += moons[i].totalEnergy();
    }
    return total;
}

pub fn simulatingMoons(input_file: []const u8) u32 {
    _ = input_file;

    var moons = [_]Moon{
        Moon.init(1, -4, 3),
        Moon.init(-14, 9, -4),
        Moon.init(-4, -6, 7),
        Moon.init(6, -9, -11),
    };

    return simulating(&moons, 1000);
}

fn find_cycle(allocator: std.mem.Allocator, points: [4]Point) u64 {
    var ps = points;
    var step: usize = 0;

    var map = std.hash_map.AutoHashMap([4]Point, usize).init(allocator);
    defer map.deinit();
    map.put(ps, 0) catch unreachable;

    while (true) {
        step += 1;
        for (0..ps.len) |i| {
            for (0..ps.len) |j| {
                ps[i].applyGravity(ps[j]);
            }
        }
        for (0..ps.len) |i| {
            ps[i].applyVelocity();
        }
        const r = map.getOrPut(ps) catch unreachable;
        if (r.found_existing) {
            return step - r.value_ptr.*;
        } else {
            r.value_ptr.* = step;
        }
    }
}

fn gcd(a: u64, b: u64) u64 {
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

fn lcm(a: u64, b: u64) u64 {
    return (a * b) / gcd(a, b);
}

fn doFindRepeat(pxs: [4]Point, pys: [4]Point, pzs: [4]Point) u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const x_cycle = find_cycle(allocator, pxs);
    const y_cycle = find_cycle(allocator, pys);
    const z_cycle = find_cycle(allocator, pzs);

    return lcm(x_cycle, lcm(y_cycle, z_cycle));
}

pub fn findRepeat(input_file: []const u8) u64 {
    _ = input_file;

    const pxs = [4]Point{
        Point.init(1),
        Point.init(-14),
        Point.init(-4),
        Point.init(6),
    };
    const pys = [4]Point{
        Point.init(-4),
        Point.init(9),
        Point.init(-6),
        Point.init(-9),
    };
    const pzs = [4]Point{
        Point.init(3),
        Point.init(-4),
        Point.init(7),
        Point.init(-11),
    };

    return doFindRepeat(pxs, pys, pzs);
}

const testing = std.testing;

test "simulating" {
    {
        var ms = [_]Moon{
            Moon.init(-1, 0, 2),
            Moon.init(2, -10, -7),
            Moon.init(4, -8, 8),
            Moon.init(3, 5, -1),
        };

        const got = simulating(&ms, 10);
        try testing.expectEqual(179, got);
    }

    {
        var ms = [_]Moon{
            Moon.init(-8, -10, 0),
            Moon.init(5, 5, 10),
            Moon.init(2, -7, 3),
            Moon.init(9, -8, -3),
        };

        const got = simulating(&ms, 100);
        try testing.expectEqual(1940, got);
    }
}

test "doFindRepeat" {
    {
        const pxs = [4]Point{
            Point.init(-1),
            Point.init(2),
            Point.init(4),
            Point.init(3),
        };

        const pys = [4]Point{
            Point.init(0),
            Point.init(-10),
            Point.init(-8),
            Point.init(5),
        };

        const pzs = [4]Point{
            Point.init(2),
            Point.init(-7),
            Point.init(8),
            Point.init(-1),
        };

        const got = doFindRepeat(pxs, pys, pzs);
        try testing.expectEqual(2772, got);
    }
    {
        const pxs = [4]Point{
            Point.init(-8),
            Point.init(5),
            Point.init(2),
            Point.init(9),
        };

        const pys = [4]Point{
            Point.init(-10),
            Point.init(5),
            Point.init(-7),
            Point.init(-8),
        };

        const pzs = [4]Point{
            Point.init(0),
            Point.init(10),
            Point.init(3),
            Point.init(-3),
        };

        const got = doFindRepeat(pxs, pys, pzs);
        try testing.expectEqual(4686774924, got);
    }
}
