const std = @import("std");

pub const Token = struct {
    tag: Tag,
    loc: Loc,

    pub const Loc = struct {
        start: usize,
        end: usize,
    };

    pub const keywords = std.StaticStringMap(Tag).initComptime(.{
        // Basic types
        .{ "const", .keyword_const },
        .{ "bool", .keyword_bool },
        .{ "float", .keyword_float },
        .{ "int", .keyword_int },
        .{ "uint", .keyword_uint },
        .{ "double", .keyword_double },

        // Vector types
        .{ "bvec2", .keyword_bvec2 },
        .{ "bvec3", .keyword_bvec3 },
        .{ "bvec4", .keyword_bvec4 },
        .{ "ivec2", .keyword_ivec2 },
        .{ "ivec3", .keyword_ivec3 },
        .{ "ivec4", .keyword_ivec4 },
        .{ "uvec2", .keyword_uvec2 },
        .{ "uvec3", .keyword_uvec3 },
        .{ "uvec4", .keyword_uvec4 },
        .{ "vec2", .keyword_vec2 },
        .{ "vec3", .keyword_vec3 },
        .{ "vec4", .keyword_vec4 },

        // Double vector types
        .{ "dvec2", .keyword_dvec2 },
        .{ "dvec3", .keyword_dvec3 },
        .{ "dvec4", .keyword_dvec4 },

        // Matrix types
        .{ "mat2", .keyword_mat2 },
        .{ "mat3", .keyword_mat3 },
        .{ "mat4", .keyword_mat4 },
        .{ "mat2x2", .keyword_mat2x2 },
        .{ "mat2x3", .keyword_mat2x3 },
        .{ "mat2x4", .keyword_mat2x4 },
        .{ "mat3x2", .keyword_mat3x2 },
        .{ "mat3x3", .keyword_mat3x3 },
        .{ "mat3x4", .keyword_mat3x4 },
        .{ "mat4x2", .keyword_mat4x2 },
        .{ "mat4x3", .keyword_mat4x3 },
        .{ "mat4x4", .keyword_mat4x4 },

        // Double matrix types
        .{ "dmat2", .keyword_dmat2 },
        .{ "dmat3", .keyword_dmat3 },
        .{ "dmat4", .keyword_dmat4 },
        .{ "dmat2x2", .keyword_dmat2x2 },
        .{ "dmat2x3", .keyword_dmat2x3 },
        .{ "dmat2x4", .keyword_dmat2x4 },
        .{ "dmat3x2", .keyword_dmat3x2 },
        .{ "dmat3x3", .keyword_dmat3x3 },
        .{ "dmat3x4", .keyword_dmat3x4 },
        .{ "dmat4x2", .keyword_dmat4x2 },
        .{ "dmat4x3", .keyword_dmat4x3 },
        .{ "dmat4x4", .keyword_dmat4x4 },

        // Sampler types
        .{ "sampler1D", .keyword_sampler1D },
        .{ "sampler2D", .keyword_sampler2D },
        .{ "sampler3D", .keyword_sampler3D },
        .{ "samplerCube", .keyword_samplerCube },
        .{ "sampler1DShadow", .keyword_sampler1DShadow },
        .{ "sampler2DShadow", .keyword_sampler2DShadow },
        .{ "samplerCubeShadow", .keyword_samplerCubeShadow },
        .{ "sampler1DArray", .keyword_sampler1DArray },
        .{ "sampler2DArray", .keyword_sampler2DArray },
        .{ "sampler1DArrayShadow", .keyword_sampler1DArrayShadow },
        .{ "sampler2DArrayShadow", .keyword_sampler2DArrayShadow },
        .{ "isampler1D", .keyword_isampler1D },
        .{ "isampler2D", .keyword_isampler2D },
        .{ "isampler3D", .keyword_isampler3D },
        .{ "isamplerCube", .keyword_isamplerCube },
        .{ "isampler1DArray", .keyword_isampler1DArray },
        .{ "isampler2DArray", .keyword_isampler2DArray },
        .{ "usampler1D", .keyword_usampler1D },
        .{ "usampler2D", .keyword_usampler2D },
        .{ "usampler3D", .keyword_usampler3D },
        .{ "usamplerCube", .keyword_usamplerCube },
        .{ "usampler1DArray", .keyword_usampler1DArray },
        .{ "usampler2DArray", .keyword_usampler2DArray },
        .{ "samplerBuffer", .keyword_samplerBuffer },
        .{ "isamplerBuffer", .keyword_isamplerBuffer },
        .{ "usamplerBuffer", .keyword_usamplerBuffer },

        // Image types
        .{ "image1D", .keyword_image1D },
        .{ "image2D", .keyword_image2D },
        .{ "image3D", .keyword_image3D },
        .{ "imageCube", .keyword_imageCube },
        .{ "image1DArray", .keyword_image1DArray },
        .{ "image2DArray", .keyword_image2DArray },
        .{ "imageBuffer", .keyword_imageBuffer },
        .{ "iimage1D", .keyword_iimage1D },
        .{ "iimage2D", .keyword_iimage2D },
        .{ "iimage3D", .keyword_iimage3D },
        .{ "iimageCube", .keyword_iimageCube },
        .{ "iimage1DArray", .keyword_iimage1DArray },
        .{ "iimage2DArray", .keyword_iimage2DArray },
        .{ "iimageBuffer", .keyword_iimageBuffer },
        .{ "uimage1D", .keyword_uimage1D },
        .{ "uimage2D", .keyword_uimage2D },
        .{ "uimage3D", .keyword_uimage3D },
        .{ "uimageCube", .keyword_uimageCube },
        .{ "uimage1DArray", .keyword_uimage1DArray },
        .{ "uimage2DArray", .keyword_uimage2DArray },
        .{ "uimageBuffer", .keyword_uimageBuffer },

        // Atomic type
        .{ "atomic_uint", .keyword_atomic_uint },

        // Type qualifiers
        .{ "centroid", .keyword_centroid },
        .{ "in", .keyword_in },
        .{ "out", .keyword_out },
        .{ "inout", .keyword_inout },
        .{ "uniform", .keyword_uniform },
        .{ "patch", .keyword_patch },
        .{ "sample", .keyword_sample },
        .{ "buffer", .keyword_buffer },
        .{ "shared", .keyword_shared },
        .{ "coherent", .keyword_coherent },
        .{ "volatile", .keyword_volatile },
        .{ "restrict", .keyword_restrict },
        .{ "readonly", .keyword_readonly },
        .{ "writeonly", .keyword_writeonly },

        // Interpolation qualifiers
        .{ "noperspective", .keyword_noperspective },
        .{ "flat", .keyword_flat },
        .{ "smooth", .keyword_smooth },

        // Layout
        .{ "layout", .keyword_layout },

        // Control flow
        .{ "while", .keyword_while },
        .{ "break", .keyword_break },
        .{ "continue", .keyword_continue },
        .{ "do", .keyword_do },
        .{ "else", .keyword_else },
        .{ "for", .keyword_for },
        .{ "if", .keyword_if },
        .{ "discard", .keyword_discard },
        .{ "return", .keyword_return },
        .{ "switch", .keyword_switch },
        .{ "case", .keyword_case },
        .{ "default", .keyword_default },

        // Other keywords
        .{ "struct", .keyword_struct },
        .{ "void", .keyword_void },
        .{ "subroutine", .keyword_subroutine },
        .{ "invariant", .keyword_invariant },
        .{ "precise", .keyword_precise },
        .{ "highp", .keyword_highp },
        .{ "mediump", .keyword_mediump },
        .{ "lowp", .keyword_lowp },
        .{ "precision", .keyword_precision },

        // Boolean constants
        .{ "true", .bool_constant },
        .{ "false", .bool_constant },
    });

    pub fn getKeyword(bytes: []const u8) ?Tag {
        return keywords.get(bytes);
    }

    pub const Tag = enum {
        invalid,
        eof,
        identifier,

        // Literals
        int_constant,
        uint_constant,
        float_constant,
        double_constant,
        bool_constant,
        string_literal,

        // Basic types
        keyword_const,
        keyword_bool,
        keyword_float,
        keyword_int,
        keyword_uint,
        keyword_double,

        // Vector types
        keyword_bvec2,
        keyword_bvec3,
        keyword_bvec4,
        keyword_ivec2,
        keyword_ivec3,
        keyword_ivec4,
        keyword_uvec2,
        keyword_uvec3,
        keyword_uvec4,
        keyword_vec2,
        keyword_vec3,
        keyword_vec4,

        // Double vector types
        keyword_dvec2,
        keyword_dvec3,
        keyword_dvec4,

        // Matrix types
        keyword_mat2,
        keyword_mat3,
        keyword_mat4,
        keyword_mat2x2,
        keyword_mat2x3,
        keyword_mat2x4,
        keyword_mat3x2,
        keyword_mat3x3,
        keyword_mat3x4,
        keyword_mat4x2,
        keyword_mat4x3,
        keyword_mat4x4,

        // Double matrix types
        keyword_dmat2,
        keyword_dmat3,
        keyword_dmat4,
        keyword_dmat2x2,
        keyword_dmat2x3,
        keyword_dmat2x4,
        keyword_dmat3x2,
        keyword_dmat3x3,
        keyword_dmat3x4,
        keyword_dmat4x2,
        keyword_dmat4x3,
        keyword_dmat4x4,

        // Sampler types
        keyword_sampler1D,
        keyword_sampler2D,
        keyword_sampler3D,
        keyword_samplerCube,
        keyword_sampler1DShadow,
        keyword_sampler2DShadow,
        keyword_samplerCubeShadow,
        keyword_sampler1DArray,
        keyword_sampler2DArray,
        keyword_sampler1DArrayShadow,
        keyword_sampler2DArrayShadow,
        keyword_isampler1D,
        keyword_isampler2D,
        keyword_isampler3D,
        keyword_isamplerCube,
        keyword_isampler1DArray,
        keyword_isampler2DArray,
        keyword_usampler1D,
        keyword_usampler2D,
        keyword_usampler3D,
        keyword_usamplerCube,
        keyword_usampler1DArray,
        keyword_usampler2DArray,
        keyword_samplerBuffer,
        keyword_isamplerBuffer,
        keyword_usamplerBuffer,

        // Image types
        keyword_image1D,
        keyword_image2D,
        keyword_image3D,
        keyword_imageCube,
        keyword_image1DArray,
        keyword_image2DArray,
        keyword_imageBuffer,
        keyword_iimage1D,
        keyword_iimage2D,
        keyword_iimage3D,
        keyword_iimageCube,
        keyword_iimage1DArray,
        keyword_iimage2DArray,
        keyword_iimageBuffer,
        keyword_uimage1D,
        keyword_uimage2D,
        keyword_uimage3D,
        keyword_uimageCube,
        keyword_uimage1DArray,
        keyword_uimage2DArray,
        keyword_uimageBuffer,

        // Atomic type
        keyword_atomic_uint,

        // Type qualifiers
        keyword_centroid,
        keyword_in,
        keyword_out,
        keyword_inout,
        keyword_uniform,
        keyword_patch,
        keyword_sample,
        keyword_buffer,
        keyword_shared,
        keyword_coherent,
        keyword_volatile,
        keyword_restrict,
        keyword_readonly,
        keyword_writeonly,

        // Interpolation qualifiers
        keyword_noperspective,
        keyword_flat,
        keyword_smooth,

        // Layout
        keyword_layout,

        // Control flow
        keyword_while,
        keyword_break,
        keyword_continue,
        keyword_do,
        keyword_else,
        keyword_for,
        keyword_if,
        keyword_discard,
        keyword_return,
        keyword_switch,
        keyword_case,
        keyword_default,

        // Other keywords
        keyword_struct,
        keyword_void,
        keyword_subroutine,
        keyword_invariant,
        keyword_precise,
        keyword_highp,
        keyword_mediump,
        keyword_lowp,
        keyword_precision,

        // Operators and punctuation
        left_paren, // (
        right_paren, // )
        left_bracket, // [
        right_bracket, // ]
        left_brace, // {
        right_brace, // }
        dot, // .
        comma, // ,
        colon, // :
        semicolon, // ;
        equal, // =
        bang, // !
        dash, // -
        tilde, // ~
        plus, // +
        star, // *
        slash, // /
        percent, // %
        left_angle, // <
        right_angle, // >
        pipe, // |
        caret, // ^
        ampersand, // &
        question, // ?

        // Multi-character operators
        left_shift, // <<
        right_shift, // >>
        inc_op, // ++
        dec_op, // --
        le_op, // <=
        ge_op, // >=
        eq_op, // ==
        ne_op, // !=
        and_op, // &&
        or_op, // ||
        xor_op, // ^^

        // Assignment operators
        mul_assign, // *=
        div_assign, // /=
        add_assign, // +=
        sub_assign, // -=
        mod_assign, // %=
        left_assign, // <<=
        right_assign, // >>=
        and_assign, // &=
        xor_assign, // ^=
        or_assign, // |=
    };

    pub fn lexeme(tag: Tag) ?[]const u8 {
        return switch (tag) {
            .identifier, .invalid, .int_constant, .uint_constant, .float_constant, .double_constant, .bool_constant, .string_literal => null,

            // Basic types
            .keyword_const => "const",
            .keyword_bool => "bool",
            .keyword_float => "float",
            .keyword_int => "int",
            .keyword_uint => "uint",
            .keyword_double => "double",

            // Vector types
            .keyword_bvec2 => "bvec2",
            .keyword_bvec3 => "bvec3",
            .keyword_bvec4 => "bvec4",
            .keyword_ivec2 => "ivec2",
            .keyword_ivec3 => "ivec3",
            .keyword_ivec4 => "ivec4",
            .keyword_uvec2 => "uvec2",
            .keyword_uvec3 => "uvec3",
            .keyword_uvec4 => "uvec4",
            .keyword_vec2 => "vec2",
            .keyword_vec3 => "vec3",
            .keyword_vec4 => "vec4",

            // Double vector types
            .keyword_dvec2 => "dvec2",
            .keyword_dvec3 => "dvec3",
            .keyword_dvec4 => "dvec4",

            // Matrix types
            .keyword_mat2 => "mat2",
            .keyword_mat3 => "mat3",
            .keyword_mat4 => "mat4",
            .keyword_mat2x2 => "mat2x2",
            .keyword_mat2x3 => "mat2x3",
            .keyword_mat2x4 => "mat2x4",
            .keyword_mat3x2 => "mat3x2",
            .keyword_mat3x3 => "mat3x3",
            .keyword_mat3x4 => "mat3x4",
            .keyword_mat4x2 => "mat4x2",
            .keyword_mat4x3 => "mat4x3",
            .keyword_mat4x4 => "mat4x4",

            // Double matrix types
            .keyword_dmat2 => "dmat2",
            .keyword_dmat3 => "dmat3",
            .keyword_dmat4 => "dmat4",
            .keyword_dmat2x2 => "dmat2x2",
            .keyword_dmat2x3 => "dmat2x3",
            .keyword_dmat2x4 => "dmat2x4",
            .keyword_dmat3x2 => "dmat3x2",
            .keyword_dmat3x3 => "dmat3x3",
            .keyword_dmat3x4 => "dmat3x4",
            .keyword_dmat4x2 => "dmat4x2",
            .keyword_dmat4x3 => "dmat4x3",
            .keyword_dmat4x4 => "dmat4x4",

            // Sampler types
            .keyword_sampler1D => "sampler1D",
            .keyword_sampler2D => "sampler2D",
            .keyword_sampler3D => "sampler3D",
            .keyword_samplerCube => "samplerCube",
            .keyword_sampler1DShadow => "sampler1DShadow",
            .keyword_sampler2DShadow => "sampler2DShadow",
            .keyword_samplerCubeShadow => "samplerCubeShadow",
            .keyword_sampler1DArray => "sampler1DArray",
            .keyword_sampler2DArray => "sampler2DArray",
            .keyword_sampler1DArrayShadow => "sampler1DArrayShadow",
            .keyword_sampler2DArrayShadow => "sampler2DArrayShadow",
            .keyword_isampler1D => "isampler1D",
            .keyword_isampler2D => "isampler2D",
            .keyword_isampler3D => "isampler3D",
            .keyword_isamplerCube => "isamplerCube",
            .keyword_isampler1DArray => "isampler1DArray",
            .keyword_isampler2DArray => "isampler2DArray",
            .keyword_usampler1D => "usampler1D",
            .keyword_usampler2D => "usampler2D",
            .keyword_usampler3D => "usampler3D",
            .keyword_usamplerCube => "usamplerCube",
            .keyword_usampler1DArray => "usampler1DArray",
            .keyword_usampler2DArray => "usampler2DArray",
            .keyword_samplerBuffer => "samplerBuffer",
            .keyword_isamplerBuffer => "isamplerBuffer",
            .keyword_usamplerBuffer => "usamplerBuffer",

            // Image types
            .keyword_image1D => "image1D",
            .keyword_image2D => "image2D",
            .keyword_image3D => "image3D",
            .keyword_imageCube => "imageCube",
            .keyword_image1DArray => "image1DArray",
            .keyword_image2DArray => "image2DArray",
            .keyword_imageBuffer => "imageBuffer",
            .keyword_iimage1D => "iimage1D",
            .keyword_iimage2D => "iimage2D",
            .keyword_iimage3D => "iimage3D",
            .keyword_iimageCube => "iimageCube",
            .keyword_iimage1DArray => "iimage1DArray",
            .keyword_iimage2DArray => "iimage2DArray",
            .keyword_iimageBuffer => "iimageBuffer",
            .keyword_uimage1D => "uimage1D",
            .keyword_uimage2D => "uimage2D",
            .keyword_uimage3D => "uimage3D",
            .keyword_uimageCube => "uimageCube",
            .keyword_uimage1DArray => "uimage1DArray",
            .keyword_uimage2DArray => "uimage2DArray",
            .keyword_uimageBuffer => "uimageBuffer",

            // Atomic type
            .keyword_atomic_uint => "atomic_uint",

            // Type qualifiers
            .keyword_centroid => "centroid",
            .keyword_in => "in",
            .keyword_out => "out",
            .keyword_inout => "inout",
            .keyword_uniform => "uniform",
            .keyword_patch => "patch",
            .keyword_sample => "sample",
            .keyword_buffer => "buffer",
            .keyword_shared => "shared",
            .keyword_coherent => "coherent",
            .keyword_volatile => "volatile",
            .keyword_restrict => "restrict",
            .keyword_readonly => "readonly",
            .keyword_writeonly => "writeonly",

            // Interpolation qualifiers
            .keyword_noperspective => "noperspective",
            .keyword_flat => "flat",
            .keyword_smooth => "smooth",

            // Layout
            .keyword_layout => "layout",

            // Control flow
            .keyword_while => "while",
            .keyword_break => "break",
            .keyword_continue => "continue",
            .keyword_do => "do",
            .keyword_else => "else",
            .keyword_for => "for",
            .keyword_if => "if",
            .keyword_discard => "discard",
            .keyword_return => "return",
            .keyword_switch => "switch",
            .keyword_case => "case",
            .keyword_default => "default",

            // Other keywords
            .keyword_struct => "struct",
            .keyword_void => "void",
            .keyword_subroutine => "subroutine",
            .keyword_invariant => "invariant",
            .keyword_precise => "precise",
            .keyword_highp => "highp",
            .keyword_mediump => "mediump",
            .keyword_lowp => "lowp",
            .keyword_precision => "precision",

            // Operators and punctuation
            .left_paren => "(",
            .right_paren => ")",
            .left_bracket => "[",
            .right_bracket => "]",
            .left_brace => "{",
            .right_brace => "}",
            .dot => ".",
            .comma => ",",
            .colon => ":",
            .semicolon => ";",
            .equal => "=",
            .bang => "!",
            .dash => "-",
            .tilde => "~",
            .plus => "+",
            .star => "*",
            .slash => "/",
            .percent => "%",
            .left_angle => "<",
            .right_angle => ">",
            .pipe => "|",
            .caret => "^",
            .ampersand => "&",
            .question => "?",

            // Multi-character operators
            .left_shift => "<<",
            .right_shift => ">>",
            .inc_op => "++",
            .dec_op => "--",
            .le_op => "<=",
            .ge_op => ">=",
            .eq_op => "==",
            .ne_op => "!=",
            .and_op => "&&",
            .or_op => "||",
            .xor_op => "^^",

            // Assignment operators
            .mul_assign => "*=",
            .div_assign => "/=",
            .add_assign => "+=",
            .sub_assign => "-=",
            .mod_assign => "%=",
            .left_assign => "<<=",
            .right_assign => ">>=",
            .and_assign => "&=",
            .xor_assign => "^=",
            .or_assign => "|=",

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
        number,
        hex_or_octal,
        float_or_int,
        float_exponent,
        float_suffix,
        string_literal,
        string_literal_escape,
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
        var state: State = .start;
        state_machine: while (true) {
            const c = self.buffer[self.index];
            switch (state) {
                .start => switch (c) {
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
                            state = .invalid;
                            continue :state_machine;
                        }
                    },
                    // Whitespace
                    ' ', '\n', '\t', '\r' => {
                        self.index += 1;
                        result.loc.start = self.index;
                        continue :state_machine;
                    },
                    // String literals
                    '"' => {
                        result.tag = .string_literal;
                        state = .string_literal;
                        self.index += 1;
                    },
                    // Identifiers and keywords
                    'a'...'z', 'A'...'Z', '_' => {
                        result.tag = .identifier;
                        state = .identifier;
                        self.index += 1;
                    },
                    // Numbers
                    '0'...'9' => {
                        state = .number;
                        self.index += 1;
                    },
                    // true/false constants are handled as keywords, but we check for them separately
                    // for boolean constant detection later
                    // Operators and punctuation
                    '(' => {
                        result.tag = .left_paren;
                        self.index += 1;
                        break :state_machine;
                    },
                    ')' => {
                        result.tag = .right_paren;
                        self.index += 1;
                        break :state_machine;
                    },
                    '[' => {
                        result.tag = .left_bracket;
                        self.index += 1;
                        break :state_machine;
                    },
                    ']' => {
                        result.tag = .right_bracket;
                        self.index += 1;
                        break :state_machine;
                    },
                    '{' => {
                        result.tag = .left_brace;
                        self.index += 1;
                        break :state_machine;
                    },
                    '}' => {
                        result.tag = .right_brace;
                        self.index += 1;
                        break :state_machine;
                    },
                    ',' => {
                        result.tag = .comma;
                        self.index += 1;
                        break :state_machine;
                    },
                    ':' => {
                        result.tag = .colon;
                        self.index += 1;
                        break :state_machine;
                    },
                    ';' => {
                        result.tag = .semicolon;
                        self.index += 1;
                        break :state_machine;
                    },
                    '?' => {
                        result.tag = .question;
                        self.index += 1;
                        break :state_machine;
                    },
                    '~' => {
                        result.tag = .tilde;
                        self.index += 1;
                        break :state_machine;
                    },
                    '.' => {
                        result.tag = .dot;
                        self.index += 1;
                        break :state_machine;
                    },
                    '+' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '+' => {
                                result.tag = .inc_op;
                                self.index += 1;
                            },
                            '=' => {
                                result.tag = .add_assign;
                                self.index += 1;
                            },
                            else => result.tag = .plus,
                        }
                        break :state_machine;
                    },
                    '-' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '-' => {
                                result.tag = .dec_op;
                                self.index += 1;
                            },
                            '=' => {
                                result.tag = .sub_assign;
                                self.index += 1;
                            },
                            else => result.tag = .dash,
                        }
                        break :state_machine;
                    },
                    '*' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '=' => {
                                result.tag = .mul_assign;
                                self.index += 1;
                            },
                            else => result.tag = .star,
                        }
                        break :state_machine;
                    },
                    '/' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '=' => {
                                result.tag = .div_assign;
                                self.index += 1;
                            },
                            else => result.tag = .slash,
                        }
                        break :state_machine;
                    },
                    '%' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '=' => {
                                result.tag = .mod_assign;
                                self.index += 1;
                            },
                            else => result.tag = .percent,
                        }
                        break :state_machine;
                    },
                    '!' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '=' => {
                                result.tag = .ne_op;
                                self.index += 1;
                            },
                            else => result.tag = .bang,
                        }
                        break :state_machine;
                    },
                    '=' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '=' => {
                                result.tag = .eq_op;
                                self.index += 1;
                            },
                            else => result.tag = .equal,
                        }
                        break :state_machine;
                    },
                    '<' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '<' => {
                                self.index += 1;
                                switch (self.buffer[self.index]) {
                                    '=' => {
                                        result.tag = .left_assign;
                                        self.index += 1;
                                    },
                                    else => result.tag = .left_shift,
                                }
                            },
                            '=' => {
                                result.tag = .le_op;
                                self.index += 1;
                            },
                            else => result.tag = .left_angle,
                        }
                        break :state_machine;
                    },
                    '>' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '>' => {
                                self.index += 1;
                                switch (self.buffer[self.index]) {
                                    '=' => {
                                        result.tag = .right_assign;
                                        self.index += 1;
                                    },
                                    else => result.tag = .right_shift,
                                }
                            },
                            '=' => {
                                result.tag = .ge_op;
                                self.index += 1;
                            },
                            else => result.tag = .right_angle,
                        }
                        break :state_machine;
                    },
                    '&' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '&' => {
                                result.tag = .and_op;
                                self.index += 1;
                            },
                            '=' => {
                                result.tag = .and_assign;
                                self.index += 1;
                            },
                            else => result.tag = .ampersand,
                        }
                        break :state_machine;
                    },
                    '|' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '|' => {
                                result.tag = .or_op;
                                self.index += 1;
                            },
                            '=' => {
                                result.tag = .or_assign;
                                self.index += 1;
                            },
                            else => result.tag = .pipe,
                        }
                        break :state_machine;
                    },
                    '^' => {
                        self.index += 1;
                        switch (self.buffer[self.index]) {
                            '^' => {
                                result.tag = .xor_op;
                                self.index += 1;
                            },
                            '=' => {
                                result.tag = .xor_assign;
                                self.index += 1;
                            },
                            else => result.tag = .caret,
                        }
                        break :state_machine;
                    },
                    else => {
                        state = .invalid;
                        continue :state_machine;
                    },
                },
                .identifier => {
                    switch (c) {
                        'a'...'z', 'A'...'Z', '_', '0'...'9' => {
                            self.index += 1;
                            continue :state_machine;
                        },
                        else => {
                            const ident = self.buffer[result.loc.start..self.index];
                            if (Token.getKeyword(ident)) |tag| {
                                result.tag = tag;
                            }
                            break :state_machine;
                        },
                    }
                },
                .number => {
                    switch (c) {
                        '0'...'9' => {
                            self.index += 1;
                            continue :state_machine;
                        },
                        'x', 'X' => {
                            // Hexadecimal (must have seen 0 before this)
                            self.index += 1;
                            state = .hex_or_octal;
                            continue :state_machine;
                        },
                        'u', 'U' => {
                            result.tag = .uint_constant;
                            self.index += 1;
                            break :state_machine;
                        },
                        'f', 'F' => {
                            result.tag = .float_constant;
                            self.index += 1;
                            break :state_machine;
                        },
                        'l', 'L' => {
                            result.tag = .double_constant;
                            self.index += 1;
                            break :state_machine;
                        },
                        '.' => {
                            self.index += 1;
                            state = .float_or_int;
                            continue :state_machine;
                        },
                        'e', 'E' => {
                            self.index += 1;
                            state = .float_exponent;
                            continue :state_machine;
                        },
                        else => {
                            result.tag = .int_constant;
                            break :state_machine;
                        },
                    }
                },
                .hex_or_octal => {
                    switch (c) {
                        '0'...'9', 'a'...'f', 'A'...'F' => {
                            self.index += 1;
                            continue :state_machine;
                        },
                        'u', 'U' => {
                            result.tag = .uint_constant;
                            self.index += 1;
                            break :state_machine;
                        },
                        'l', 'L' => {
                            result.tag = .int_constant;
                            self.index += 1;
                            break :state_machine;
                        },
                        else => {
                            result.tag = .int_constant;
                            break :state_machine;
                        },
                    }
                },
                .float_or_int => {
                    switch (c) {
                        '0'...'9' => {
                            self.index += 1;
                            state = .float_suffix;
                            continue :state_machine;
                        },
                        'e', 'E' => {
                            self.index += 1;
                            state = .float_exponent;
                            continue :state_machine;
                        },
                        else => {
                            // Backtrack: the '.' is actually a separate token
                            self.index -= 1;
                            result.tag = .int_constant;
                            break :state_machine;
                        },
                    }
                },
                .float_suffix => {
                    switch (c) {
                        '0'...'9' => {
                            self.index += 1;
                            continue :state_machine;
                        },
                        'e', 'E' => {
                            self.index += 1;
                            state = .float_exponent;
                            continue :state_machine;
                        },
                        'f', 'F' => {
                            result.tag = .float_constant;
                            self.index += 1;
                            break :state_machine;
                        },
                        'l', 'L' => {
                            result.tag = .double_constant;
                            self.index += 1;
                            break :state_machine;
                        },
                        else => {
                            result.tag = .float_constant;
                            break :state_machine;
                        },
                    }
                },
                .float_exponent => {
                    switch (c) {
                        '+', '-' => {
                            self.index += 1;
                            state = .float_suffix;
                            continue :state_machine;
                        },
                        '0'...'9' => {
                            self.index += 1;
                            state = .float_suffix;
                            continue :state_machine;
                        },
                        else => {
                            self.index -= 1;
                            result.tag = .float_constant;
                            break :state_machine;
                        },
                    }
                },
                .string_literal => {
                    switch (c) {
                        '\\' => {
                            self.index += 1;
                            state = .string_literal_escape;
                            continue :state_machine;
                        },
                        '"' => {
                            self.index += 1;
                            break :state_machine;
                        },
                        0 => {
                            if (self.index == self.buffer.len) {
                                result.tag = .invalid;
                            } else {
                                self.index += 1;
                                continue :state_machine;
                            }
                            break :state_machine;
                        },
                        '\n' => {
                            // Unterminated string
                            result.tag = .invalid;
                            break :state_machine;
                        },
                        else => {
                            self.index += 1;
                            continue :state_machine;
                        },
                    }
                },
                .string_literal_escape => {
                    self.index += 1;
                    state = .string_literal;
                    continue :state_machine;
                },
                .invalid => {
                    self.index += 1;
                    switch (self.buffer[self.index]) {
                        0 => if (self.index == self.buffer.len) {
                            result.tag = .invalid;
                            break :state_machine;
                        } else {
                            continue :state_machine;
                        },
                        '\n' => {
                            result.tag = .invalid;
                            break :state_machine;
                        },
                        else => continue :state_machine,
                    }
                },
            }
        }
        result.loc.end = self.index;
        return result;
    }
};

pub const Parser = struct {};

test "test basic type keywords" {
    try testTokenize("const int double", &.{ .keyword_const, .keyword_int, .keyword_double });
    try testTokenize("const", &.{.keyword_const});
    try testTokenize("bool", &.{.keyword_bool});
    try testTokenize("float", &.{.keyword_float});
    try testTokenize("int", &.{.keyword_int});
    try testTokenize("uint", &.{.keyword_uint});
    try testTokenize("double", &.{.keyword_double});
}

test "test vector keywords" {
    try testTokenize("vec2 vec3 vec4", &.{ .keyword_vec2, .keyword_vec3, .keyword_vec4 });
    try testTokenize("ivec2 ivec3 ivec4", &.{ .keyword_ivec2, .keyword_ivec3, .keyword_ivec4 });
    try testTokenize("uvec2 uvec3 uvec4", &.{ .keyword_uvec2, .keyword_uvec3, .keyword_uvec4 });
    try testTokenize("bvec2 bvec3 bvec4", &.{ .keyword_bvec2, .keyword_bvec3, .keyword_bvec4 });
    try testTokenize("dvec2 dvec3 dvec4", &.{ .keyword_dvec2, .keyword_dvec3, .keyword_dvec4 });
}

test "test matrix keywords" {
    try testTokenize("mat2 mat3 mat4", &.{ .keyword_mat2, .keyword_mat3, .keyword_mat4 });
    try testTokenize("mat2x2 mat2x3 mat2x4", &.{ .keyword_mat2x2, .keyword_mat2x3, .keyword_mat2x4 });
    try testTokenize("dmat2 dmat3 dmat4", &.{ .keyword_dmat2, .keyword_dmat3, .keyword_dmat4 });
}

test "test sampler and image keywords" {
    try testTokenize("sampler2D isampler2D usampler2D", &.{ .keyword_sampler2D, .keyword_isampler2D, .keyword_usampler2D });
    try testTokenize("image2D iimage2D uimage2D", &.{ .keyword_image2D, .keyword_iimage2D, .keyword_uimage2D });
    try testTokenize("samplerCube imageCube", &.{ .keyword_samplerCube, .keyword_imageCube });
}

test "test type qualifiers" {
    try testTokenize("in out inout uniform", &.{ .keyword_in, .keyword_out, .keyword_inout, .keyword_uniform });
    try testTokenize("const volatile shared", &.{ .keyword_const, .keyword_volatile, .keyword_shared });
    try testTokenize("layout centroid flat", &.{ .keyword_layout, .keyword_centroid, .keyword_flat });
}

test "test control flow keywords" {
    try testTokenize("if else while for do", &.{ .keyword_if, .keyword_else, .keyword_while, .keyword_for, .keyword_do });
    try testTokenize("break continue return", &.{ .keyword_break, .keyword_continue, .keyword_return });
    try testTokenize("switch case default discard", &.{ .keyword_switch, .keyword_case, .keyword_default, .keyword_discard });
}

test "test other keywords" {
    try testTokenize("struct void subroutine", &.{ .keyword_struct, .keyword_void, .keyword_subroutine });
    try testTokenize("invariant precise", &.{ .keyword_invariant, .keyword_precise });
    try testTokenize("highp mediump lowp precision", &.{ .keyword_highp, .keyword_mediump, .keyword_lowp, .keyword_precision });
}

test "test punctuation" {
    try testTokenize("(){}", &.{ .left_paren, .right_paren, .left_brace, .right_brace });
    try testTokenize("[].,;:", &.{ .left_bracket, .right_bracket, .dot, .comma, .semicolon, .colon });
    try testTokenize("?~", &.{ .question, .tilde });
}

test "test single char operators" {
    try testTokenize("+-*/%", &.{ .plus, .dash, .star, .slash, .percent });
    try testTokenize("!&|^", &.{ .bang, .ampersand, .pipe, .caret });
    try testTokenize("=<>", &.{ .equal, .left_angle, .right_angle });
}

test "test multi-char operators" {
    try testTokenize("++--", &.{ .inc_op, .dec_op });
    try testTokenize("<<>>", &.{ .left_shift, .right_shift });
    try testTokenize("==!=", &.{ .eq_op, .ne_op });
    try testTokenize("<=>= >=", &.{ .le_op, .ge_op, .ge_op });
    try testTokenize("&&||^^", &.{ .and_op, .or_op, .xor_op });
}

test "test assignment operators" {
    try testTokenize("+=-=*=/=%=", &.{ .add_assign, .sub_assign, .mul_assign, .div_assign, .mod_assign });
    try testTokenize("<<=>>=&=^=|=", &.{ .left_assign, .right_assign, .and_assign, .xor_assign, .or_assign });
}

test "test expression tokenization" {
    try testTokenize("vec3 color = texture(sampler, uv);", &.{
        .keyword_vec3, .identifier, .equal,
        .identifier,   .left_paren, .identifier,
        .comma,        .identifier, .right_paren,
        .semicolon,
    });
}

test "test integer constants" {
    try testTokenize("0 42 123 9999", &.{ .int_constant, .int_constant, .int_constant, .int_constant });
    try testTokenize("42u 100U", &.{ .uint_constant, .uint_constant });
}

test "test floating point constants" {
    try testTokenize("0.0 3.14 0.5", &.{ .float_constant, .float_constant, .float_constant });
    try testTokenize("1.0f 2.5F", &.{ .float_constant, .float_constant });
    try testTokenize("1.0l 2.5L", &.{ .double_constant, .double_constant });
    try testTokenize("1e10 1E-5 2.5e+3", &.{ .float_constant, .float_constant, .float_constant });
}

test "test string literals" {
    try testTokenize("\"hello\"", &.{.string_literal});
    try testTokenize("\"hello world\"", &.{.string_literal});
    try testTokenize("\"escaped\\nstring\"", &.{.string_literal});
}

test "test number and operator combinations" {
    try testTokenize("x = 42 + 3.14f;", &.{
        .identifier, .equal, .int_constant, .plus, .float_constant, .semicolon,
    });
}

test "test dot as separate token from float" {
    try testTokenize("vec.x", &.{
        .identifier, .dot, .identifier,
    });
}

test "test hexadecimal and octal constants" {
    try testTokenize("0x00 0x42 0XABCDEF", &.{
        .int_constant, .int_constant, .int_constant,
    });
}

test "test boolean constants" {
    try testTokenize("true false", &.{
        .bool_constant, .bool_constant,
    });
}

test "test complex shader expression" {
    try testTokenize("float x = 1.5f; vec3 color = vec3(0x00, 1.0, 0.5);", &.{
        .keyword_float, .identifier, .equal,          .float_constant, .semicolon,
        .keyword_vec3,  .identifier, .equal,          .keyword_vec3,   .left_paren,
        .int_constant,  .comma,      .float_constant, .comma,          .float_constant,
        .right_paren,   .semicolon,
    });
}

test "test full shader" {
    try testTokenize(
        \\uniform mat4 matVP;
        \\uniform mat4 matGeo;
        \\layout (location = 0) in vec3 pos;
        \\layout (location = 1) in vec3 normal;
        \\layout (location = 2) in vec2 uv;
        \\out vec4 outPos;
        \\out vec4 outColor;
        \\out vec2 outUV;
        \\void main() {
        \\  outPos = matGeo * vec4(pos, 1);
        \\  gl_Position = matVP * outPos;
        \\  outUV = uv;
        \\  outColor = vec4(abs(normal), 1.0);
        \\}
    , &.{
        .keyword_uniform, .keyword_mat4,   .identifier,     .semicolon,
        .keyword_uniform, .keyword_mat4,   .identifier,     .semicolon,
        .keyword_layout,  .left_paren,     .identifier,     .equal,
        .int_constant,    .right_paren,    .keyword_in,     .keyword_vec3,
        .identifier,      .semicolon,      .keyword_layout, .left_paren,
        .identifier,      .equal,          .int_constant,   .right_paren,
        .keyword_in,      .keyword_vec3,   .identifier,     .semicolon,
        .keyword_layout,  .left_paren,     .identifier,     .equal,
        .int_constant,    .right_paren,    .keyword_in,     .keyword_vec2,
        .identifier,      .semicolon,      .keyword_out,    .keyword_vec4,
        .identifier,      .semicolon,      .keyword_out,    .keyword_vec4,
        .identifier,      .semicolon,      .keyword_out,    .keyword_vec2,
        .identifier,      .semicolon,      .keyword_void,   .identifier,
        .left_paren,      .right_paren,    .left_brace,     .identifier,
        .equal,           .identifier,     .star,           .keyword_vec4,
        .left_paren,      .identifier,     .comma,          .int_constant,
        .right_paren,     .semicolon,      .identifier,     .equal,
        .identifier,      .star,           .identifier,     .semicolon,
        .identifier,      .equal,          .identifier,     .semicolon,
        .identifier,      .equal,          .keyword_vec4,   .left_paren,
        .identifier,      .left_paren,     .identifier,     .right_paren,
        .comma,           .float_constant, .right_paren,    .semicolon,
        .right_brace,
    });
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
