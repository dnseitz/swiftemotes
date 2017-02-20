
import Foundation

class Frame {
  private(set) var tape: [Int]
  private(set) var current: Int
  var memory: Int
  var retReg: Int

  var currentCell: Int {
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

  func recycle() {
    // Not implemented yet...
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
  var functions: [Int: Function]
  var currentFrame: Frame {
    return self.frames.last!
  }

  init() {
    self.frames = [Frame(initialValue: 0)]
    self.functions = [:]
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

  func register(function fn: Function) {
    if self.functions[fn.id] != nil {
      self.error("Function \(fn.id) already registered!")
    }
    else {
      self.functions[fn.id] = fn
    }
  }

  func call(id: Int) {
    if let fn = self.functions[id] {
      fn.block.eval(context: self)
    }
    else {
      self.error("Function \(id) not registered!")
    }
  }

  func error(_ string: String) {
    print("ERROR: \(string)")
  }

}
