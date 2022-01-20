import Foundation

public class NLogger {
    let loggingQueue = DispatchQueue(label: "ru.napps.logger.queue")
    
    public var writers: [NLogWriter] = []
    public var levels: NLogger.LogType = .all
    
    public var enabled: Bool {
      return levels != .none
    }
    
    public func send(_ message: Any, type: NLogger.LogType, date: Date = Date(), queue: String = DispatchQueue.currentLabel, thread: String = Thread.currentName, file: String = #file, function: String = #function, line: Int = #line
      ) {
        
    }
    
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
      return "[\(prefixString.trimmingCharacters(in: CharacterSet(arrayLiteral: " ")))] "
    }
    
    public func canSendAMessageWithLogType(_ logType: NLogger.LogType) -> Bool {
        levels.contains(logType)
    }
    
    public struct LogType: OptionSet, Equatable, Hashable {
        public let rawValue: UInt32
        
        // Reserverd Log Types
        public static let none = LogType([])
        public static let debug = LogType(rawValue: 1 << 0)
        public static let info = LogType(rawValue: 1 << 1)
        public static let event = LogType(rawValue: 1 << 2)
        public static let warn = LogType(rawValue: 1 << 3)
        public static let error = LogType(rawValue: 1 << 4)
        public static let log = LogType(rawValue: 1 << 31)
        public static let all = LogType(rawValue: UInt32.max)
        
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

