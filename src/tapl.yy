
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

%token <std::string> VAR TYPE
%token SEP LPAR RPAR
%token ARROW LAMBDA COLON
%token TRUE FALSE
%token IF THEN ELSE
%token ZERO
%token <std::string> PREFIX

%type <json11::Json> type_factor s_type_factor s_type_factor_s type_lambda type type_s
%type <json11::Json> declare declare_s s_declare_s
%type <json11::Json> factor
%type <json11::Json> prefix
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
	| IF term THEN term ELSE term {
		$$ = Json::object{
			{"rule", "if"},
			{"cond", $2},
			{"true", $4},
			{"false", $6}
		};
	}
	| SEP IF term THEN term ELSE term {
		$$ = Json::object{
			{"rule", "if"},
			{"cond", $3},
			{"true", $5},
			{"false", $7}
		};
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
	| PREFIX SEP prefix {
		$$ = Json::object{
			{"rule", $1},
			{"arg", $3}
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
	| declare_s COLON type {
		$$ = Json::object{
			{"rule", "annotation"},
			{"type", $3},
			{"value", $1}
		};
	}
type_s
	: type {
		$$ = $1;
	}
	| type_s SEP {
		$$ = $1;
	}
type
	: type_lambda {
		$$ = $1;
	}
type_lambda
	: s_type_factor {
		$$ = $1;
	}
	| LAMBDA s_type_factor_s ARROW type_lambda {
		$$ = Json::object{
			{"rule", "lambda"},
			{"arg", $2},
			{"body", $4}
		};
	}
	| SEP LAMBDA s_type_factor_s ARROW type_lambda {
		$$ = Json::object{
			{"rule", "lambda"},
			{"arg", $3},
			{"body", $5}
		};
	}
s_type_factor_s
	: s_type_factor {
		$$ = $1;
	}
	| s_type_factor_s SEP {
		$$ = $1;
	}
s_type_factor
	: type_factor {
		$$ = $1;
	}
	| SEP s_type_factor {
		$$ = $2;
	}
type_factor
	: LPAR type_s RPAR {
		$$ = $2;
	}
	| TYPE {
		$$ = Json::object{
			{"rule", "primitive"},
			{"value", $1}
		};
	}

%%

namespace tapl {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
