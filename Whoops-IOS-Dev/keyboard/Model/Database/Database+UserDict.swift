//
//  Database+UserDict.swift
//  LoginputKeyboard
//
//  Created by Aaron on 4/22/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import LoginputEngineLib

// MARK: user dict

let kMaxWeight: Double = 9_999_999
extension Database {
    var userdictTableName: String {
        if ConfigManager.shared.isCodeTableModeOn, ConfigManager.shared.quanPin {
            return ConfigManager.shared.codeTableName + "Quanpin"
        } else if ConfigManager.shared.quanPin { return "Quanpin" }

        if !ConfigManager.shared.disableDatabase, !ConfigManager.shared.isCodeTableModeOn {
            return ConfigManager.shared.inputPlanName
        } else {
            return ConfigManager.shared.codeTableName + ConfigManager.shared.inputPlanName
        }
    }

    func checkUserDictTable(name: String) {
        let sql: String = "CREATE TABLE IF NOT EXISTS \"\(name)\" ('Py' TEXT NOT NULL ,'Word' TEXT NOT NULL ,'Weight' double NOT NULL , 'New' BOOL NOT NULL DEFAULT true)"
        let sql2 = "CREATE INDEX IF NOT EXISTS \"\(name)_index\" on \"\(name)\" ('Py' DESC, 'Weight' DESC)"
        userDBQueue.inDatabase { (db) -> Void in
            _ = db.executeUpdate(sql)
            _ = db.executeUpdate(sql2)
        }
    }

    private func insertTableToUserDict(codeTable: CodeTable) {
        checkUserDictTable(name: userdictTableName)
        // new 字段不再使用，原本是给dag用的，现在已经废弃了

        if ConfigManager.shared.quanPin, ConfigManager.shared.superSP, PyString.isValidPinyin(for: codeTable.code), codeTable.table.count > 1 {
            // 如果是全拼，开启了超级简拼，且buffer是合法拼音，但内容是词汇，就过滤掉，避免冲击全拼单字
            return
        }

        let sql: String = "INSERT INTO \"\(userdictTableName)\" VALUES(\"\(codeTable.code)\",\"\(codeTable.table)\",\"\(codeTable.weight)\",0 ) "
        userDBQueue.inDatabase { (db) -> Void in
            _ = db.executeUpdate(sql)
        }
    }

    func setMaxCandidate(codeTable: CodeTable) {
        checkUserDictTable(name: userdictTableName)
        let rowId = getUserDictRowId(fromCodeTable: codeTable)
        userDBQueue.inDatabase { db in
            _ = db.executeUpdate("DELETE FROM \"\(self.userdictTableName)\" WHERE Py=? and Weight>=?", withArgumentsIn: [codeTable.code, codeTable.weight])
            if ConfigManager.shared.quanPin, codeTable.code.contains(char: "'") {
                let code = codeTable.code.replacingOccurrences(of: "'", with: "")
                _ = db.executeUpdate("DELETE FROM \"\(self.userdictTableName)\" WHERE Py=? and Weight>=?", withArgumentsIn: [code, codeTable.weight])
            }
        }
        if rowId == -1 {
            insertTableToUserDict(codeTable: codeTable)
        } else {
            updateTableToUserDict(codeTable: codeTable, toRemove: false, maxWeight: true)
        }
    }

    func updateTableToUserDict(codeTable: CodeTable, toRemove: Bool = false, maxWeight: Bool = false) {
        func special() {
            var codeTable = codeTable
            if ConfigManager.shared.quanPin, codeTable.code.contains(char: "'") {
                codeTable.weight = 1
                codeTable.code = codeTable.code.replacingOccurrences(of: "'", with: "")
                updateTableToUserDict(codeTable: codeTable, toRemove: toRemove, maxWeight: maxWeight)
            }
            if codeTable.table.count > 1, codeTable.pyList.count > 1, ConfigManager.shared.superSP { // 如果是拼音就单独处理全拼变简拼
                var str = ""
                for py in codeTable.pyList {
                    str += py.subString(to: 1)
                }
                codeTable.weight = 1
                codeTable.code = str
                codeTable.pyList.removeAll()
                updateTableToUserDict(codeTable: codeTable, toRemove: toRemove, maxWeight: maxWeight)
            }
        }
        if codeTable.weight == 1234 {
            special()
            return
        }

        checkUserDictTable(name: userdictTableName)

        let rowId = getUserDictRowId(fromCodeTable: codeTable)

        if rowId == -1 {
            if toRemove { return }
            insertTableToUserDict(codeTable: codeTable)
        } else {
            if toRemove {
                userDBQueue.inDatabase { db in
                    _ = db.executeUpdate("DELETE FROM \"\(self.userdictTableName)\" WHERE rowid=\(rowId)")
//                    _ = db.executeStatements("vacuum")
                }
            } else {
                if maxWeight {
                    userDBQueue.inDatabase { db in
                        _ = db.executeUpdate("UPDATE \"\(self.userdictTableName)\" SET Weight=\(codeTable.weight) WHERE rowid=\(rowId)")
                    }
                } else {
                    userDBQueue.inDatabase { db in
                        _ = db.executeUpdate("UPDATE \"\(self.userdictTableName)\" SET Weight=Weight+1 WHERE rowid=\(rowId)")
                    }
                }
            }
        }

        special()
    }

    func traceBackUserDict(codeTable: CodeTable) {
        checkUserDictTable(name: userdictTableName)
        let sql: String = "SELECT rowid,Weight FROM \"\(userdictTableName)\" WHERE Py=? and Word=?"
        var rowId = -1
        var weight = -1
        userDBQueue.inDatabase { db in
            if let resultSet = db.executeQuery(sql, withArgumentsIn: [codeTable.code, codeTable.table]), resultSet.next() {
                rowId = Int(resultSet.int(forColumnIndex: 0))
                weight = Int(resultSet.int(forColumnIndex: 1))
                resultSet.close()
            }
        }
        guard rowId != -1 else { return }
        let toRemove = weight - 1 <= 0
        if toRemove {
            userDBQueue.inDatabase { db in
                _ = db.executeUpdate("DELETE FROM \"\(self.userdictTableName)\" WHERE rowid=\(rowId)")
                //                    _ = db.executeStatements("vacuum")
            }
        } else {
            userDBQueue.inDatabase { db in
                _ = db.executeUpdate("UPDATE \"\(self.userdictTableName)\" SET Weight=Weight-1 WHERE rowid=\(rowId)")
            }
        }
        if ConfigManager.shared.quanPin, codeTable.code.contains(char: "'") {
            var codeTable = codeTable
            codeTable.code = codeTable.code.replacingOccurrences(of: "'", with: "")
            traceBackUserDict(codeTable: codeTable)
        }
    }

    func getUserDictRowId(fromCodeTable codeTable: CodeTable) -> Int {
        checkUserDictTable(name: userdictTableName)
        let sql: String = "SELECT rowid FROM \"\(userdictTableName)\" WHERE Py=? and Word=?"
        var rowId = -1
        userDBQueue.inDatabase { db in
            if let resultSet = db.executeQuery(sql, withArgumentsIn: [codeTable.code, codeTable.table]), resultSet.next() {
                rowId = Int(resultSet.int(forColumnIndex: 0))
                resultSet.close()
            }
        }
        return rowId
    }

    func isCodeTableInDatabase(codeTable: CodeTable) -> Bool {
        let rowId = getUserDictRowId(fromCodeTable: codeTable)
        return rowId >= 0
    }

    func userDictSql(fromCode code: String) -> String {
        var sqlCode = ""
        for char in code {
            sqlCode.append("\(char)_")
        }
        return sqlCode
    }
}
