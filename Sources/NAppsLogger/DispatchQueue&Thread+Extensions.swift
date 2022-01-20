//
//  File.swift
//  
//
//  Created by mr paw on 20.01.2022.
//

import Foundation

extension DispatchQueue {
  /// The label of the current `DispatchQueue`
  /// or `"Unknown Queue"` if no label was set
  public static var currentLabel: String {
    return String(validatingUTF8: __dispatch_queue_get_label(nil)) ?? "Unknown Queue"
  }
}

public extension Thread {
  /// The name describing the current executing Thread
  static var currentName: String {
    if Thread.isMainThread {
      return "Main Thread"
    } else if let threadName = Thread.current.name, !threadName.isEmpty {
      return threadName
    } else {
      return String(format: "%p", Thread.current).uppercased()
    }
  }
}
