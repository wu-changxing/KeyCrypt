//
//  QuanpinStrategy.swift
//  LoginputKeyboard
//
//  Created by Aaron on 9/11/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import Foundation
import LoginputEngineLib

final class QuanpinStrategy: InputDelegate {
    private var pinyin: [[String]] = []
    private var splitedPinyin: [String] = []

    let fuzzPinyinList = [
        "fangan": [["fan", "fang"], ["gan", "an"]],
        "wanan": [["wan"], ["an"]],
        "nanan": [["nan", "na"], ["an", "nan"]],
        "xinlianwei": [["xin"], ["li"], ["an"], ["wei"]],
        "jine": [["jin", "ji"], ["e", "ne"]],
    ]
    override func getResult(WithBuffer buffer: String, quick: Bool, result: inout CodeTableArray) {
        pinyin.removeAll()

        if let py = fuzzPinyinList[buffer] {
            pinyin = py
        } else {
            pinyin = LoginputEngineLib.shared.segment(from: buffer)
        }
        splitedPinyin = pinyin.map { $0.first ?? "" }

        let length = pinyin.count

        for index in 1 ... 4 where length >= index {
//            queue.async(group: group) {
                let isFullLength = length == index
                let num = isFullLength ? 30 : 5 // 如果是在整句输入中的词汇候选，就少一点。  //如果是单字，把全长改大一点来兼容模糊音
                let t = self.getSubResult(SubBuffer: Array(self.pinyin.prefix(index)), pathNumber: num)//需要切分词语，单个字的和整句的
                self.resultCache[index] = t
//            }
        }

        if length > 4 {
            queue.async(group: group) {
                let t = self.getSubResult(SubBuffer: self.pinyin, pathNumber: 2)
                self.resultCache[10] = t
            }
        }
        if !quick || isVoiceOverOn {
            queue.async(group: group) {
                guard let first = self.pinyin.first else { return }
                let py = PyString.py2fuzzy(pyList: [first], config: self.configManager)
                var r: CodeTableArray = []
                self.processSingle(fuzzedPinyin: py, list: &r, cuted: false)
                if let a = self.resultCache[0] {
                    self.resultCache[0] = a + r
                } else {
                    self.resultCache[0] = r
                }
            }
        }

        _ = group.wait(timeout: DispatchTime.now() + 0.8)

        for i in (0 ... 10).reversed() {
            guard let cts = resultCache[i] else { continue }
            result += cts
        }
    }

    func getSubResult(SubBuffer pinyin: [[String]], pathNumber: Int) -> CodeTableArray {
        guard pathNumber > 0 else { return [] }
        var result: CodeTableArray = []

        let group = DispatchGroup()

        let pinyin_i = PyString.pyList2i(from: pinyin) //pinyin:hao

        var userCodeTable: CodeTableArray = []
        queue.async(group: group) {
            guard self.configManager.userDict else { return }
            userCodeTable = self.dictDB.getCodeTableOrderedByWeightInUserDB(fromCode: self.inputBuffer)//用户词库中查词
            userCodeTable.forEach {
                $0.from.insert(.main)
                guard pinyin == self.pinyin else { return }
                $0.pyList = self.splitedPinyin
            }
        }

        var codeTable: CodeTableArray = []
        queue.async(group: group) {
            guard !self.normalSP else { return }
            codeTable = self.dictDB.getCodeTableOrderedByWeight(fromCode: self.inputBuffer)
            if self.configManager.revealCode {
                let table = self.dictDB.getCodeTableOrderedByWeight(fromCode: self.inputBuffer, asPrefix: true)
                codeTable += Array(table.prefix(pathNumber))
            } else {
                if codeTable.isEmpty, self.configManager.emptySlide {
                    let cts = self.dictDB.getCodeTableOrderedByWeight(fromCode: self.inputBuffer, asPrefix: true)
                    codeTable = !cts.isEmpty ? [cts[0]] : []
                }
            }
        }

        var expandResult: CodeTableArray = []
        queue.async(group: group) {
            guard pinyin.count != 1 else {
                self.processSingle(fuzzedPinyin: pinyin, list: &expandResult)
                return
            }
            guard pinyin.count == self.pinyin.count else {
                let s = (pinyin.map { $0[0] }).joined()
                expandResult = self.dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: s, withLimit: pathNumber, fullpylist: pinyin_i)
                expandResult.forEach {
                    $0.from.insert(.main)
                    $0.code = s
                }
                return
            }

            expandResult = self.dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: self.inputBuffer, withLimit: pathNumber, fullpylist: pinyin_i)//扩展词库
            if expandResult.isEmpty, !self.configManager.disableDatabase {
                let s = LoginputEngineLib.shared.getPhrase(from: pinyin_i)
                if !s.isEmpty {
                    expandResult.append(CodeTable(Table: s))
                }
            }
            expandResult.forEach {
                $0.from.insert(.main)
                $0.code = self.inputBuffer
                $0.pyList = self.splitedPinyin
            }

            guard pinyin.count <= 6, var c = self.dictDB.getCodeTableFromFuture(fromCode: self.inputBuffer, fullpylist: pinyin_i) else { return }

            c.from.insert(.main)
            c.code = self.inputBuffer

            if expandResult.count > 1 {
                expandResult.insert(c, at: 2)
            } else {
                expandResult.append(c)
            }
        }

        var superJPResult: CodeTableArray = []
        queue.async(group: group) {
            guard self.configManager.superSP, pinyin == self.pinyin else { return }
            superJPResult = self.dictDB.getCodeTableOrderedByWeightInExpandDBSuperSP(fromCode: self.inputBuffer, fullpylist: pinyin_i)
            superJPResult.forEach {
                $0.from.insert(.main)
                $0.code = self.inputBuffer
            }
        }
        var zpinyin: CodeTableArray = []
        queue.async(group: group) {
            guard ConfigManager.shared.zFullSpell,
                  ConfigManager.shared.isCodeTableModeOn,
                  let n = self.inputBuffer.first, n == "z", self.inputBuffer.count > 1 else { return }
            var code = self.inputBuffer
            code.remove(at: code.startIndex)

            guard !code.isEmpty else { return }
            let pylist = LoginputEngineLib.shared.segment_i(from: code)

            zpinyin = self.dictDB.getCodeTableOrderedByWeightInExpandDB(fromCode: code, fullpylist: pylist)

            if pylist.count == 1 {
                var r: [CodeTableArray] = []
                for py in pylist[0] {
                    guard let s = self.py2hz[PyString.pyString(from: py) ?? ""] else { continue }
                    r.append(s.map { CodeTable(Table: String($0)) })
                }
                zpinyin += self.mashUp(contents: r)
            }

            self.dictDB.getCode(fromTable: &zpinyin)
            zpinyin.forEach {
                $0.from.insert(.main)
                $0.code = self.inputBuffer
            }
        }
        // 等待并发组执行完毕
        let status = group.wait(timeout: DispatchTime.now() + 0.5)
        guard status == .success else { return [] }

        if configManager.codetableInUserDict {
            result.append(contentsOf: userCodeTable)
            // 码表一定要优先，然后才是词频
            result.append(contentsOf: codeTable)
        } else {
            result.append(contentsOf: codeTable)
            // 码表一定要优先，然后才是词频
            result.append(contentsOf: userCodeTable)
        }
        result.append(contentsOf: zpinyin)

        result.append(contentsOf: superJPResult)

        result.append(contentsOf: expandResult)

        return result
    }
}
