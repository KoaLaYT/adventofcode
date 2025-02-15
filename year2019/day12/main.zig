const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(u32, "Part One", solution.simulatingMoons);
    try helper.solve(u64, "Part Two", solution.findRepeat);
}
