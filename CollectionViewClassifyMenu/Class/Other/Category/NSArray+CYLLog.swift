//
//  NSArray+CYLLog.swift
//
//
//  Created by CHENYI LONG on 14-8-10.
//  Copyright (c) 2014年 (year 2014) CHENYI LONG. All rights reserved.
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import Foundation

extension NSArray {

    /**
     * A readable description for logs: the count, then one element per line, with non-ASCII text as is.
     */
    @objc(cyl_descriptionWithLocale:)
    open func cyl_description(withLocale locale: Any!) -> String! {
        var description = "\(count) (\n"
        for element in self {
            description += "\t\(element),\n"
        }
        description += ")"
        return description
    }
}
