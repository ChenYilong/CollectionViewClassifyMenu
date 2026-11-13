//
//  NSDictionary+CYLLog.swift
//
//
//  Created by CHENYI LONG on 14-8-10.
//  Copyright (c) 2014年 (year 2014) CHENYI LONG. All rights reserved.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import Foundation

extension NSDictionary {

    /**
     * The dictionary's description with `\u` escapes decoded, so non-ASCII text (Chinese) reads as text in logs.
     * Returns nil when the description cannot be decoded (the type keeps the Objective-C API's `String!`).
     */
    @objc(cyl_descriptionWithLocale:)
    open func cyl_description(withLocale locale: Any!) -> String! {
        let escaped = description
            .replacingOccurrences(of: "\\u", with: "\\U")
            .replacingOccurrences(of: "\"", with: "\\\"")
        guard let data = "\"\(escaped)\"".data(using: .utf8) else {
            return nil
        }
        return (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? String
    }
}
