const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(usize, "Part One", solution.shuffle);
    try helper.solve(isize, "Part Two", solution.largeShuffle);
}
