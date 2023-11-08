//
//  Database+KeyLogger.swift
//  LoginputKeyboard
//
//  Created by Aaron on 5/15/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import Foundation
enum KeyLoggerType: String {
    case key, char
}

extension Database {
    func checkKeyLoggerTable() {
        let sql: String = "CREATE TABLE IF NOT EXISTS \"Key\" ('year' INT NOT NULL ,'month' INT NOT NULL ,'day' INT NOT NULL ,'count' INT NOT NULL )"
        let sql2 = "CREATE TABLE IF NOT EXISTS \"Char\" ('year' INT NOT NULL ,'month' INT NOT NULL ,'day' INT NOT NULL ,'count' INT NOT NULL )"

        keyLoggerDBQueue?.inDatabase { (db) -> Void in
            _ = db.executeUpdate(sql)
            _ = db.executeUpdate(sql2)
        }
    }

    func addCount(_ n: Int, for type: KeyLoggerType, at date: Date) {
        checkKeyLoggerTable()
        let tableName = type.rawValue.capitalized
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: date)
        keyLoggerDBQueue.inDatabase { db in
            db.executeStatements("""
            update \"\(tableName)\" set \"count\"=count+\(n) where \"year\"=\(dateComponents.year!) and \"month\"=\(dateComponents.month!) and \"day\"=\(dateComponents.day!);
            insert into \"\(tableName)\" (\"year\",\"month\",\"day\",\"count\") select \(dateComponents.year!),\(dateComponents.month!),\(dateComponents.day!),\(n) where (select changes()=0);
            """)
//            db.executeUpdate("""
//                            update \"\(tableName)\" set \"count\"=count+\(n) where \"year\"=? and \"month\"=? and \"day\"=?;
//                            insert into \"\(tableName)\" (\"year\",\"month\",\"day\",\"count\") select ?,?,?,? where (select changes()=0);
//                            """, dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.year!,dateComponents.month!,dateComponents.day!,n)
        }
    }

    func all(for type: KeyLoggerType) -> Int {
        checkKeyLoggerTable()
        var count = 0
        let tableName = type.rawValue.capitalized
        keyLoggerDBQueue.inDatabase { db in
            if let resultSet = db.executeQuery("select sum(count) from \"\(tableName)\""), resultSet.next() {
                count = Int(resultSet.int(forColumnIndex: 0))
                resultSet.close()
            }
        }
        return count
    }

    func all(day: Int, month: Int, year: Int, for type: KeyLoggerType) -> Int {
        checkKeyLoggerTable()
        var count = 0
        let tableName = type.rawValue.capitalized
        keyLoggerDBQueue.inDatabase { db in
            if let resultSet = db.executeQuery("select sum(count) from \"\(tableName)\" where \"year\"=? and \"month\"=? and \"day\"=?", year, month, day), resultSet.next() {
                count = Int(resultSet.int(forColumnIndex: 0))
                resultSet.close()
            }
        }
        return count
    }

    func all(month: Int, year: Int, for type: KeyLoggerType) -> Int {
        checkKeyLoggerTable()
        var count = 0
        let tableName = type.rawValue.capitalized
        keyLoggerDBQueue.inDatabase { db in
            if let resultSet = db.executeQuery("select sum(count) from \"\(tableName)\" where \"year\"=? and \"month\"=?", year, month), resultSet.next() {
                count = Int(resultSet.int(forColumnIndex: 0))
                resultSet.close()
            }
        }
        return count
    }

    func all(year: Int, for type: KeyLoggerType) -> Int {
        checkKeyLoggerTable()
        var count = 0
        let tableName = type.rawValue.capitalized
        keyLoggerDBQueue.inDatabase { db in
            if let resultSet = db.executeQuery("select sum(count) from \"\(tableName)\" where \"year\"=?", year), resultSet.next() {
                count = Int(resultSet.int(forColumnIndex: 0))
                resultSet.close()
            }
        }
        return count
    }
}
