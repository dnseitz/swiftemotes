
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
  case right // > \u{1F449}
  case left // < \u{1F448}
  case increase // ^ \u{1F44D}
  case decrease // v \u{1F44E}
  case reset // 0 \u{1F4A9}
  case write // W \u{270D}
  case read // R \u{1F4D6}
  case returnValue // @ \u{1F300}
  case swap // S swap \u{1F503}
  case flush // L flush \u{1F4A6}
  case firstIndex // $ \u{1F51A}
  case random // % \u{1F3B2}
  case numPrint // , nprint \u{1F4AF}
  case charPrint // . cprint \u{1F4AC}
  case pause // P pause \u{270B}
  case newline // N \u{1F44C}
  case sleep // Z sleep \u{1F4A4}
  case clear // C clear \u{267B}
  case comment // / \u{1F47B}
  case loop // ? loop \u{1F517}
  case positive // + \u{2795}
  case negative // - \u{2796}
  case equals // = \u{2714}
  case notEquals // ! \u{2716}
  case functionDeclaration // F fn \u{1F4BE}
  case functionEnd // \u{1F44F}
  case functionCall(Int) // \u{1F601} - \u{1F637}
}

extension RawToken {
  static func generate(from char: Character) -> RawToken? {
    switch char {
    case ">", "\u{1F449}": return .right
    case "<", "\u{1F448}": return .left
    case "^", "\u{1F44D}": return .increase
    case "v", "\u{1F44E}": return .decrease
    case "0", "\u{1F4A9}": return .reset
    case "W", "\u{270D}": return .write
    case "R", "\u{1F4D6}": return .read
    case "@", "\u{1F300}": return .returnValue
    case "S", "\u{1F503}": return .swap
    case "L", "\u{1F4A6}": return .flush
    case "$", "\u{1F51A}": return .firstIndex
    case "%", "\u{1F3B2}": return .random
    case ",", "\u{1F4AF}": return .numPrint
    case ".", "\u{1F4AC}": return .charPrint
    case "P", "\u{270B}": return .pause
    case "N", "\u{1F44C}": return .newline
    case "Z", "\u{1F4A4}": return .sleep
    case "C", "\u{267B}": return .clear
    case "/", "\u{1F47B}": return .comment
    case "?", "\u{1F517}": return .loop
    case "+", "\u{2795}": return .positive
    case "-", "\u{2796}": return .negative
    case "=", "\u{2714}": return .equals
    case "!", "\u{2716}": return .notEquals
    case "F", "\u{1F4BE}": return .functionDeclaration
    case "E", "\u{1F44F}": return .functionEnd
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
