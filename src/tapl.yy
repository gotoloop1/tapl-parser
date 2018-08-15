
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
%token ZERO
%token <std::string> PREFIX

%type <json11::Json> factor
%type <json11::Json> prefix
%type <json11::Json> term
%type <json11::Json> expr expr_s s_expr_s

%start input

%%

input
	: s_expr_s {
		json.push_back($1);
	}
s_expr_s
	: expr_s {
		$$ = $1;
	}
	| SEP s_expr_s {
		$$ = $2;
	}
expr_s
	: expr {
		$$ = $1;
	}
	| expr_s SEP {
		$$ = $1;
	}
expr
	: term {
		$$ = $1;
	}
	| IF SEP term SEP THEN SEP term SEP ELSE SEP term {
		$$ = Json::object{
			{"rule", "if"},
			{"cond", $3},
			{"true", $7},
			{"false", $11}
		};
	}
term
	: prefix {
		$$ = $1;
	}
prefix
	: factor {
		$$ = $1;
	}
	| PREFIX SEP prefix {
		$$ = Json::object{
			{"rule", $1},
			{"arg", $3}
		};
	}
factor
	: LPAR s_expr_s RPAR {
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
	| ZERO {
		$$ = Json::object{
			{"rule", "constant"},
			{"type", "int"},
			{"value", "0"}
		};
	}

%%

namespace tapl {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
