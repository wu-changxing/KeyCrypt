//
//  InLineController.swift
//  LogInput
//
//  Created by Aaron on 2016/12/10.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import LoginputEngineLib
import UIKit

final class InLineController {
    private var textDocumentProxy: UITextDocumentProxy? {
        (KeyboardViewController.inputProxy as! KeyboardViewController).textDocumentProxy
    }

    private lazy var isIncompatible: Bool = {
        incompatibleID.firstIndex(of: (KeyboardViewController.inputProxy as! KeyboardViewController).clientID) != nil
    }()

    private let incompatibleID: Set<String> = [
        "com.lkzhao.editor", // Noto
        "com.taobao.fleamarket", // 闲鱼
        "com.soulapp.cn", // Soul
        "com.linkedin.LinkedIn", // linkedin
        "com.qbb6.app.iphone", // 亲宝宝
        "com.crystalnix.ServerAuditor", // Termius - SSH client
        "tv.danmaku.bilianime", // bilibili
        "com.facebook.Messenger", // Messenger
        "com.mutangtech.qianji.fltios", // 钱迹
        "com.alicloud.smartdrive", // 阿里云盘
        "com.shi.AviaryApp", // Aviary 第三方 Twitter 客户端
        "com.netease.godlike", // 网易大神
        "com.czzhao.binance", // 币安
        "com.wenyu.bodian", // 波点音乐
        "com.gotokeep.keep", //keep 卡路里计算
        "com.apple.MobileSMS",//iMessage 内输入会随机追加字母，要用兼容模式
    ]

    init() {}

    var isBuffering: Bool {
        guard ConfigManager.shared.inLineBuffer else { return false }
        return !lastBuffer.isEmpty
    }

    private var lastBuffer = ""
    func bufferUpdate(_ content: String) {
        clearBuffer()
        lastBuffer = content.stringWithBufferStyle()

        if #available(iOSApplicationExtension 13.0, *), !isIncompatible {
            textDocumentProxy?.setMarkedText(lastBuffer, selectedRange: NSRange(location: lastBuffer.count, length: 0))
        } else {
            textDocumentProxy?.insertText(lastBuffer)
        }
    }

    func insertTextDirectly(_ s: String) {
        clearBuffer()
        lastBuffer = ""
        textDocumentProxy?.insertText(s)
    }

    func insertText(_ text: String) {
        clearBuffer()
        lastBuffer = ""
        let leftString = textDocumentProxy?.documentContextBeforeInput
        if ConfigManager.shared.autoBlank, !isEnMode, !CapsLock, text != "\n",
           let leftChar = leftString?.last,
           let newChar = text.first
        {
            let leftChar = String(leftChar)
            let newChar = String(newChar)

            let enRange = leftChar.range(of: "[a-z|A-Z|0-9]", options: .regularExpression, range: nil, locale: nil)
            let chRange = leftChar.range(of: "[\\u4e00-\\u9fa5]", options: .regularExpression, range: nil, locale: nil)

            let isChinese = newChar.range(of: "[\\u4e00-\\u9fa5]", options: .regularExpression, range: nil, locale: nil) != nil
            let isEnglish = newChar.range(of: "[a-z|A-Z|0-9]", options: .regularExpression, range: nil, locale: nil) != nil

            if enRange != nil && isChinese || chRange != nil && isEnglish {
                textDocumentProxy?.insertText(" ") // 如果开了 inlinebuffer，则空格在inlinebuffer管理器中处理
            }
        }
        /// 为 iOS Spotlight 专门打补丁，避免文本上的 mark 效果始终保持
        if textDocumentProxy?.documentContextBeforeInput == nil,
           (KeyboardViewController.inputProxy as! KeyboardViewController).clientID == "com.apple.Spotlight"
        {
            textDocumentProxy?.insertText(" ")
            textDocumentProxy?.deleteBackward()
        }
        textDocumentProxy?.insertText(text)
    }

    let ms: Double = 1000
    private func clearBuffer() {
        if #available(iOSApplicationExtension 13.0, *), !isIncompatible {
//            textDocumentProxy?.setMarkedText("", selectedRange: NSRange(location: 0, length: 0))
        } else {
            for _ in lastBuffer {
                textDocumentProxy?.deleteBackward()
                usleep(useconds_t(1.5 * ms))
            }
            // Fallback on earlier versions
        }
    }
}
