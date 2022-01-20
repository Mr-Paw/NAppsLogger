//
//  File.swift
//  
//
//  Created by mr paw on 11.01.2022.
//

import Foundation

public protocol NLogWriter {
    var executor: LogExecutable { get }
    var prefix: LogPrefix { get }
    
    func write(_ message: String)
}

public protocol LogExecutable {
  func execute(log job: @escaping () -> Void)
}

public enum LogExecutionType: LogExecutable {
  case sync(lock: NSLocking)
  case async(queue: DispatchQueue)

  public func execute(log job: @escaping () -> Void) {
    switch self {
    case let .sync(lock):
      lock.synchronize(job)
    case let .async(queue):
      queue.async {
        job()
      }
    }
  }
}

public struct LogPrefix: OptionSet, Equatable, Hashable {
  public let rawValue: UInt32

  // Reserverd Prefix Types
  public static let none = LogPrefix([])
  public static let level = LogPrefix(rawValue: 1 << 0)
  public static let date = LogPrefix(rawValue: 1 << 1)
  public static let queue = LogPrefix(rawValue: 1 << 2)
  public static let thread = LogPrefix(rawValue: 1 << 3)
  public static let file = LogPrefix(rawValue: 1 << 4)
  public static let function = LogPrefix(rawValue: 1 << 5)
  public static let line = LogPrefix(rawValue: 1 << 6)
  public static let all = LogPrefix(rawValue: UInt32.max)

  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
}

extension NSLocking {
  @inline(__always)
  func synchronize(_ closure: () -> Void) {
    lock()
    defer { unlock() }
    return closure()
  }

  @discardableResult
  @inline(__always)
  func synchronize<T>(_ closure: () -> T) -> T {
    lock()
    defer { unlock() }
    return closure()
  }

  @discardableResult
  @inline(__always)
  func synchronize<T>(_ closure: () throws -> T) throws -> T {
    lock()
    defer { unlock() }
    let result = try closure()
    return result
  }
}
