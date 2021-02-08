module token

pub type TokenKind = Identifier | Keyword | f64 | string | RegExp | EOF

pub struct Identifier {
	name string
}

pub enum Keyword {
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

const keyword_to_str = [
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

pub struct RegExp {
	pattern string
	flags string
}

pub struct EOF {}

pub struct Token {
	position SourceLocation
	kind TokenKind
}

const keyword_to_enum = (fn()map[string]Keyword{
	mut enumap := map[string]Keyword
	for i, key in keyword_to_str {
		enumap[key] = Keyword(i)
	}
	return enumap
}())

const keyword_list_word = (fn()[]string{
	return keyword_to_str.filter(it[0].is_letter())
}())

const keyword_list_sign = (fn()[]string{
	return keyword_to_str.filter(!it[0].is_letter())
}())

const keyword_list_1 = (fn()[]string{
	return keyword_list_sign.filter(it.len == 1)
}())

const keyword_list_2 = (fn()[]string{
	return keyword_list_sign.filter(it.len == 2)
}())

const keyword_list_3 = (fn()[]string{
	return keyword_list_sign.filter(it.len == 3)
}())

pub fn get_priority(key Keyword) ?int {
	priority := match key {
		.lor {4}
		.land {5}
		.bor {6}
		.bxor {7}
		.band {8}
		.shl, .sar, .shr {11}
		.mul, .div, .mod {13}
		.add, .sub {12}
		.assign, .assign_bor, .assign_bxor, .assign_band,
		.assign_shl, .assign_sar, .assign_shr,
		.assign_mul, .assign_div, .assign_mod,
		.assign_add, .assign_sub {2}
		.comma {1}
		.cond {3}
		.eq, .teq, .ne, .tne {9}
		.lt, .gt, .lte, .gte, .insof, .inn {10}
		else {0}
	}
	if priority == 0 {
		return none
	} else {
		return priority
	}
}
