const helper = @import("helper");
const solution = @import("solution.zig");

pub fn main() !void {
    try helper.solve(void, "Part One", solution.findPassword);
}
