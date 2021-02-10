module main

//import ast
import token

fn main() {
	mut hoge := token.Scanner {
		text: '  \n /* */\r\n '.ustring()
	}
	tok := hoge.scan_once()?
	println(tok)
}
