//
//  StringExtension.swift
//  LogInput
//
//  Created by Aaron on 2017/2/14.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import LoginputEngineLib
import UIKit
let key17map: [Character: String] = [
    "h": "hp", "s": "sh", "z": "zh", "b": "b", "x": "x", "m": "sm",
    "l": "l", "d": "d", "y": "y", "w": "wz", "j": "jk", "n": "rn",
    "c": "ch", "q": "q", "g": "g", "f": "cf", "t": "t",
]
extension String {
    var pinyinString: String? {
        guard !(KeyboardViewController.inputProxy?.zhInput?.isThinking ?? false) else { return nil }
        return applyingTransform(.mandarinToLatin, reverse: false)?.applyingTransform(.stripDiacritics, reverse: false)?.replacingOccurrences(of: " ", with: "'")
    }

    var slmHash: Int64 {
        return shash.hash64(self)
    }

    func getCorrections4En() -> [String] {
        UITextChecker().guesses(forWordRange: NSRange(0 ..< utf16.count),
                                in: self,
                                language: "en_US") ?? []
    }

    func getCompletions4En() -> [String] {
        UITextChecker().completions(
            forPartialWordRange: NSRange(0 ..< utf16.count),
            in: self,
            language: "en_US"
        ) ?? []
    }

    func tokenize(_ flag: CFOptionFlags = kCFStringTokenizerUnitWordBoundary) -> [String] {
        let inputRange = CFRangeMake(0, utf16.count)
        let flag = UInt(flag)
        let l = CFStringTokenizerCopyBestStringLanguage(self as CFString, CFRange(location: 0, length: utf16.count)) ?? ("zh_Hans_CN" as CFString)
        let locale = Locale(identifier: l as String) // CFLocaleCopyCurrent()
        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, self as CFString, inputRange, flag, locale as CFLocale)
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        var tokens: [String] = []

        while !tokenType.isEmpty {
            let currentTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let substring = substringWithRange(aRange: currentTokenRange)
            tokens.append(substring)
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }

        return tokens
    }

    func substringWithRange(aRange: CFRange) -> String {
        let nsrange = NSMakeRange(aRange.location, aRange.length)
        let substring = (self as NSString).substring(with: nsrange)
        return substring
    }

    func stringWithBufferStyle() -> String {
        let containingCaps = range(of: "[A-Z]", options: .regularExpression) != nil

        if keyboardLayout == .key9 { // 九宫格无法兼容各种候选风格
            if let r = KeyboardViewController.inputProxy?.candidates.first?.table.pinyinString {
                return r
            } else {
                return self
            }
        }

        switch ConfigManager.shared.bufferDisplayMode {
        case 0: return self

        case 1 where ConfigManager.shared.quanPin && !containingCaps: return LoginputEngineLib.shared.segment_loss(from: self).joined(separator: "'")

        case 2 where !containingCaps:
            var str = ""
            for (index, c) in enumerated() {
                if index > 0, index % 2 == 0 { str.append("'") }
                str.append(c)
            }
            return str
        default: break
        }
        return self
    }

    func stringWithDateMacro() -> String {
        var table = self

        let formatStr = "%y|%Y|%m|%d|%I|%H|%M|%S|%w"
        guard let r = Date().formattedTime(format: formatStr) else { return self }
        let list = r.components(separatedBy: "|")
        let list_no_0 = r.replacingOccurrences(of: "|0", with: "|").components(separatedBy: "|")

        table = table.replacingOccurrences(of: "##", with: "{-#-}")
        table = table.replacingOccurrences(of: "#yyyy", with: list[1])
        table = table.replacingOccurrences(of: "#yy", with: list[0])
        table = table.replacingOccurrences(of: "#MM", with: list[2])
        table = table.replacingOccurrences(of: "#dd", with: list[3])
        table = table.replacingOccurrences(of: "#M", with: list_no_0[2])
        table = table.replacingOccurrences(of: "#date", with: "\(list[1])年\(list_no_0[2])月\(list_no_0[3])日")
        table = table.replacingOccurrences(of: "#d", with: list_no_0[3])
        table = table.replacingOccurrences(of: "#time", with: "\(list_no_0[5]):\(list_no_0[6])")
        table = table.replacingOccurrences(of: "#hh", with: list[4])
        table = table.replacingOccurrences(of: "#HH", with: list[5])
        table = table.replacingOccurrences(of: "#mm", with: list[6])
        table = table.replacingOccurrences(of: "#ss", with: list[7])
        table = table.replacingOccurrences(of: "#h", with: list_no_0[4])
        table = table.replacingOccurrences(of: "#H", with: list_no_0[5])
        table = table.replacingOccurrences(of: "#m", with: list_no_0[6])
        table = table.replacingOccurrences(of: "#s", with: list_no_0[7])
        table = table.replacingOccurrences(of: "#E", with: toChinese(day: Int(list[8])!))
        table = table.replacingOccurrences(of: "#e", with: "\(list[8])")
        table = table.replacingOccurrences(of: "{-#-}", with: "#")
        return table
    }
}

extension String {
    func contains(char element: Character) -> Bool {
        return range(of: String(element)) != nil
    }

    func contains(char element: String) -> Bool {
        return range(of: element) != nil
    }
}

extension String {
    func size(of font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [.font: font])
    }
}
