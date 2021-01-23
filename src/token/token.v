module token

type TokenKind = Identifier | Keyword | f64 | string | RegExp | NewLine | EOF

struct Identifier {
	name string
}

enum Keyword {
	// Operators
	lor
	land
	bor
	bxor
	band
	shl
	sar
	shr
	mul
	div
	mod
	add
	sub
	assign
	assign_bor
	assign_bxor
	assign_band
	assign_shl
	assign_sar
	assign_shr
	assign_mul
	assign_div
	assign_mod
	assign_add
	assign_sub
}

const KeywordToStr = [
	'||',
	'&&'
]

struct RegExp {
	pattern string
	flags string
}

struct NewLine {}

struct EOF {}

struct Token {
	position SourceLocation
}
