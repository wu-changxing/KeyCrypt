//
//  ArrayExtension.swift
//  LoginputKeyboard
//
//  Created by Aaron on 3/3/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import Foundation
extension Array {
    /// 依次遍历数组中每个 CodeTable，并可对其进行修改
    mutating func forEach(_ process: (inout Element) -> Void) {
        for i in 0 ..< count {
            process(&self[i])
        }
    }
}

extension CodeTableArray {
    var description: String {
        return (map { $0.table }).joined(separator: "|")
    }
}
