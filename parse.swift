
protocol Expression {
  //func eval(context: Context)
}

extension Token {
  func toExpression() -> Expression {
    switch self.token {
    case .left: return MovePointer(by: -1)
    case .right: return MovePointer(by: 1)
    case .increase: return IncrementCell(by: 1)
    case .decrease: return IncrementCell(by: -1)
    //case .functionDeclaration: return FunctionDeclaration()
    case .functionCall(let num): return FunctionCall(num)
    default: return Unimplemented()
    }
  }

  func isLoopCondition() -> Bool {
    switch self.token {
    case .positive, .negative,
         .equals, .notEquals: return true
    default: return false
    }
  }

  func asLoopCondition() -> LoopingCondition? {
    switch self.token {
      case .positive: return .positive
      case .negative: return .negative
      case .equals: return .equalZero
      case .notEquals: return .notEqualZero
      default: return nil
    }
  }
}

struct Unimplemented: Expression {

}

enum LoopingCondition {
  case positive, negative, equalZero, notEqualZero
}

struct MovePointer: Expression {
  let amount: Int

  init(by amount: Int) {
    self.amount = amount
  }
}

struct IncrementCell: Expression {
  let amount: Int

  init(by amount: Int) {
    self.amount = amount
  }
}

//struct FunctionDeclaration: Expression {}

struct Function: Expression {
  let id: Int
  let block: Block

  init(_ id: Int, doing block: Block) {
    self.id = id
    self.block = block
  }
}

struct FunctionCall: Expression {
  let id: Int

  init(_ id: Int) {
    self.id = id
  }
}

struct Block: Expression {
  private var expressions: [Expression]

  init() {
    self.expressions = [Expression]()
  }

  mutating func add(expression: Expression) {
    self.expressions.append(expression)
  }
}

struct Loop: Expression {
  let condition: LoopingCondition
  let block: Block

  init(doing block: Block, when condition: LoopingCondition) {
    self.block = block
    self.condition = condition
  }
}

func parse(tokens: [Token]) -> [Expression]? {
  var expressions = [Expression]()
  var loopStack = [(Token, block: Block)]()

  var tokenIterator = tokens.makeIterator()

  while let token = tokenIterator.next() {
    print("Parsing: \(token)")
    // Function parsing
    if case .functionDeclaration = token.token {
      var block = Block()
      var valid = false
      guard let idToken = tokenIterator.next() else {
        print("ERROR: Function declared without identifier - line: \(token.line) char: \(token.char)")
        return nil
      }
      guard case .functionCall(let id) = idToken.token else {
        print("ERROR: Function declared without a valid identifier - line: \(token.line) char: \(token.char)")
        return nil
      }
      while let token = tokenIterator.next() {
        print("Parsing: \(token)")
        guard RawToken.functionDeclaration != token.token else {
          print("ERROR: Function declarations not allowed within a function - line \(token.line) char: \(token.char)")
          return nil
        }
        if case .functionEnd = token.token {
          expressions.append(Function(id, doing: block))
          valid = true
          break
        }
        block.add(expression: token.toExpression())
      }
      guard valid else {
        print("ERROR: File ended before end of function declared - line \(token.line) char: \(token.char)")
        return nil
      }
      continue
    }

    // Loop Parsing
    if case .loop = token.token {
      loopStack.append((token, block: Block()))
      while let token = tokenIterator.next(), loopStack.count > 0 {
        if case .loop = token.token {
          loopStack.append((token, block: Block()))
          continue
        }
        if let condition = token.asLoopCondition() {
          guard let loop = loopStack.popLast() else {
            print("ERROR: Loop conditional token found without starting loop token - line: \(token.line) char: \(token.char)")
            return nil
          }
          let loopExpr = Loop(doing: loop.block, when: condition)
          if var loop = loopStack.popLast() {
            loop.block.add(expression: loopExpr)
            loopStack.append(loop)
          }
          else {
            expressions.append(loopExpr)
            break
          }
        }
        else {
          guard var loop = loopStack.popLast() else {
            print("ERROR: This should never happen but it did... Sorry m8 :-) - line: \(token.line) char: \(token.char)")
            return nil
          }
          loop.block.add(expression: token.toExpression())
          loopStack.append(loop)
        }
      }
      guard loopStack.count == 0 else {
        print("ERROR: File ended before end of loop declared - line \(token.line) char: \(token.char)")
        return nil
      }
      continue
    }

    guard token.isLoopCondition() else {
      print("ERROR: Loop conditional token found without starting loop token - line: \(token.line) char: \(token.char)")
      return nil
    }
    guard token.token != .functionEnd else {
      print("ERROR: Function end token found without function declaration token - line: \(token.line) char: \(token.char)")
      return nil
    }

    // Everything else
    expressions.append(token.toExpression())
  }

  if let loopToken = loopStack.popLast() {
    print("ERROR: Loop token found without matching conditional token - line: \(loopToken.0.line) char: \(loopToken.0.char)")
  }
  return expressions
}
