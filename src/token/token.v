module token

pub type TokenKind = Identifier | Keyword | f64 | string | RegExp | EOF

pub struct Identifier {
pub:
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
	key_await
	key_break
	key_case
	key_catch
	key_class
	key_const
	key_continue
	key_debugger
	key_default
	key_do
	key_else
	key_enum
	key_export
	key_extends
	key_finally
	key_for
	key_function
	key_if
	key_import
	key_new
	key_return
	key_switch
	key_throw
	key_try
	key_var
	key_while
	key_with
	key_yield
	key_this
	key_super

	// Literals
	key_null
	key_true
	key_false
}

pub fn (k Keyword) str() string {
	return keyword_to_str[int(k)]
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
	'await',//	await
	'break',//	break
	'case',//	case
	'catch',//	catch
	'class',//	class
	'const',//	const
	'continue',//	continue
	'debugger',//	debugger
	'default',//	default
	'do',//	do
	'else',//	else
	'enum',//	enum
	'export',//	export
	'extends',//	extends
	'finally',//	finally
	'for',//	for
	'function',//	function
	'if',//	if
	'import',//	import
	'new',//	new
	'return',//	return
	'switch',//	switch
	'throw',//	throw
	'try',//	try
	'var',//	var
	'while',//	while
	'with',//	with
	'yield',//	yield
	'this',//	this
	'super',//	super
	//
	//	// Literals
	'null',//	nul
	'true',//	tru
	'false',//	fals
]

pub struct RegExp {
pub:
	pattern string
	flags string
}

pub struct EOF {}

pub struct Token {
pub:
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

pub fn (kind TokenKind) str() string {
	return match kind {
		Identifier {'id: $kind.name'}
		Keyword {keyword_to_str[int(kind)]}
		f64 {kind.str()}
		string {kind}
		RegExp {'/$kind.pattern/$kind.flags'}
		EOF {'EOF'}
	}
}

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
