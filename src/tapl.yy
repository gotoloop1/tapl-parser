
%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define parse.error verbose
%define api.value.type variant
%define api.namespace {tapl}

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
int yylex(tapl::Parser::semantic_type* lval, Lexer& lexer);
using namespace json11;
}

%token <std::string> VAR
%token SEP LPAR RPAR
%token ARROW LAMBDA

%type <json11::Json> declare declare_s s_declare_s
%type <json11::Json> factor
%type <json11::Json> apply apply_s
%type <json11::Json> term
%type <json11::Json> expr

%start input

%%

input
	: expr {
		json.push_back($1);
	}
expr
	: term {
		$$ = $1;
	}
	| LAMBDA s_declare_s ARROW expr {
		$$ = Json::object{
			{"rule", "lambda"},
			{"arg", $2},
			{"body", $4}
		};
	}
	| SEP LAMBDA s_declare_s ARROW expr {
		$$ = Json::object{
			{"rule", "lambda"},
			{"arg", $3},
			{"body", $5}
		};
	}
term
	: apply {
		$$ = $1;
	}
	| SEP term {
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
	| factor {
		$$ = $1;
	}
  | apply_s factor {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
factor
	: LPAR expr RPAR {
		$$ = $2;
	}
	| VAR {
		$$ = Json::object{
			{"rule", "variable"},
			{"value", $1}
		};
	}
s_declare_s
	: declare_s {
		$$ = $1;
	}
	| SEP s_declare_s {
		$$ = $2;
	}
declare_s
	: declare {
		$$ = $1;
	}
	| declare_s SEP {
		$$ = $1;
	}
declare
	: VAR {
		$$ = Json::object{
			{"rule", "variable"},
			{"value", $1}
		};
	}

%%

namespace tapl {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
