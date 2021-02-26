module parser

import token

pub struct Parser {
mut:
	last_token token.Token
	prev_term bool
	read bool
	scanner &token.Scanner
}

pub fn new_parser(scanner &token.Scanner) &Parser {
	return &Parser {
		read: false,
		scanner: scanner
	}
}

fn (mut p Parser) get() ?token.Token {
	if !p.read {
		p.last_token = p.scanner.scan_once()?
		p.read = true
		p.prev_term = p.scanner.prev_term
	}
	return p.last_token
}

fn (mut p Parser) walk() {
	p.read = false
}

fn (mut p Parser) is_term() ?bool {
	tok := p.get()?
	if p.prev_term {
		return true
	}
	if tok.kind is token.Keyword {
		if tok.kind == .rbrace {
			return true
		}
	}
	if tok.kind is token.EOF {
		return true
	}
	return false
}
