//
//  File.swift
//  
//
//  Created by mr paw on 11.01.2022.
//

import Foundation

public struct ConsoleLogWriter: NLogWriter {
  public var sendToNSLog: Bool
  public var executor: LogExecutable
  public var prefix: LogPrefix

  public init(
    sendToNSLog: Bool = false,
    prefix: LogPrefix = .all,
    executor: LogExecutionType = .sync(lock: NSRecursiveLock())
  ) {
    self.sendToNSLog = sendToNSLog
    self.prefix = prefix
    self.executor = executor
  }

  public func write(_ message: String) {
    if sendToNSLog {
      NSLog("%@", message)
    } else {
      print(message)
    }
  }
}


open class FileLogWriter: NLogWriter {

  internal static var logger = NLogger()
  public var executor: LogExecutable
  public var prefix: LogPrefix

  /// The maximum size of each log file
  public var maxFileSize: Int64 = 1024 * 1024 * 20
  /// The maximum number of log files before files start to be replaced
  public var maxLogFiles = 5
  /// The directory URL where log files will be stored
  public var directoryURL: URL

  /// The current log file
  var currentFile: URL?

  public required init(
    logDirectory: URL,
    executor: LogExecutionType = .sync(lock: NSRecursiveLock()),
    prefix: LogPrefix = .all
  ) {
    directoryURL = logDirectory
    self.executor = executor
    self.prefix = prefix
    Self.logger.writers = [ConsoleLogWriter()]
  }

  /// Attempts to create a `LogFileWriter` at the specified directory location
  ///
  /// - parameters:
  ///   - inside: The base location of the parent directory
  ///   - at: The file system location where logs will be stored
  ///   - name: The name of the directory inside the parent directory
  ///   - prefix: Prefix formatting options
  ///   - executor: The executor of this log writer
  public convenience init(
    inside domain: FileManager.SearchPathDomainMask = .userDomainMask,
    at directory: FileManager.SearchPathDirectory = .cachesDirectory,
    with name: String = "napps_logger",
    executor: LogExecutionType = .sync(lock: NSRecursiveLock()),
    prefix: LogPrefix = .all
  ) {
    do {
      guard let parentDir = FileManager.default.urls(for: directory, in: domain).first else {
        Self.logger.send("Error: Nothing found at the intersection of the domain and parent directory", type: .log)
        preconditionFailure("Nothing found at the intersection of the domain and parent directory")
      }
      let logDir = parentDir.appendingPathComponent(name, isDirectory: true)
      try FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true, attributes: nil)

      Self.logger.send("File log writer will output logs to: `\(logDir)`", type: .log)

      self.init(logDirectory: logDir, executor: executor, prefix: prefix)
    } catch {
      Self.logger.send("Error: Could not create logging files at location provided due to \(error)", type: .log)
      preconditionFailure("Could not create logging files at location provided due to \(error)")
    }
  }

  public func write(_ message: String) {
    // If we have a cached URL then we should use it otherwise create a new file
    currentFile = createOrUpdateFile(with: "\(message)\n")

    // Ensure that the max number of log files hasn't been reached
    if FileManager.default.files(in: directoryURL).count > maxLogFiles {
      if let oldest = FileManager.default.oldestFile(directoryURL) {
        delete(oldest)
      }
    }
  }

  public func createOrUpdateFile(with contents: String) -> URL? {
    // Update a file if it exists
    // and if the file + message size is less than maxFileSize

    if let file = currentFile,
      FileManager.default.fileExists(atPath: file.path),
      file.sizeOf + contents.utf8.count < maxFileSize {
      update(file, message: contents)
      return file
    }

    // Create a new file
    let fileURL = directoryURL.appendingPathComponent(logFilename, isDirectory: false)
    if !create(fileURL, with: contents) {
      Self.logger.send("Error: Failed to create log file at \(fileURL.absoluteString)", type: .log)
    } else {
      Self.logger.send("Created new log file at \(fileURL.absoluteString)", type: .log)
    }

    return fileURL
  }

  func create(_ file: URL, with contents: String) -> Bool {
    return FileManager.default.createFile(atPath: file.path,
                                          contents: contents.data(using: .utf8),
                                          attributes: nil)
  }

  public func update(_ file: URL, message: String) {
    if FileManager.default.fileExists(atPath: file.path),
      let stream = OutputStream(toFileAtPath: file.path, append: true),
      let messageData = message.data(using: .utf8) {
      let dataArray = [UInt8](messageData)
      stream.open()
      defer { stream.close() }
      // This might need to take a buffer pointer and not an array
      if stream.hasSpaceAvailable {
        let dataWritten = stream.write(dataArray, maxLength: dataArray.count)
        if dataWritten != dataArray.count {
          Self.logger.send("Error: Data remainig to be written", type: .log)
        }
      }
    }
  }

  var logFilename: String {
    return "\(Date().timeIntervalSince1970)-nappslogger.log"
  }

  public func delete(_ file: URL) {
    do {
      try FileManager.default.removeItem(at: file)
    } catch {
      Self.logger.send("Error: Could not delete file at \(file) due to: \(error)", type: .log)
    }
  }
}
