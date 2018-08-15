第5章ののパーサ

#例
## \a -> \b -> a b
{
  rule: "lambda",
  arg: "a",
  body: {
    rule: "lambda",
    arg: "b",
    body: {
      rule: "apply",
      func: {
        rule: "variable",
        value, "a"
      },
      arg: {
        rule: "variable",
        value, "b"
      }
    }
  }
}
