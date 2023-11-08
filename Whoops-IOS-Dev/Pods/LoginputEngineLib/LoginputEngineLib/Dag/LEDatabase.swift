//
//  Database.swift
//  LMDB Test
//
//  Created by Aaron on 5/4/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import Foundation
import SQLite3

class LEDatabase {
    let kMinValue = "min_value".encode()
    let kMinValue2 = "___".encode()
    let kMinValue3 = "_____".encode()
    var minValueCache1:Double?
    var minValueCache2:Double?
    var minValueCache3:Double?
    
    var dagDBQueue: FMDatabaseQueue?
    weak var config: LEConfigDelegate?
    var env: Environment?
    var db: Database?
    var dagAvaliable = true
        
    var cache1 = LogCache<GBString,Double>()
    var cache2 = LogCache<GBString,Double>()
    var cache3 = LogCache<GBString,Double>()
    
    func cleanCache() {
        cache1.clear()//chche 123 分别对应的表是？
        cache2.clear()
        cache3.clear()
    }
    init(emissionPath: String, transitionPath: String, configDelegate: LEConfigDelegate?) {
        if FileManager.default.fileExists(atPath: transitionPath) {
            self.env = try? Environment(path: transitionPath, flags: [.readOnly, .noLock, .noSubDir], maxDBs: 1, mapSize: 10485760)
            self.db = try! env?.openDatabase(named: nil, flags: [])
        } else {
            self.dagAvaliable = false
        }
        
        self.config = configDelegate
        self.dagDBQueue = FMDatabaseQueue(path: emissionPath, flags: SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_EXCLUSIVE)
        self.dagDBQueue?.inDatabase {$0.executeStatements("""
            PRAGMA page_size = 4096;
            PRAGMA synchronous = OFF;
            PRAGMA locking_mode =  EXCLUSIVE;
            PRAGMA journal_mode = OFF;
            PRAGMA temp_store = MEMORY;
            PRAGMA cache_size = 40960;
            PRAGMA mmap_size = 40960;
            PRAGMA query_only = 1;
            """) }

    }
    
    func getWordsWithGram1Weight(from pinyin: PyList) -> [GBString: Double]? {
        var result: [GBString: Double] = [:]
        guard let words = getWords(from: pinyin) else { return nil }
        for word in words {
            result[word] = getGram1WeightFrom(word: word)
        }
        return result
    }
    
    func getWords(from pylist: PyList, plus_one: Bool = false, sortHeads: Bool = false) -> [GBString]? {
        // 整句搜索的部分
        guard !pylist.isEmpty else { return nil }
        if pylist.count == 1 {
            for py in pylist[0] where PyString.isShengMu(py) {
                // 如果只查一阶且是模糊查询，就跳过，加速超级简拼的查询速度
                return nil
            }
        }
        var length = pylist.count
        if plus_one { length += 1 }
        guard length <= 8, length > 0 else { return nil } // 如果查询的代码不符合规则就提前退出避免数据库出错
        let sqlForExp: String = "SELECT Words FROM \"w\(length)\" WHERE \(getSql4dagDB(fromPy: pylist)) "
        
        var words: [[GBString]] = []
        var resultCount = 0
        self.dagDBQueue?.inDatabase({ (db) in
            if let resultSet = try? db.executeQuery(sqlForExp, values: nil) {
                while resultSet.next() {
                    guard let s = resultSet.data(forColumnIndex: 0)?.splitedGBString() else { continue }
                    words.append(s)
                    resultCount += s.count
                }
                resultSet.close()
            }
        })

        guard !words.isEmpty else { return nil }
        
        var result :[GBString] = []
        result.reserveCapacity(resultCount > 99 ? 50 : resultCount) //resultCount统计的是字数
        if sortHeads {
            let stack = PriorityStack<WordsNode>(Length: resultCount > 99 ? 50 : resultCount)
            for i in 0..<words.count {
                words[i].forEach {
                    stack.push(WordsNode(path: $0, score: getGram1WeightFrom(word: $0)))
                }
            }
            result = stack.map { $0.path! }
        } else {
            if resultCount > 99 {
                result = Array(mashUp(contents: words).prefix(50))
            } else {
                result = mashUp(contents: words)
            }
        }
        return result
    }
    
    func getGram1WeightFrom(word: GBString) -> Double {
        //获取score
        if let d = cache1[word] { return d }
        
        if let d = db?.getDouble(for: word) {
            cache1[word] = d
            return d
        }
        if let d = minValueCache1 {
            return d
        }
        if let d = db?.getDouble(for: kMinValue) {
            minValueCache1 = d - 9.5
            return d - 9.5
        }
        return -999999
    }
    
    func getGram2WeightFrom(lastOne: GBString, one: GBString) -> Double {
        var key = lastOne
        key.appendGBString(another: one)
        if let d = cache2[key] { return d }
        
        if let d = db?.getDouble(for: key) {
            cache2[key] = d
            return d
        }
        if let d = minValueCache2 {
            return d
        }
        if let d = db?.getDouble(for: kMinValue2) {
            minValueCache2 = d
            return d
        }
        return -999999//理论上不会到这里
    }
    
    func getGram3WeightFrom(lastLastOne: GBString, lastOne: GBString, one: GBString) -> Double {
        var key = lastLastOne
        key.appendGBString(another: lastOne)
        key.appendGBString(another: one)

        if let d = cache3[key] { return d }
        if let d = db?.getDouble(for: key) {
            cache3[key] = d
            return d
        }
        if let d = minValueCache3 {
            return d
        }
        if let d = db?.getDouble(for: kMinValue3) {
            minValueCache3 = d
            return d
        }
        return -999999//理论上不会到这里
    }
}

extension LEDatabase {
    func mashUp(contents: [[GBString]]) -> [GBString] {
        guard !contents.isEmpty else { return [] }//空返回空
        
        guard contents.count > 1 else {
            return contents[0]//小于1 返回第一个
        }
        
        var elementsCount = 0
        var maxLength = 0
        
        for i in 0 ..< contents.count {
            elementsCount += contents[i].count
            maxLength = max(maxLength, contents[i].count)
        }
        var result:[GBString] = []
        result.reserveCapacity(elementsCount)
        for i in 0 ..< maxLength {
            for listIndex in 0 ..< contents.count where contents[listIndex].count > i {
                result.append(contents[listIndex][i])
            }
        }
        return result
    }
}
