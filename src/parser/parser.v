module parser

import token

pub struct Parser {
mut:
	scanner &token.Scanner
}

pub fn new_parser(scanner &token.Scanner) &Parser {
	return &Parser {
		scanner: scanner
	}
}
