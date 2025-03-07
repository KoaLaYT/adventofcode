const std = @import("std");

const width = 25;
const height = 6;
const layer_size = width * height;

const ImageData = struct {
    data: []u8,
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, input_file: []const u8) !Self {
        var f = try std.fs.cwd().openFile(input_file, .{});
        defer f.close();

        const size = try f.getEndPos();
        const data = try allocator.alloc(u8, size - 1);

        const read = try f.readAll(data);
        std.debug.assert(read == data.len);
        std.debug.assert(data.len % (width * height) == 0);

        return .{
            .data = data,
            .allocator = allocator,
        };
    }

    fn deinit(self: *Self) void {
        self.allocator.free(self.data);
    }

    fn checksum(self: Self) u32 {
        var min_count_0: u32 = std.math.maxInt(u32);
        var result: u32 = 0;

        const layers = self.data.len / layer_size;

        for (0..layers) |layer| {
            var count_0: u32 = 0;
            var count_1: u32 = 0;
            var count_2: u32 = 0;

            for (0..layer_size) |j| {
                const i = layer_size * layer + j;
                const digits = self.data[i];
                switch (digits) {
                    '0' => count_0 += 1,
                    '1' => count_1 += 1,
                    '2' => count_2 += 1,
                    else => unreachable,
                }
            }

            if (count_0 < min_count_0) {
                min_count_0 = count_0;
                result = count_1 * count_2;
            }
        }

        return result;
    }

    fn decode(self: Self, ouput: []u8) void {
        var buf: [layer_size]u8 = undefined;
        @memset(buf[0..], '2');

        const layers = self.data.len / layer_size;
        for (0..layers) |layer| {
            for (0..layer_size) |j| {
                const i = layer_size * layer + j;
                if (buf[j] == '2') {
                    buf[j] = self.data[i];
                }
            }
        }

        var fbs = std.io.fixedBufferStream(ouput);
        const w = fbs.writer();
        w.writeByte('\n') catch unreachable;
        for (0..height) |j| {
            for (0..width) |i| {
                const idx = j * width + i;
                w.writeByte(if (buf[idx] == '0') ' ' else '*') catch unreachable;
            }
            w.writeByte('\n') catch unreachable;
        }
    }
};

pub fn countFewestLayer(input_file: []const u8) u32 {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const allocator = gpa.allocator();

    var d = ImageData.init(allocator, input_file) catch unreachable;
    defer d.deinit();

    return d.checksum();
}

pub fn decode(input_file: []const u8, ouput: []u8) void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const allocator = gpa.allocator();

    var d = ImageData.init(allocator, input_file) catch unreachable;
    defer d.deinit();

    d.decode(ouput);
}

test "ImageData" {
    var d = try ImageData.init(std.testing.allocator, "day08/input.txt");
    defer d.deinit();
    _ = d.checksum();
}
