const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(u32, "Part One", solution.countBlockTiles);
    try helper.solve(u32, "Part Two", solution.play);
}
