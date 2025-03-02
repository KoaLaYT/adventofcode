const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(u32, "Part One", solution.detechLoop);
    try helper.solve(usize, "Part Two", solution.countBugs);
}
