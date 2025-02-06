const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(i32, "Part One", solution.largestOutput);
    try helper.solve(i32, "Part Two", solution.feedbackLoop);
}
