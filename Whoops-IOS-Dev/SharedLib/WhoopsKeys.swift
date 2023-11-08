//
//  WhoopsKeys.swift
//  Whoops
//
//  Created by Aaron on 7/14/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

let isNotGoodToGo = false // Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

enum Platform: String, CaseIterable {
    case weChat = "WeChat", weibo = "Weibo", apple = "Apple", qq = "QQ", telegram = "Telegram", whatsApp = "WhatsApp"
}

extension Platform {
    var readableName: String {
        switch self {
        case .weChat: return "微信"
        case .weibo: return "微博"
        case .qq: return "QQ"
        case .apple: return "苹果"
        case .telegram: return "Telegram"
        case .whatsApp: return "WhatsApp"
        }
    }

    static func fromCode(_ i: Int) -> Platform? {
        switch i {
        case 1: return .weChat
        case 3: return .apple
        case 2: return .weibo
        case 4: return .qq
        case 5: return .telegram
        case 6: return .whatsApp
        default: return nil
        }
    }

    static func fromClientID(_ id: String) -> Platform? {
        switch id {
        case "com.tencent.xin":
            return .weChat
        case "com.sina.weibo":
            return .weibo
        case "com.apple.MobileSMS":
            return .apple
        case "com.tencent.mqq":
            return .qq
        case "com.tencent.tim":
            return .qq
        case "ph.telegra.Telegraph":
            return .telegram
        case "com.nicegram.Telegram-iOS":
            return .telegram
        case "net.whatsapp.WhatsApp":
            return .whatsApp
        default:
            return nil
        }
    }

    var intValue: Int {
        switch self {
        case .apple: return 3
        case .weChat: return 1
        case .weibo: return 2
        case .qq: return 4
        case .telegram: return 5
        case .whatsApp: return 6
        }
    }
}

extension Array where Element: Hashable {
    var unique: [Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(count)
        return filter {
            return uniq.insert($0).inserted
        }
    }
}

let kAddressModeAuto = 0
let kAddressModeTest = 1
let kAddressModeMain = 2

func kBasicFont(size2x: CGFloat, semibold: Bool = false) -> UIFont {
    if !semibold {
        return UIFont(name: "PingFangSC-Regular", size: size2x / 2)!
    } else {
        return UIFont(name: "PingFangSC-Semibold", size: size2x / 2)!
    }
}

func kBasicFont(size: CGFloat, semibold: Bool = false) -> UIFont {
    if semibold {
        return UIFont(name: "PingFangSC-Regular", size: size)!
    } else {
        return UIFont(name: "PingFangSC-Semibold", size: size)!
    }
}

let kBasic28Font = UIFont(name: "PingFangSC-Regular", size: 14)!
let kBasic34Font = UIFont(name: "PingFangSC-Regular", size: 17)!
let kBold28Font = UIFont(name: "PingFangSC-Semibold", size: 14)!
let kBold34Font = UIFont(name: "PingFangSC-Semibold", size: 17)!

let kOnlineDotColor = 0x4BE748
let kWhoopsBlue = 0x3BCFED
let kButtonBorderColor = 0xE0E0E0
let kColor5c5c5c = UIColor(red: 0.36, green: 0.36, blue: 0.36, alpha: 1)
let kColorSysBg = UIColor(red: 214 / 255, green: 216 / 255, blue: 221 / 255, alpha: 1)

let kGroupIdentifier = "group.life.whoops.app"
let kNetLayerUser = "life.whoops.userStorage"
let kNetLayerRecentUserList = "life.whoops.recentUserList"

let kWelcomeGuidShown = "WelcomeGuidShown"

func get(localPath fileName: String) -> String {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(fileName)
    return fileURL.path
}

extension String {
    static func read(from path: String) -> String? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        var str: NSString?
        NSString.stringEncoding(for: data, encodingOptions: nil, convertedString: &str, usedLossyConversion: nil)
        return str as String?
    }

    /// 用数字切字符串 [0,count)
    ///
    /// - Parameters:
    ///   - from: 开始位置，最小为0
    ///   - to: 结束位置，最大为字符串长度
    /// - Returns: 返回新的字符串
    func subString(from: Int, to: Int) -> String {
        guard from < to, to <= count else { return "" }
        let startIndex = index(self.startIndex, offsetBy: from)
        let endIndex = index(self.startIndex, offsetBy: to)
        return String(self[startIndex ..< endIndex])
    }

    /// 从某位置开始直到字符串的末尾
    ///
    /// - Parameter from: 最小为0，最大不能超过字符串长度
    /// - Returns: 新的字符串
    func subString(from: Int) -> String {
        guard from < count else { return "" }
        let startIndex = index(self.startIndex, offsetBy: from)
        return String(self[startIndex ..< endIndex])
    }

    /// 从头开始直到某位置停止，不包含索引位置(0,int),如果是负数则从后往前数n位
    ///
    /// - Parameter to: 要停止的位置，不包含这个位置
    /// - Returns: 新的字符串
    func subString(to: Int) -> String {
        guard abs(to) <= count else { return "" }
        if to < 0 {
            let endIndex = index(self.endIndex, offsetBy: to)
            return String(self[startIndex ..< endIndex])
        }
        let endIndex = index(startIndex, offsetBy: to)
        return String(self[startIndex ..< endIndex])
    }
}
