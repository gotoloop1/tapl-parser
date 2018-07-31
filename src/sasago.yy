
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
%token CR

%type <json11::Json> factor expr

%left ADD

%start input

%%

input
	:
  | input line
line
	: CR
  | expr CR {
		json.push_back($1);
	}
expr
	: factor {
		$$ = $1;
	}
  | expr ADD expr {
		$$ = Json::object{
			{"rule", "apply"},
			{"func", Json::object{
				{"rule", "apply"},
				{"func", "add"},
				{"arg", $1}
			}},
			{"arg", $3}
		};
	}
factor
	: INT {
		$$ = Json::object{
			{"rule", "constant"},
			{"type", "int"},
			{"value", $1}
		};
	}

%%

namespace sasago {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
