第9章のパーサ

#例
## \a : (\A -> B) -> a
{
  "rule": "lambda",
  "arg": {
    "rule": "annotation",
    "type": {
      "rule": "lambda",
      "arg": {
        "rule": "primitive",
        "value": "A"
      },
      "body": {
        "rule": "primitive",
        "value": "B"
      }
    },
    "value": {
      "rule": "variable",
      "value": "a"
    }
  },
  "body": {
    "rule": "variable",
    "value": "a"
  }
}
