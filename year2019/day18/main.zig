const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(u32, "Part One", solution.minSteps);
    try helper.solve(u32, "Part Two", solution.minSteps4);
}
