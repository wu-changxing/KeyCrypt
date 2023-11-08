//
//  Database+Think.swift
//  LoginputKeyboard
//
//  Created by Aaron on 4/22/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import Foundation
let thinkCharBlackList: Set<String> = ["", " ", "\r", "\n", "\u{2028}"]
extension Database {
    func checkThinkTable() {
        let sql: String = "CREATE TABLE IF NOT EXISTS \"Think\" ('from' INT NOT NULL ,'to' TEXT NOT NULL ,'count' INT NOT NULL )"
        let sql2 = "CREATE INDEX IF NOT EXISTS \"Think_index\" on \"Think\" (\"from\" DESC, \"count\" DESC)"

        thinkDBQueue?.inDatabase { (db) -> Void in
            _ = db.executeUpdate(sql)
            _ = db.executeUpdate(sql2)
        }
    }

    func updateThinkDB(from: String, to: String) {
        guard thinkCharBlackList.firstIndex(of: to) == nil else { return }
        let hash = from.slmHash
        let rowId = getThinkDBRowId(from: hash, to: to)
        if rowId >= 0 {
            thinkDBQueue?.inDatabase { db in
                db.executeUpdate("UPDATE \"Think\" SET \"count\"=count+1 WHERE rowid=?", rowId)
            }
        } else {
            thinkDBQueue?.inDatabase { $0
                .executeUpdate("INSERT INTO \"Think\" VALUES(?,?,?)", hash, to, 0)
            }
            thinkDBCanRemoveLast = true
        }
    }

    func think(from: String) -> CodeTableArray {
        checkThinkTable()
        var result: CodeTableArray = []
        thinkDBQueue?.inDatabase { db in
            if let resultSet = db.executeQuery("select \"to\" from \"Think\" where \"from\"=? ORDER BY \"count\" DESC limit 50", from.slmHash) {
                while resultSet.next() {
                    let content = resultSet.string(forColumnIndex: 0)!
                    let ct = CodeTable(Table: content)
                    result.append(ct)
                }
                resultSet.close()
            }
        }
        return result
    }

    func removeFromThinkDB(to: String) {
        thinkDBQueue?.inDatabase { db in
            db.executeUpdate("DELETE FROM \"Think\" WHERE \"to\"=?", to)
        }
    }

    func tryRemoveNewThink() {
        guard thinkDBCanRemoveLast else { return }
        var lastId: Int32 = 0
        thinkDBQueue?.inDatabase { db in
            if let resultSet = db.executeQuery("SELECT max(rowid) FROM \"Think\""), resultSet.next() {
                lastId = resultSet.int(forColumnIndex: 0)
                resultSet.close()
            }
        }
        guard lastId > 0 else { return }

        var count = 0
        thinkDBQueue?.inDatabase { db in
            if let resultSet = db.executeQuery("SELECT count FROM \"Think\" WHERE rowid=?", lastId), resultSet.next() {
                count = Int(resultSet.int(forColumnIndex: 0))
                resultSet.close()
            }
        }
        if count > 0 {
            thinkDBQueue?.inDatabase { db in
                db.executeUpdate("UPDATE \"Think\" SET \"count\"=count-1 WHERE rowid=?", lastId)
            }
        } else {
            thinkDBQueue?.inDatabase { db in
                db.executeUpdate("DELETE FROM \"Think\" WHERE rowid=?", lastId)
            }
        }
        thinkDBCanRemoveLast = false
    }

    func getThinkDBRowId(from: Int64, to: String) -> Int {
        checkThinkTable()
        var rowId = -1
        thinkDBQueue?.inDatabase {
            if let resultSet = $0.executeQuery("SELECT rowid FROM \"Think\" WHERE \"from\"=? and \"to\"=?", withArgumentsIn: [from, to]), resultSet.next() {
                rowId = Int(resultSet.int(forColumnIndex: 0))
                resultSet.close()
            }
        }
        return rowId
    }

    func isTransitionInThinkDB(from: Int64, to: String) -> Bool {
        let rowId = getThinkDBRowId(from: from, to: to)
        return rowId >= 0
    }

    func isStringInThinkDB(_ s: String) -> Bool {
        checkThinkTable()
        var rowId = -1
        thinkDBQueue?.inDatabase {
            if let resultSet = $0.executeQuery("SELECT rowid FROM \"Think\" WHERE \"to\"=?", s), resultSet.next() {
                rowId = Int(resultSet.int(forColumnIndex: 0))
                resultSet.close()
            }
        }
        return rowId > -1
    }
}
