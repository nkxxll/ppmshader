const std = @import("std");
const ppmshader = @import("ppmshader");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked != .ok) std.debug.print("GPA detected memory leaks!\n", .{});
    }
    const allocator = gpa.allocator();
    const ppm = try ppmshader.PPMImage.init(16, 16, allocator);
    const filename = "test.ppm";
    defer ppm.deinit();
    const file = try std.fs.cwd().createFile(filename, .{});
    var write_buffer: [1024]u8 = undefined;
    var writer = file.writer(&write_buffer);
    defer writer.flush();
    for (0..ppm.height) |y| {
        for (0..ppm.width) |x| {
            ppm.data[x * y] = 0;
        }
    }
    try ppm.write(&writer);
    try print("PPM image written to {s}", .{filename});
}
