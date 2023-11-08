//
//  GB18030.swift
//  LMDB Test
//
//  Created by R0uter on 5/5/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import Foundation

extension String.Encoding {
    static let gb18030 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
}

extension String {
    func encode() -> Data {
        self.data(using: .gb18030) ?? Data()
    }
}

let SEP = "_".encode()
typealias GBString = Data
extension GBString {
    var UInt8: UInt8 {
        var number: UInt8 = 0
        self.copyBytes(to: &number, count: MemoryLayout<UInt8>.size)
        return number
    }

    func decode() -> String {
        String(data: self, encoding: .gb18030) ?? ""
    }

    func splitedGBString() -> [GBString] {
        var result: [GBString] = []
        var lastIndex = 0
        for i in 1..<self.count {
            if self[i] == SEP[0], (i - lastIndex)%2 == 0 {
                result.append(self[lastIndex..<i])
                lastIndex = i + 1
            }
        }
        result.append(self[lastIndex..<self.endIndex])
        
        return result
    }

    mutating func appendGBString(another s: GBString) {
        guard !s.isEmpty else {return}
        self.append(SEP)
        self.append(s)
    }
}
extension Array where Element == GBString {
    func joinWith(sep:String) -> String {
        let s = sep.encode()
        var d = GBString()
        for data in self.joined(separator: s) {
            d.append(data)
        }
        return d.decode()
    }
}
extension Database {
    func getString(for key: String) -> GBString? {
        if let data = try? self.get(type: Data.self, forKey: key.encode()) {
            return data
        }
        return nil
    }

    func getDouble(for key: GBString) -> Double? {
        return try? self.get(type: Double.self, forKey: key)
    }
}
