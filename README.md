第11章のパーサ

#例
## \a : (\A -> B) -> a
[
  {
    "arg": {
      "body": {
        "rule": "variable",
        "value": "a"
      },
      "rule": "annotation",
      "type": {
        "arg": {
          "rule": "primitive",
          "value": "A"
        },
        "body": {
          "rule": "primitive",
          "value": "B"
        },
        "rule": "lambda"
      }
    },
    "body": {
      "rule": "variable",
      "value": "a"
    },
    "rule": "lambda"
  }
]
