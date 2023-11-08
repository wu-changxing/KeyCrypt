//
//  Database+Extended.swift
//  LoginputKeyboard
//
//  Created by Aaron on 7/30/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import LoginputEngineLib

extension Database {
    // MARK: 从外置扩展词库查词

    func getCodeTableOrderedByWeightExtendedDB(from pylist: [[String]]) -> CodeTableArray {
        let m = ConfigManager.shared
//        guard !m.disableDatabase, m.extendedDict else { return [] }
        let length = pylist.count

//        guard length <= 10, length > 1 else { return [] } // 如果查询的代码不符合规则就提前退出避免数据库出错

        let sqlForExp: String = "SELECT Word,Weight FROM \"w\(length)\" WHERE \(getSql_String(fromPy: pylist))  ORDER BY Weight"

        var extendedCodeTables: CodeTableArray = []
        extendedDBQueue?.inDatabase { db in
            if let resultSet = db.executeQuery(sqlForExp) {
                while resultSet.next() {
                    var codeTable = CodeTable()
                    codeTable.table = (resultSet.string(forColumnIndex: 0))!
                    codeTable.weight = resultSet.double(forColumnIndex: 1)
                    extendedCodeTables.append(codeTable)
                } //                print(count)
                resultSet.close()
            }
        }
        return extendedCodeTables.unique
    }

    func getSql_String(fromPy pylist: [[String]]) -> String {
        var condition = " "
        let fuzzy_list = PyString.py2fuzzy(pyList: pylist, config: ConfigManager.shared)

        for i in 0 ..< fuzzy_list.count {
            if i == fuzzy_list.count - 1, let a = fuzzy_list[i].first, PyString.isShengMu(from: a) {
                condition = condition + "p\(i + 1) >= '\(a)' and p\(i + 1) < '\(a)zzzzzzzz'     "
                break
            }
            condition = condition + "p\(i + 1) in ('\(fuzzy_list[i].joined(separator: "','"))') and "
        }
        return condition.subString(to: -4)
    }
}
