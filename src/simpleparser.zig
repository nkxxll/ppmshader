const std = @import("std");
const Allocator = std.mem.Allocator;
const GPA = std.heap.GeneralPurposeAllocator(.{});
const ArrayList = std.ArrayList;
const Rule = enum(u8) { // Use u8 for explicit numbering like the C++ code
    sf = 1, // S -> F
    ssf = 2, // S -> ( S + F )
    fa = 3, // F -> a
};

const Symbol = enum {
    lpar,
    rpar,
    a,
    plus,
    eof,
    invalid,
    S, // Non-terminal S
    F, // Non-terminal F
};

// --- Lexer Function ---
pub fn lexer(c: u8) Symbol {
    switch (c) {
        '(' => return .lpar,
        ')' => return .rpar,
        'a' => return .a,
        '+' => return .plus,
        0 => return .eof, // end of string terminator
        else => return .invalid,
    }
}

// --- Parsing Table Struct ---
// Maps Non-terminal rows to Terminal columns to get a Rule
const ParsingTable = struct {
    table: [2][5]?Rule = [2][5]?Rule{
        // TS_L_PARENS, TS_R_PARENS, TS_A, TS_PLUS, TS_EOS
        // lpar,        rpar,        a,    plus,  eof
        [_]?Rule{ null, null, null, null, null }, // Placeholder for S (NTS_S)
        [_]?Rule{ null, null, null, null, null }, // Placeholder for F (NTS_F)
    },

    // A helper function to map Symbol enum to array indices
    fn get_nts_index(nts: Symbol) usize {
        return switch (nts) {
            .S => 0,
            .F => 1,
            else => @panic("Expected Non-Terminal Symbol"),
        };
    }

    fn get_ts_index(ts: Symbol) usize {
        return switch (ts) {
            .lpar => 0,
            .rpar => 1,
            .a => 2,
            .plus => 3,
            .eof => 4,
            else => @panic("Expected Terminal Symbol"),
        };
    }

    // Initialize the table based on the C++ code:
    // table[NTS_S][TS_L_PARENS] = 2; (Rule 2: ssf)
    // table[NTS_S][TS_A] = 1;        (Rule 1: sf)
    // table[NTS_F][TS_A] = 3;        (Rule 3: fa)
    pub fn init_table() ParsingTable {
        var self: ParsingTable = .{};
        self.table[get_nts_index(.S)][get_ts_index(.lpar)] = .ssf; // S, ( -> Rule 2
        self.table[get_nts_index(.S)][get_ts_index(.a)] = .sf; // S, a -> Rule 1
        self.table[get_nts_index(.F)][get_ts_index(.a)] = .fa; // F, a -> Rule 3
        return self;
    }

    pub fn lookup(self: ParsingTable, nts: Symbol, ts: Symbol) ?Rule {
        return self.table[get_nts_index(nts)][get_ts_index(ts)];
    }
};

pub fn parse(allocator: Allocator, input: []const u8) !void {
    const table = ParsingTable.init_table();
    var stack = try ArrayList(Symbol).initCapacity(allocator, 8);
    var p: usize = 0; // input buffer cursor

    // Initialize the symbols stack
    try stack.append(allocator, .eof); // terminal, $
    try stack.append(allocator, .S); // non-terminal, S

    std.debug.print("Starting parse of: '{s}'\n", .{input});

    while (stack.items.len > 0) {
        const top_of_stack = stack.pop();
        const current_input_char = input[p];
        const lookahead = lexer(current_input_char);

        // --- Terminal Match Check (The 'if' block) ---
        // Terminal symbols are TS_L_PARENS, TS_R_PARENS, TS_A, TS_PLUS, TS_EOS (eof)
        if (top_of_stack.? == lookahead) {
            std.debug.print("Matched terminal: {s}\n", .{@tagName(lookahead)});
            p += 1; // Consume input
        }

        // --- Non-terminal Expansion Check (The 'else' block) ---
        else if (top_of_stack.? == .S or top_of_stack.? == .F) {
            // Push the popped Non-terminal back on the stack for the error case
            // If the rule is found, we immediately pop it again inside the switch.
            // This is safer than the C++ approach of always popping before the lookup.
            try stack.append(allocator, top_of_stack.?);

            const rule_opt = table.lookup(top_of_stack.?, lookahead);

            if (rule_opt) |rule| {
                // Remove the Non-terminal (NTS) from the stack now that we have a rule
                _ = stack.pop();

                std.debug.print("Rule {d}: {s}\n", .{ @intFromEnum(rule), @tagName(rule) });

                // Push RHS of the rule onto the stack in REVERSE order
                switch (rule) {
                    .sf => { // 1. S → F
                        try stack.append(allocator, .F);
                    },
                    .ssf => { // 2. S → ( S + F )
                        try stack.append(allocator, .rpar); // )
                        try stack.append(allocator, .F); // F
                        try stack.append(allocator, .plus); // +
                        try stack.append(allocator, .S); // S
                        try stack.append(allocator, .lpar); // (
                    },
                    .fa => { // 3. F → a
                        try stack.append(allocator, .a); // a
                    },
                }
            } else {
                // Error case: No rule found for <NTS, TS>
                std.debug.print("Parsing Error: No rule found for <{s}, {s}>\n", .{ @tagName(top_of_stack.?), @tagName(lookahead) });
                return error.ParsingFailure;
            }
        } else {
            // Error case: Stack top is a terminal, but it didn't match the lookahead
            std.debug.print("Parsing Error: Terminal mismatch! Expected {s}, got {s}\n", .{ @tagName(top_of_stack.?), @tagName(lookahead) });
            return error.ParsingFailure;
        }
    }

    if (p == input.len) {
        std.debug.print("Finished parsing successfully!\n", .{});
    } else {
        std.debug.print("Finished parsing, but input was not fully consumed.\n", .{});
        return error.InputRemaining;
    }
}

test "this is all teh tests" {
    var gpa = GPA{};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Test cases (like the C++ example command line argument)
    try parse(allocator, "a\x00");
    std.debug.print("\n", .{});
    try parse(allocator, "(a+a)\x00");
}
