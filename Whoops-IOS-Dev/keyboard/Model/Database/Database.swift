//
//  Database.swift
//  flyinput
//
//  Created by Aaron on 16/7/30.
//  Copyright © 2016年 Aaron. All rights reserved.
//
import Foundation
import LoginputEngineLib
import SQLite3

private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

public final class Database {
    private init() {}

    public static let shared = Database()

    private var databaseQueue: FMDatabaseQueue?
    var superJP_DBQueue: FMDatabaseQueue!
    var extendedDBQueue: FMDatabaseQueue?

    private var englishDBQueue: FMDatabaseQueue!
    private var smartHintDBQueue: FMDatabaseQueue!
    private var emojiDBQueue: FMDatabaseQueue!
    private var assistDBQueue: FMDatabaseQueue?
    private var customDBQueue: FMDatabaseQueue?

    var t9dictQueue: FMDatabaseQueue?

    var keyLoggerDBQueue: FMDatabaseQueue!
    var userDBQueue: FMDatabaseQueue!
    var thinkDBQueue: FMDatabaseQueue!
    let queue = DispatchQueue(label: "com.logcg.LogInputMac.queue.Databases", qos: .userInitiated, attributes: .concurrent)
    let group = DispatchGroup()

    var thinkDBCanRemoveLast = false

    func releaseMe() {
        databaseQueue?.close()
        superJP_DBQueue.close()
        englishDBQueue.close()
        smartHintDBQueue.close()
        emojiDBQueue.close()
        assistDBQueue?.close()
        customDBQueue?.close()
        userDBQueue.close()
        thinkDBQueue.close()
        keyLoggerDBQueue.close()
        t9dictQueue?.close()
    }
    
    deinit {
        releaseMe()
    }

    // MARK: 从自定义码表查词

    func getCustomCodeTableOrderedByWeight(fromCode code: String) -> CodeTableArray {
        var codeTables: CodeTableArray = []
        customDBQueue?.inDatabase { db in
            guard let resultSet = db.executeQuery("SELECT \"Code\",\"Table\",\"Weight\" FROM CodeTable WHERE Code=? ", withArgumentsIn: [code]) else { return }

            while resultSet.next() {
                var codeTable = CodeTable()
                codeTable.code = (resultSet.string(forColumnIndex: 0))! // 获取编码为反查编码做准备--自定义编码不再支持模糊查询，也不支持编码反查了
                codeTable.table = (resultSet.string(forColumnIndex: 1))!
                if codeTable.table.contains(char: "#") {
                    codeTable.table = codeTable.table.stringWithDateMacro()
                }
                codeTable.weight = resultSet.double(forColumnIndex: 2)
//                codeTable.from = .main
                codeTable.from = .custom
                codeTables.append(codeTable)
            }
            resultSet.close()
        }
        return codeTables
    }

    /// 从码表反查编码
    ///
    /// - Parameter tbales: 要反查的候选列表
    func getCode(fromTable tables: inout CodeTableArray) {
        guard ConfigManager.shared.isCodeTableModeOn else { return }
        let wordList = tables.map { $0.table }
        databaseQueue?.inDatabase {
            guard let resultSet = $0.executeQuery("SELECT \"Code\",\"Table\" FROM CodeTable WHERE \"Table\" in ('\(wordList.joined(separator: "','"))') ORDER BY Weight") else { return }
            while resultSet.next() {
                let code = resultSet.string(forColumnIndex: 0)!
                let table = resultSet.string(forColumnIndex: 1)!

                if let index = wordList.firstIndex(of: table) {
                    tables[index].code = code
                }
            }
        }
    }

    // MARK: 从码表查词

    func getCodeTableOrderedByWeight(fromCode code: String, asPrefix prefix: Bool = false) -> CodeTableArray {
        var codeTables: CodeTableArray = []
        var prefix = prefix
        var maskOnlyCharacter = false
        var method = "="
        if code.contains(char: "_") {
            prefix = false // 如果是通配，就不反查
            method = " like "
            maskOnlyCharacter = ConfigManager.shared.maskOnlyCharacter
        }
        if prefix {
            let a = code
            let b = code + "zzzzzzzzzz"
            databaseQueue?.inDatabase { db in
                guard let resultSet = db.executeQuery("SELECT \"Code\",\"Table\" FROM CodeTable WHERE Code >= ? and Code < ? ORDER BY Weight limit 200", withArgumentsIn: [a, b]) else { return }
                while resultSet.next() {
                    var codeTable = CodeTable()
                    codeTable.code = resultSet.string(forColumnIndex: 0)!
                    codeTable.table = resultSet.string(forColumnIndex: 1)!
                    codeTable.from = .main
                    codeTables.append(codeTable)
                }
                resultSet.close()
            }
        } else {
            databaseQueue?.inDatabase { db in
                guard let resultSet = db.executeQuery("SELECT \"Code\",\"Table\" FROM CodeTable WHERE Code\(method)? ORDER BY Weight limit 200", withArgumentsIn: [code]) else { return }
                while resultSet.next() {
                    var codeTable = CodeTable()
                    codeTable.code = resultSet.string(forColumnIndex: 0)! // 获取编码为反查编码做准备
                    codeTable.table = resultSet.string(forColumnIndex: 1)!
                    codeTable.from = .main
                    if maskOnlyCharacter {
                        if codeTable.table.count == 1 {
                            codeTables.append(codeTable)
                        }
                    } else {
                        codeTables.append(codeTable)
                    }
                }
                resultSet.close()
            }
        }
        return codeTables
    }

    // MARK: 从用户词库查词

    func getCodeTableOrderedByWeightInUserDB(fromCode code: String) -> CodeTableArray {
        guard ConfigManager.shared.userDict else { return [] }

        checkUserDictTable(name: userdictTableName)
        var noSuperJp = ""
        let except = code.count == 1

        if !ConfigManager.shared.superSP, !ConfigManager.shared.isCodeTableModeOn, !except {
            noSuperJp = "and length(Py)>length(Word)"
        }
        let sql: String = "SELECT * FROM \"\(userdictTableName)\" WHERE Py=? \(noSuperJp) ORDER BY Weight DESC limit 100"
        var codeTables: CodeTableArray = []

        userDBQueue.inDatabase { db in
            if let resultSet = db.executeQuery(sql, withArgumentsIn: [code]) {
                var counter = 0

                while resultSet.next() {
                    var codeTable = CodeTable()
                    codeTable.code = (resultSet.string(forColumnIndex: 0))!
                    codeTable.table = (resultSet.string(forColumnIndex: 1))!
                    codeTable.weight = resultSet.double(forColumnIndex: 2)
                    codeTable.from = .user
                    codeTables.append(codeTable)
                    counter += 1
                }
                resultSet.close()
            }
        }

        return codeTables
    }

    private let cache = LogCache<String, CodeTableArray>()

    func cleanCache() {
        cache.clear()
    }

    // MARK: 从扩展词库查词

    func getCodeTableOrderedByWeightInExpandDB(fromCode code: String, withLimit _: Int = 100, dag: Bool = false, fullpylist: PyList = []) -> CodeTableArray {
        let m = ConfigManager.shared
        guard !m.disableDatabase || !fullpylist.isEmpty else { return [] }
        if let r = cache[code] { return r } //从cache中获取 code内容为 \'kei'
        let pylist = fullpylist //pyList是完全的列表
        let isSuperJP = code.count == pylist.count && code.count > 1 // 超级简拼使用专门的简拼库查询，不从这里查

        guard let s = pylist.last?.first, s > 0, !isSuperJP else { return [] }

        var codeTables: CodeTableArray = []
        queue.async(group: group) {
            //pylist:ke le kei lei 得到的结果为这几个拼音对应所有的汉字
            codeTables = LoginputEngineLib.shared.getWords(from: pylist).map { CodeTable(Table: $0) }
        }
        var extendedTables: CodeTableArray = []
        queue.async(group: group) { [weak self] in
            guard !dag, self != nil else { return }
            extendedTables = self!.getCodeTableOrderedByWeightExtendedDB(from: PyString.pyList2s(from: pylist))
        }
        _ = group.wait(timeout: DispatchTime.now() + 0.5)

        if codeTables.isEmpty {
            codeTables = extendedTables
        } else {
            codeTables.insert(contentsOf: extendedTables, at: 1)
            codeTables = codeTables.unique
        }
        codeTables = Array(codeTables.prefix(6))
        cache[code] = codeTables
        return codeTables //返回词语 类比 累次
    }
    
    func getCodeTableFromFuture(fromCode code: String, fullpylist: PyList = []) -> CodeTable? {//？模糊查询
        let m = ConfigManager.shared
        guard !m.disableDatabase else { return nil }

        let pylist = fullpylist //是所有拼音列表 pinyin

        let length = pylist.count + 1

        let tableNameE = "w\(length)"

        let a = code
        let b = code + "zzzzzzzzzzzzzzzzzzzz"
        let sqlForUser: String = "SELECT * FROM \"\(userdictTableName)\" WHERE Py > ? and Py < ? ORDER BY Weight DESC limit 1"
        let sqlForExp: String = "SELECT Word FROM \"\(tableNameE)\" WHERE \(getSql4dagDB(fromPy: pylist)) "

        var codeTables: CodeTable?
        queue.async(group: group) {
            guard ConfigManager.shared.userDict else { return }

            self.userDBQueue.inDatabase { db in
                if let resultSet = db.executeQuery(sqlForUser, withArgumentsIn: [a, b]), resultSet.next() {
                    var codeTable = CodeTable()
                    codeTable.code = (resultSet.string(forColumnIndex: 0))!
                    codeTable.table = (resultSet.string(forColumnIndex: 1))!
                    codeTable.weight = resultSet.double(forColumnIndex: 2)

                    codeTable.from = .user
                    codeTables = codeTable
                    resultSet.close()
                }
            }
        }
        var dicCodeTable: CodeTable?
        queue.async(group: group) {
            guard let r = LoginputEngineLib.shared.getWords(from: pylist, plus_one: true).first else { return }
            dicCodeTable = CodeTable(Table: r)
        }
        var extendedCodeTables: CodeTable?
        queue.async(group: group) {
            self.extendedDBQueue?.inDatabase { db in
                if let resultSet = db.executeQuery(sqlForExp + " ORDER BY Weight limit 1"), resultSet.next() {
                    extendedCodeTables = CodeTable(Table: (resultSet.string(forColumnIndex: 0))!)
                    resultSet.close()
                }
            }
        }
        _ = group.wait(timeout: DispatchTime.now() + 0.5)
        return codeTables ?? extendedCodeTables ?? dicCodeTable
    }

    // MARK: 从扩展词库查简拼

    func getCodeTableOrderedByWeightInExpandDBSuperSP(fromCode _: String, fullpylist: PyList = []) -> CodeTableArray {
        let m = ConfigManager.shared
        let opt = ConfigManager.shared.quanPin && fullpylist.count > 1
        guard !m.disableDatabase, opt || !ConfigManager.shared.quanPin else { return [] }
        let pylist = fullpylist
        let length = pylist.count
//        let r = LoginputEngineLib.shared.getWords(from: PyString.pyList2i(from: pylist)).map{CodeTable(Table: $0)}
//        return Array(r.prefix(20))

        guard length < 6, length > 1 else { return [] } // 如果查询的代码不符合规则就提前退出避免数据库出错
        var codeTables: CodeTableArray = []
        let sqlForExp: String = "SELECT Word FROM \"jw\(length)\" WHERE \(getSql4dagDB(fromPy: pylist)) "
        var word = ""
        superJP_DBQueue.inDatabase { db in
            if let resultSet = db.executeQuery(sqlForExp, withArgumentsIn: []) {
                while resultSet.next() {
                    word += resultSet.string(forColumnIndex: 0)! + "|"
                } //                print(count)
                resultSet.close()
            }
        }
        var lastWord = ""
        autoreleasepool {
            for (index, w) in word.split(separator: "|", maxSplits: Int.max, omittingEmptySubsequences: true).enumerated() {
                if index % 2 == 0 {
                    lastWord = String(w)
                } else {
                    let ct = CodeTable(Table: lastWord, Weight: Double(w) ?? 0)
                    codeTables.append(ct)
                }
            }
        }

        codeTables.sort { $0.weight > $1.weight }

        return Array(codeTables.prefix(20))
    }

    // MARK: 从英文词库查词

    func getCodeTableOrderedByWeightInEnglishDB(fromCode code: String, asPrefix prefix: Bool = false, withLimit l: Int = 20) -> CodeTableArray {
        guard ConfigManager.shared.mixEnglishInput || isEnMode, !code.contains(char: "_") else { return [] }

        let code = code.lowercased()

        var codeTables: CodeTableArray = []

        let a = code
        let b = code + "zzzzzzzzzzzzzzzzzzzz"

        var r: CodeTableArray = []
        if isEnMode {
            r = code.getCompletions4En().map { s in
                var codeTable = CodeTable()
                codeTable.table = s
                codeTable.code = s
                codeTable.weight = 999_999
                codeTable.from = .english
                return codeTable
            }
        }

        if prefix {
            englishDBQueue.inDatabase { db in
                guard let resultSet = db.executeQuery("SELECT \"Table\",\"Code\",\"Weight\" FROM CodeTable WHERE Code >= ? and Code < ? ORDER BY Weight limit ?", withArgumentsIn: [a, b, l]) else { return }
                while resultSet.next() {
                    var codeTable = CodeTable()
                    codeTable.table = resultSet.string(forColumnIndex: 0) ?? ""
                    codeTable.code = resultSet.string(forColumnIndex: 1) ?? ""
                    codeTable.weight = resultSet.double(forColumnIndex: 2)
                    codeTable.from = .english
                    codeTables.append(codeTable)
                }
                resultSet.close()
            }
            if l == 1, codeTables.isEmpty, let c = r.first {
                codeTables.append(c)
            } else if codeTables.count < l {
                codeTables.append(contentsOf: r)
                codeTables = codeTables.unique
            }

        } else {
            englishDBQueue.inDatabase { db in
                guard let resultSet = db.executeQuery("SELECT \"Table\",\"Code\",\"Weight\" FROM CodeTable WHERE Code=? ORDER BY Weight limit ?", withArgumentsIn: [code, l]) else { return }
                while resultSet.next() {
                    var codeTable = CodeTable()
                    codeTable.table = resultSet.string(forColumnIndex: 0) ?? ""
                    codeTable.code = resultSet.string(forColumnIndex: 1) ?? ""
                    codeTable.weight = resultSet.double(forColumnIndex: 2)
                    codeTable.from = .english
                    codeTables.append(codeTable)
                }
                resultSet.close()
            }

            if codeTables.isEmpty, !r.isEmpty {
                codeTables.append(r[0])
            }
        }

        return codeTables
    }

    // MARK: 从英文词库查英文转移

    func getTransitionEn(from str: String) -> CodeTableArray {
        var result: CodeTableArray = []
        englishDBQueue.inDatabase {
            guard let resultSet = $0.executeQuery("select \"value\" from Transition where key=? limit 1 ", withArgumentsIn: [str.lowercased()]) else { return }
            while resultSet.next() {
                let s = resultSet.string(forColumnIndex: 0)!
                result = s.components(separatedBy: "|").map { CodeTable(Table: $0, from: .english_think) }
            }
        }
        return result
    }

    // MARK: 从联想库中查联想

    func getSmartHint(from str: String) -> CodeTableArray {
        var result: CodeTableArray = []
        smartHintDBQueue?.inDatabase {
            guard let resultSet = $0.executeQuery("select \"value\" from Hint where key=? limit 1 ", withArgumentsIn: [str.lowercased()]) else { return }
            while resultSet.next() {
                let s = resultSet.string(forColumnIndex: 0)!
                result = s.components(separatedBy: "|").map { CodeTable(Table: $0) }
            }
        }
        return result
    }

    // MARK: 从 Emoji 库中查 Emoji

    func getEmoji(from str: String, inputBuffer: String) -> CodeTableArray {
        var result: CodeTableArray = []
        var table = "Emoji_old"
        if #available(OSX 10.14.1, *) {
            table = "Emoji"
        }
        if #available(iOSApplicationExtension 12.1, *) {
            table = "Emoji"
        }
        emojiDBQueue.inDatabase {
            guard let resultSet = $0.executeQuery("select \"value\" from \(table) where key=? limit 1 ", withArgumentsIn: [str]) else { return }
            while resultSet.next() {
                let s = resultSet.string(forColumnIndex: 0)!
                result = s.components(separatedBy: "|").map { CodeTable(Code: inputBuffer, Table: $0, from: .emoji) }
            }
        }
        return result
    }

    // MARK: 从辅码码表查字

    func getAssistWord(fromCode code: String) -> String {
        var codeTables: String = ""
        assistDBQueue?.inDatabase { db in
            if let resultSet = db.executeQuery("SELECT \"Table\" FROM CodeTable WHERE Code=?", withArgumentsIn: [code]) {
                var tmp: [String] = []
                while resultSet.next() {
                    tmp.append(resultSet.string(forColumnIndex: 0)!)
                }
                codeTables = tmp.joined()
                resultSet.close()
            }
        }
        return codeTables
    }

    // MARK: 从辅码码表查码

    func getAssistWord(fromWord word: String) -> String {
        var codeTables: String = ""
        assistDBQueue?.inDatabase { db in
            if let resultSet = db.executeQuery("SELECT \"Code\" FROM TableCode WHERE \"Table\"=?", withArgumentsIn: [word]) {
                var tmp: [String] = []
                while resultSet.next() {
                    tmp.append(resultSet.string(forColumnIndex: 0)!)
                }
                codeTables = tmp.joined()
                resultSet.close()
            }
        }
        return codeTables
    }

    func needsReloadDBLink() {
        let rwSettings = """
        PRAGMA page_size = 4096;
        PRAGMA locking_mode =  EXCLUSIVE;
        PRAGMA temp_store = MEMORY;
        PRAGMA cache_size = 40960;
        PRAGMA mmap_size = 40960;
        PRAGMA synchronous = normal;
        """
        queue.async {
            self.userDBQueue = FMDatabaseQueue(path: Database.get(localPath: "user.db"))
            self.userDBQueue.inDatabase { $0.executeStatements(rwSettings) }
            self.keyLoggerDBQueue = FMDatabaseQueue(path: Database.get(localPath: "keys.db"))
            self.keyLoggerDBQueue.inDatabase { $0.executeStatements(rwSettings) }
            self.thinkDBQueue = FMDatabaseQueue(path: Database.get(localPath: "think.db"))
            self.thinkDBQueue.inDatabase { $0.executeStatements(rwSettings) }

            if ConfigManager.shared.extendedDict, !ConfigManager.shared.disableDatabase {
                self.extendedDBQueue = FMDatabaseQueue(path: FileSyncCheck.extendedDBDynamicPath, flags: SQLITE_OPEN_READONLY)
                self.setupDatabase(self.extendedDBQueue)
            }
            if ConfigManager.shared.isAssistCodeModeOn {
                self.assistDBQueue = FMDatabaseQueue(path: FileSyncCheck.assistDBDynamicPath, flags: SQLITE_OPEN_READONLY)
                self.setupDatabase(self.assistDBQueue)
            }

            if ConfigManager.shared.customCodeTableVersion >= 0 {
                self.customDBQueue = FMDatabaseQueue(path: FileSyncCheck.customDBDynamicPath, flags: SQLITE_OPEN_READONLY)
                self.setupDatabase(self.customDBQueue)
            }

            if ConfigManager.shared.isCodeTableModeOn {
                self.databaseQueue = FMDatabaseQueue(path: FileSyncCheck.mainCodeTableDBDynamicPath, flags: SQLITE_OPEN_READONLY)
                self.setupDatabase(self.databaseQueue)
            }

            self.superJP_DBQueue = self.loadReadOnlyDB(name: "superJP")
            self.setupDatabase(self.superJP_DBQueue)

            self.englishDBQueue = self.loadReadOnlyDB(name: "english")
            self.setupDatabase(self.englishDBQueue)

            self.smartHintDBQueue = self.loadReadOnlyDB(name: "smartHint")
            self.setupDatabase(self.smartHintDBQueue)

            self.emojiDBQueue = self.loadReadOnlyDB(name: "emoji")
            self.setupDatabase(self.emojiDBQueue)

            self.t9dictQueue = self.loadReadOnlyDB(name: "t9dict")
            self.setupDatabase(self.t9dictQueue)
        }
    }

    func loadReadOnlyDB(name: String) -> FMDatabaseQueue {
        let path = Bundle.main.path(forResource: name, ofType: "db")!
        return FMDatabaseQueue(path: path, flags: SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX | SQLITE_OPEN_EXCLUSIVE)!
    }

    func setupDatabase(_ db: FMDatabaseQueue?) {
        let rSettings = """
        PRAGMA page_size = 4096;
        PRAGMA locking_mode =  EXCLUSIVE;
        PRAGMA temp_store = MEMORY;
        PRAGMA cache_size = 40960;
        PRAGMA mmap_size = 40960;
        PRAGMA synchronous = OFF;
        PRAGMA query_only = 1;
        PRAGMA journal_mode = OFF;
        """
        db?.inDatabase { $0.executeStatements(rSettings) }
        db?.inDatabase { $0.shouldCacheStatements = true }
    }
}

// MARK: env

extension Database {
    /**
     获取的路径为 app groups 共享路径

     - author: Aaron
     - date: 16-08-14 16:08:13

     - parameter fileName: 文件名

     - returns: 共享目录的路径
     */
    private static var urlCache: String?
    class func get(groupPath fileName: String) -> String {
        if urlCache == nil {
            urlCache = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.logcg.Input")?.path
        }
        guard urlCache != nil else { return "" }
        return "\(urlCache!)/\(fileName)"
    }

    /**
     获取键盘自己容器储存路径

     - author: Aaron
     - date: 16-08-14 16:08:47

     - parameter fileName: 文件名

     - returns: 键盘自身路名
     */
    //    class func get(cachePath fileName: String) ->String {
    //            let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    ////            现在所有的数据库文件都存在缓存目录里
    //            let fileURL = documentsURL.appendingPathComponent(fileName)
    //            return fileURL.path
    //    }
    class func get(localPath fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return fileURL.path
    }

    class func copyFile(toCache fileName: String) {
        //        let dbPath: String = get(cachePath: "")
        //        copyFile(fileName, toPath: dbPath)
        copyFile(toDocument: fileName)
    }

    class func copyFile(toDocument fileName: String) {
        let dbPath: String = get(localPath: "")
        copyFile(fileName, toPath: dbPath)
    }

    class func copyFile(_ fileName: String, toPath: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: toPath) {
            do { try FileManager.default.removeItem(atPath: toPath) }
            catch {}
        }

        do {
            let fromPath = Bundle.main.resourceURL?.appendingPathComponent(fileName as String)

            try fileManager.copyItem(atPath: (fromPath?.path)!, toPath: toPath)
        } catch {}
    }
}

extension Database {}
