const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(u64, "Part One", solution.findMinORE);
    try helper.solve(u64, "Part Two", solution.produceFuel);
}
