const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(i32, "Part One", solution.diagnosticCode);
    try helper.solve(i32, "Part Two", solution.diagnosticCode2);
}
