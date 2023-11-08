//
//  ConfigManager.swift
//  flyinput
//
//  Created by Aaron on 16/7/30.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import LoginputEngineLib
import UIKit

final class ConfigManager {
//    enum SPClasses:Int {
//        case 双拼 = 0,
//        全拼 = 1
//    }
    private var configData: [String: Any] = [:]
    private let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!

    private var keyboardHeightStorage: CGFloat = {
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.height > screenSize.width ? screenSize.width : screenSize.height
        if deviceName == .iPad {
            return width * 0.45
        } else {
            switch width {
            case 320: return 240
            case 375: return 260
            case 414: return 270
            default: return width * 0.65
            }
        }
    }() // 键盘高度设置

    /// 键盘高度设置
    var keyboardHeight: CGFloat! {
        let screenSize = UIScreen.main.bounds.size
        if screenSize.height > screenSize.width { return keyboardHeightStorage }
        else {
            if deviceName == .iPad { return keyboardHeightStorage * 1.2 }
            return keyboardHeightStorage * 0.8
        }
    }

    /// 四码上屏是否开启  0 不开启， 1 四码直接上屏 2 顶字上屏 3 空码上屏
    private(set) var fourCode = 0
    /// 双击空格输入句号
    private(set) var doubleSpace = true
    /// 是否在有输入时可在键盘滑动移动光标
    private(set) var moveCursorWhenInput = false
    /// 输入方案名称
    private(set) var inputPlanName = "全拼"
    /// 辅码方案名称
    private(set) var assistPlanName = "不使用辅码"
    /// 主码表名称
    private(set) var codeTableName = "不使用主码表"
    /// 映射提示方案名称
    private(set) var revPlanName = "不使用映射提示"
    /// 中英混合输入
    private(set) var mixEnglishInput = true
    /// 锁定表情输入面板
    private(set) var lockEmoji = false
    /// 锁定符号输入面板
    private(set) var lockPunc = true
    /// 显示编码反查
    private(set) var revealCode = false
    /// 辅码方案版本，如果是负数说明不使用
    private(set) var assistCodePlanVersion = -1
    /// 自定义编码版本，如果是负数说明不使用
    private(set) var customCodeTableVersion = -1
    /// 主码表版本，如果是负数说明不使用
    private(set) var codeTableVersion = -1
    /// 用户词库版本，更新之后改变一个数字以触发拷贝
    private(set) var userDictVersion = -1
    /// 长按开启快捷设置面板
    private(set) var longPressSettings = true
    /// 按键气泡
    private(set) var usePopView = true
    /// 键盘映射提示
    private(set) var mapHint = false
    /// 输简出繁
    private(set) var s2t = false
    private(set) var an2ang = false
    private(set) var in2ing = false
    private(set) var en2eng = false
    private(set) var z2zh = false
    private(set) var c2ch = false
    private(set) var s2sh = false
    private(set) var f2h = false
    private(set) var r2l = false
    private(set) var l2n = false
    /// 在输入框中显示buffer
    private(set) var inLineBuffer: Bool = {
        if #available(iOSApplicationExtension 13.0, *) {
            return true
        } else {
            return false
        }
    }()

    /// 关闭文本替换
    private(set) var stopTextReplacement = false
    /// 仅在空格上移动光标
    private(set) var moveCursorOnlySpace = false
    /// buffer显示 0 为默认，1 为全拼，2 为双拼
    private(set) var bufferDisplayMode = 0
    /// 用户词典，默认开启
    private(set) var userDict = true
    /// 锁定键盘大写
    private(set) var lockUpperCase = false
    /// 关闭表情界面，默认不开启此功能
    private(set) var disableSwipeDownToEmoji = false
    /// 关闭词库
    private(set) var disableDatabase = false
    /// 反向表情和点划手势
    private(set) var reverseSwipe = false
    /// 联想，默认打开
    private(set) var thinking = true
    /// 辅码首选后移
    private(set) var moveBack = true
    /// 自动在数字和字母后插入空格
    private(set) var autoBlank = false
    /// 按键音，默认打开
    private(set) var clickSound = true
    /// 按键振动，默认关闭
    private(set) var clickVibrate = false
    /// 五笔传统z功能
    private(set) var zRepeat = false
    /// z+全拼
    private(set) var zFullSpell = false
    /// 键盘无刻模式
    private(set) var keyboardNoPattern = false
    /// 四码词汇词汇优先
    private(set) var wordFirst = true
    /// 关闭emoji候选
    private(set) var noEmoji = false
    /// 仅点划振动
    private(set) var onlyBootVibrate = false
    /// 辅码提示
    private(set) var revealAssist = false
    /// 码表空码下滑
    private(set) var emptySlide = true
    /// 键盘皮肤颜色，0是自动，1是白色，2是黑色
    private(set) var skinColor = kSkinColorAuto
    /// 输简出繁类型，0 台湾正体 1 港澳繁体 2 繁体出简 3 普通繁体 4 火星文
    private(set) var s2tType = 0
    /// 空格选定，默认开启
    private(set) var spaceConfirmation = true
    /// 双键模式
    private(set) var doubleKeyMode = false
    /// 时间日期星期快捷键，默认打开
    private(set) var sjrqxq = true
    /// 超级简拼   默认打开
    private(set) var superSP = true
    /// 首选加粗 默认关闭
    private(set) var firstBold = false
    /// 码表码长，默认为4
    private(set) var codeLength = 4
    /// 键盘字体名称，带后缀
    private(set) var keyboardKeyFontName = "PingFangSC-Regular"
    /// 按键透明模式，默认关闭
    private(set) var keyTransparent = false
    /// 按键毛玻璃特效
    private(set) var keyGlass = false
    /// 键盘用图片做背景
    private(set) var imgBg = false
    /// 键盘用图片做背景的沉浸模式
    private(set) var imgBgFull = false
    /// 键盘候选栏模糊特效
    private(set) var imgBgBlur = false
    /// 背景图片透明度
    private(set) var imgBgAlpha = 1.0
    /// 标点数字键盘风格 0 默认 1 九宫格 2 仿t9
    private(set) var puncKeyboardStyle = kPuncKeyboardStyleNormal
    /// 首选变色
    private(set) var firstColor = false
    /// 首选变色的颜色值
    private(set) var firstColorValue = 0xF5821F
    /// 按键上屏数量统计 默认关闭
    private(set) var keyLogger = false
    /// 空格键动画，默认开启
    private(set) var spaceAnimation = true
    /// 按键音文件名称，默认留空用系统的
    private(set) var clickSoundName = ""
    /// 扩展词库，默认关闭
    private(set) var extendedDict = false
    /// 空格上屏联想，默认关闭
    private(set) var spaceUpThink = false
    /// 空格上划通配，默认关闭，关了就上划次选
    private(set) var spaceSwipeUpMask = false
    /// 通配仅查询单字,默认开启
    private(set) var maskOnlyCharacter = true
    /// 空码清屏，默认关闭
    private(set) var emptyClean = false
    /// 隐藏候选栏，默认关闭
    private(set) var hideCandidateBar = false
    /// -1 微小 0 小 1 中 2 大
    private(set) var keyFeedBackType = 0
    /// 兼容安卓的软回车
    private(set) var compatibleReturn = true
    /// 白色时键盘字母的颜色
    private(set) var whiteLetterColor = UIColor.darkText.int
    /// 黑色键盘时字母的颜色
    private(set) var darkLetterColor = UIColor.white.int
    /// 白色时皮肤文字的颜色
    private(set) var whiteRevLetterColor = UIColor.gray.int
    /// 黑色时皮肤文字的颜色
    private(set) var darkRevLetterColor = UIColor.white.int

    /// 全拼纠错
    private(set) var gn2ng = false
    /// 全拼纠错
    private(set) var mg2ng = false
    /// 全拼纠错
    private(set) var uen2un = false
    /// 全拼纠错
    private(set) var iou2iu = false
    /// 全拼纠错
    private(set) var uei2ui = false
    /// 全拼，默认开启
    private(set) var quanPin = true
    /// 全拼智能纠错 默认开启
    private(set) var smartCorrection = true

    /// 强制符号键盘显示英文
    private(set) var forceEngPunc = false
    /// 空码空格清buffer
    private(set) var spaceClean = false
    /// 点划上屏buffer而不是首选
    private(set) var swipeInputBuffer = false
    /// 0 没有功能 1 上屏次选 2 当作分号 3 全拼的分词键 4 清空buffer
    private(set) var shiftMode = kShiftModeNone
    /// VoiceOver 解释库版本，0为落格解释库，1为经典解释库
    private(set) var voiceOverLibVersion = 0
    /// VoiceOver 解释风格，0 先读词再解字，1 只解字不读词 ， 2 只读词不解字。
    private(set) var voiceOverReadStyle = 0
    /// 码表参与词频
    private(set) var codetableInUserDict = false
    /// 超大字符集
    private(set) var bigCharacterSet = false
    /// 辅码参与词频
    private(set) var assistInUserDict = false
    /// 快速用户词频学习模式
    private(set) var quickUserDict = false
    /// z模式回车z也上屏
    private(set) var zGoScreen = false
    /// 全局的中英模式切换，默认关闭
    private(set) var persistedEnMode = false
    /// 单手键盘宽度比例
    private(set) var oneHandWidth = 0.8
    /// 候选栏字体大小
    private(set) var candidateFontSize = 20
    /// 候选栏候选间距 默认 0
    private(set) var candidateSpace = 0

    /// 炫彩扩展, 负数为不使用，0 为小清新动态随机色
    private(set) var colorfulStyle = -1
    /// 炫彩键盘变色速度
    private(set) var colorfulSpeed = 2.0
    /// 键盘背景色
    private(set) var keyboardBackgroundColor = -1
    /// 锁定便签， 默认关闭，开启后保存便签不自动重启键盘
    private(set) var lockNote = false
    /// 拒绝导出用户词库，开启后就不能关闭
    private(set) var refuseBackupUserDict = false
    /// 存储键盘布局
    private(set) var keyboardLayoutStore = 0
    /// 默认的点划配置名称
    private(set) var bootButtonName = "BootButtons.plist"
    /// 剪切板历史，默认关闭
    private(set) var pasteBoardHistory = false

    private(set) var canReadConfigs = false // 是否应该读取配置

    // 配置管理器的单件模式，方便其他类实例来获取配置，同时保证管理器全局唯一
    static let shared = ConfigManager()

    private init() {
//        self.getConfig()
        /// 在键盘初始化中触发更新配置，放在这里可能导致配置再更改后无法立即生效
    }

    private(set) var bootButtons = [
        "a": "！", "b": "%", "c": "”", "d": "、", "e": "+",
        "f": "#上次上屏",
        "g": "·", "h": "《》#光标左移", "i": "，",
        "j": "“”#光标左移", "k": "（）#光标左移", "l": "【】#光标左移", "m": "‘’#光标左移",
        "n": "#行尾", "o": "←",
        "p": "→", "q": "#", "r": "-", "s": "……", "t": "=", "u": "#撤销上屏", "v": "——",
        "w": "？", "x": "_", "y": "@", "z": "“",

        "a⇣": "", "b⇣": "#大团结", "c⇣": "", "d⇣": "", "e⇣": "#中英切换",
        "f⇣": "#繁简切换",
        "g⇣": "", "h⇣": "", "i⇣": "",
        "j⇣": "", "k⇣": "", "l⇣": "", "m⇣": "",
        "n⇣": "#便签", "o⇣": "",
        "p⇣": "#隐私模式", "q⇣": "", "r⇣": "", "s⇣": "", "t⇣": "", "u⇣": "", "v⇣": "",
        "w⇣": "", "x⇣": "", "y⇣": "", "z⇣": "",
    ]
    var spScheme_rev: [String: String] = [:]
    /**
     获取配置信息，如果配置信息不完整即为旧版，则自动初始化剩余信息同时将新的配置写入完成配置文件的升级
     如果文件不存在就抛出错误。

     - author: Aaron
     - date: 16-08-03 01:08:46

     - throws: 配置文件地址
     */
    func getConfig() {
        // 键盘布局设定给所有用户开放。
        keyboardLayout = KeyboardLayout(rawValue: shareDefault.integer(forKey: "Layout"))!

        if let data = shareDefault.dictionary(forKey: "Config") {
            configData = data
        } else { return }

        if let b = configData["SmartCorrection"] as? Bool { smartCorrection = b }
        if let b = configData["An2ang"] as? Bool { an2ang = b }
        if let b = configData["En2eng"] as? Bool { en2eng = b }
        if let b = configData["In2ing"] as? Bool { in2ing = b }
        if let b = configData["Z2zh"] as? Bool { z2zh = b }
        if let b = configData["C2ch"] as? Bool { c2ch = b }
        if let b = configData["S2sh"] as? Bool { s2sh = b }
        if let b = configData["R2l"] as? Bool { r2l = b }
        if let b = configData["F2h"] as? Bool { f2h = b }
        if let b = configData["L2n"] as? Bool { l2n = b }
        if let s = configData["InputPlanName"] as? String { inputPlanName = s }
        if let i = configData["AssistCodePlanVersion"] as? Int { assistCodePlanVersion = i }
        if let i = configData["CodeTableVersion"] as? Int { codeTableVersion = i }
        if let b = configData["RefuseBackupUserDict"] as? Bool { refuseBackupUserDict = b }
        if let s = configData["CodeTableName"] as? String { codeTableName = s }
        if let b = configData["QuanPin"] as? Bool { quanPin = b }
        if let b = configData["StopTextReplacement"] as? Bool { stopTextReplacement = b }
        if let b = configData["DisableDatabase"] as? Bool { disableDatabase = b }

        canReadConfigs = true
        if let dic = shareDefault.dictionary(forKey: "BootButtons") as? [String: String] {
            bootButtons = dic
        }
        /// 如果用户开启了映射皮肤，就在加载配置的时候一起加载，否则变量会一直缓存不切换
        if let b = configData["MapHint"] as? Bool {
            mapHint = b
            if b, let d = getSPScheme_rev() as? [String: String] {
                spScheme_rev = d
            }
        }
        if let i = configData["CustomCodeTableVersion"] as? Int { customCodeTableVersion = i }
        if let k = configData["KeyboardHeight"] as? CGFloat { keyboardHeightStorage = k }
        if let f = configData["FourCode"] as? Int { fourCode = f }
        if let d = configData["DoubleSpace"] as? Bool { doubleSpace = d }
        if let d = configData["MoveCursorWhenInput"] as? Bool { moveCursorWhenInput = d }
        else if let d = configData["MoveCusorWhenInput"] as? Bool { moveCursorWhenInput = d }
        if let i = configData["MixEnglishInput"] as? Bool { mixEnglishInput = i }
        if let i = configData["LockEmoji"] as? Bool { lockEmoji = i }
        if let i = configData["LockPunc"] as? Bool { lockPunc = i }
        if let d = configData["RevealCode"] as? Bool { revealCode = d }
        if let b = configData["S2T"] as? Bool { s2t = b }
        if let b = configData["LongPressSettings"] as? Bool { longPressSettings = b }
        if let b = configData["UsePopView"] as? Bool { usePopView = b }
        if let i = configData["UserDictVersion"] as? Int { userDictVersion = i }
        if let b = configData["InLineBuffer"] as? Bool { inLineBuffer = b }
        if let b = configData["MoveCursorOnlySpace"] as? Bool { moveCursorOnlySpace = b }
        else if let b = configData["MoveCurserOnlySpace"] as? Bool { moveCursorOnlySpace = b }
        if let i = configData["BufferDisplayMode"] as? Int { bufferDisplayMode = i }
        if let b = configData["UserDict"] as? Bool { userDict = b }
        if let b = configData["LockUpperCase"] as? Bool { lockUpperCase = b }
        if let b = configData["DisableSwipeDownToEmoji"] as? Bool { disableSwipeDownToEmoji = b }
        if let b = configData["ReverseSwipe"] as? Bool { reverseSwipe = b }
        if let b = configData["Thinking"] as? Bool { thinking = b }
        if let b = configData["MoveBack"] as? Bool { moveBack = b }
        if let b = configData["AutoBlank"] as? Bool { autoBlank = b }
        if let b = configData["ClickSound"] as? Bool { clickSound = b }
        if let b = configData["ClickVibrate"] as? Bool { clickVibrate = b }
        if let b = configData["ZRepeat"] as? Bool { zRepeat = b }
        if let b = configData["ZFullSpell"] as? Bool { zFullSpell = b }
        if let b = configData["KeyboardNoPattern"] as? Bool { keyboardNoPattern = b }
        if let b = configData["WordFirst"] as? Bool { wordFirst = b }
        if let b = configData["NoEmoji"] as? Bool { noEmoji = b }
        if let b = configData["OnlyBootVibrate"] as? Bool { onlyBootVibrate = b }
        if let b = configData["RevealAssist"] as? Bool { revealAssist = b }
        if let b = configData["EmptySlide"] as? Bool { emptySlide = b }
        if let i = configData["SkinColor"] as? Int { skinColor = i }
        if let i = configData["S2tType"] as? Int { s2tType = i }
        if let b = configData["SpaceConfirmation"] as? Bool { spaceConfirmation = b }
        if let b = configData["SJRQXQ"] as? Bool { sjrqxq = b }
        if let i = configData["ColorfulStyle"] as? Int { colorfulStyle = i }
        if let b = configData["SuperSP"] as? Bool { superSP = b }
        if let b = configData["FirstBold"] as? Bool { firstBold = b }
        if let b = configData["LockNote"] as? Bool { lockNote = b }
        if let i = configData["CodeLength"] as? Int { codeLength = i }
        if let s = configData["KeyboardKeyFontName"] as? String { keyboardKeyFontName = s }
        if let d = configData["ColorfulSpeed"] as? Double { colorfulSpeed = d }
        if let i = configData["KeyboardBackgroundColor"] as? Int { keyboardBackgroundColor = i }
        if let b = configData["KeyTransparent"] as? Bool { keyTransparent = b }
        if let b = configData["KeyGlass"] as? Bool { keyGlass = b }
        if let b = configData["ImgBg"] as? Bool { imgBg = b }
        if let i = configData["PuncKeyboardStyle"] as? Int { puncKeyboardStyle = i }
        if let b = configData["FirstColor"] as? Bool { firstColor = b }
        if let i = configData["FirstColorValue"] as? Int { firstColorValue = i }
        if let b = configData["KeyLogger"] as? Bool { keyLogger = b }
        if let b = configData["SpaceAnimation"] as? Bool { spaceAnimation = b }
        if let s = configData["ClickSoundName"] as? String { clickSoundName = s }
        if let b = configData["ExtendedDict"] as? Bool { extendedDict = b }
        if let b = configData["SpaceUpThink"] as? Bool { spaceUpThink = b }
        if let b = configData["SpaceSwipeUpMask"] as? Bool { spaceSwipeUpMask = b }
        if let b = configData["EmptyClean"] as? Bool { emptyClean = b }
        if let b = configData["HideCandidateBar"] as? Bool { hideCandidateBar = b }
        if let i = configData["KeyFeedBackType"] as? Int { keyFeedBackType = i }
        if let b = configData["CompatibleReturn"] as? Bool { compatibleReturn = b }
        if let i = configData["WhiteLetterColor"] as? Int { whiteLetterColor = i }
        if let i = configData["DarkLetterColor"] as? Int { darkLetterColor = i }
        if let i = configData["WhiteRevLetterColor"] as? Int { whiteRevLetterColor = i }
        if let i = configData["DarkRevLetterColor"] as? Int { darkRevLetterColor = i }
        if let b = configData["Gn2ng"] as? Bool { gn2ng = b }
        if let b = configData["Mg2ng"] as? Bool { mg2ng = b }
        if let b = configData["Uen2un"] as? Bool { uen2un = b }
        if let b = configData["Iou2iu"] as? Bool { iou2iu = b }
        if let b = configData["Uei2ui"] as? Bool { uei2ui = b }
        if let b = configData["ForceEngPunc"] as? Bool { forceEngPunc = b }
        if let b = configData["SpaceClean"] as? Bool { spaceClean = b }
        if let b = configData["SwipeInputBuffer"] as? Bool { swipeInputBuffer = b }
        if let i = configData["ShiftMode"] as? Int { shiftMode = i }
        if let i = configData["VoiceOverLibVersion"] as? Int { voiceOverLibVersion = i }
        if let b = configData["CodetableInUserDict"] as? Bool { codetableInUserDict = b }
        if let i = configData["VoiceOverReadStyle"] as? Int { voiceOverReadStyle = i }
        else if let b = configData["VoiceOverWordOnly"] as? Bool { voiceOverReadStyle = b ? kVoiceOverOnlyWord : kVoiceOverPhraseWord } // 老用户自动识别并迁移配置
        if let b = configData["BigCharacterSet"] as? Bool { bigCharacterSet = b }
        if let b = configData["AssistInUserDict"] as? Bool { assistInUserDict = b }
        if let b = configData["QuickUserDict"] as? Bool { quickUserDict = b }
        if let b = configData["ZGoScreen"] as? Bool { zGoScreen = b }
        if let b = configData["PersistedEnMode"] as? Bool { persistedEnMode = b }
        if let d = configData["ImgBgAlpha"] as? Double { imgBgAlpha = d }
        if let d = configData["OneHandWidth"] as? Double { oneHandWidth = d }
        if let b = configData["MaskOnlyCharacter"] as? Bool { maskOnlyCharacter = b }
        if let i = configData["CandidateFontSize"] as? Int { candidateFontSize = i }
        if let i = configData["CandidateSpace"] as? Int { candidateSpace = i }
        if let b = configData["ImgBgFull"] as? Bool { imgBgFull = b }
        if let b = configData["ImgBgBlur"] as? Bool { imgBgBlur = b }
        if let b = configData["PasteBoardHistory"] as? Bool { pasteBoardHistory = b }
    }

    func setKeyboardNoPattern(_ b: Bool) { keyboardNoPattern = b }
    func setRevealAssist(_ b: Bool) { revealAssist = b }
    func setKeyboardHeight(_ height: CGFloat) { keyboardHeightStorage = height }
    func setRevealCode(_ b: Bool) { revealCode = b }
    func setLockEmoji(_ b: Bool) { lockEmoji = b }
    func setLockPunc(_ b: Bool) { lockPunc = b }
    func setS2T(_ b: Bool) { s2t = b }
    func setFourCode(_ b: Int) { fourCode = b }
    func setClickSound(_ b: Bool) { clickSound = b }
    func setClickVibrate(_ b: Bool) { clickVibrate = b }
    func setQuanpin(_ b: Bool) { quanPin = b }
}

extension ConfigManager {
    func getMessages() -> [String: Any]? {
        return shareDefault.dictionary(forKey: "Messages")
    }

    func getSPScheme() -> [String: Any]? {
        return shareDefault.dictionary(forKey: "SPScheme")
    }

    func getSPScheme_rev() -> [String: Any]? {
        return shareDefault.dictionary(forKey: "SPScheme_rev")
    }
}

extension ConfigManager {
    var isCodeTableModeOn: Bool {
        return codeTableVersion >= 0
    }

    var isAssistCodeModeOn: Bool {
        return assistCodePlanVersion >= 0
    }
}

extension ConfigManager: LEConfigDelegate {}
