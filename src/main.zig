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
    const ppm = try ppmshader.PPMImage.init(16 * 60, 9 * 60, allocator);
    const filename = "test.ppm";
    defer ppm.deinit();
    const file = try std.fs.cwd().createFile(filename, .{});
    var write_buffer: [1024]u8 = undefined;
    var file_writer = file.writer(&write_buffer);
    const writer = &file_writer.interface;
    const block_size = 60;

    for (0..ppm.height / block_size) |y_block| {
        for (0..ppm.width / block_size) |x_block| {
            // --- Determine the color for the entire 60x60 block ---
            const is_red_block = (y_block + x_block) % 2 == 0;

            const r: u8 = if (is_red_block) 0xff else 0x00;
            const g: u8 = 0x00;
            const b: u8 = if (is_red_block) 0x00 else 0xff;

            // --- Loop through every pixel within this block ---
            for (0..block_size) |y_pix| {
                for (0..block_size) |x_pix| {
                    // Calculate the ABSOLUTE pixel coordinates
                    const y_abs = y_block * block_size + y_pix;
                    const x_abs = x_block * block_size + x_pix;

                    // Calculate the start index in the data array
                    // Index = (Absolute Row * Image Width * 3) + (Absolute Column * 3)
                    const start = (y_abs * ppm.width + x_abs) * 3;

                    // Set the color for the pixel
                    ppm.data[start] = r;
                    ppm.data[start + 1] = g;
                    ppm.data[start + 2] = b;
                }
            }
        }
    }
    try ppm.write(writer);
    print("PPM image written to {s}", .{filename});
}
