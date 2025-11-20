//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.io.Writer;

pub const PPMImage = struct {
    width: u32,
    height: u32,
    maxval: u32,
    data: []u8,
    allocator: Allocator,

    pub fn initMaxval(width: u32, height: u32, maxval: u32, allocator: Allocator) !PPMImage {
        const size = width * height * 3;
        const data = try allocator.alloc(u8, size);
        return PPMImage{ .width = width, .height = height, .maxval = maxval, .data = data, .allocator = allocator };
    }

    pub fn init(width: u32, height: u32, allocator: Allocator) !PPMImage {
        return try initMaxval(width, height, 255, allocator);
    }

    pub fn write(self: PPMImage, writer: *Writer) !void {
        try writer.print("P6\n{d}\n{d}\n{d}\n", .{ self.width, self.height, self.maxval });
        try writer.writeAll(self.data);
        try writer.flush();
    }

    pub fn deinit(self: PPMImage) void {
        self.allocator.free(self.data);
    }
};
