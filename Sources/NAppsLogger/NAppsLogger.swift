import Foundation

public class NLogger {
    let loggingQueue = DispatchQueue(label: "ru.napps.logger.queue")
    
    /// A collection of `NLogWriter` s. `NLogger` use them to write log messages. Defaulst are `[ConsoleLogWriter()]`
    public var writers: [NLogWriter] = []
    
    /// `NLogger` can write only only specific log types if you want. Default is `.all`, logs all levels. You can change it at anytime you want
    public var levels: NLogger.LogType = .all
    
    /// Indicates whether `NLogger` is enabled. Returns `true` if `NLogger` log level isn't `.none`
    public var enabled: Bool {
      return levels != .none
    }
    
    /// Sends a message to `writers` and they write this message to console (`ConsoleLogWriter`)/ log file on disk(`FileLogWriter`)/ write to somewhere else(if you create your own custom log writer)
    public func send(_ message: Any, type: NLogger.LogType, date: Date = Date(), queue: String = DispatchQueue.currentLabel, thread: String = Thread.currentName, file: String = #file, function: String = #function, line: Int = #line
      ) {
        guard canSendAMessageWithLogType(type) else {
            return
        }
        for i in writers {
            let formattedPrefix = format(prefix: i.prefix, level: type, date: date, queue: queue, thread: thread, file: file, function: function, line: line)
            let message = "\(formattedPrefix) \(message)"
            i.executor.execute {
                i.write(message)
            }
        }
    }
    
    /// Formats message prefix (log info)
    public func format(prefix: LogPrefix, level: LogType, date: Date, queue: String, thread: String, file: String, function: String, line: Int) -> String {
      var prefixString = "[]"
      if prefix == .none {
        return prefixString
      }
      if prefix.contains(.level) {
        prefixString = "\(level.description) "
      }
      if prefix.contains(.date) {
        prefixString = "\(prefixString)\(DateFormatter.iso8601.string(from: date)) "
      }
      if prefix.contains(.queue) || prefix.contains(.thread) {
        prefixString = "\(prefixString)(\(queue)#\(thread)) "
      }
      if prefix.contains(.file) || prefix.contains(.function) || prefix.contains(.line) {
        prefixString = "\(prefixString){\(file.absolutePathFilename).\(function)#\(line)} "
      }
      return "[\(prefixString.trimmingCharacters(in: CharacterSet(arrayLiteral: " ")))]"
    }
    
    /// Checks if `NLogger` can log messages of a certain type
    public func canSendAMessageWithLogType(_ logType: NLogger.LogType) -> Bool {
        levels.contains(logType) && enabled
    }
    
    /// Log Types. You should pass a type in `send(_ message: Any, type: NLogger.LogType, date: Date = Date(), queue: String = DispatchQueue.currentLabel, thread: String = Thread.currentName, file: String = #file, function: String = #function, line: Int = #line)` when logging
    public struct LogType: OptionSet, Equatable, Hashable {
        public let rawValue: UInt32
        
        /// 'no-log' type. `NLogger` can't log mesages if its `levels` property is `.none`. Don't use this type to log messages
        public static let none = LogType([])
        
        /// Debug log type. Use this type to log messages that help you debugging your code
        public static let debug = LogType(rawValue: 1 << 0)
        
        /// Info log type. Use this type to log addictional information
        public static let info = LogType(rawValue: 1 << 1)
        
        /// Log type for events. Use this type to log your events
        public static let event = LogType(rawValue: 1 << 2)
        
        /// Warning log type. Use this type to log warnings in your code
        public static let warn = LogType(rawValue: 1 << 3)
        
        /// Error log type. Use this type to log errors
        public static let error = LogType(rawValue: 1 << 4)
        
        /// Log type for `NAppsLogger` module events. Don't use this type in your code
        public static let log = LogType(rawValue: 1 << 31)
        
        /// Contains all log types. Don't use this type to log messages
        public static let all = LogType(rawValue: UInt32.max)
        
        /// `LogType` can be initialized with `UInt32` `rawValue`
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    
    public init(levels: NLogger.LogType = .all, writers: [NLogWriter] = [ConsoleLogWriter()]) {
      self.writers = writers
      self.levels = levels
    }
}

extension NLogger.LogType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .event:
            return "EVENT"
        case .warn:
            return "WARNING"
        case .error:
            return "ERROR"
        case .log:
            return "LOG EVENT"
        case .all:
            return "ALL"
        default:
            return "CUSTOM"
        }
    }
}

