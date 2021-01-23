module ast

import token

// Node Objects

struct Node {
	loc ?token.SourceLocation
	body NodeBody
}

type NodeBody = Program | Function | Statement | Directive | SwitchCase | CatchClause | VariableDeclarator | Expression | Property


// Identifier

struct Identifier {
	name string
}

// Literal

struct Literal {
	value LiteralBody
}

type LiteralBody = string | bool | Nulltype | f64 | RegExp

struct Nulltype {}

struct RegExp {
	pattern string
	flags string
}

// Programs

struct Program {
	body []ProgramBody
}

type ProgramBody = Directive | Statement

// Functions

struct Function {
	id ?Identifier
	params []Pattern
	body FunctionBody
}

type FunctionBody = Directive | Statement

// Statements

type Statement = ExpressionStatement | BlockStatement | EmptyStatement | DebuggerStatement |
WithStatement | ReturnStatement | LabelStatement | BreakStatement | ContinueStatement |
IfStatement | SwitchStatement | ThrowStatement | TryStatement | WhileStatement | DoWhileStatement |
ForStatement | ForInStatement | Declaration

struct ExpressionStatement {
	expression Expression
}

struct Directive {
	expression Literal
	directive string
}

struct BlockStatement {
	body []Statement
}

struct EmptyStatement {}

struct DebuggerStatement {}

struct WithStatement {
	object Expression
	body Statement
}

// Control Flow

struct ReturnStatement {
	argument ?Expression
}

struct LabelStatement {
	label Identifier
	body Statement
}

struct BreakStatement {
	label ?Identifier
}

struct ContinueStatement {
	label ?Identifier
}

// Choice

struct IfStatement {
	test Expression
	consequent Statement
	alternate ?Statement
}

struct SwitchStatement {
	discriminant Expression
	cases []SwitchCase
}

struct SwitchCase {
	test ?Expression
	consequent []Statement
}

// Exceptions

struct ThrowStatement {
	argument Expression
}

struct TryStatement {
	block BlockStatement
	handler ?CatchClause
	finalizer ?BlockStatement
}

struct CatchClause {
	param Pattern
	body BlockStatement
}

// Loops

struct WhileStatement {
	test Expression
	body Statement
}

struct DoWhileStatement {
	body Statement
	test Expression
}

struct ForStatement {
	init ?ForInit
	test ?Expression
	update ?Expression
	body Statement
}

type ForInit = VariableDeclaration | Expression

struct ForInStatement {
	left ForInLeft
	right Expression
	body Statement
}

type ForInLeft = VariableDeclaration | Pattern

// Declarations

type Declaration = FunctionDeclaration | VariableDeclaration

struct FunctionDeclaration {
	id Identifier
	body Function
}

struct VariableDeclaration {
	declarations []VariableDeclarator
	kind VariableDeclarationKind
}

enum VariableDeclarationKind { var }

struct VariableDeclarator {
	id Pattern
	init ?Expression
}

// Expressions

type Expression = Identifier | Literal | ThisExpression | ArrayExpression | ObjectExpression |
FunctionExpression | UnaryExpression | UpdateExpression | Binaryexpression | AssignmentExpression |
LogicalExpression | MemberExpression | ConditionalExpression | CallExpression | NewExpression |
SequenceExpression

struct ThisExpression {}

struct ArrayExpression {
	elements ?Expression
}

struct ObjectExpression {
	properties []Property
}

struct Property {
	key PropertyKey
	value Expression
	kind PropertyKind
}

type PropertyKey = Literal | Identifier

enum PropertyKind { init get set }

struct FunctionExpression {
	body Function
}

struct UnaryExpression {
	operator UnaryOperator
	prefix bool
	argument Expression
}

enum UnaryOperator {
	minus // -
	plus  // +
	neg   // !
	bneg  // ~
	typof // typeof
	void  // void
	del   // delete
}

struct UpdateExpression {
	operator UpdateOperator
	argument Expression
	prefix bool
}

enum UpdateOperator {
	plus  // ++
	minus // --
}

struct Binaryexpression {
	operator BinaryOperator
	left Expression
	right Expression
}

enum BinaryOperator {
	eq // ==
	ne // !=
	teq // ===
	tne // !==
	gt // <
	ge // <=
	lt // >
	le // >=
	shl // <<
	sar // >>
	shr // >>>
	add // +
	sub // -
	mul // *
	div // /
	mod // %
	bor // |
	bxor // ^
	band // &
	inobj // in
	insof // instanceof
}

struct AssignmentExpression {
	operator AssignmentOperator
	left AssignmentLeft
	right Expression
}

type AssignmentLeft = Pattern | Expression

enum AssignmentOperator {
	assign // =
	add // +=
	sub // -=
	mul // *=
	div // /=
	mod // %=
	shl // <<=
	sar // >>=
	shr // >>>=
	bor // |=
	bxor // ^=
	band // &=
}

struct LogicalExpression {
	operator LogicalOperator
	left Expression
	right Expression
}

enum LogicalOperator { land lor }

struct MemberExpression {
	object Expression
	property MemberProperty
}

type MemberProperty = Expression | Pattern

struct ConditionalExpression {
	test Expression
	alternate Expression
	consequent Expression
}

struct CallExpression {
	callee Expression
	arguments []Expression
}

struct NewExpression {
	callee Expression
	arguments []Expression
}

struct SequenceExpression {
	expressions []Expression
}

// Patterns

type Pattern = Identifier
