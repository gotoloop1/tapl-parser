
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

%type <json11::Json> factor s_factor_s
%type <json11::Json> prefix prefix_s s_prefix_s
%type <json11::Json> apply apply_s
%type <json11::Json> term
%type <json11::Json> infix_1 infix_2
%type <json11::Json> expr

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
	| apply_s {
		$$ = $1;
	}
	| SEP term {
		$$ = $2;
	}
apply_s
	: prefix_s {
		$$ = $1;
	}
	| s_prefix_s {
		$$ = $1;
	}
	| apply SEP {
		$$ = $1;
	}
	| apply s_prefix_s {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| apply_s prefix_s {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| apply_s s_prefix_s {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| apply_s SEP {
		$$ = $1;
	}
apply
	: prefix {
		$$ = $1;
	}
  | apply_s prefix {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", $1},
			{"arg", $2}
		};
	}
s_prefix_s
	: s_factor_s {
		$$ = $1;
	}
prefix_s
	: PREFIX s_prefix_s {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| PREFIX SEP s_prefix_s {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $3}
		};
	}
	| PREFIX prefix_s {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $2}
		};
	}
	| PREFIX SEP prefix_s {
		$$ = Json::object{
			{"rule", "prefix"},
			{"func", $1},
			{"arg", $3}
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
s_factor_s
	: LPAR expr RPAR {
		$$ = $2;
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

%%

namespace sasago {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
