//
//  ZhInput+Learning.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/13/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import Foundation

extension ZhInput {
    func learnIfCan(inputedBuffer: String, codeTable: CodeTable, index: Int) {
        guard ConfigManager.shared.userDict, !LocalConfigManager.shared.privateMode else {
            return
        }

        if !inputBuffer.isEmpty,
           learningOne == nil,
           ConfigManager.shared.fourCode == 0
        {
            learningOne = CodeTable(Code: inputedBuffer)
        }

        if learningOne != nil {
            learningOne!.table += codeTable.table

            if codeTable.pyList.isEmpty {
                learningOne!.pyList.append(codeTable.code)
            } else {
                learningOne!.pyList += codeTable.pyList
            }
        }

        if inputBuffer.isEmpty, learningOne != nil {
            confirmLearntCodeTable()
        } else if inputBuffer.isEmpty, learningOne == nil, !codeTable.from.contains(.custom) {
            var t = codeTable
            t.code = inputedBuffer
            t.weight = 0

            addCodeTableFreq(t, index: index)
        }
    }

    func addCodeTableFreq(_ codeTable: CodeTable, index: Int) {
        var codeTable = codeTable
        if ConfigManager.shared.quickUserDict, index == 0 {
            codeTable.weight = 1234
        }
        // 如果是快速学习模式，首选不计入词频

        // 无论是不是码表都存词频，是否启用在查询时设定
        if codeTable.from.contains(.assisted), !ConfigManager.shared.assistInUserDict { return }

        Database.shared.cleanCache()

        DispatchQueue.global().async {
            if codeTable.from.contains(.assisted) {
                codeTable.code = codeTable.code.subString(to: codeTable.code.count - codeTable.assistedCode.count)
            }
            Database.shared.updateTableToUserDict(codeTable: codeTable)
        }
    }

    func dropLearntCodeTable() {
        learningOne = nil
    }

    func confirmLearntCodeTable() {
        guard var ct = learningOne else { return }
        learningOne = nil
        ct.weight = 1
        DispatchQueue.global().async {
            Database.shared.updateTableToUserDict(codeTable: ct)
        }
    }
}
