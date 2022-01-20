//
//  File.swift
//  
//
//  Created by mr paw on 20.01.2022.
//

import Foundation

extension DateFormatter {
    /// Returns a string representation of the current `date` formatted using the receiver’s current settings.
    public var currentDateString: String {
        return string(from: Date())
    }
    
    /// DateFormatter class that generates and parses string representations of dates following the ISO 8601 standard
    public static let iso8601: DateFormatter = {
        let iso8601DateFormatter = DateFormatter()
        
        iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        iso8601DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return iso8601DateFormatter
    }()
    
    static let iso8601_noMilliseconds: DateFormatter = {
        let iso8601DateFormatter = DateFormatter()
        
        iso8601DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        iso8601DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        iso8601DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return iso8601DateFormatter
    }()
}


extension String {
    var absolutePathFilename: String {
        var pathComponents = components(separatedBy: "/")
        let filename = pathComponents.removeLast().components(separatedBy: ".")
        if !filename.isEmpty {
            return filename[0]
        }
        return self
    }
}
