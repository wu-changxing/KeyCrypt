//
//  InputDelegateProtocol.swift
//  LogInput
//
//  Created by Aaron on 16/9/6.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import LoginputEngineLib
import UIKit

class InputDelegate {
    let queue = DispatchQueue(label: "subBufferQueue", attributes: .concurrent, autoreleaseFrequency: .workItem)
    let group = DispatchGroup()
    let resultCache = LogCache<Int, CodeTableArray>()

    var normalSP: Bool { return !ConfigManager.shared.isCodeTableModeOn } // 判断是否为普通双拼
    var dictDB: Database { return Database.shared }

    var lastPYBuffer = ""
    var candidateCache: CodeTableArray = []
    var configManager: ConfigManager { return ConfigManager.shared }
    var inputBuffer: String = ""
//    lazy var d2f: Double2Pinyin = Double2Pinyin()

    lazy var py2hzDic: [String: String] = {
        let name = configManager.bigCharacterSet ? "py2hz_fullsize" : "py2hz"
        let filePath = Bundle.main.url(forResource: name, withExtension: "plist")!.path
        return NSDictionary(contentsOfFile: filePath) as! [String: String]
    }()

    var py2hz: [String: String] {
        guard !configManager.disableDatabase else { return [:] }
        return py2hzDic
    }

    func getResult(WithBuffer _: String, quick _: Bool, result _: inout CodeTableArray) {
        assert(false, "sub class must implement")
    }

    func getCandidates(from buffer: String, quick: Bool = false, result: inout CodeTableArray) {
        inputBuffer = buffer
        result.removeAll()

        let containingCaps = inputBuffer.range(of: "[A-Z]", options: .regularExpression) != nil

        if !containingCaps {
            getResult(WithBuffer: buffer, quick: quick, result: &result)
            resultCache.clear()
        }

        let fourCodeRule = result.isEmpty && inputBuffer.count > 4 //结果是空，并且输入大于4
        let normalRule = inputBuffer.count >= 2
        if configManager.mixEnglishInput, configManager.fourCode == 0 ? normalRule : fourCodeRule { // 查询英文词库
            let max = configManager.quanPin ? 6 : 4
            var englishResult: CodeTableArray = []
            if inputBuffer.count > max {
                englishResult = dictDB.getCodeTableOrderedByWeightInEnglishDB(fromCode: buffer, asPrefix: true)
                var index = 0
                for (i, ct) in result.enumerated() {
                    guard !ct.from.contains(.user) else { continue }
                    index = i
                    break
                }
                result.insert(contentsOf: englishResult, at: index)

            } else if inputBuffer.count > 3, configManager.quanPin {
                englishResult = dictDB.getCodeTableOrderedByWeightInEnglishDB(fromCode: buffer, asPrefix: true, withLimit: 1)
                if result.count <= 1 {
                    result += englishResult
                } else {
                    result.insert(contentsOf: englishResult, at: 2)
                }

            } else if result.isEmpty {
                englishResult = dictDB.getCodeTableOrderedByWeightInEnglishDB(fromCode: buffer, asPrefix: true)
                result += englishResult
                result.insert(CodeTable(Code: inputBuffer, Table: inputBuffer, from: .english), at: 0)
            } else {
                englishResult = dictDB.getCodeTableOrderedByWeightInEnglishDB(fromCode: buffer)
                if result.count <= 1 {
                    result += englishResult
                } else {
                    result.insert(contentsOf: englishResult, at: 2)
                }
            }
            if buffer.range(of: "^[A-Z]", options: .regularExpression) != nil {
                result.forEach { $0.table = $0.table.capitalized }
            }
        }
//        ----- emoji
        if configManager.fourCode != 1, !configManager.noEmoji,!containingCaps {
            var pinyinStr = ""

            if configManager.quanPin {
                pinyinStr = LoginputEngineLib.shared.segment_loss(from: inputBuffer).joined(separator: "'")
            }
            var firstTwo: CodeTableArray = []
            var restAll: CodeTableArray = []
            for ct in Database.shared.getEmoji(from: pinyinStr, inputBuffer: inputBuffer) {
                if firstTwo.count < 2 { firstTwo.append(ct) }
                else { restAll.append(ct) }
            }
            if result.count > 1 {
                result.insert(contentsOf: firstTwo, at: 2)
            } else {
                result.append(contentsOf: firstTwo)
            }
            result.append(contentsOf: restAll)
        }
//         -----
        var customCodeTable: CodeTableArray = []
        if configManager.customCodeTableVersion >= 0 {
            customCodeTable = dictDB.getCustomCodeTableOrderedByWeight(fromCode: inputBuffer)
        }
        var set = Set(customCodeTable)
        result = result.filter { (ct) -> Bool in
            set.insert(ct).inserted
        }
        for ct in customCodeTable {
            let num = Int(ct.weight)//权重
            if result.count > num {//字
                result.insert(ct, at: num)
            } else {
                result.append(ct)
            }
        }

        guard !containingCaps else { return }
        if result.isEmpty, !containingCaps { result = candidateCache }
        else { candidateCache = result }
    }
}

extension InputDelegate {
    func candidateCacheClear() {
        candidateCache.removeAll()
    }

    func getPreAssistCodeIfNeeded(for cts: inout CodeTableArray) {
        guard configManager.revealAssist,
              configManager.isAssistCodeModeOn,
              inputBuffer.count % 2 == 0
        else { return }
        autoreleasepool {
            cts.forEach {
                guard $0.table.count * 2 == inputBuffer.count else { return }
                guard let c = $0.table.last else { return }
                $0.preAssistedCode = dictDB.getAssistWord(fromWord: String(c))
            }
        }
    }

    func processSingle(fuzzedPinyin: [[String]], list: inout CodeTableArray, cuted: Bool = true) {
        guard normalSP, !configManager.disableDatabase, !fuzzedPinyin.isEmpty else { return }
        var tmp: [[CodeTable]] = []
        for s in fuzzedPinyin[0] {
            guard let str = py2hzDic[s] else { continue }
            var result = str.map { CodeTable(Code: s, Table: String($0),
                                             from: (self is QuanpinStrategy) ? .main : .none)
            }

            if self is QuanpinStrategy, !cuted {
                var ct = CodeTable(Code: s, from: .main)
                var handled = true
                switch s {
                case "xian": ct.table = "西安"
                case "yuan": ct.table = "预案"
                case "qian": ct.table = "奇案"
                case "dian": ct.table = "堤岸"
                case "mian": ct.table = "谜案"
                default: handled = false
                }

                if handled {
                    result.insert(ct, at: 0)
                }
            }
            tmp.append(cuted ? Array(result.prefix(15)) : result)
        }
        list += mashUp(contents: tmp)
        if list.isEmpty, let s = py2hzDic[inputBuffer.subString(to: 1)] {
            let result = s.map { CodeTable(Code: s, Table: String($0),
                                           from: (self is QuanpinStrategy) ? .main : .none)
            }
            list = CodeTableArray(cuted ? Array(result.prefix(15)) : result)
        }
    }

    func mashUp(contents: [[CodeTable]]) -> [CodeTable] {
        guard !contents.isEmpty else { return [] }

        guard contents.count > 1 else {
            return contents[0]
        }

        var listCount = 0
        var elementsCount = 0
        var maxLength = 0

        for list in contents {
            listCount += 1
            elementsCount += list.count
            maxLength = max(maxLength, list.count)
        }
        var result = CodeTableArray(withReservedCapacity: elementsCount)
        for i in 0 ..< maxLength {
            for listIndex in 0 ..< listCount where contents[listIndex].count > i {
                result.append(contents[listIndex][i])
            }
        }
        return result
    }
}
