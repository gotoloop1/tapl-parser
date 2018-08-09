#include "sasago.yacc.hpp"
#include "lexer.hpp"
#include "json11.hpp"
#include <iostream>

int main(int argn, char* args[]) {
  Lexer lexer;
  json11::Json::array json;
  sasago::Parser parser(lexer, json);
  int res = parser.parse();
  if(res == 0) {
    std::cout << json11::Json(json).dump() << std::endl;
  }
  else {
    std::cout << "parser error" << std::endl;
  }
  return res;
}
