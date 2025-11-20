//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.io.Writer;

const BLOCK_SIZE = 60;

fn progressBar(current: usize, total: usize) void {
    const width = 40;
    const filled = (current * width) / total;
    std.debug.print("\r[", .{});
    for (0..width) |i| {
        std.debug.print("{c}", .{if (i < filled) '=' else ' '});
    }
    std.debug.print("] {d}/{d}", .{ current, total });
    std.debug.print(" ({d}%)", .{(current * 100) / total});
}

// --gpt glsl translation
pub const Vec2 = struct {
    x: f32,
    y: f32,
};

pub const Vec4 = struct {
    x: f32,
    y: f32,
    z: f32,
    q: f32,

    pub fn add(a: Vec4, b: Vec4) Vec4 {
        return Vec4{ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z, .q = a.q + b.q };
    }
    pub fn sub(a: Vec4, b: Vec4) Vec4 {
        return Vec4{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z, .q = a.q - b.q };
    }
    pub fn mul_scalar(a: Vec4, s: f32) Vec4 {
        return Vec4{ .x = a.x * s, .y = a.y * s, .z = a.z * s, .q = a.q * s };
    }
};

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return Vec3{ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
    }
    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        return Vec3{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
    }
    pub fn mul_scalar(a: Vec3, s: f32) Vec3 {
        return Vec3{ .x = a.x * s, .y = a.y * s, .z = a.z * s };
    }
};

fn mat2_mul_vec(m: [2][2]f32, v: Vec2) Vec2 {
    return Vec2{
        .x = m[0][0] * v.x + m[0][1] * v.y,
        .y = m[1][0] * v.x + m[1][1] * v.y,
    };
}

fn vec2_mul_mat(v: Vec2, m: [2][2]f32) Vec2 {
    // same as mat * vec; kept for clarity
    return mat2_mul_vec(m, v);
}

fn vec3_length(a: Vec3) f32 {
    return std.math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
}

fn vec2_length(a: Vec2) f32 {
    return std.math.sqrt(a.x * a.x + a.y * a.y);
}

fn vec3_abs(a: Vec3) Vec3 {
    return Vec3{ .x = @abs(a.x), .y = @abs(a.y), .z = @abs(a.z) };
}

fn vec3_max(a: Vec3, b: Vec3) Vec3 {
    return Vec3{ .x = if (a.x > b.x) a.x else b.x, .y = if (a.y > b.y) a.y else b.y, .z = if (a.z > b.z) a.z else b.z };
}

fn vec3_min(a: Vec3, b: Vec3) Vec3 {
    return Vec3{ .x = if (a.x < b.x) a.x else b.x, .y = if (a.y < b.y) a.y else b.y, .z = if (a.z < b.z) a.z else b.z };
}

fn floor_f32(x: f32) f32 {
    return std.math.floor(x);
}

fn modf(x: f32, y: f32) f32 {
    // GLSL's mod: x - y * floor(x / y)
    return x - y * floor_f32(x / y);
}

fn vec3_mod(a: Vec3, m: f32) Vec3 {
    return Vec3{ .x = modf(a.x, m), .y = modf(a.y, m), .z = modf(a.z, m) };
}

fn clamp01(x: f32) f32 {
    if (x < 0.0) return 0.0;
    if (x > 1.0) return 1.0;
    return x;
}

// --- shader conversions ---

fn rot(a: f32) [2][2]f32 {
    const c = std.math.cos(a);
    const s = std.math.sin(a);
    // GLSL mat2(c, s, -s, c) is column-major in GLSL; here we store row-major [ [c, s], [-s, c] ]
    // but we use it consistently with mat2_mul_vec above.
    return [2][2]f32{
        [2]f32{ c, s },
        [2]f32{ -s, c },
    };
}

fn sdBox(p: Vec3, b: Vec3) f32 {
    const q = Vec3{
        .x = @abs(p.x) - b.x,
        .y = @abs(p.y) - b.y,
        .z = @abs(p.z) - b.z,
    };
    const m = Vec3{
        .x = if (q.x > 0.0) q.x else 0.0,
        .y = if (q.y > 0.0) q.y else 0.0,
        .z = if (q.z > 0.0) q.z else 0.0,
    };
    const len = vec3_length(m);
    const inside = if (q.x > q.y) (if (q.x > q.z) q.x else q.z) else (if (q.y > q.z) q.y else q.z);
    return len + @min(inside, 0.0);
}

fn box_fn(pos_in: Vec3, scale: f32) f32 {
    var pos = Vec3{ .x = pos_in.x * scale, .y = pos_in.y * scale, .z = pos_in.z * scale };
    const base = sdBox(pos, Vec3{ .x = 0.4, .y = 0.4, .z = 0.1 }) / 1.5;
    // pos.xy *= 5.
    pos.x *= 5.0;
    pos.y *= 5.0;
    // pos.y -= 3.5;
    pos.y -= 3.5;
    // pos.xy *= rot(.75);
    const r = rot(0.75);
    const newxy = mat2_mul_vec(r, Vec2{ .x = pos.x, .y = pos.y });
    pos.x = newxy.x;
    pos.y = newxy.y;
    const result = -base;
    return result;
}

fn box_set(pos_in: Vec3, iTime: f32, gTime: f32) f32 {
    _ = iTime;
    const pos_origin = pos_in;
    var pos = pos_origin;

    // pos .y += sin(gTime * 0.4) * 2.5;
    pos.y += std.math.sin(gTime * 0.4) * 2.5;
    var xy = mat2_mul_vec(rot(0.8), Vec2{ .x = pos.x, .y = pos.y });
    pos.x = xy.x;
    pos.y = xy.y;
    const box1 = box_fn(pos, 2.0 - @abs(std.math.sin(gTime * 0.4)) * 1.5);

    pos = pos_origin;
    pos.y -= std.math.sin(gTime * 0.4) * 2.5;
    xy = mat2_mul_vec(rot(0.8), Vec2{ .x = pos.x, .y = pos.y });
    pos.x = xy.x;
    pos.y = xy.y;
    const box2 = box_fn(pos, 2.0 - @abs(std.math.sin(gTime * 0.4)) * 1.5);

    pos = pos_origin;
    pos.x += std.math.sin(gTime * 0.4) * 2.5;
    xy = mat2_mul_vec(rot(0.8), Vec2{ .x = pos.x, .y = pos.y });
    pos.x = xy.x;
    pos.y = xy.y;
    const box3 = box_fn(pos, 2.0 - @abs(std.math.sin(gTime * 0.4)) * 1.5);

    pos = pos_origin;
    pos.x -= std.math.sin(gTime * 0.4) * 2.5;
    xy = mat2_mul_vec(rot(0.8), Vec2{ .x = pos.x, .y = pos.y });
    pos.x = xy.x;
    pos.y = xy.y;
    const box4 = box_fn(pos, 2.0 - @abs(std.math.sin(gTime * 0.4)) * 1.5);

    pos = pos_origin;
    xy = mat2_mul_vec(rot(0.8), Vec2{ .x = pos.x, .y = pos.y });
    pos.x = xy.x;
    pos.y = xy.y;
    const box5 = box_fn(pos, 0.5) * 6.0;

    pos = pos_origin;
    const box6 = box_fn(pos, 0.5) * 6.0;

    var result = box1;
    if (box2 > result) result = box2;
    if (box3 > result) result = box3;
    if (box4 > result) result = box4;
    if (box5 > result) result = box5;
    if (box6 > result) result = box6;
    return result;
}

fn map_fn(pos: Vec3, iTime: f32, gTime: f32) f32 {
    return box_set(pos, iTime, gTime);
}

fn normalize_vec3(v: Vec3) Vec3 {
    const len = vec3_length(v);
    if (len == 0.0) return v;
    return Vec3{ .x = v.x / len, .y = v.y / len, .z = v.z / len };
}

pub fn mainImage(fragCoordX: f32, fragCoordY: f32, iResolutionX: f32, iResolutionY: f32, iTime: f32) Vec4 {
    // returns (r,g,b,alpha) in 0..1
    const p_x = (fragCoordX * 2.0 - iResolutionX) / @min(iResolutionX, iResolutionY);
    const p_y = (fragCoordY * 2.0 - iResolutionY) / @min(iResolutionX, iResolutionY);
    const p = Vec2{ .x = p_x, .y = p_y };

    const ro = Vec3{ .x = 0.0, .y = -0.2, .z = iTime * 4.0 };
    var ray = Vec3{ .x = p.x, .y = p.y, .z = 1.5 };
    ray = normalize_vec3(ray);

    // ray.xy = ray.xy * rot(sin(iTime * .03) * 5.);
    const xy = mat2_mul_vec(rot(std.math.sin(iTime * 0.03) * 5.0), Vec2{ .x = ray.x, .y = ray.y });
    ray.x = xy.x;
    ray.y = xy.y;

    // ray.yz = ray.yz * rot(sin(iTime * .05) * .2);
    const yz_rot = rot(std.math.sin(iTime * 0.05) * 0.2);
    const yz = mat2_mul_vec(yz_rot, Vec2{ .x = ray.y, .y = ray.z });
    ray.y = yz.x;
    ray.z = yz.y;

    var t: f32 = 0.1;
    var ac: f32 = 0.0;

    // raymarch loop
    for (0..99) |i| {
        const pos = Vec3{ .x = ro.x + ray.x * t, .y = ro.y + ray.y * t, .z = ro.z + ray.z * t };
        // pos = mod(pos-2., 4.) -2.;
        var pos2 = Vec3{ .x = pos.x - 2.0, .y = pos.y - 2.0, .z = pos.z - 2.0 };
        pos2 = vec3_mod(pos2, 4.0);
        pos2.x -= 2.0;
        pos2.y -= 2.0;
        pos2.z -= 2.0;

        const gTime = iTime - (@as(f32, @floatFromInt(i)) * 0.01);
        var d = map_fn(pos2, iTime, gTime);
        d = @max(@abs(d), 0.01);
        const exp_val = std.math.exp(-d * 23.0);
        if (!std.math.isFinite(exp_val)) {
            ac += 0.0;
        } else {
            ac += exp_val;
        }
        t += d * 0.55;
    }

    var col_r = ac * 0.02;
    var col_g = 0.0 + 0.2 * @abs(std.math.sin(iTime));
    var col_b = 0.5 + std.math.sin(iTime) * 0.2;
    col_r += 0.0; // originally vec3(0.,0.2*abs(sin(iTime)),0.5+...)
    col_g += ac * 0.0; // keep consistent
    col_b += 0.0;

    // final alpha as in shader:
    var alpha = 1.0 - t * (0.02 + 0.02 * std.math.sin(iTime));

    // clamp
    col_r = clamp01(col_r);
    col_g = clamp01(col_g);
    col_b = clamp01(col_b);
    alpha = clamp01(alpha);

    return Vec4{ .x = col_r, .y = col_g, .z = col_b, .q = alpha };
}

// --- Example: how to plug this into your PPM filling loop ---
//
// Replace the block that writes solid-color blocks with this code. It assumes:
// - ppm.width and ppm.height exist (pixel dimensions)
// - BLOCK_SIZE is your block pixel size (you were using that in your example)
// - frames loop is indexed by `f` and time_per_frame controls frame-to-frame time
//
// I produce fragCoord at pixel centers (x + 0.5, y + 0.5).
//

pub fn fill_ppm_with_shader(ppm_width: usize, ppm_height: usize, ppm_data: []u8, f: usize) void {
    const time_per_frame = 1.0 / 30.0; // seconds per frame (adjust as needed)
    const iTime = @as(f32, @floatFromInt(f)) * time_per_frame;

    for (0..ppm_height) |y| {
        for (0..ppm_width) |x| {
            const start = (y * ppm_width + x) * 3;

            // fragCoord in shader coordinates: use pixel center
            const frag_x = @as(f32, @floatFromInt(x)) + 0.5;
            const frag_y = @as(f32, @floatFromInt(y)) + 0.5;

            const vec = mainImage(frag_x, frag_y, @as(f32, @floatFromInt(ppm_width)), @as(f32, @floatFromInt(ppm_height)), iTime);
            const r_f = clamp01(vec.x);
            const g_f = clamp01(vec.y);
            const b_f = clamp01(vec.z);

            // convert to u8
            const r_u: u8 = @intFromFloat(r_f * 255.0);
            const g_u: u8 = @intFromFloat(g_f * 255.0);
            const b_u: u8 = @intFromFloat(b_f * 255.0);

            ppm_data[start] = r_u;
            ppm_data[start + 1] = g_u;
            ppm_data[start + 2] = b_u;
        }
    }
}
// --gpt glsl translation end

pub fn coolShader(comptime frames: usize, width: u32, height: u32, allocator: Allocator) !void {
    for (0..frames) |f| {
        progressBar(f + 1, frames);
        const ppm = try PPMImage.init(width, height, allocator);
        var buf: [12]u8 = undefined;
        const filename = try std.fmt.bufPrint(&buf, "test-{d:0>2.0}.ppm", .{f});
        defer ppm.deinit();
        const file = try std.fs.cwd().createFile(filename, .{});
        var write_buffer: [1024]u8 = undefined;
        var file_writer = file.writer(&write_buffer);
        const writer = &file_writer.interface;

        fill_ppm_with_shader(ppm.width, ppm.height, ppm.data, f);

        try ppm.write(writer);
    }
    std.debug.print("\n", .{});
}

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
                const is_frame = (y_block + x_block) == f % (y_block + x_block + 1);
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
        const size = @as(usize, width) * height * 3;
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
