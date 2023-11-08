//
// Created by Aaron on 2018-10-04.
// Copyright (c) 2018 Aaron. All rights reserved.
//

import Foundation

final class PuncMap {
    static var puncMap_Ch: [Int: String] {
        return ConfigManager.shared.puncKeyboardStyle == kPuncKeyboardStyleFake9 ? puncDicT9 : puncDicNormal
    }

    static var puncMap_En: [Int: String] {
        return ConfigManager.shared.puncKeyboardStyle == kPuncKeyboardStyleFake9 ? puncDicT9_En : puncDicNormal_En
    }

    private static var puncDicNormal_En: [Int: String] {
        var map: [Int: String] = [:]
        switch keyboardLayout {
        case .key9: map = puncDicNormal
        case .qwerty:
            map = [
                100: "-", 101: "!", 102: "%", 103: ":", 104: "3", 105: ";",
                106: "(", 107: ")", 108: "8", 109: "$", 110: "&", 111: "@",
                112: "\"", 113: ".", 114: "9", 115: "0", 116: "1", 117: "4",
                118: "/", 119: "5", 120: "7", 121: "?", 122: "2",
                123: ",", 124: "6", 125: "#", 3: "Whoops",
            ]
        }
        return map
    }

    private static var puncDicT9_En: [Int: String] {
        var map: [Int: String] = [:]
        switch keyboardLayout {
        case .key9: map = puncDicNormal
        case .qwerty:
            map = [
                100: "-", 101: "3", 102: "1", 103: ":", 104: ")", 105: "4",
                106: "5", 107: "6", 108: "!", 109: "$", 110: "&", 111: "@",
                112: "\"", 113: ".", 114: "%", 115: "?", 116: ";", 117: "7",
                118: "/", 119: "8", 120: "0", 121: "2", 122: "(",
                123: ",", 124: "9", 125: "#", 127: ";", 3: "Whoops",
            ]
        }
        return map
    }

    private static var puncDicNormal: [Int: String] {
        var map: [Int: String] = [:]
        switch keyboardLayout {
        case .key9:
            map = [
                202: "2", 203: "3", 204: "4", 205: "5", 206: "6", 207: "7", 208: "8", 209: "9", 201: "1", 299: "0",
            ]
        case .qwerty:
            map = [
                100: "-", 101: "！", 102: "、", 103: "：", 104: "3", 105: "；",
                106: "(", 107: ")", 108: "8", 109: "$", 110: "&", 111: "@",
                112: "\"", 113: ".", 114: "9", 115: "0", 116: "1", 117: "4",
                118: "/", 119: "5", 120: "7", 121: "？", 122: "2",
                123: "，", 124: "6", 125: "。", 3: "Whoops",
            ]
        }
        return map
    }

    private static var puncDicT9: [Int: String] {
        var map: [Int: String] = [:]
        switch keyboardLayout {
        case .key9: map = puncDicNormal
        case .qwerty:
            map = [
                100: "-", 101: "3", 102: "1", 103: "：", 104: ")", 105: "4",
                106: "5", 107: "6", 108: "！", 109: "$", 110: "&", 111: "@",
                112: "\"", 113: ".", 114: "、", 115: "？", 116: "；", 117: "7",
                118: "/", 119: "8", 120: "0", 121: "2", 122: "(",
                123: "，", 124: "9", 125: "。", 127: ";", 3: "Whoops",
            ]
        }
        return map
    }
}
