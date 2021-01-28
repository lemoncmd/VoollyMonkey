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
	lnot
	bnot
	delete
	typof
	void
	inc
	dec
	eq
	teq
	ne
	tne
	lt
	gt
	lte
	gte
	insof
	inn
	cond
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

	// Puncts
	lbrack
	rbrack
	lparen
	rparen
	lbrace
	rbrace
	colon
	semi
	comma
	period

	// Statements
	key_break
	key_case
	key_catch
	key_continue
	key_debugger
	key_default
	key_do
	key_else
	key_finally
	key_for
	key_function
	key_if
	key_new
	key_return
	key_switch
	key_throw
	key_try
	key_var
	key_while
	key_with
	key_this
	key_super

	// Literals
	key_null
	key_true
	key_false
}

const KeywordToStr = [
	//	// Operators
	'||',//	lor
	'&&',//	land
	'|',//	bor
	'^',//	bxor
	'&',//	band
	'<<',//	shl
	'>>',//	sar
	'>>>',//	shr
	'*',//	mul
	'/',//	div
	'%',//	mod
	'+',//	add
	'-',//	sub
	'!',//	lnot
	'~',//	bnot
	'delete',//	delete
	'typeof',//	typof
	'void',//	void
	'++',//	inc
	'--',//	dec
	'==',//	eq
	'===',//	teq
	'!=',//	ne
	'!==',//	tne
	'<',//	lt
	'>',//	gt
	'<=',//	lte
	'>=',//	gte
	'instanceof',//	insof
	'in',//	inn
	'?',//	cond
	'=',//	assign
	'|=',//	assign_bor
	'^=',//	assign_bxor
	'&=',//	assign_band
	'<<=',//	assign_shl
	'>>=',//	assign_sar
	'>>>=',//	assign_shr
	'*=',//	assign_mul
	'/=',//	assign_div
	'%=',//	assign_mod
	'+=',//	assign_add
	'-=',//	assign_sub
	//
	//	// Puncts
	'[',//	lbrack
	']',//	rbrack
	'(',//	lparen
	')',//	rparen
	'{',//	lbrace
	'}',//	rbrace
	':',//	colon
	';',//	semi
	',',//	comma
	'.',//	period
	//
	//	// Statements
	'break',//	brek
	'case',//	case
	'catch',//	catch
	'continue',//	cont
	'debugger',//	debug
	'default',//	deflt
	'do',//	doo
	'else',//	els
	'finally',//	final
	'for',//	forr
	'function',//	func
	'if',//	iff
	'new',//	new
	'return',//	ret
	'switch',//	swit
	'throw',//	throw
	'try',//	try
	'var',//	var
	'while',//	whil
	'with',//	with
	'this',//	this
	'super',//	super
	//
	//	// Literals
	'null',//	nul
	'true',//	tru
	'false',//	fals
]

struct RegExp {
	pattern string
	flags string
}

struct NewLine {}

struct EOF {}

struct Token {
	position SourceLocation
	kind TokenKind
}

const KeywordToEnum = (fn(){
	mut enumap := map[string]Keyword
	for i, key in KeywordToStr {
		enumap[key] = Keyword(i)
	}
	return enumap
})()
