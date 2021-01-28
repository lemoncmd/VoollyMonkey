module token

struct Scanner {
	buffer []Token
}

fn (s mut Scanner) skip_whitespace() {}

fn (s mut Scanner) scan_once() {}
