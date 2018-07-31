%option c++
%option yyclass="Lexer"
%option noyywrap

%{
#include "sasago.yacc.hpp"
#include "lexer.hpp"
#include <iostream>

using namespace sasago;

#undef YY_DECL
#define YY_DECL int Lexer::yylex(Parser::semantic_type& lval)
%}

%%

"+" {
  return Parser::token::ADD;
}
"\n" {
  return Parser::token::CR;
}
-?[0-9]+ {
  lval.build<int>(std::stoi(YYText()));
  return Parser::token::INT;
}

%%

int yylex(sasago::Parser::semantic_type* lval, Lexer& lexer) {
	return lexer.yylex(*lval);
}
