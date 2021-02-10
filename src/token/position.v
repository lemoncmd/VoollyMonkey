module token

struct SourceLocation {
	source string  //should be optional
	start Position
	end Position
}

struct Position {
	line int
	column int
}
