#include "sasago.yacc.hpp"
#include "lexer.hpp"
#include "json11.hpp"
#include <iostream>

int main(int argn, char* args[]) {
  Lexer lexer;
  json11::Json::array json;
  sasago::Parser parser(lexer, json);
  int res = parser.parse();
  std::cout << "res: " << res << std::endl;
  std::cout << json11::Json(json).dump() << std::endl;
}
