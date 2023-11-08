//
//  ConfigManager.swift
//  flyinput
//
//  Created by Aaron on 16/7/30.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import MMKVAppExtension
import UIKit

final class LocalConfigManager {
    private var storage = MMKV.default()
    private var configData: [String: Any] = [:]
    private(set) var emojiMode = 0 // 表情输入界面 emoji or 颜文字 2 表示快捷短语
    private(set) var boomIsLeft = false // 默认右侧控制按钮
    private(set) var handMode = 0 // 0为不使用单手模式 1为左手 2为右手
    private(set) var messageClass = 0 // 记忆上次短语选择的分类
    private(set) var privateMode = false // 隐私模式，该模式下键盘不记录任何数据
    private(set) var logType = 0 // 0 为 按键数量统计 1 为 上屏字数统计
    private(set) var userDictVersion = -1 // 用户词库版本，更新之后改变一个数字以触发拷贝
    private(set) var editorTab = 0 // 长按编辑的功能页面

    private(set) var currentEnMode = false // 持久化中英文模式

    private(set) var tempHideHint = false // 临时隐藏皮肤

    // 配置管理器的单件模式，方便其他类实例来获取配置，同时保证管理器全局唯一
    static let shared: LocalConfigManager! = LocalConfigManager()

    private init() { getConfig() }
    /**
     保存配置信息

     - author: Aaron
     - date: 16-08-03 01:08:06
     */
    func saveConfig() {
        configData["EmojiMode"] = emojiMode
        configData["BoomIsLeft"] = boomIsLeft
        configData["HandMode"] = handMode
        configData["MessageClass"] = messageClass
        configData["PrivateMode"] = privateMode
        configData["LogType"] = logType
        configData["UserDictVersion"] = userDictVersion
        configData["EditorTab"] = editorTab
        configData["CurrentEnMode"] = currentEnMode

        let ud = UserDefaults.standard
        ud.set(configData, forKey: "Config")
        ud.synchronize()
    }

    /**
     获取配置信息，如果配置信息不完整即为旧版，则自动初始化剩余信息同时将新的配置写入完成配置文件的升级
     如果文件不存在就抛出错误。

     - author: Aaron
     - date: 16-08-03 01:08:46

     - throws: 配置文件地址
     */
    func getConfig() {
        if let data = UserDefaults.standard.dictionary(forKey: "Config") {
            configData = data
        }

        if let e = configData["EmojiMode"] as? Int { emojiMode = e }
        if let b = configData["BoomIsLeft"] as? Bool { boomIsLeft = b }
        if let i = configData["UserDictVersion"] as? Int { userDictVersion = i }

        if let i = configData["HandMode"] as? Int { handMode = i }
        if let i = configData["MessageClass"] as? Int { messageClass = i }
        if let b = configData["PrivateMode"] as? Bool { privateMode = b }
        if let i = configData["LogType"] as? Int { logType = i }
        if let i = configData["EditorTab"] as? Int { editorTab = i }
        if let b = configData["CurrentEnMode"] as? Bool { currentEnMode = b }
    }

    func setCurrentEnMode(_ b: Bool) { currentEnMode = b; saveConfig() }
    func setEditorTab(_ i: Int) { editorTab = i; saveConfig() }
    func setTempHideHint(_ b: Bool) { tempHideHint = b }
    func setLogType(_ i: Int) { logType = i; saveConfig() }
    func setPrivateMode(_ b: Bool) { privateMode = b; saveConfig() }
    func setMessageClass(_ i: Int) { messageClass = i; saveConfig() }
    func setHandMode(_ i: Int) { handMode = i; saveConfig() }
    func setEmojiMode(_ m: Int) { emojiMode = m; saveConfig() }
    func setBoomIsLeft(_ b: Bool) { boomIsLeft = b; saveConfig() }
    func setUserDictVersion(_ n: Int) {
        userDictVersion = n; saveConfig()
    }
}

extension LocalConfigManager {
    var isPrivateModeAlertShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isPrivateModeAlertShown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isPrivateModeAlertShown")
        }
    }

    var isKeyLoggerAlertViewShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isKeyLoggerAlertViewShown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isKeyLoggerAlertViewShown")
        }
    }

    var isDataManageAlertViewShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isDataManageAlertViewShown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDataManageAlertViewShown")
        }
    }

    var isBigUnionAlertViewShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isBigUnionAlertViewShown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isBigUnionAlertViewShown")
        }
    }
}

extension LocalConfigManager {
    var privacyMode: Bool {
        get {
            storage?.bool(forKey: "PrivacyMode") ?? false
        }
        set {
            storage?.set(newValue, forKey: "PrivacyMode")
        }
    }

    var lastChatTarget: WhoopsUser? {
        get {
            guard let s = storage?.string(forKey: "LastChatTarget") else { return nil }
            return WhoopsUser.fromJsonCode(s)
        }
        set {
            guard let s = newValue?.toJsonCode() else {
                storage?.removeValue(forKey: "LastChatTarget")
                return
            }
            storage?.set(s, forKey: "LastChatTarget")
        }
    }
}
