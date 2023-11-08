//
//  String+Extension.swift
//  LoginputEngineLib
//
//  Created by R0uter on 5/19/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import Foundation
extension String {
    static func read(from path:String) ->String? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {return nil}
        var str:NSString?
        NSString.stringEncoding(for: data, encodingOptions: nil, convertedString: &str, usedLossyConversion: nil)
        return str as String?
    }
    /// 用数字切字符串 [0,count)
    ///
    /// - Parameters:
    ///   - from: 开始位置，最小为0
    ///   - to: 结束位置，最大为字符串长度
    /// - Returns: 返回新的字符串
    func subString(from:Int,to:Int) -> String {
        guard from < to && to <= self.count else {return ""}
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex ..< endIndex])
    }
    
    /// 从某位置开始直到字符串的末尾
    ///
    /// - Parameter from: 最小为0，最大不能超过字符串长度
    /// - Returns: 新的字符串
    func subString(from:Int) -> String {
        guard from < self.count else {return ""}
        let startIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[startIndex ..< self.endIndex])
    }
    
    
    /// 从头开始直到某位置停止，不包含索引位置(0,int),如果是负数则从后往前数n位
    ///
    /// - Parameter to: 要停止的位置，不包含这个位置
    /// - Returns: 新的字符串
    func subString(to:Int) -> String {
        guard abs(to) <= self.count else {return ""}
        if to < 0 {
            let endIndex = self.index(self.endIndex, offsetBy: to)
            return String(self[self.startIndex ..< endIndex])
        }
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex ..< endIndex])
    }
}
extension String {
    func contains(char element: Character) -> Bool {
        return self.range(of: String(element)) != nil
    }
    func contains(char element: String) -> Bool {
        return self.range(of: element) != nil
    }
}
