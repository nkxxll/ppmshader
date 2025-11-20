//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.io.Writer;

const BLOCK_SIZE = 60;

pub fn shuffleBoardAnimation(comptime frames: usize, width: u32, height: u32, allocator: Allocator) !void {
    for (0..frames) |f| {
        const ppm = try PPMImage.init(width * BLOCK_SIZE, height * BLOCK_SIZE, allocator);
        var buf: [12]u8 = undefined;
        const filename = try std.fmt.bufPrint(&buf, "test-{d:0>2.0}.ppm", .{f});
        defer ppm.deinit();
        const file = try std.fs.cwd().createFile(filename, .{});
        var write_buffer: [1024]u8 = undefined;
        var file_writer = file.writer(&write_buffer);
        const writer = &file_writer.interface;
        for (0..ppm.height / BLOCK_SIZE) |y_block| {
            for (0..ppm.width / BLOCK_SIZE) |x_block| {
                const is_red_block = (y_block + x_block) % 2 == 0;
                const is_frame = (y_block + x_block) == f;
                const r: u8 = if (is_red_block) 0xff else 0x00;
                const g: u8 = if (is_frame) 0xff else 0x00;
                const b: u8 = if (is_red_block) 0x00 else 0xff;

                for (0..BLOCK_SIZE) |y_pix| {
                    for (0..BLOCK_SIZE) |x_pix| {
                        const y_abs = y_block * BLOCK_SIZE + y_pix;
                        const x_abs = x_block * BLOCK_SIZE + x_pix;

                        const start = (y_abs * ppm.width + x_abs) * 3;

                        ppm.data[start] = r;
                        ppm.data[start + 1] = g;
                        ppm.data[start + 2] = b;
                    }
                }
            }
        }

        try ppm.write(writer);
        std.debug.print("PPM image written to {s}", .{filename});
    }
}

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
