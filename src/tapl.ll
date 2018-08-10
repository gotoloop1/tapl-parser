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

%%

int yylex(tapl::Parser::semantic_type* lval, Lexer& lexer) {
	return lexer.yylex(*lval);
}
