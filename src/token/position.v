module token

struct SourceLocation {
	source ?string
	start Position
	end Position
}

struct Position {
	line int
	column int
}
