//
//  enBoard.swift
//  flyinput
//
//  Created by Aaron on 16/7/21.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import LoginputEngineLib
import UIKit

var englishModeLeftStr = "" // 用来给英文模式的智能补全做缓存

var gTime = Date()
var CapsLock = false
var keyboardMode: KeyboardType = .lower
var isEnMode = false
var okToUse = false
extension ZhInput {
    var isThinking: Bool { return inputBuffer.isEmpty }
}

final class ZhInput {
    let upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ;"
    let lowerCase = "abcdefghijklmnopqrstuvwxyz;"
    private weak var keyboard: InputProxy!
    private var configManager: ConfigManager!
    private let bufferQueue = DispatchQueue(label: "zhinput_bufferQueue", qos: .userInteractive, attributes: .concurrent)
    private var inputBufferStorage = ""
    var inputBuffer:String {
        get {
            bufferQueue.sync {inputBufferStorage}
        }
        set {
            bufferQueue.async(flags:.barrier) {
                self.inputBufferStorage = newValue
            }
        }
    }
    var inputBufferWithStyle: String {
        inputBuffer.stringWithBufferStyle()
    }

    var delegate: InputDelegate!
    private var t9PinyinSelector: PinYinSelector!

    private let keyProcessQueue = DispatchQueue(label: "zhinput_keyProcessQueue", qos: .userInteractive, autoreleaseFrequency: .workItem)

    private var textReplacement: [String: [String]] = [:]

    func reloadInputStrategyDelegate() {
        if keyboardLayout == .key9 {
            t9PinyinSelector = PinYinSelector()
            delegate = T9Strategy()
            t9PinyinSelector.zhInput = self
            t9PinyinSelector.inputDelegate = delegate as? T9Strategy
            (delegate as! T9Strategy).pinYinSelector = t9PinyinSelector
            if let k = keyboard as? KeyboardViewController, let v = k.customInterface as? NKeyButtons {
                t9PinyinSelector.tableView = v.tableView
                v.tableView.delegate = t9PinyinSelector
                v.tableView.dataSource = t9PinyinSelector
            }

        } else if ConfigManager.shared.quanPin {
            delegate = QuanpinStrategy()

        } else if ConfigManager.shared.fourCode > 0 {
//            delegate = FourCodeInputStrategy()
        } else {
//             delegate = SunpyInputStrategy()
        }
    }

    init(_ input: InputProxy) {
        keyboard = input
        configManager = ConfigManager.shared

//        if configManager.persistedEnMode {
//            isEnMode = LocalConfigManager.shared.currentEnMode //英文模式补丁，每次重新初始化
//        } else {
//            isEnMode = false //英文模式补丁，每次重新初始化
//        }

        reloadInputStrategyDelegate()

        let group = DispatchGroup()
        let queue = DispatchQueue(label: "zhinputInitQueue", qos: .userInteractive, attributes: .concurrent)
        queue.async {
            LoginputEngineLib.shared.initEngine(emissionDBPath: Bundle.main.path(forResource: "emission", ofType: "db")!, transitionDBPath: Bundle.main.path(forResource: "transition", ofType: "mdb")!, configDelegate: self.configManager)
            LoginputEngineLib.shared.old_Device = !iphone7UP || ProcessInfo.processInfo.isLowPowerModeEnabled
        }
        queue.async(group: group) {
            [unowned self] in

            if !FileSyncCheck.userDBSync {
                self.waitingForUnZipDatabase(true)
                FileSyncCheck.copyUserDB()
            }
        }
        queue.async {
            if self.configManager.extendedDict {
                FileSyncCheck.copyExtendedDB()
            }
        }
        queue.async {
            if self.configManager.customCodeTableVersion >= 0 {
                FileSyncCheck.copyCustomDB()
            }
        }
        queue.async {
            if self.configManager.isCodeTableModeOn {
                FileSyncCheck.copyMainCodeTableDB()
            }
        }
        queue.async {
            if self.configManager.isAssistCodeModeOn {
                FileSyncCheck.copyAssistDB()
            }
        }
        queue.async {
            FileSyncCheck.copyXinhuaDB()
        }

        DispatchQueue.global().async { // 这个不能放到等待线程里，太慢了，会导致键盘初始化时不响应用户按键
            self.keyboard.requestSupplementaryLexicon(completion: {
                guard !self.configManager.stopTextReplacement else { return }
                for le in $0.entries {
                    guard le.userInput.count > 1 else { continue }
                    if let list = self.textReplacement[le.userInput] {
                        self.textReplacement[le.userInput] = list + [le.documentText]
                    } else {
                        self.textReplacement[le.userInput] = [le.documentText]
                    }
                }
            })
        }

        // 等待并发组执行完毕发出通知
        group.notify(queue: DispatchQueue.global()) {
            Database.shared.needsReloadDBLink() // 手动刷新单例
            self.waitingForUnZipDatabase(false)
        }
    }

    // manually config notification in order to prevent double Zhinput receive noti!!!
    func deActive() {
        Database.shared.releaseMe()
//        NotificationCenter.default.removeObserver(self)
//        KeyLogger.shared.commitLog()
//        LightManager.shared.deActive()
    }

    func active() {
//        NotificationCenter.default.removeObserver(self)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.input(_:)), name: NSNotification.Name.DidTapButton, object: nil)
//        LightManager.shared.active()
    }

    deinit {
//        NotificationCenter.default.removeObserver(self)
    }

    /**
     获取按钮动作，对按钮名称进行响应

     - author: Aaron
     - date: 16-08-14 23:08:24

     - parameter button: 按下的按钮实例
     */
    @objc func input(_: Notification) { // redirect thread to background
//        let button = noti.object as! UIButton
//        DispatchQueue.global(qos: .userInitiated).sync {
//            self.input(button:button)
//        }
    }

    func keyPress(_ button: KeyboardKey) {
        let title = button.currentTitle
        let tag = button.tag
        keyProcessQueue.async {
            self.input(title: title, tag: tag)//title；a tag：100
        }
    }

    private func input(title: String?, tag: Int) {
        guard okToUse else { return }
        guard tag != 666 else {
            bufferChanged("_")
            return
        }

        var handled = true
        switch tag {
        case kEmojiButtonID: //表情
            DispatchQueue.main.async {
                self.keyboard.openEmojiOrMessageBoard()
            }
        case kNumberButtonID://数字
            CapsLock = false
            if keyboardMode == .punc {
                changeBoard(type: .lower)
            } else {
                if keyboard.canConfirmSelection {
                    confirmSelection()
                }
                changeBoard(type: .punc)
            }

        case kDeleteButtonID where !inputBuffer.isEmpty:
            let index = inputBuffer.index(before: inputBuffer.endIndex)
            let deletedChar = inputBuffer.remove(at: index)
            DispatchQueue.main.async {
                UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "\(deletedChar)")
            }
            dropSelection()
            dropLearntCodeTable()
            bufferDisplayNeedsUpdate()
            guard !isContinueDelete else { break }

            bufferChanged()
            if isThinking {
                displaySmartHint()
            }

        case kDeleteButtonID: //删除
            if let word = keyboard.documentContextBeforeInput?.last {
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: String(word))
                }
            }
            keyboard.deleteBackward()
            if isContinueDelete { bufferChanged() }
            if !isContinueDelete {
                displaySmartHint()
                DispatchQueue.global().async {
                    Database.shared.tryRemoveNewThink()
                }
            }

        case 201 ... 217 where keyboardMode != .punc:
            switch keyboardLayout {
            case .key9 where tag == 201:
                if inputBuffer.isEmpty {
                    break
                } else {
                    bufferChanged("'")
                }
            case .key9:
                bufferChanged("\(tag - 200)")
//            case .key12: break
//            case .key17: bufferChanged(title?.first?.lowercased() ?? "")

            default: break
            }

        case 299 where keyboardLayout == .key9 && keyboardMode != .punc:

            cleanUp()
            DispatchQueue.main.async {
                if isEnMode {
                    self.keyboard.dismissEnglishKeyboard()
                } else {
                    self.keyboard.openEnglishKeyboard()
                }
            }

        case 299 where keyboardMode != .punc:
            cleanUp()
            isEnMode.toggle()
            englishModeChanged()
            changeBoard(type: keyboardMode)
            if isEnMode {
                keyProcessQueue.async {
                    _ = UITextChecker() // 提前调用一下英文智能补全，避免第一次运算延迟
                }
            }
        case kNormalFunctionButtonID where title == "符": fallthrough
        case kShiftButtonID where title == "符":
            cleanUp()
            DispatchQueue.main.async {
                (self.keyboard as! KeyboardViewController).dismissNumberKeyboard()
                NotificationCenter.default.post(name: .MorePuncMode, object: nil)
            }
            changeBoard(type: .lower)
        case kShiftButtonID where configManager.shiftMode == kShiftModeSelectSecond && !isThinking && !keyboard.candidates.isEmpty:
            let n = keyboard.candidates.count >= 2 ? 1 : 0
            if configManager.spaceConfirmation {
                didSelectCandidate(n)
            } else {
                confirmSelection()
            }
        case kShiftButtonID where configManager.shiftMode == kShiftModeSemicolon && !isThinking && !keyboard.candidates.isEmpty:
            bufferChanged(";")
        case kShiftButtonID where configManager.shiftMode == kShiftModeSpSeparate && !isThinking && !keyboard.candidates.isEmpty:
            bufferChanged("'")
        case kShiftButtonID where configManager.shiftMode == kShiftModeClearBuffer && !isThinking:
            cleanUp()
        case kShiftButtonID:
            CapsLock = false
            if keyboardMode == .upper { changeBoard(type: .lower) } else {
                keyboard.confirmSelection()
                if inputBuffer != "" {
                    insertText(inputBuffer)
                    cleanUp()
                }
                changeBoard(type: .upper)
            }
        case kiPadDismissButtonID:
            keyboard.dismissKeyboard()
        case kSpaceButtonID where !isThinking:
            if keyboard.candidates.isEmpty, ConfigManager.shared.spaceClean {
                cleanUp()
                break
            } else if keyboard.candidates.isEmpty {
                updateCandidates([CodeTable(Code: inputBuffer, Table: inputBuffer)])
            }
            if configManager.spaceConfirmation {
                didSelectCandidate(0)
            } else {
                selectNext()
            }
        case kSpaceButtonID where isThinking && ConfigManager.shared.spaceUpThink:
            guard !keyboard.candidates.isEmpty else {
                fallthrough
            }
            if configManager.spaceConfirmation {
                didSelectCandidate(0)
            } else {
                selectNext()
            }
        case kSpaceButtonID:

            guard configManager.doubleSpace, let str = keyboard.documentContextBeforeInput else {
                insertText(" ")
                break
            }

            let isCh = str.range(of: "([\\u4e00-\\u9fa5|”）】》]) $", options: .regularExpression, range: nil, locale: nil) != nil
            let isEn = str.range(of: "([0-9|a-z|A-Z]) $", options: .regularExpression, range: nil, locale: nil) != nil

            if isCh || isEn { keyboard.deleteBackward() } else { insertText(" ") }

            if isCh {
                insertText(isEnMode ? ". " : "。")
                break
            }
            if isEn {
                insertText(". ")
                break
            }

            if isEnMode {
                DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: DispatchTime.now() + 0.01) {
                    self.displaySmartHint()
                }
            }
        default:
            handled = false
        }
        if handled { return }

        guard let title = title else { return }
        let returnKeyNameSet = "确认|前往|换行|完成|搜索|谷歌|发送|雅虎|继续|加入|下一项|路线|紧急"

        switch title {
        case _ where !inputBuffer.isEmpty && returnKeyNameSet.contains(char: title):
            var tmp = inputBuffer
            if configManager.zFullSpell,
               !configManager.zGoScreen,
               tmp.first == "z"
            {
                tmp.remove(at: tmp.startIndex)
                insertText(tmp)
            } else {
                insertText(tmp)
            }
            cleanUp()

        case _ where returnKeyNameSet.contains(char: title):
            insertText("\n")
        case "选定":
            confirmSelection()

        case "返", "返回":
            break
        case let key where lowerCase.contains(char: key) && keyboardMode == .lower:
            bufferChanged(key)
        case let key where key <= "Z" && key >= "A" && CapsLock:
            insertText(title)
        case let key where upperCase.contains(char: key) && configManager.lockUpperCase && keyboardMode == .lower:
            bufferChanged(key.lowercased())
        case let key where key <= "Z" && key >= "A":
            changeBoard(type: .lower)
            bufferChanged(key)

        case "(", ")": // 对括号单独处理，这个始终无法居中，于是用英文代替显示，输出时替换为中文的。
            let char = title == ")" ? "）" : "（"
            dealWithCandidatesBeforeInsert(isEnMode || configManager.forceEngPunc ? title : char)
            insertText(isEnMode || configManager.forceEngPunc ? title : char)
            changeBoard(type: .lower)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: DispatchTime.now() + 0.01) {
                self.displaySmartHint()
            }
        case "。", "，", "、", "？", "！", "；", "（", "）", "@", "\"":
            dealWithCandidatesBeforeInsert(title)

            insertText(title)
            changeBoard(type: .lower)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: DispatchTime.now() + 0.01) {
                self.displaySmartHint()
            }
        case ",", "?", "!", "%":
            guard isEnMode else { fallthrough }
            dealWithCandidatesBeforeInsert(title)
            insertText(title)
            changeBoard(type: .lower)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: DispatchTime.now() + 0.01) {
                self.displaySmartHint()
            }
        default:
            dealWithCandidatesBeforeInsert(title)
            insertText(title)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: DispatchTime.now() + 0.01) {
                self.displaySmartHint()
            }
        }
    }

    func dealWithCandidatesBeforeInsert(_ punc: String) {
        guard !isThinking else {
            if isEnMode, !punc.first!.isNumber, ".,?!;)".contains(char: punc),
               let space = keyboard.documentContextBeforeInput?.last,
               space == " "
            {
                keyboard.deleteBackward()
            }
            return
        }

        switch punc {
        case "。", "，", "、", "？", "！", "；", "（", "）":
            if !keyboard.candidates.isEmpty {
                didSelectCandidate(0)
            }

        default:
            dropSelection()
            insertText(inputBuffer)
        }
        cleanUp()
    }

    private var macroSet: Set<String> {
        var tmp: Set<String> = []

        if ConfigManager.shared.sjrqxq {
            tmp.formUnion(["sj", "rq", "xq"])
        }
        if ConfigManager.shared.zRepeat {
            tmp.insert("z")
        }
        return tmp
    }

    /**
     中文输入响应方法

     - author: Aaron
     - date: 16-08-14 23:08:55

     - parameter moreCharacter: 输入的内容缓存
     */
    private var spaceSelectCache: String? // 专为空格选字做的顶字缓存
    private var fiveCodeDedouble = false
    func bufferChanged(_ moreCharacter: String = "", giveMeMore: Bool = false) {
        guard !isEnMode else { //检测英文模式
            insertText(moreCharacter)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: DispatchTime.now() + 0.01) {
                self.displaySmartHint()
            }
            return
        }

        if let c = spaceSelectCache {
            inputBuffer += c
            spaceSelectCache = nil
        }
        if !configManager.spaceConfirmation, keyboard.canConfirmSelection, !giveMeMore {
            spaceSelectCache = moreCharacter //空格选字
            confirmSelection()
            return
        } else {
            inputBuffer += moreCharacter //新输入了字符
        }
        let zMode = inputBuffer.first == "z" && ConfigManager.shared.zFullSpell
        let dequeue = inputBuffer //？dequeue 作用
        let cl = configManager.codeLength
        // 第五码顶字上屏
        if (configManager.fourCode == 2 || configManager.fourCode == 1) && inputBuffer.count > cl && !zMode, !fiveCodeDedouble {
            if let ct = keyboard.candidates.first, !ct.code.isEmpty {
                fiveCodeDedouble = true
                didSelectCandidate(0)
                return
            } else if configManager.emptyClean {
                fiveCodeDedouble = true
                inputBuffer = moreCharacter
                bufferChanged()
                return
            }
        } else {
            fiveCodeDedouble = false
        }

        // 第五码顶字上屏-end
        var result: CodeTableArray = []
        if !inputBuffer.isEmpty {
            delegate.getCandidates(from: inputBuffer, quick: !giveMeMore, result: &result)//inputBuffer:zhijuea // result:zhijue 直觉
        } else {
            delegate.candidateCacheClear()
        }
        if !giveMeMore { loadFullCache = "" }
        // 空码顶上屏

        if (configManager.fourCode == 3 || configManager.fourCode == 4) && result.isEmpty && !keyboard.candidates.isEmpty && inputBuffer.count > 1 && !zMode {
            if keyboard.candidates[0].code.count == inputBuffer.count {
                inputBuffer += moreCharacter // 此时为错码顶，避免新码被消掉，补一位
            }
            didSelectCandidate(0)
            return
        }
        // 空码顶字上屏-end

        if macroSet.contains(inputBuffer) {
            let n = configManager.zRepeat ? 0 : 1
            if !result.isEmpty {
                result.insert(contentsOf: bufferMacro(withBuffer: inputBuffer), at: n)
            } else {
                result = bufferMacro(withBuffer: inputBuffer)
            }
        }
        if let list = textReplacement[inputBuffer] {
            for line in list {
                guard line != inputBuffer else { continue }
                result.insert(CodeTable(Code: inputBuffer, Table: line, from: .textReplacement), at: 0)
            }
        }
//        gTime = Date().timeIntervalSince1970
//        LogPrint(log:"按键执行时间：\(gTime-time)")
        guard delegate != nil, !delegate.normalSP || dequeue == inputBuffer else { return }

        updateCandidates(result, loadFullCandidates: giveMeMore)
        bufferDisplayNeedsUpdate()
        // 空码直接上屏
        if configManager.fourCode == 4, result.count == 1, !inputBuffer.isEmpty, !zMode {
            var test: CodeTableArray = []
            delegate.getCandidates(from: inputBuffer + "_", quick: true, result: &test)
            if test.isEmpty {
                didSelectCandidate(0)
                return
            }
        }
        // 空码直接上屏-end

        let needsGoToScreen = inputBuffer.count == cl && result.count == 1
        if configManager.fourCode == 1, needsGoToScreen, !zMode {
            didSelectCandidate(0)
        } else if configManager.emptyClean, configManager.fourCode == 1, inputBuffer.count == cl, !zMode, result.isEmpty {
            cleanUp()
        }
    }

    private var loadFullCache = ""
    func pleaseGiveMeMore() {
        guard loadFullCache != inputBuffer else { return }
        loadFullCache = inputBuffer
        bufferChanged("", giveMeMore: true)
    }

    var learningOne: CodeTable?

    var tracebackStack: CodeTableArray = []

    func candidateSelect(_ codeTable: CodeTable, index: Int) {
        var timeCodetable = CodeTable()
        timeCodetable.table = codeTable.table
        let length = !codeTable.from.intersection([.main, .assisted, .user, .custom]).isEmpty || configManager.quanPin ? codeTable.code.count : codeTable.table.count * 2
        let zMode = inputBuffer.first == "z" && configManager.zFullSpell && !configManager.quanPin

        let spSpecial = !configManager.quanPin && inputBuffer.range(of: "'") != nil
        guard
            codeTable.from.intersection([.english, .emoji, .sjrq, .auto_comp, .english_think]).isEmpty, !zMode, !spSpecial
        else {
            if codeTable.from.contains(.english) { // 单独处理下英文的词频学习
                var t = codeTable
                t.code = inputBuffer.lowercased()
                t.weight = 0

                addCodeTableFreq(t, index: index)
            }

            if codeTable.from.contains(.emoji), codeTable.table.count == 1 {
                DispatchQueue.global().async {
                    let emojiPath = Database.get(localPath: "recentEmoji.plist")
                    let arr = NSMutableArray(contentsOfFile: emojiPath)
                    arr?.remove(codeTable.table)
                    arr?.insert(codeTable.table, at: 0)
                    arr?.write(to: URL(fileURLWithPath: emojiPath), atomically: true)
                }
            }

            // ----
            tracebackStack.removeAll()
            if !LocalConfigManager.shared.privateMode {
                timeCodetable.code = inputBuffer
                tracebackStack.append(timeCodetable)
            }
            // ----
            cleanUp()
            return
        }

        let tmp = inputBuffer

        if length > inputBuffer.count {
            inputBuffer = ""
            timeCodetable.code = tmp
        } else {
            inputBuffer = String(inputBuffer.dropFirst(length))
            if let c = inputBuffer.first, c == "'" {
                inputBuffer = String(inputBuffer.dropFirst(1))
            }
            timeCodetable.code = String(tmp[tmp.startIndex ..< tmp.index(tmp.startIndex, offsetBy: length)])
        }

        learnIfCan(inputedBuffer: tmp, codeTable: codeTable, index: index)

        bufferChanged()
        displaySmartHint()
        // --
        tracebackStack.append(timeCodetable)
    }

    func englishSmartComplete() {
        var result: CodeTableArray = []
        defer {
            updateCandidates(result)
        }

        guard let s = keyboard.documentContextBeforeInput else {
            return
        }
        let list = s.tokenize()
        guard var str = list.last else { return }

        if str == " ", list.count > 1 {
            str = list[list.count - 2]
            result = Database.shared.getTransitionEn(from: str)
            return
        }

        var r = Database.shared.getCodeTableOrderedByWeightInEnglishDB(fromCode: str, asPrefix: true, withLimit: 99)

        if r.isEmpty {
            r = str.getCorrections4En().map { CodeTable(Code: $0, Table: $0, Weight: 1, from: .auto_comp) }
        } else {
            r.forEach { $0.from = .auto_comp }
        }

        if let index = r.firstIndex(of: CodeTable(Table: str)) {
            r.remove(at: index)
        }

        result = r.filter { $0.weight > 0 }

        if str.first?.isUppercase ?? false { // 如果是大写开头，就都大写开头
            result.forEach { $0.table = $0.table.capitalized }
        }
        englishModeLeftStr = str
    }

    func displaySmartHint(for _: String = "") {
        guard isThinking else { return }
        guard configManager.thinking else {
            updateCandidates([])
            return
        }

        guard !isEnMode else {
            englishSmartComplete()
            return
        }
        updateCandidates([])
//        var result: CodeTableArray = []
//        var str = content
//        if str.isEmpty, let s = keyboard.documentContextBeforeInput { str = s }
//
//        switch str.count {
//        case 3 ... Int.max:
//            result = autoreleasepool {
//                Database.shared.think(from: str.subString(from: str.count - 3))
//            }
//
//            if result.count < 5 {
//                fallthrough
//            }
//        case 2:
//            result += autoreleasepool {
//                Database.shared.think(from: str.subString(from: str.count - 2))
//            }
//
//        default: break
//        }
//
//        let list = str.tokenize()
//        if let a = list.last, a.count > 1 {
//            result += Database.shared.getSmartHint(from: a)
//        }
//        if result.count < 5, let c = str.last {
//            result += Database.shared.getSmartHint(from: String(c))
//        }
//        result = result.unique
//        guard result.isEmpty else { updateCandidates(result); return }
//        let firstLine: CodeTableArray = CodeTableArray(["我", "你", "在", "这", "一", "不", "是", "有", "我们", "今天", "就", "好", "他", "那", "但", "也"].map { CodeTable(Table: $0) })
//        updateCandidates(firstLine)
    }

    // MARK: 点划宏识别

    let macros = "^(#光标左移|#光标右移|#行首|#行尾|#上次上屏|#撤销上屏|#软回车|#硬回车|#粘贴|#空格上屏|#四码上屏|#顶字上屏|#空码直接上屏|#空码顶字上屏|#声音|#振动|#繁简切换|#中英切换|#退格|#全拼|" + "#下一键盘|#符号库|#便签|#隐私模式|#字数统计|#数据管理|#大团结|#分词|#剪切板|#小字典|#快捷设置)"
    /**
     分号引导符实现方法

     - author: Aaron
     - date: 16-08-09 13:08:40

     */
    func shortCutInput(buttonTag: Int, isDown: Bool = false) -> Bool {
        guard let button = chDicLower[buttonTag]?.first?.lowercased(),
              let line = isDown ? configManager.bootButtons[button + "⇣"] : configManager.bootButtons[button],
              !line.isEmpty
        else { return false }

        fuckWithLine(line)
        keyProcessQueue.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            self.displaySmartHint() // 不延迟一下候选刷不出来
        }
        return true
    }

    func fuckWithLine(_ l: String) {
        var line = l.stringWithDateMacro()
        var count = 0
        let haveMacro = line.contains(char: "#")

        if line.range(of: "^(#二选|#次选|#三选|#首选|#一选)", options: .regularExpression, range: nil, locale: nil) != nil, line.count == 3 {
            guard !isThinking || configManager.spaceUpThink else { return }
            let maxCount = keyboard.candidates.count
            var n = 0
            switch line {
            case "#二选" where maxCount >= 2: n = 1
            case "#次选" where maxCount >= 2: n = 1
            case "#三选" where maxCount >= 3: n = 2
            case "#首选" where maxCount >= 1: n = 0
            default: return
            }

            keyboard.didSelectCandidate(n)
            return

        } else {
            if !keyboard.candidates.isEmpty, !isThinking, !configManager.swipeInputBuffer {
                if configManager.spaceConfirmation {
                    keyboard.didSelectCandidate(0)
                } else {
                    keyboard.confirmSelection()
                }
            } else {
                insertText(inputBuffer)
                cleanUp()
            }
        }

        guard haveMacro else {
            insertText(line)
            return
        }

        if let range = line.range(of: "^#链接", options: .regularExpression, range: nil, locale: nil) {
            line.removeSubrange(range)
            line = line.replacingOccurrences(of: " ", with: "")
            if let url = URL(string: line) {
                UIApplication.fuckApplication().fuckURL(url: url)
            }
            return
        }
        while count < line.count {
            if line[line.index(line.startIndex, offsetBy: count)] == "#" {
                let b = line.subString(to: count)
                if !b.isEmpty {
                    insertText(b)
                    line = line.subString(from: count)
                    count = 0
                }
                if let r: Range<String.Index> = line.range(of: macros, options: .regularExpression, range: nil, locale: nil) {
                    line = line.subString(from: fuckWithMacros(line[r]))
                    continue
                }
            }
            count += 1
        }
        if !line.isEmpty {
            insertText(line)
        }
    }

    func cleanUp() {
        inputBuffer = ""
        bufferDisplayNeedsUpdate()
        Database.shared.cleanCache()
        dropLearntCodeTable()
        LoginputEngineLib.shared.cleanCache()
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: DispatchTime.now() + 0.01) {
            self.displaySmartHint()
        }
    }

    var puncDic: [Int: String] {
        return (isEnMode || configManager.forceEngPunc) ? PuncMap.puncMap_En : PuncMap.puncMap_Ch
    }

    private lazy var chDicUpper: [Int: String] = {
        var m = [
            100: "A", 101: "B", 102: "C", 103: "D", 104: "E",
            105: "F", 106: "G", 107: "H", 108: "I", 109: "J",
            110: "K", 111: "L", 112: "M", 113: "N", 114: "O", 115: "P",
            116: "Q", 117: "R", 118: "S", 119: "T", 120: "U",
            121: "V", 122: "W", 123: "X", 124: "Y", 125: "Z", 127: ";", 3: "123",
        ]
        if keyboardLayout == .key9 {
            [
                202: "ABC", 203: "DEF", 204: "GHI", 205: "JKL", 206: "MNO", 207: "PQRS", 208: "TUV", 209: "WXYZ", 201: "'",
            ].forEach { m[$0] = $1 }
        }
        return m
    }()

    private lazy var chDicLower: [Int: String] = {
        var m = [
            100: "a", 101: "b", 102: "c", 103: "d", 104: "e",
            105: "f", 106: "g", 107: "h", 108: "i", 109: "j",
            110: "k", 111: "l", 112: "m", 113: "n", 114: "o", 115: "p",
            116: "q", 117: "r", 118: "s", 119: "t", 120: "u",
            121: "v", 122: "w", 123: "x", 124: "y", 125: "z", 127: ";", 3: "123",
        ]
        if keyboardLayout == .key9 {
            [
                202: "abc", 203: "def", 204: "ghi", 205: "jkl", 206: "mno", 207: "pqrs", 208: "tuv", 209: "wxyz", 201: "'",
            ].forEach { m[$0] = $1 }
        }
        return m
    }()

    func changeBoard(type: KeyboardType) {
        DispatchQueue.main.async {
            for (tag, list) in KeyboardKey.keyboardButtons {
                for button in list {
                    if tag == 299 {
                        let content = isEnMode ? "中" : "En"
                        button.setTitle(content, for: .normal)
                    }

                    switch type {
                    case .punc:
                        keyboardMode = .punc
                        if tag == kShiftButtonID {
                            button.setTitle("符", for: .normal)
                            button.setImage(nil, for: .normal)
                            button.buttonUp()
                            button.accessibilityHint = nil
                            button.accessibilityLabel = "更多符号"
                        } else if tag == kNumberButtonID {
                            button.accessibilityLabel = "字母键盘"
                        }
                        guard let t = self.puncDic[tag] else { continue }

                        button.setTitle(t, for: .normal)
                        if ConfigManager.shared.mapHint {
                            button.textUp.isHidden = true
                        }
                        button.changeFont(for: .punc)

                    case .upper:
                        keyboardMode = .upper
                        if tag == kShiftButtonID {
                            button.buttonDown(button)
                            let imgName = CapsLock ? "shift_doubleclick" : "shift_fill"
                            button.setImage(UIImage(named: imgName), for: .normal)
                            button.setTitle(nil, for: .normal)
                            button.accessibilityLabel = "shift"
                            button.accessibilityHint = "轻点取消大写锁定"
                            button.tintColor = UIColor.darkText
                            button.imageView?.tintColor = UIColor.darkText

                        } else if tag == kNumberButtonID {
                            button.accessibilityLabel = "数字键盘"
                        }
                        guard let t = self.chDicUpper[tag] else { continue }
                        button.setTitle(t, for: .normal)
                        if ConfigManager.shared.mapHint {
                            button.textUp.isHidden = true
                        }
                        button.titleEdgeInsets.left = 0
                        button.changeFont(for: .upper)
                    case .lower:
                        KeyboardKey.isPuncDragMode = false
                        keyboardMode = .lower

                        if tag == kShiftButtonID {
                            let name = darkMode ? "shift_white" : "shift_black"
                            button.setImage(UIImage(named: name), for: .normal)
                            button.setTitle(nil, for: .normal)
                            if self.configManager.keyboardNoPattern {
                                button.setImage(nil, for: .normal)
                            }
                            button.buttonUp()
                            button.accessibilityLabel = "shift"
                            button.accessibilityHint = "轻点三次大写锁定"
                            button.tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
                            button.imageView?.tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
                        }

                        if tag == kNumberButtonID {
                            button.accessibilityLabel = "数字键盘"
                        }
                        guard let t = self.chDicLower[tag] else { continue }
                        let tt = self.configManager.lockUpperCase ? t.uppercased() : t
                        button.setTitle(tt, for: .normal)
                        button.titleEdgeInsets.left = 0
                        button.changeFont(for: .lower)
                        button.buttonUp()
                        if ConfigManager.shared.mapHint {
                            button.textUp.isHidden = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 宏处理

extension ZhInput {
    func intIntoString(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "zh_Hans_CN")

        formatter.numberStyle = NumberFormatter.Style(rawValue: UInt(CFNumberFormatterRoundingMode.roundHalfDown.rawValue))!

        let string: String = formatter.string(from: NSNumber(value: number))!

        return string
    }

    func date2Chinese(y: String, m: String, d: String) -> String {
        var result = ""
        let numChinese: NSString = "〇一二三四五六七八九"
        for char in y {
            if let n = Int(String(char)) {
                var char = numChinese.character(at: n)
                let n = NSString(characters: &char, length: 1)
                result += n as String
            } else {
                result += String(char)
            }
        }
        result += "年\(intIntoString(Int(m)!))月\(intIntoString(Int(d)!))日"
        return result
    }

    /// buffer 的日期宏处理
    ///
    /// - Parameter withBuffer: 要处理的宏
    /// - Returns: 宏对应的候选词
    func bufferMacro(withBuffer: String) -> CodeTableArray {
        var result: CodeTableArray = []
        let formatStr = "%Y|%m|%d|%I|%H|%M|%S|%w"
        guard let r = Date().formattedTime(format: formatStr) else { return [] }
        let list = r.components(separatedBy: "|")

        switch withBuffer {
        case "sj", "osj":
            result.append(CodeTable(Table: "\(list[3])点\(list[5])分", from: .sjrq))
            result.append(CodeTable(Table: "\(list[4]):\(list[5])", from: .sjrq))
            result.append(CodeTable(Table: "\(list[4]):\(list[5]):\(list[6])", from: .sjrq))
        case "rq", "orq":
            result.append(CodeTable(Table: "\(list[2])号", from: .sjrq))
            result.append(CodeTable(Table: "\(list[1])月\(list[2])日", from: .sjrq))
            result.append(CodeTable(Table: "\(list[0])-\(list[1])-\(list[2])", from: .sjrq))
            let dateString = date2Chinese(y: list[0], m: list[1], d: list[2])
            result.append(CodeTable(Table: dateString, from: .sjrq))
        case "xq", "oxq":
            let e = Int(list[7])!
            let E = toChinese(day: e)
            result.append(CodeTable(Table: "星期" + E, from: .sjrq))
            result.append(CodeTable(Table: E, from: .sjrq))
        case "z":
            if lastInputedString.isEmpty { break }
            result = [CodeTable(Table: lastInputedString, from: .sjrq)]
        default:
            break
        }
        return result
    }

    /// 点划宏处理
    ///
    /// - Parameter macro: 宏命令
    /// - Returns: 宏的有效字符长度
    func fuckWithMacros(_ macro: String.SubSequence) -> Int {
        var number = macro.count
        switch macro {
        case "#光标左移":
            keyboard.adjustTextPosition(byCharacterOffset: -1)
        case "#光标右移":
            keyboard.adjustTextPosition(byCharacterOffset: 1)
        case "#行首":
            if let count = keyboard.documentContextBeforeInput?.utf16.count {
                keyboard.adjustTextPosition(byCharacterOffset: -count)
            }
        case "#行尾":
            if let count = keyboard.documentContextAfterInput?.utf16.count {
                keyboard.adjustTextPosition(byCharacterOffset: count)
            }
        case "#上次上屏":
            insertText(lastInputedString)
            cleanUp()
        case "#撤销上屏":
            let s = lastInputedString
            for _ in 0 ..< s.utf16.count {
                keyboard.deleteBackward()
            }
            lastInputedString = ""
            cleanUp()
        case "#软回车":
            let r = configManager.compatibleReturn ? "\r" : "\u{2028}"
            insertText(r)
            cleanUp()
        case "#硬回车":
            insertText("\n")
            cleanUp()
//        case "#粘贴":
//            insertText(PasteBoard.string)
        case "#空格上屏":
            ConfigManager.shared.setFourCode(0)
            reloadInputStrategyDelegate()
        case "#四码上屏":
            ConfigManager.shared.setFourCode(1)
            reloadInputStrategyDelegate()
        case "#顶字上屏":
            ConfigManager.shared.setFourCode(2)
            reloadInputStrategyDelegate()
        case "#空码顶字上屏":
            ConfigManager.shared.setFourCode(3)
            reloadInputStrategyDelegate()
        case "#空码直接上屏":
            ConfigManager.shared.setFourCode(4)
            reloadInputStrategyDelegate()
        case "#声音":
            ConfigManager.shared.setClickSound(!ConfigManager.shared.clickSound)
        case "#振动":
            ConfigManager.shared.setClickVibrate(!ConfigManager.shared.clickVibrate)
        case "#繁简切换":
            ConfigManager.shared.setS2T(!ConfigManager.shared.s2t)

        case "#中英切换":
            isEnMode.toggle()
            englishModeChanged()
            if isEnMode {
                keyProcessQueue.async {
                    _ = UITextChecker() // 提前调用一下英文智能补全，避免第一次运算延迟
                }
            }
        case "#下一键盘":
            KeyboardViewController.inputProxy?.nextKeyboard()
        case "#符号库":
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .MorePuncMode, object: nil)
            }
            changeBoard(type: .lower)
//        case "#便签":
//            if !noteModeStatus {
//                KeyboardViewController.inputProxy?.noteMode()
//            } else if !needDismissKeyboard {
//                KeyboardViewController.inputProxy?.noteMode()
//            } else {
//                (KeyboardViewController.inputProxy as? KeyboardViewController)?.crashMe()
//            }
        case "#隐私模式":
            KeyboardViewController.inputProxy?.privateMode()
        case "#字数统计":
            KeyboardViewController.inputProxy?.keyLoggerPanel()
        case "#数据管理":
            KeyboardViewController.inputProxy?.dataManagePanel()
        case "#大团结":
            KeyboardViewController.inputProxy?.bigUnionPanel()
        case "#退格":
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                // 退格慢一点，不然比其他宏快了
                KeyboardViewController.inputProxy?.deleteBackward()
            }
        case "#全拼":
            guard !configManager.disableDatabase else { break }
            configManager.setQuanpin(!configManager.quanPin)
            reloadInputStrategyDelegate()
        case "#分词":
            LocalConfigManager.shared.setEditorTab(0)
            KeyboardViewController.inputProxy?.openEditor()
        case "#剪切板":
            LocalConfigManager.shared.setEditorTab(1)
            KeyboardViewController.inputProxy?.openEditor()
        case "#小字典":
            LocalConfigManager.shared.setEditorTab(2)
            KeyboardViewController.inputProxy?.openEditor()
        case "#快捷设置":
            LocalConfigManager.shared.setEditorTab(3)
            KeyboardViewController.inputProxy?.openEditor()

        default:
            number = 0
        }
        return number
    }
}

// MARK: - encapsule some functions

extension ZhInput {
    func bufferDisplayNeedsUpdate() {
        DispatchQueue.main.async {
            KeyboardViewController.inputProxy?.bufferUpdate(self.inputBuffer)
        }
    }

    func englishModeChanged() {
        DispatchQueue.main.async {
            (self.keyboard as! KeyboardViewController).showCandidateBarIfNeeded()
            NotificationCenter.default.post(Notification(name: Notification.Name.EnglishModeChanged))
        }
        LocalConfigManager.shared.setCurrentEnMode(isEnMode)
    }

    func didSelectCandidate(_ index: Int) {
        DispatchQueue.main.async {
            KeyboardViewController.inputProxy?.didSelectCandidate(index)
        }
    }

    func selectNext() {
        DispatchQueue.main.async {
            KeyboardViewController.inputProxy?.selectNext()
        }
    }

    func confirmSelection() {
        DispatchQueue.main.async {
            KeyboardViewController.inputProxy?.confirmSelection()
        }
    }

    func dropSelection() {
//        DispatchQueue.main.async { 去掉主线程并发避免候选来不及刷新。
        KeyboardViewController.inputProxy?.dropSelection()
//        }
    }

    func insertText(_ text: String) {
        DispatchQueue.main.async {
            KeyboardViewController.inputProxy?.insertText(str: text)
        }
    }

    func updateCandidates(_ c: CodeTableArray, loadFullCandidates: Bool = false) {
        DispatchQueue.main.async {
            KeyboardViewController.inputProxy?.updateCandidates(c, loadFullCandidates: loadFullCandidates)
        }
    }

    func waitingForUnZipDatabase(_ b: Bool) {
        okToUse = !b
//        if okToUse {
//            self.displaySmartHint()
//        }
    }
}

enum KeyboardType {
    case punc, upper, lower
}
