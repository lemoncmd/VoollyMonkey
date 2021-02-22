module token

import strconv

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
	is_strict bool
}

enum IEContext {
	div regexp
}

const (
	unexpected_token = 'Invalid or unexpected token'
	invalid_hexadecimal = 'Invalid hexadecimal escape sequence'
	invalid_unicode = 'Invalid Unicode escape sequence'
	strict_octal = 'Octal escape sequences are not allowed in strict mode.'
	octal_not_allowed = 'Octal literals are not allowed in strict mode.'
	missing_slash = 'Invalid regular expression: missing /'
	invalid_flags = 'Invalid regular expression flags'
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
		if ss := s.try_take(2) {
			if ss == '\r\n' {
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
							s.add_pos(2)
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

fn (mut s Scanner) scan_regexp() ?Token {
	start_lpos := s.get_position()
	s.add_pos(1)
	start_pos := s.pos
	for {
		if ss := s.try_take(1) {
			if ss == '/' {
				break
			}
			if is_terminator(ss) {
				return error(missing_slash)
			}
			if ss == '\\' {
				s.add_pos(1)
				if follow := s.try_take(1) {
					if is_terminator(follow) {
						return error(missing_slash)
					}
					s.add_pos(1)
				} else {
					return error(missing_slash)
				}
			} else if ss == '[' {
				for {
					if clazz := s.try_take(1) {
						if clazz == ']' {
							s.add_pos(1)
							break
						}
						if is_terminator(clazz) {
							return error(missing_slash)
						}
						if clazz == '\\' {
							s.add_pos(1)
							if follow := s.try_take(1) {
								if is_terminator(follow) {
									return error(missing_slash)
								}
								s.add_pos(1)
							} else {
								return error(missing_slash)
							}
						} else {
							s.add_pos(1)
						}
					} else {
						return error(missing_slash)
					}
				}
			} else {
				s.add_pos(1)
			}
		} else {
			return error(missing_slash)
		}
	}
	pattern := s.text.substr(start_pos, s.pos)
	s.add_pos(1)
	mut flag_left := ['g', 'i', 'm', 's', 'u', 'y']
	mut flags := ''
	for {
		if flag := s.try_take(1) {
			if flag == '\\' {
				return error(invalid_flags)
			}
			if !is_id_continue(flag) {
				break
			}
			if flag !in flag_left {
				return error(invalid_flags)
			}
			flags += flag
			flag_left.delete(flag_left.index(flag))
		} else {
			break
		}
	}
	return Token{
		kind: RegExp{pattern: pattern, flags: flags},
		position: s.get_location(start_lpos, s.get_position())
	}
}

fn (mut s Scanner) scan_string(punct string) ?Token {
	start_pos := s.pos
	start_lpos := s.get_position()
	s.add_pos(1)
	for {
		if ss := s.try_take(1) {
			match ss {
				punct {
					s.add_pos(1)
					return Token{
						kind: s.text.substr(start_pos, s.pos),
						position: s.get_location(start_lpos, s.get_position())
					}
				}
				'\\' {
					s.add_pos(1)
					if esc := s.try_take(1) {
						if is_terminator(esc) {
							was_term := s.prev_term
							s.skip_terminator()
							s.prev_term = was_term
						} else if esc[0].is_oct_digit() {
							if s.is_strict && esc != '0' {
								return error(strict_octal)
							}
							s.add_pos(1)
							if second := s.try_take(1) {
								if second[0].is_oct_digit() {
									if s.is_strict {
										return error(strict_octal)
									}
									s.add_pos(1)
									if third := s.try_take(1) {
										if third[0].is_oct_digit() {
											s.add_pos(1)
										}
									}
								}
							} else {
								return error(unexpected_token)
							}
						} else if esc == 'u' {
							s.add_pos(1)
							if hex_first := s.try_take(1) {
								if hex_first == '{' {
									mut has_hex := false
									for {
										if hex := s.try_take(1) {
											if hex == '}' {
												if !has_hex {
													return error(invalid_unicode)
												}
												s.add_pos(1)
												break
											}
											has_hex = true
											if !hex[0].is_hex_digit() {
												return error(invalid_unicode)
											}
											s.add_pos(1)
										} else {
											return error(invalid_unicode)
										}
									}
								} else {
									if hex := s.try_take(4) {
										if !hex[0].is_hex_digit() || !hex[1].is_hex_digit()
										|| !hex[2].is_hex_digit() || !hex[3].is_hex_digit() {
											return error(invalid_unicode)
										}
										s.add_pos(4)
									} else {
										return error(invalid_unicode)
									}
								}
							}
						} else if esc == 'x' {
							s.add_pos(1)
							if hex := s.try_take(2) {
								if !hex[0].is_hex_digit() || !hex[1].is_hex_digit() {
									return error(invalid_hexadecimal)
								}
								s.add_pos(2)
							} else {
								return error(invalid_hexadecimal)
							}
						} else {
							s.add_pos(1)
						}
					} else {
						return error(unexpected_token)
					}
				}
				'\n', '\r' {
					return error(unexpected_token)
				}
				else {
					s.add_pos(1)
				}
			}
		} else {
			return error(unexpected_token)
		}
	}
	return error(unexpected_token)
}

fn (mut s Scanner) scan_digit() ?Token {
	start_pos := s.pos
	start_lpos := s.get_position()
	mut ret_num := f64(0)
	finally: for {
		if s.text.at(s.pos) == '0' {
			s.add_pos(1)
			if ss := s.try_take(1) {
				match ss {
					'x', 'X' {
						s.add_pos(1)
						mut had_number := false
						for {
							if follow := s.try_take(1) {
								if !follow[0].is_hex_digit() {
									break
								}
								s.add_pos(1)
								had_number = true
							} else {
								break
							}
						}
						if !had_number {
							return error(unexpected_token)
						}
						ret_num = f64(strconv.parse_int(s.text.substr(start_pos + 2, s.pos), 16, 0))
						break finally
					}
					'o', 'O' {
						s.add_pos(1)
						mut had_number := false
						for {
							if follow := s.try_take(1) {
								if !follow[0].is_oct_digit() {
									break
								}
								s.add_pos(1)
								had_number = true
							} else {
								break
							}
						}
						if !had_number {
							return error(unexpected_token)
						}
						ret_num = f64(strconv.parse_int(s.text.substr(start_pos + 2, s.pos), 8, 0))
						break finally
					}
					'b', 'B' {
						s.add_pos(1)
						mut had_number := false
						for {
							if follow := s.try_take(1) {
								if follow !in ['0', '1'] {
									break
								}
								s.add_pos(1)
								had_number = true
							} else {
								break
							}
						}
						if !had_number {
							return error(unexpected_token)
						}
						ret_num = f64(strconv.parse_int(s.text.substr(start_pos + 2, s.pos), 2, 0))
						break finally
					}
					else {}
				}
			}
		}
		for {
			if ss := s.try_take(1) {
				if !ss[0].is_digit() {
					break
				}
				s.add_pos(1)
			} else {
				break
			}
		}
		num_base := s.text.substr(start_pos, s.pos)
		if num_base.len != 0 && num_base[0] == `0` && !num_base.contains_any('89') {
			if num_base != '0' && s.is_strict {
				return error(octal_not_allowed)
			}
			ret_num = f64(strconv.parse_int(s.text.substr(start_pos, s.pos), 8, 0))
			break finally
		}
		if ss := s.try_take(1) {
			if ss == '.' {
				s.add_pos(1)
				for {
					if follow := s.try_take(1) {
						if !follow[0].is_digit() {
							break
						}
						s.add_pos(1)
					} else {
						break
					}
				}
			}
		}
		if ss := s.try_take(1) {
			if ss == 'e' {
				s.add_pos(1)
				if prefix := s.try_take(1) {
					if prefix in ['+', '-'] {
						s.add_pos(1)
					}
				}
				mut had_number := false
				for {
					if follow := s.try_take(1) {
						if !follow[0].is_digit() {
							break
						}
						s.add_pos(1)
						had_number = true
					} else {
						break
					}
				}
				if !had_number {
					return error(unexpected_token)
				}
			}
		}
		ret_num = s.text.substr(start_pos, s.pos).f64()
	}
	if follow := s.try_take(1) {
		if is_id_start(follow) {
			return error(unexpected_token)
		}
	}
	return Token{
		kind: ret_num,
		position: s.get_location(start_lpos, s.get_position())
	}
}

fn (mut s Scanner) scan_ident() ?Token {
	mut name := ''
	start_lpos := s.get_position()
	if s.text.at(s.pos) == '\\' {
		s.add_pos(1)
		if ss := s.try_take(1) {
			if ss != 'u' {
				return error(unexpected_token)
			}
			s.add_pos(1)
			if follow := s.try_take(1) {
				if follow == '{' {
					mut has_hex := false
					mut code := ''
					for {
						if hex := s.try_take(1) {
							if hex == '}' {
								if !has_hex {
									return error(invalid_unicode)
								}
								s.add_pos(1)
								break
							}
							has_hex = true
							if !hex[0].is_hex_digit() {
								return error(invalid_unicode)
							}
							code += hex
							s.add_pos(1)
						} else {
							return error(invalid_unicode)
						}
					}
					name += utf32_to_str(u32(strconv.parse_int(code, 16, 0)))
				} else {
					if code := s.try_take(4) {
						if !code[0].is_hex_digit() || !code[1].is_hex_digit()
						|| !code[2].is_hex_digit() || !code[3].is_hex_digit() {
							return error(invalid_unicode)
						}
						name += utf32_to_str(u32(strconv.parse_int(code, 16, 0)))
					} else {
						return error(invalid_unicode)
					}
				}
			} else {
				return error(invalid_unicode)
			}
		} else {
			return error(unexpected_token)
		}
	} else {
		name += s.text.at(s.pos)
		s.add_pos(1)
	}
	for {
		if id := s.try_take(1) {
			if id == '\\' {
				s.add_pos(1)
				if ss := s.try_take(1) {
					if ss != 'u' {
						return error(unexpected_token)
					}
					s.add_pos(1)
					if follow := s.try_take(1) {
						if follow == '{' {
							mut has_hex := false
							mut code := ''
							for {
								if hex := s.try_take(1) {
									if hex == '}' {
										if !has_hex {
											return error(invalid_unicode)
										}
										s.add_pos(1)
										break
									}
									has_hex = true
									if !hex[0].is_hex_digit() {
										return error(invalid_unicode)
									}
									code += hex
									s.add_pos(1)
								} else {
									return error(invalid_unicode)
								}
							}
							name += utf32_to_str(u32(strconv.parse_int(code, 16, 0)))
						} else {
							if code := s.try_take(4) {
								if !code[0].is_hex_digit() || !code[1].is_hex_digit()
								|| !code[2].is_hex_digit() || !code[3].is_hex_digit() {
									return error(invalid_unicode)
								}
								name += utf32_to_str(u32(strconv.parse_int(code, 16, 0)))
							} else {
								return error(invalid_unicode)
							}
						}
					} else {
						return error(invalid_unicode)
					}
				} else {
					return error(unexpected_token)
				}
			} else if !is_id_continue(id) {
				if name in keyword_list_word {
					return Token {
						kind: keyword_to_enum[name],
						position: s.get_location(start_lpos, s.get_position())
					}
				}
				return Token{
					kind: Identifier{name: name},
					position: s.get_location(start_lpos, s.get_position())
				}
			}
			name += id
			s.add_pos(1)
		} else {
			if name in keyword_list_word {
				return Token {
					kind: keyword_to_enum[name],
					position: s.get_location(start_lpos, s.get_position())
				}
			}
			return Token{
				kind: Identifier{name: name},
				position: s.get_location(start_lpos, s.get_position())
			}
		}
	}
	return error(unexpected_token)
}

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
			if ss := s.try_take(2) {
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
			return s.scan_regexp()
		}
	}
	// Float like .1
	if s.text.at(s.pos) == '.' {
		if ss := s.try_take(2) {
			if ss[1].is_digit() {
				return s.scan_digit()
			}
		}
	}
	// Puncts
	if ss := s.try_take(4) {
		if ss == '>>>=' {
			start := s.get_position()
			s.add_pos(4)
			return Token{
				kind: Keyword.assign_shr,
				position: s.get_location(start, s.get_position())
			}
		}
	}
	if ss := s.try_take(3) {
		if ss in keyword_list_3 {
			start := s.get_position()
			s.add_pos(3)
			return Token{
				kind: keyword_to_enum[ss],
				position: s.get_location(start, s.get_position())
			}
		}
	}
	if ss := s.try_take(2) {
		if ss in keyword_list_2 {
			start := s.get_position()
			s.add_pos(2)
			return Token{
				kind: keyword_to_enum[ss],
				position: s.get_location(start, s.get_position())
			}
		}
	}
	if ss := s.try_take(1) {
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
	if s.text.at(s.pos) in ['"', "'"] {
		return s.scan_string(s.text.at(s.pos))
	}
	// Number
	if s.text.at(s.pos)[0].is_digit() {
		return s.scan_digit()
	}
	// Identifier
	if is_id_start(s.text.at(s.pos)) || s.text.at(s.pos) == '\\' {
		return s.scan_ident()
	}

	return error(unexpected_token)
}
