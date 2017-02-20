
struct Program {
  let expressions: [Expression]

  init(expressions: [Expression]) {
    self.expressions = expressions
  }

  func run() {
    let context = Context()
    for expression in expressions {
      //expression.eval(context)
    }
  }
}
