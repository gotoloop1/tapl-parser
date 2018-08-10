
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

%token TRUE FALSE
%token IF THEN ELSE
%token SEP LPAR RPAR

%type <json11::Json> factor
%type <json11::Json> if if_s
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
term
	: if_s {
		$$ = $1;
	}
	| SEP term {
		$$ = $2;
	}
if_s
	: if {
		$$ = $1;
	}
	| if_s SEP {
		$$ = $1;
	}
if
	: factor {
		$$ = $1;
	}
	| IF SEP factor SEP THEN SEP factor SEP ELSE SEP factor {
		$$ = Json::object{
			{"rule", "if"},
			{"cond", $3},
			{"true", $7},
			{"false", $11}
		};
	}
factor
	: LPAR expr RPAR {
		$$ = $2;
	}
	| TRUE {
		$$ = Json::object{
			{"rule", "constant"},
			{"type", "bool"},
			{"value", "true"}
		};
	}
	| FALSE {
		$$ = Json::object{
			{"rule", "constant"},
			{"type", "bool"},
			{"value", "false"}
		};
	}

%%

namespace tapl {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
