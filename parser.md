# zig parser research

- entry point `parseRoot(p: *Parse)`
- entry point for zon files is `parseZon(p: *Parse)`
- Parse is the parser struct in `lib/std/zig/Parse.zig`
- the zig language can be parsed by an LL(k) parser
- this is a recursive descent hand written parser

## simple grammar LL(k) parser

- the grammar is 
- S -> ( S + F )
- S -> ( F + F )
- S -> ( a + F )
- S -> ( a + a )
