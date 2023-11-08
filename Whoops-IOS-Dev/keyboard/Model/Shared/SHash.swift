//
//  SHash.swift
//  LoginputKeyboard
//
//  Created by Aaron on 4/22/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import Foundation
final class shash {
    private static let HSTART: Int64 = 1_349_303_770_470_715_811
    private static let HMULT: Int64 = 7_664_345_821_815_920_749
    private static let byteTable: [Int64] = createLookupTable()
    private static func createLookupTable() -> [Int64] {
        var byteTable = [Int64](repeating: 0, count: 256)
        var h: Int64 = 0x544B_2FBA_CAAF_1684
        for i in 0 ..< 256 {
            for _ in 0 ..< 31 {
                h = (h >> 7) ^ h
                h = (h << 11) ^ h
                h = (h >> 10) ^ h
            }
            byteTable[i] = h
        }
        return byteTable
    }

    static func hash64(_ s: String) -> Int64 {
        var h = HSTART
        let hmult = HMULT
        let ht = byteTable
        for char in s {
            let c = char.asciiValue
            h = (h &* hmult) ^ ht[c & 0xFF]
            h = (h &* hmult) ^ ht[(c >> 8) & 0xFF]
        }
        return h
    }
}

extension Character {
    var asciiValue: Int {
        let s = String(self).unicodeScalars
        return Int(s[s.startIndex].value)
    }
}
