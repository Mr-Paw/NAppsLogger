//
//  File.swift
//  
//
//  Created by mr paw on 20.01.2022.
//

import Foundation

extension FileManager {
  /// Finds the URL for the newest file in a directory
  /// - Parameter directory: The URL of the directory to search in
  /// - Returns: The URL of the newest file, or `nil` if the directory was empty or not found
  public func newestFile(_ directory: URL) -> URL? {
    let logFiles = files(in: directory)

    if logFiles.isEmpty {
      return nil
    }

    var newestFile: URL?
    var newestDate = Date.distantPast

    for file in logFiles {
      if let creation = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate {
        if newestDate < creation {
          newestFile = file
          newestDate = creation
        }
      }
    }
    return newestFile
  }

  /// Finds the URL for the oldest file in a directory
  /// - Parameter directory: The URL of the directory to search in
  /// - Returns: The URL of the newest file, or `nil` if the directory was empty or not found
  public func oldestFile(_ directory: URL) -> URL? {
    let logFiles = files(in: directory)

    if logFiles.isEmpty {
      return nil
    }

    var oldestFile: URL?
    var oldestDate = Date.distantFuture

    for file in logFiles {
      if let creation = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate {
        if oldestDate > creation {
          oldestFile = file
          oldestDate = creation
        }
      }
    }
    return oldestFile
  }

  /// A list of file URLs contained inside a directory
  /// - Parameter directory: The URL of the directory to search in
  /// - Returns: The URL of the newest file, or `nil` if the directory was empty or not found
  public func files(in directory: URL) -> [URL] {
    if let fileURLs = try? contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: [.isRegularFileKey, .creationDateKey],
      options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
    ) {
      return fileURLs
    }
    return []
  }

  func makeUniqueFilename(_ url: URL) -> URL {
    let origPath = url.deletingLastPathComponent().path
    let origExtension = url.pathExtension
    let origFilename = url.filenameWithoutExtension()

    var duplicateCount = 0
    var tempFileURL = url

    while fileExists(atPath: tempFileURL.path) {
      duplicateCount += 1

      tempFileURL = URL(fileURLWithPath: origPath)
        .appendingPathComponent("\(origFilename)_\(duplicateCount).\(origExtension)")
    }

    return tempFileURL
  }

  /// Get a temporary directory for all support versions
  internal var tempDirectory: URL {
    if #available(iOS 10.0, macOS 10.12, macCatalyst 13.0, tvOS 10.0, watchOS 3.0, *) {
      return FileManager.default.temporaryDirectory
    } else {
      // Fallback on earlier versions
      return URL(fileURLWithPath: NSTemporaryDirectory())
    }
  }

}
