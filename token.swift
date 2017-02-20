
// Valid keywords are:
// > - Move pointer right
// < - Move pointer left
// ^ - Increase
// v - Decrease
// 0 - Reset
// W - Write
// R - Read
// @ - Function Return Value
// swap - Swap
// flush - Flush
// $ - Return to first index
// % - Random
// nprint - Print number
// cprint - Print character
// pause - Pause and wait for input
// \n - Print Newline
// sleep - Sleep for duration
// clear - Clear screen
// / - Comment begin/end
// loop - Begin Loop
// + - positive loop
// - - negative loop
// = - equals loop
// ! - not equals loop
// fn - declare function

enum RawToken {
  case right // >
  case left // <
  case increase // ^
  case decrease // v
  case reset // 0
  case write // W
  case read // R
  case returnValue // @
  case swap // S swap
  case flush // L flush
  case firstIndex // $
  case random // %
  case numPrint // , nprint
  case charPrint // . cprint
  case pause // P pause
  case newline // N
  case sleep // Z sleep
  case clear // C clear
  case comment // /
  case loop // ? loop
  case positive // +
  case negative // -
  case equals // =
  case notEquals // !
  case functionDeclaration // F fn
  case functionEnd
  case functionCall(Int)
}

extension RawToken {
  static func generate(from char: Character) -> RawToken? {
    switch char {
    case ">": return .right
    case "<": return .left
    case "^": return .increase
    case "v": return .decrease
    case "0": return .reset
    case "W": return .write
    case "R": return .read
    case "@": return .returnValue
    case "S": return .swap
    case "L": return .flush
    case "$": return .firstIndex
    case "%": return .random
    case ",": return .numPrint
    case ".": return .charPrint
    case "P": return .pause
    case "N": return .newline
    case "Z": return .sleep
    case "C": return .clear
    case "/": return .comment
    case "?": return .loop
    case "+": return .positive
    case "-": return .negative
    case "=": return .equals
    case "!": return .notEquals
    case "F": return .functionDeclaration
    case "E": return .functionEnd
    case "1": return .functionCall(1)
    case "2": return .functionCall(2)
    case "3": return .functionCall(3)
    case "4": return .functionCall(4)
    case "5": return .functionCall(5)
    case "6": return .functionCall(6)
    case "7": return .functionCall(7)
    case "8": return .functionCall(8)
    case "9": return .functionCall(9)
    default: return nil
    }
  }
}

extension RawToken: Equatable {
  static func ==(lhs: RawToken, rhs: RawToken) -> Bool {
    switch (lhs, rhs) {
      case (.right, .right): return true
      case (.left, .left): return true
      case (.increase, .increase): return true
      case (.decrease, .decrease): return true
      case (.reset, .reset): return true
      case (.write, .write): return true
      case (.read, .read): return true
      case (.returnValue, .returnValue): return true
      case (.swap, .swap): return true
      case (.flush, .flush): return true
      case (.firstIndex, .firstIndex): return true
      case (.random, .random): return true
      case (.numPrint, .numPrint): return true
      case (.charPrint, .charPrint): return true
      case (.pause, .pause): return true
      case (.newline, .newline): return true
      case (.sleep, .sleep): return true
      case (.clear, .clear): return true
      case (.comment, .comment): return true
      case (.loop, .loop): return true
      case (.positive, .positive): return true
      case (.negative, .negative): return true
      case (.equals, .equals): return true
      case (.notEquals, .notEquals): return true
      case (.functionDeclaration, .functionDeclaration): return true
      case (.functionEnd, .functionEnd): return true
      case (.functionCall(_), .functionCall(_)): return true
      default: return false
    }
  }
}

struct Token {
  let line: Int
  let char: Int
  let token: RawToken

  init(line: Int, char: Int, token: RawToken) {
    self.line = line
    self.char = char
    self.token = token
  }
}

extension Token {
  static func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.token == rhs.token
  }
}

func getTokens(string: String) -> [Token] {
  var lineNum = 1
  var charNum = 1
  var tokens = [Token]()
  var inComment = false

  for char in string.characters {
    if char == "\n" {
      lineNum += 1
      charNum = 0
      inComment = false
    }
    if let rawToken = RawToken.generate(from: char) {
      let token = Token(line: lineNum, char: charNum, token: rawToken)
      if case .comment = rawToken {
        inComment = !inComment
      }
      if !inComment {
        tokens.append(token)
      }
    }
    charNum += 1
  }

  return tokens
}
