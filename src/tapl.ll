%option c++
%option yyclass="Lexer"
%option noyywrap

%{
#include "tapl.yacc.hpp"
#include "lexer.hpp"
#include <iostream>

using namespace tapl;

#undef YY_DECL
#define YY_DECL int Lexer::yylex(Parser::semantic_type& lval)
%}

%%

[[:space:]]+ {
  return Parser::token::SEP;
}
\( {
  return Parser::token::LPAR;
}
\) {
  return Parser::token::RPAR;
}
\\ {
  return Parser::token::LAMBDA;
}
-> {
  return Parser::token::ARROW;
}
=> {
  return Parser::token::FARROW;
}
: {
  return Parser::token::COLON;
}
;; {
  return Parser::token::SS;
}
; {
  return Parser::token::SEMIC;
}
= {
  return Parser::token::EQ;
}
\. {
  return Parser::token::DOT;
}
\{ {
  return Parser::token::LBRA;
}
\} {
  return Parser::token::RBRA;
}
, {
  return Parser::token::COMMA;
}
\< {
  return Parser::token::LANG;
}
\> {
  return Parser::token::RANG;
}
\| {
  return Parser::token::PIPE;
}
true {
  return Parser::token::TRUE;
}
false {
  return Parser::token::FALSE;
}
if {
  return Parser::token::IF;
}
then {
  return Parser::token::THEN;
}
else {
  return Parser::token::ELSE;
}
0 {
  return Parser::token::ZERO;
}
unit {
  return Parser::token::UNIT;
}
as {
  return Parser::token::AS;
}
let {
  return Parser::token::LET;
}
in {
  return Parser::token::IN;
}
type {
  return Parser::token::TYPE;
}
case {
  return Parser::token::CASE;
}
of {
  return Parser::token::OF;
}
succ {
  lval.build<std::string>(YYText());
  return Parser::token::PREFIX;
}
pred {
  lval.build<std::string>(YYText());
  return Parser::token::PREFIX;
}
iszero {
  lval.build<std::string>(YYText());
  return Parser::token::PREFIX;
}
fix {
  lval.build<std::string>(YYText());
  return Parser::token::PREFIX;
}
[[:lower:]_][[:alnum:]_]* {
  lval.build<std::string>(YYText());
  return Parser::token::VAR;
}
[[:upper:]][[:alnum:]_]* {
  lval.build<std::string>(YYText());
  return Parser::token::TNAME;
}

%%

int yylex(tapl::Parser::semantic_type* lval, Lexer& lexer) {
	return lexer.yylex(*lval);
}
