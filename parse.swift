
import Foundation

protocol Expression {
  func eval(context: Context)
}

extension Token {
  func toExpression() -> Expression {
    switch self.token {
    case .left: return MovePointer(by: -1)
    case .right: return MovePointer(by: 1)
    case .increase: return IncrementCell(by: 1)
    case .decrease: return IncrementCell(by: -1)
    case .reset: return Reset()
    case .write: return Write()
    case .read: return Read()
    case .returnValue: return FunctionRead()
    case .swap: return Swap()
    case .flush: return Flush()
    case .firstIndex: return Return()
    case .random: return Random()
    case .numPrint: return PrintNumber()
    case .charPrint: return PrintCharacter()
    case .pause: return Pause()
    case .newline: return NewLine()
    case .sleep: return Sleep()
    case .clear: return Recycle()
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
  func eval(context: Context) {
    /* Do nothing */
  }
}

struct Reset: Expression {
  func eval(context: Context) {
    context.currentFrame.currentCell = 0
  }
}

struct Write: Expression {
  func eval(context: Context) {
    context.currentFrame.memory = context.currentFrame.currentCell
  }
}

struct Read: Expression {
  func eval(context: Context) {
    context.currentFrame.currentCell = context.currentFrame.memory
  }
}

struct FunctionRead: Expression {
  func eval(context: Context) {
    context.currentFrame.currentCell = context.currentFrame.retReg
  }
}

struct Swap: Expression {
  func eval(context: Context) {
    let temp = context.currentFrame.memory
    context.currentFrame.memory = context.currentFrame.currentCell
    context.currentFrame.currentCell = temp
  }
}

struct Flush: Expression {
  func eval(context: Context) {
    context.currentFrame.flush()
  }
}

struct Return: Expression {
  func eval(context: Context) {
    context.currentFrame.ret()
  }
}

struct Random: Expression {
  func eval(context: Context) {
    context.currentFrame.currentCell = Int(arc4random_uniform(100))
  }
}

struct PrintNumber: Expression {
  func eval(context: Context) {
    print(context.currentFrame.currentCell, terminator: "")
  }
}

struct PrintCharacter: Expression {
  func eval(context: Context) {
    print(Character(UnicodeScalar(context.currentFrame.currentCell)!))
  }
}

struct Pause: Expression {
  func eval(context: Context) {
    readLine()
  }
}

struct NewLine: Expression {
  func eval(context: Context) {
    print()
  }
}

struct Sleep: Expression {
  func eval(context: Context) {
    usleep(UInt32(context.currentFrame.currentCell * 100000))
  }
}

struct Recycle: Expression {
  func eval(context: Context) {
    // Not implemented yet...
  }
}

enum LoopingCondition {
  case positive, negative, equalZero, notEqualZero
}

extension LoopingCondition {
  func isMet(`for` value: Int) -> Bool {
    switch self {
    case .positive: return value > 0
    case .negative: return value < 0
    case .equalZero: return value == 0
    case .notEqualZero: return value != 0
    }
  }
}

struct MovePointer: Expression {
  let amount: Int

  init(by amount: Int) {
    self.amount = amount
  }

  func eval(context: Context) {
    context.currentFrame.movePointer(by: self.amount)
  }
}

struct IncrementCell: Expression {
  let amount: Int

  init(by amount: Int) {
    self.amount = amount
  }

  func eval(context: Context) {
    context.currentFrame.incrementCell(by: self.amount)
  }
}

struct Loop: Expression {
  let condition: LoopingCondition
  let block: Block

  init(doing block: Block, when condition: LoopingCondition) {
    self.block = block
    self.condition = condition
  }

  func eval(context: Context) {
    while !self.condition.isMet(for: context.currentFrame.currentCell) {
      self.block.eval(context: context)
    }
  }
}

struct Function: Expression {
  let id: Int
  let block: Block

  init(_ id: Int, doing block: Block) {
    self.id = id
    self.block = block
  }

  func eval(context: Context) {
    context.register(function: self)
  }
}

struct FunctionCall: Expression {
  let id: Int

  init(_ id: Int) {
    self.id = id
  }

  func eval(context: Context) {
    context.pushFrame()
    context.call(id: self.id)
    context.popFrame()
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

  func eval(context: Context) {
    for expr in self.expressions {
      expr.eval(context: context)
    }
  }
}

func parse(tokens: [Token]) -> [Expression]? {
  var expressions = [Expression]()
  var loopStack = [(Token, block: Block)]()

  var tokenIterator = tokens.makeIterator()

  while let token = tokenIterator.next() {
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

    guard !token.isLoopCondition() else {
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
