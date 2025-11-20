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

    try ppmshader.shuffleBoardAnimation(60, 16, 9, allocator);
}
