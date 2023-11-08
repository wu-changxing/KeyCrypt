//
//  DateExtension.swift
//  LoginputKeyboard
//
//  Created by Aaron on 3/29/20.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Foundation

extension Date {
    /*
      This source file is part of the Swift.org open source project
      Copyright 2015 - 2016 Apple Inc. and the Swift project authors
      Licensed under Apache License v2.0 with Runtime Library Exception
      See http://swift.org/LICENSE.txt for license information
      See http://swift.org/CONTRIBUTORS.txt for Swift project authors
     */
    func formattedTime(format: String) -> String? {
        let resultSize = format.count + 200
        var result = [Int8](repeating: 0, count: resultSize)
        var currentTime = time(nil)
        var time = localtime(&currentTime).pointee
        guard strftime(&result, resultSize, format, &time) != 0 else {
            return nil
        }
        return String(cString: result, encoding: .utf8)
    }
}
