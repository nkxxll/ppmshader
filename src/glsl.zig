const std = @import("std");

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Loc = struct {
        start: usize,
        end: usize,
    };

    pub const keywords = std.StaticStringMap(Tag).initComptime(.{
        .{ "const", .keyword_const },
        .{ "bool", .keyword_bool },
        .{ "float", .keyword_float },
        .{ "int", .keyword_int },
        .{ "uint", .keyword_uint },
        .{ "double", .keyword_double },
    });

    pub fn getKeyword(bytes: []const u8) ?Tag {
        return keywords.get(bytes);
    }

    pub const Tag = enum {
        invalid,
        keyword_const,
        keyword_bool,
        keyword_float,
        keyword_int,
        keyword_uint,
        keyword_double,
        eof,
        identifier,
    };

    pub fn lexeme(tag: Tag) ?[]const u8 {
        return switch (tag) {
            .identifier, .invalid => null,
            .keyword_const => "const",
            .keyword_bool => "bool",
            .keyword_float => "float",
            .keyword_int => "int",
            .keyword_uint => "uint",
            .keyword_double => "double",
            .eof => "eof",
        };
    }

    pub fn symbol(tag: Tag) []const u8 {
        return tag.lexeme() orelse switch (tag) {
            .identifier => "an identifier",
            .invalid => "invalid token",
        };
    }
};

pub const Tokenizer = struct {
    buffer: [:0]const u8,
    index: usize,

    /// For debugging purposes.
    pub fn dump(self: *Tokenizer, token: *const Token) void {
        std.debug.print("{s} \"{s}\"\n", .{ @tagName(token.tag), self.buffer[token.loc.start..token.loc.end] });
    }

    pub fn init(buffer: [:0]const u8) Tokenizer {
        // Skip the UTF-8 BOM if present.
        return .{
            .buffer = buffer,
            .index = if (std.mem.startsWith(u8, buffer, "\xEF\xBB\xBF")) 3 else 0,
        };
    }

    const State = enum {
        start,
        identifier,
        invalid,
    };
    /// An eof token will always be returned at the end.
    pub fn next(self: *Tokenizer) Token {
        var result: Token = .{
            .tag = undefined,
            .loc = .{
                .start = self.index,
                .end = undefined,
            },
        };
        state: switch (State.start) {
            .start => switch (self.buffer[self.index]) {
                0 => {
                    if (self.index == self.buffer.len) {
                        return .{
                            .tag = .eof,
                            .loc = .{
                                .start = self.index,
                                .end = self.index,
                            },
                        };
                    } else {
                        continue :state .invalid;
                    }
                },
                ' ', '\n', '\t', '\r' => {
                    self.index += 1;
                    result.loc.start = self.index;
                    continue :state .start;
                },
                'a'...'z', 'A'...'Z', '_' => {
                    result.tag = .identifier;
                    continue :state .identifier;
                },
                else => {
                    continue :state .invalid;
                },
            },
            .identifier => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => continue :state .identifier,
                    else => {
                        const ident = self.buffer[result.loc.start..self.index];
                        if (Token.getKeyword(ident)) |tag| {
                            result.tag = tag;
                        }
                    },
                }
            },
            .invalid => {
                self.index += 1;
                switch (self.buffer[self.index]) {
                    0 => if (self.index == self.buffer.len) {
                        result.tag = .invalid;
                    } else {
                        continue :state .invalid;
                    },
                    '\n' => result.tag = .invalid,
                    else => continue :state .invalid,
                }
            },
        }
        result.loc.end = self.index;
        return result;
    }
};

pub const Parser = struct {};

test "test keywords" {
    try testTokenize("const int double", &.{ .keyword_const, .keyword_int, .keyword_double });
    try testTokenize("const", &.{.keyword_const});
    try testTokenize("bool", &.{.keyword_bool});
    try testTokenize("float", &.{.keyword_float});
    try testTokenize("int", &.{.keyword_int});
    try testTokenize("uint", &.{.keyword_uint});
    try testTokenize("double", &.{.keyword_double});
}

fn testTokenize(source: [:0]const u8, expected_token_tags: []const Token.Tag) !void {
    var tokenizer = Tokenizer.init(source);
    for (expected_token_tags) |expected_token_tag| {
        const token = tokenizer.next();
        try std.testing.expectEqual(expected_token_tag, token.tag);
    }
    // Last token should always be eof, even when the last token was invalid,
    // in which case the tokenizer is in an invalid state, which can only be
    // recovered by opinionated means outside the scope of this implementation.
    const last_token = tokenizer.next();
    try std.testing.expectEqual(Token.Tag.eof, last_token.tag);
    try std.testing.expectEqual(source.len, last_token.loc.start);
    try std.testing.expectEqual(source.len, last_token.loc.end);
}
