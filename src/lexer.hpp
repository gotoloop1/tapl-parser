#ifndef FLEX_SCANNER
#include <FlexLexer.h>
#endif

class Lexer : public yyFlexLexer {
public:
	int yylex(sasago::Parser::semantic_type& lval);
};
