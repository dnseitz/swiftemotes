
import Foundation

class Frame {
  private(set) var tape: [Int]
  private(set) var current: Int
  private(set) var memory: Int
  fileprivate var retReg: Int

  private(set) var currentCell: Int {
    get {
      self.lazyUpdateBounds()
      return self.tape[self.current]
    }
    set {
      self.lazyUpdateBounds()
      self.tape[self.current] = newValue
    }
  }

  init(initialValue value: Int) {
    self.tape = [value]
    self.current = 0
    self.memory = 0
    self.retReg = 0
  }

  func movePointer(by value: Int) {
    self.current += value
    assert(self.current >= 0)
  }

  func incrementCell(by value: Int) {
    self.currentCell += value
  }

  func swap() {
    let temp = self.memory
    self.memory = self.currentCell
    self.currentCell = temp
  }

  func flush() {
    self.tape = []
    self.current = 0
    self.memory = 0
    self.retReg = 0
  }

  func ret() {
    self.current = 0
  }

  func random() {
    self.currentCell = Int(arc4random_uniform(100))
  }

  func printNum() {
    print("\(self.currentCell)")
  }

  func printChar() {
    print(Character(UnicodeScalar(self.currentCell)!))
  }

  func newline() {
    print("")
  }

  func sleep() {
    usleep(UInt32(self.currentCell * 100000))
  }

  func pause() {
    // Not implemented yet...
  }

  func recycle() {
    // Not implemented yet...
  }

  // Yeah... that's what it's called in the specs...
  func write() {
    self.memory = self.currentCell
  }

  func read(value: Int) {
    self.currentCell = self.memory
  }

  private func lazyUpdateBounds() {
    // There's got to be a better way to do this...
    while self.current >= self.tape.count {
      self.tape.append(0)
    }
  }
}

class Context {
  private(set) var frames: [Frame]
  var functions: [Function]
  var currentFrame: Frame {
    return self.frames.last!
  }

  init() {
    self.frames = [Frame(initialValue: 0)]
    self.functions = []
  }

  func pushFrame() {
    let currentValue = self.currentFrame.currentCell
    self.frames.append(Frame(initialValue: currentValue))
  }

  func popFrame() {
    let retValue = self.currentFrame.currentCell
    let _ = self.frames.popLast()
    self.currentFrame.retReg = retValue
  }
}
