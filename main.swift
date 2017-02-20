import Foundation

func main() {
  if CommandLine.arguments.count < 2 {
    print("USAGE: \(CommandLine.arguments[0]) <file_name>")
    return
  }

  let fileName = URL(fileURLWithPath: CommandLine.arguments[1])
  print(fileName)
  do {
    let contents = try Data(contentsOf: fileName)
    let stringContents = String(data: contents, encoding: .utf8)!
    let tokens = getTokens(string: stringContents)
    let expressions = parse(tokens: tokens)!
    for expr in expressions {
      debugPrint(expr)
    }
    let program = Program(expressions: expressions)
    program.run()
  }
  catch {
    print(error)
  }
}

main()
