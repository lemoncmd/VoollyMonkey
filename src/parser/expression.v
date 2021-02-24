module parser

import token
import ast

const (
	unexpected_eof = 'Unexpected end of input'
)

pub fn (mut p Parser) parse_primary() ?ast.Expression {
	p.scanner.switch_context(.regexp)
	tok := p.scanner.scan_once()?
	position := tok.position
	p.scanner.switch_context(.div)
	match tok.kind {
		token.Identifier {
			return ast.Identifier {
				name: tok.kind.name,
				loc: position
			}
		}
		f64 {
			return ast.Literal {
				value: f64(tok.kind), // temporary cgen hack
				loc: position
			}
		}
		string {
			return ast.Literal {
				value: ''+tok.kind, // temporary cgen hack
				loc: position
			}
		}
		token.RegExp {
			return ast.Literal {
				value: ast.RegExp{pattern: tok.kind.pattern, flags: tok.kind.flags},
				loc: position
			}
		}
		token.Keyword {
			if tok.kind == .key_null {
				return ast.Literal {
					value: ast.Nulltype{},
					loc: position
				}
			}
			if tok.kind in [.key_true, .key_false] {
				return ast.Literal {
					value: tok.kind == .key_true,
					loc: position
				}
			}
			if tok.kind == .key_this {
				return ast.ThisExpression{
					loc: position
				}
			}
			return error('Unexpected token \'${tok.kind}\'')
		}
		token.EOF {
			return error(unexpected_eof)
		}
	}
}
