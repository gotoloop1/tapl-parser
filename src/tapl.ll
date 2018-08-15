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
[[:lower:]][[:alnum:]_]* {
  lval.build<std::string>(YYText());
  return Parser::token::VAR;
}
\\ {
  return Parser::token::LAMBDA;
}
-> {
  return Parser::token::ARROW;
}

%%

int yylex(tapl::Parser::semantic_type* lval, Lexer& lexer) {
	return lexer.yylex(*lval);
}
