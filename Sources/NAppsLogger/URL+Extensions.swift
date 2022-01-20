//
//  File.swift
//  
//
//  Created by mr paw on 20.01.2022.
//

import Foundation

// NOTE: Still currently in beta for macOS https://developer.apple.com/documentation/uniformtypeidentifiers/
#if canImport(UniformTypeIdentifiers)
  import UniformTypeIdentifiers
#endif

#if os(iOS) || os(watchOS) || os(tvOS)
  import MobileCoreServices
#elseif os(macOS)
  import CoreServices
#endif

public extension URL {
  /// Appends a news query items to an existing URL
  /// - parameters:
  ///   - queryItems: The `URLQueryItem` collection to append
  /// - returns: A new URL with the provided query items or nil if the appending failed
  func appending(queryItems: [URLQueryItem]) -> URL? {
    var urlComponents = URLComponents(string: absoluteString)

    if urlComponents?.queryItems != nil {
      urlComponents?.queryItems?.merge(queryItems)
    } else {
      urlComponents?.queryItems = queryItems
    }

    return urlComponents?.url
  }

  /// The size of the file found at the URL
  ///
  /// Will return a value of 0 if the file cannot be found
  var sizeOf: Int {
    if let fileResources = try? resourceValues(forKeys: [.fileSizeKey]),
      let fileSize = fileResources.fileSize {
      return fileSize
    }
    return 0
  }

  /// The content of the URL if one exists
  var contentType: String {
    #if canImport(UniformTypeIdentifiers)
      if #available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, *) {
        // swiftlint:disable:next line_length
        guard let contentType = try? self.resourceValues(forKeys: [.contentTypeKey]).contentType?.preferredMIMEType else {
          return "application/octet-stream"
        }

        return contentType
      }

      return preferenceIdentifier()
    #else
      return preferenceIdentifier()
    #endif
  }

  private func preferenceIdentifier() -> String {
    let fileExtension = UTTypeCreatePreferredIdentifierForTag(
      kUTTagClassFilenameExtension, pathExtension as CFString, nil
    )

    if let fileExt = fileExtension?.takeRetainedValue(),
      let mimeType = UTTypeCopyPreferredTagWithClass(fileExt, kUTTagClassMIMEType)?.takeRetainedValue() {
      return mimeType as String
    }
    return "application/octet-stream"
  }

  internal func filenameWithoutExtension() -> String {
    // Default to last path if either path or extension are empty
    if pathExtension.isEmpty || lastPathComponent.isEmpty {
      return lastPathComponent
    }

    // pathExtension.count + 1 represents the extension and the assumed '.' seperator
    return String(lastPathComponent.prefix(lastPathComponent.count - (pathExtension.count + 1)))
  }
}

public extension Array where Element == URLQueryItem {
  /// Returns new list of query items replaces any existing
  func merging(_ other: [URLQueryItem]) -> [URLQueryItem] {
    var queryItems = self

    queryItems.merge(other)

    return queryItems
  }

  /// Merges list of query items replaces any existing
  mutating func merge(_ other: [URLQueryItem]) {
    for query in other {
      if let index = firstIndex(of: query.name) {
        replaceSubrange(index ... index, with: [query])
      } else {
        append(query)
      }
    }
  }

  /// Returns the first index whose name matches the parameter
  func firstIndex(of name: String) -> Int? {
    return firstIndex { $0.name == name }
  }

  /// Creates a new query item and appends only if the value is not nil
  mutating func appendIfPresent(name: String, value: String?) {
    if let value = value {
      append(URLQueryItem(name: name, value: value))
    }
  }
}
