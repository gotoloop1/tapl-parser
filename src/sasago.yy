
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
%token <std::string> VAR
%token <std::string> PREFIX INFIX1 INFIX2
%token SEP LPAR RPAR

%type <json11::Json> factor factor_s s_factor_s term term_s expr_1 expr_2 expr

%start input

%%

input
	: expr {
		json.push_back($1);
	}
expr
	: expr_2 {
		$$ = $1;
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
	: term {
		$$ = $1;
	}
	| expr_1 INFIX1 term {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
term_s
	: factor_s {
		$$ = $1;
	}
	| term_s factor_s {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| term s_factor_s {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
term
	: term_s {
		$$ = $1;
	}
	| factor {
		$$ = $1;
	}
  | term_s factor {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
s_factor_s
	: LPAR expr RPAR {
		$$ = $2;
	}
factor_s
	: s_factor_s {
		$$ = $1;
	}
	| factor SEP {
		$$ = $1;
	}
	| PREFIX factor_s {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| SEP factor_s {
		$$ = $2;
	}
	| factor_s SEP {
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
	| VAR {
		$$ = Json::object{
			{"rule", "variable"},
			{"value", $1}
		};
	}
	| PREFIX factor {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| SEP factor {
		$$ = $2;
	}

%%

namespace sasago {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
