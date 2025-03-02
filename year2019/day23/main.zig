const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(i64, "Part One", solution.simulateNetworks);
    try helper.solve(i64, "Part Two", solution.simulateNetworksWithNAT);
}
