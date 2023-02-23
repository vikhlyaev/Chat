import OSLog

extension Logger {    
    func calledInfo(_ methodName: String = #function) {
      info("Called method: \(methodName)")
    }
}
