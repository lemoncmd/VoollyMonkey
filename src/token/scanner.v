module token

pub struct Scanner {
	buffer []Token
	file_name ?string
	text ustring
mut:
	context IEContext
	pos int
	line int
	lpos int
	prev_term bool
}

enum IEContext {
	div regexp
}

const (
	unexpected_token = 'Invalid or unexpected token'
)

[inline]
fn (s Scanner) get_position() Position {
	return Position{line: s.line, column: s.lpos}
}

[inline]
fn (s Scanner) get_location(start Position, end Position) SourceLocation {
	return SourceLocation{source: s.file_name, start: start, end: end}
}

[inline]
fn is_whitespace(s string) bool {
	ss := s.utf32_code()
	return ss in [0x9, 0xb, 0xc, 0x20, 0xa0, 0xfeff, 0x1680, 0x202f, 0x205f, 0x3000] ||
	(0x2000 <= ss && ss <= 0x200a)
}

[inline]
fn is_terminator(s string) bool {
	ss := s.utf32_code()
	return ss in [0xa, 0xd, 0x2028, 0x2029]
}

// TODO add other unicode character
[inline]
fn is_id_start(s string) bool {
	return s[0].is_letter() || s in ['_', '\$']
}

[inline]
fn is_id_continue(s string) bool {
	return s[0].is_letter() || s in ['_', '\$'] || s[0].is_digit()
}

[inline]
fn (mut s Scanner) add_pos(number int) {
	s.pos += number
	s.lpos += number
}

fn (mut s Scanner) skip_whitespace() {
	for s.pos < s.text.len && is_whitespace(s.text.at(s.pos)) {
		s.add_pos(1)
	}
}

fn (mut s Scanner) skip_terminator() {
	if s.text.at(s.pos) == '\r' {
		if ss := s.try_take(1) {
			if ss == '\n' {
				s.pos++
			}
		}
	}
	s.pos++
	s.lpos = 0
	s.line++
	s.prev_term = true
}

[inline]
fn (s Scanner) try_take(number int) ?string {
	if s.pos + number <= s.text.len {
		return s.text.substr(s.pos, s.pos + number)
	}
	return none
}

fn (mut s Scanner) skip_comment() ?bool {
	if com := s.try_take(2) {
		match com {
			'//' {
				s.add_pos(2)
				for s.pos < s.text.len && !is_terminator(s.text.at(s.pos)) {
					s.add_pos(1)
				}
			}
			'/*' {
				s.add_pos(2)
				for {
					if ss := s.try_take(2) {
						if ss == '*/' {
							break
						} else if is_terminator(s.text.at(s.pos)) {
							s.skip_terminator()
						}
						s.add_pos(1)
					} else {
						return error(unexpected_token)
					}
				}
			}
			else {return false}
		}
		return true
	}
	return false
}

fn (mut s Scanner) scan_string() ?Token {}

fn (mut s Scanner) scan_digit() ?Token {}

fn (mut s Scanner) scan_ident() ?Token {}

pub fn (mut s Scanner) scan_once() ?Token {
	// skip ws and term and comment
	s.prev_term = false
	for {
		if c := s.try_take(1) {
			if is_whitespace(c) {
				s.skip_whitespace()
			} else if is_terminator(c) {
				s.skip_terminator()
			} else if c == '/' {
				was_comment := s.skip_comment()?
				if !was_comment {
					break
				}
			} else {
				break
			}
		} else {
			break
		}
	}

	// EOF
	if s.pos == s.text.len {
		return Token{
			kind: EOF{},
			position: s.get_location(s.get_position(), s.get_position())
		}
	}

	// Puncts with slash
	if s.text.at(s.pos) == '/' {
		if s.context == .div {
			start := s.get_position()
			if ss := try_take(2) {
				if ss == '/=' {
					s.add_pos(2)
					return Token{
						kind: Keyword.assign_div,
						position: s.get_location(start, s.get_position())
					}
				}
			}
			s.add_pos(1)
			return Token{
				kind: Keyword.div,
				position: s.get_location(start, s.get_position())
			}
		} else {
			// RegExp
		}
	}
	// Puncts
	if ss := try_take(4) {
		if ss == '>>>=' {
			start := s.get_position()
			s.add_pos(4)
			return Token{
				kind: Keyword.assign_shr,
				position: s.get_location(start, s.get_position())
			}
		}
	}
	if ss := try_take(3) {
		if ss in keyword_list_3 {
			start := s.get_position()
			s.add_pos(3)
			return Token{
				kind: keyword_to_enum[ss],
				position: s.get_location(start, s.get_position())
			}
		}
	}
	if ss := try_take(2) {
		if ss in keyword_list_2 {
			start := s.get_position()
			s.add_pos(2)
			return Token{
				kind: keyword_to_enum[ss],
				position: s.get_location(start, s.get_position())
			}
		}
	}
	if ss := try_take(1) {
		if ss in keyword_list_1 {
			start := s.get_position()
			s.add_pos(1)
			return Token{
				kind: keyword_to_enum[ss],
				position: s.get_location(start, s.get_position())
			}
		}
	}
	// String
	if s.text.at(s.pos) == '"' {
		return s.scan_string()
	}
	// Number
	if s.text.at(s.pos)[0].is_digit() {
		return s.scan_digit()
	}
	// Identifier

	return error(unexpected_token)
}
