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

[[:space:]]+ {
  return Parser::token::SEP;
}
\( {
  return Parser::token::LPAR;
}
\) {
  return Parser::token::RPAR;
}
-?[0-9]+ {
  lval.build<int>(std::stoi(YYText()));
  return Parser::token::INT;
}
[\?!~][!%&\*\+-\./<=>\?@\^\|~]* {
  lval.build<std::string>(YYText());
  return Parser::token::PREFIX;
}
[\*/%][!%&\*\+-\./<=>\?@\^\|~]* {
  lval.build<std::string>(YYText());
  return Parser::token::INFIX1;
}
[\+-][!%&\*\+-\./<=>\?@\^\|~]* {
  lval.build<std::string>(YYText());
  return Parser::token::INFIX2;
}
[\^:@][!%&\*\+-\./<=>\?@\^\|~]* {
  lval.build<std::string>(YYText());
  return Parser::token::INFIX3;
}
[<=>][!%&\*\+-\./<=>\?@\^\|~]* {
  lval.build<std::string>(YYText());
  return Parser::token::INFIX4;
}
&[!%&\*\+-\./<=>\?@\^\|~]* {
  lval.build<std::string>(YYText());
  return Parser::token::INFIX5;
}
\|[!%&\*\+-\./<=>\?@\^\|~]* {
  lval.build<std::string>(YYText());
  return Parser::token::INFIX6;
}

%%

int yylex(sasago::Parser::semantic_type* lval, Lexer& lexer) {
	return lexer.yylex(*lval);
}
