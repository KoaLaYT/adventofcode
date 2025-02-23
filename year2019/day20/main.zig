const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(u32, "Part One", solution.fewestSteps);
    try helper.solve(u32, "Part Two", solution.recursionFewestSteps);
}
