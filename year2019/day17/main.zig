const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(u32, "Part One", solution.sumOfAlignmentParams);
    try helper.solve(i64, "Part Two", solution.collectedDust);
}
