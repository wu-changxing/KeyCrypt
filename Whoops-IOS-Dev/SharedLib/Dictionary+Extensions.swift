//
//  Dictionary+Extensions.swift
//  Whoops
//
//  Created by Aaron on 8/14/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Foundation
extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key, value) in self {
            output += "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}
