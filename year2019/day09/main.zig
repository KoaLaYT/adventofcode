const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(i64, "Part One", solution.boostKeycode);
    try helper.solve(i64, "Part Two", solution.distressSignal);
}
