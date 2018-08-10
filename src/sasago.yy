
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

%type <json11::Json> factor
%type <json11::Json> prefix apply apply_s term
%type <json11::Json> infix_1 infix_2 expr

%start input

%%

input
	: expr {
		json.push_back($1);
	}
expr
	: infix_2 {
		$$ = $1;
	}
infix_2
	: infix_1 {
		$$ = $1;
	}
	| infix_2 INFIX2 infix_1 {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
infix_1
	: term {
		$$ = $1;
	}
	| infix_1 INFIX1 term {
		$$ = Json::object{
			{"rule", "infix"},
			{"func", $2},
			{"arg", Json::array{$1, $3}}
		};
	}
term
	: apply {
		$$ = $1;
	}
	| SEP apply {
		$$ = $2;
	}
apply_s
	: apply SEP {
		$$ = $1;
	}
apply
	: apply_s {
		$$ = $1;
	}
	| prefix {
		$$ = $1;
	}
  | apply_s prefix {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
prefix
	: factor {
		$$ = $1;
	}
	| PREFIX prefix {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| PREFIX SEP prefix {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $3}
		};
	}
factor
	: LPAR expr RPAR {
		$$ = $2;
	}
	| INT {
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

%%

namespace sasago {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
