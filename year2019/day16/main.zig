const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solveS("Part One", solution.firstEightOfFFT);
    try helper.solveS("Part Two", solution.realSignal);
}
