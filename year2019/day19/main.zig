const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(u32, "Part One", solution.countAffected);
    try helper.solve(usize, "Part Two", solution.findShip);
}
