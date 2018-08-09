
%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define parse.error verbose
%define api.value.type variant
%define api.namespace {sasago}

%code requires {
#include <iostream>
#include "json11.hpp"
class Lexer;
}

%define parser_class_name {Parser}
%parse-param {Lexer& lexer} {json11::Json::array& json}
%lex-param {Lexer& lexer}

%code {
#include "lexer.hpp"
int yylex(sasago::Parser::semantic_type* lval, Lexer& lexer);
using namespace json11;
}

%token <int> INT
%token <std::string> PREFIX INFIX1 INFIX2 INFIX3 INFIX4 INFIX5 INFIX6
%token SEP LPAR RPAR

%type <json11::Json> factor expr_p expr_0 expr_1 expr_2 expr_3 expr_4 expr_5 expr_6 expr

%start input

%%

input
	: expr {
		json.push_back($1);
	}

expr
	: expr_6 {
		$$ = $1;
	}
expr_6
	: expr_5 {
		$$ = $1;
	}
	| expr_6 INFIX6 expr_5 {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
expr_5
	: expr_4 {
		$$ = $1;
	}
	| expr_5 INFIX5 expr_4 {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
expr_4
	: expr_3 {
		$$ = $1;
	}
	| expr_4 INFIX4 expr_3 {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
expr_3
	: expr_2 {
		$$ = $1;
	}
	| expr_3 INFIX3 expr_2 {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
expr_2
	: expr_1 {
		$$ = $1;
	}
	| expr_2 INFIX2 expr_1 {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
expr_1
	: expr_0 {
		$$ = $1;
	}
	| expr_1 INFIX1 expr_0 {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
expr_0
	: expr_p {
		$$ = $1;
	}
  | expr_0 expr_p {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
expr_p
	: factor {
		$$ = $1;
	}
	| PREFIX expr_p {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| SEP expr_p {
		$$ = $2;
	}
	| expr_p SEP {
		$$ = $1;
	}
factor
	: INT {
		$$ = Json::object{
			{"rule", "constant"},
			{"type", "int"},
			{"value", $1}
		};
	}
	| LPAR expr RPAR {
		$$ = $2;
	}

%%

namespace sasago {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
