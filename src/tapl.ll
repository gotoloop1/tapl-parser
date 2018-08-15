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
: {
  return Parser::token::COLON;
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
[[:lower:]][[:alnum:]_]* {
  lval.build<std::string>(YYText());
  return Parser::token::VAR;
}
[[:upper:]][[:alnum:]_]* {
  lval.build<std::string>(YYText());
  return Parser::token::TYPE;
}

%%

int yylex(tapl::Parser::semantic_type* lval, Lexer& lexer) {
	return lexer.yylex(*lval);
}
