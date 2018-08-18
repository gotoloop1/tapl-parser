
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

%token <std::string> VAR TNAME
%token SEP LPAR RPAR LBRA RBRA LANG RANG
%token ARROW FARROW LAMBDA COLON EQ DOT COMMA PIPE
%token TRUE FALSE
%token IF THEN ELSE
%token ZERO
%token <std::string> PREFIX
%token UNIT SEMIC SS
%token AS LET IN TYPE DEF CASE OF

%type <json11::Json> s_var s_var_s
%type <json11::Json> type_factor s_type_factor s_type_factor_s
%type <json11::Json> type_lambda type_lambda_s
%type <json11::Json::array> type_record_body type_variant_body
%type <json11::Json> type_record type_variant
%type <json11::Json> type type_s
%type <json11::Json> declare declare_s s_declare_s
%type <json11::Json> factor proj
%type <json11::Json> prefix
%type <json11::Json> apply apply_s
%type <json11::Json> term
%type <json11::Json> expr stat let
%type <json11::Json::array> record_body case_body
%type <json11::Json> record
%type <json11::Json> type_def def
%type <json11::Json> top

%start input

%%

input
	: top {
		json.push_back($1);
	}
	| input SS top {
		json.push_back($3);
	}
	| input SS {}
	| input SS SEP {}
top
	: let {
		$$ = $1;
	}
	| type_def {
		$$ = $1;
	}
	| def {
		$$ = $1;
	}
def
	: s_def s_declare_s EQ let {
		$$ = Json::object{
			{"rule", "def"},
			{"var", $2},
			{"content", $4}
		};
	}
type_def
	: s_type_def SEP TNAME s_eq type_s {
		$$ = Json::object{
			{"rule", "typedef"},
			{"name", $3},
			{"type", $5}
		};
	}
case_body
	:	s_lang s_var s_eq s_var_s rang_s FARROW stat {
		$$ = Json::array{
			Json::object{
				{"label", $2},
				{"var", $4},
				{"content", $7}
			}
		};
	}
	| case_body PIPE s_lang s_var s_eq s_var_s rang_s FARROW stat {
		$1.push_back(
			Json::object{
				{"label", $4},
				{"var", $6},
				{"content", $9}
			}
		);
		$$ = $1;
	}
record
	: LBRA record_body RBRA {
		$$ = Json::object{
			{"rule", "record"},
			{"body", $2}
		};
	}
	| LBRA RBRA {
		$$ = Json::object{
			{"rule", "record"},
			{"body", Json::array{}}
		};
	}
	| LBRA SEP RBRA {
		$$ = Json::object{
			{"rule", "record"},
			{"body", Json::array{}}
		};
	}
record_body
	: s_var s_eq let {
		$$ = Json::array{
			Json::object{
				{"label", $1},
				{"content", $3}
			}
		};
	}
	| record_body COMMA s_var s_eq let {
		$1.push_back(
			Json::object{
				{"label", $3},
				{"content", $5}
			}
		);
		$$ = $1;
	}
let
	: expr {
		$$ = $1;
	}
	| s_let s_declare_s EQ let IN let {
		$$ = Json::object{
			{"rule", "let"},
			{"var", $2},
			{"content", $4},
			{"body", $6}
		};
	}
expr
	: stat {
		$$ = $1;
	}
	| s_if let THEN let ELSE let {
		$$ = Json::object{
			{"rule", "if"},
			{"cond", $2},
			{"true", $4},
			{"false", $6}
		};
	}
	| s_lambda s_declare_s ARROW let {
		$$ = Json::object{
			{"rule", "lambda"},
			{"arg", $2},
			{"body", $4}
		};
	}
	| term AS type_s {
		$$ = Json::object{
			{"rule", "ascrive"},
			{"type", $3},
			{"body", $1}
		};
	}
	| s_lang s_var s_eq let rang_s {
		$$ = Json::object{
			{"rule", "variant"},
			{"label", $2},
			{"content", $4}
		};
	}
	| s_case let OF case_body {
		$$ = Json::object{
			{"rule", "case"},
			{"content", $2},
			{"body", $4}
		};
	}
stat
	: term {
		$$ = $1;
	}
	| stat SEMIC term {
		$$ = Json::object{
			{"rule", "sequent"},
			{"former", $1},
			{"latter", $3}
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
	: proj {
		$$ = $1;
	}
	| PREFIX SEP prefix {
		$$ = Json::object{
			{"rule", $1},
			{"arg", $3}
		};
	}
proj
	: factor {
		$$ = $1;
	}
	| proj DOT VAR {
		$$ = Json::object{
			{"rule", "projrcd"},
			{"var", $1},
			{"label", $3}
		};
	}
factor
	: LPAR let RPAR {
		$$ = $2;
	}
	| record {
		$$ = $1;
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
			{"type", "Bool"},
			{"value", "true"}
		};
	}
	| FALSE {
		$$ = Json::object{
			{"rule", "constant"},
			{"type", "Bool"},
			{"value", "false"}
		};
	}
	| ZERO {
		$$ = Json::object{
			{"rule", "constant"},
			{"type", "Nat"},
			{"value", "0"}
		};
	}
	| UNIT {
		$$ = Json::object{
			{"rule", "constant"},
			{"type", "Unit"},
			{"value", "unit"}
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
			{"body", $1}
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
type_variant
	: LANG type_variant_body RANG {
		$$ = Json::object{
			{"rule", "variant"},
			{"body", $2}
		};
	}
	| LANG RANG {
		$$ = Json::object{
			{"rule", "variant"},
			{"body", Json::array{}}
		};
	}
	| LANG SEP RANG {
		$$ = Json::object{
			{"rule", "variant"},
			{"body", Json::array{}}
		};
	}
type_variant_body
	: s_var s_colon type_lambda_s {
		$$ = Json::array{
			Json::object{
				{"label", $1},
				{"type", $3}
			}
		};
	}
	| type_variant_body COMMA s_var s_colon type_lambda_s {
		$1.push_back(
			Json::object{
				{"label", $3},
				{"type", $5}
			}
		);
		$$ = $1;
	}
type_record
	: LBRA type_record_body RBRA {
		$$ = Json::object{
			{"rule", "record"},
			{"body", $2}
		};
	}
	| LBRA RBRA {
		$$ = Json::object{
			{"rule", "record"},
			{"body", Json::array{}}
		};
	}
	| LBRA SEP RBRA {
		$$ = Json::object{
			{"rule", "record"},
			{"body", Json::array{}}
		};
	}
type_record_body
	: s_var s_colon type_lambda_s {
		$$ = Json::array{
			Json::object{
				{"label", $1},
				{"type", $3}
			}
		};
	}
	| type_record_body COMMA s_var s_colon type_lambda_s {
		$1.push_back(
			Json::object{
				{"label", $3},
				{"type", $5}
			}
		);
		$$ = $1;
	}
type_lambda_s
	: type_lambda {
		$$ = $1;
	}
	| type_lambda_s SEP {
		$$ = $1;
	}
type_lambda
	: s_type_factor {
		$$ = $1;
	}
	| s_lambda s_type_factor_s ARROW type_lambda {
		$$ = Json::object{
			{"rule", "lambda"},
			{"arg", $2},
			{"body", $4}
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
	| type_variant {
		$$ = $1;
	}
	| type_record {
		$$ = $1;
	}
	| TNAME {
		$$ = Json::object{
			{"rule", "primitive"},
			{"value", $1}
		};
	}
s_if
	: IF {}
	| SEP s_if {}
s_let
	: LET {}
	| SEP s_let {}
s_lambda
	: LAMBDA {}
	| SEP s_lambda {}
s_eq
	: EQ {}
	| SEP s_eq {}
s_colon
	: COLON {}
	| SEP s_colon {}
s_lang
	: LANG {}
	| SEP s_lang {}
rang_s
	: RANG {}
	| rang_s SEP {}
s_case
	: CASE {}
	| SEP s_case {}
s_var_s
	: s_var {
		$$ = $1;
	}
	| s_var_s SEP {
		$$ = $1;
	}
s_var
	: VAR {
		$$ = $1;
	}
	| SEP s_var {
		$$ = $2;
	}
s_type_def
	: TYPE {}
	| SEP s_type_def {}
s_def
	: DEF {}
	| SEP s_def {}

%%

namespace tapl {
  void Parser::error(const std::string& message) {
    std::cerr << message << std::endl;
  }
}
