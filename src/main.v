module main

import ast
import token

fn main() {
	hoge := token.Scanner {
		text: '  \n /* */\r\n '.ustring()
	}
}
