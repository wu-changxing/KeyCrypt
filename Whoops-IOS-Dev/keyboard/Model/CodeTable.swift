//
//  CodeTable.swift
//  flyinput
//
//  Created by Aaron on 16/7/24.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import Foundation
typealias CodeTableArray = [CodeTable]
extension Array where Element: Equatable {
    /**
     * Will init the array and reserve an initial capacity.
     */
    init(withReservedCapacity rc: Int) {
        self.init()
        reserveCapacity(rc)
    }
}

struct CodeTableFromType: OptionSet {
    let rawValue: Int
    static let none = CodeTableFromType([])

    static let user = CodeTableFromType(rawValue: 1 << 0)
    static let main = CodeTableFromType(rawValue: 1 << 1)
    static let custom = CodeTableFromType(rawValue: 1 << 2)
    static let emoji = CodeTableFromType(rawValue: 1 << 3)
    static let english = CodeTableFromType(rawValue: 1 << 4)
    static let assisted = CodeTableFromType(rawValue: 1 << 5)
    static let sjrq = CodeTableFromType(rawValue: 1 << 6)
    static let auto_comp = CodeTableFromType(rawValue: 1 << 6)
    static let english_think = CodeTableFromType(rawValue: 1 << 7)

    static let textReplacement: CodeTableFromType = [.custom, .main]
}

/// 码表项目模型类
struct CodeTable {
    init(Table table: String, Weight weight: Double, Code code: String = "") {
        self.code = code // 编码-供反查编码使用
        self.table = table // 对应中文
        self.weight = weight // 权重 not used
    }

    init(Code code: String = "", Table table: String = "", Weight weight: Int = 0, from: CodeTableFromType = .none) {
        self.code = code // 编码-供反查编码使用
        self.table = table // 对应中文
        self.weight = Double(weight) // 权重 not used
        self.from = from
    }

    var code = "" // 编码-供反查编码使用
    var table = "" // 对应中文
    var weight: Double = 1 // 权重默认为1给用户词用，如果为0则无法参与整句计算了

    var from = CodeTableFromType.none
    var assistedCode = "" // 辅码参与词频用的实际辅码值
    var preAssistedCode = "" // 辅码提示用的属性
    var pyList: [String] = []
}

extension CodeTable {
    func isValid() -> Bool {
        return !code.isEmpty && !table.isEmpty
    }
}

extension CodeTable: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(table)
    }

    var description: String {
        return table
    }
}

extension CodeTable {
    func containsString(_ other: String) -> Bool {
//        return self.table.containsString(other)
        if table.range(of: other) != nil { return true }
        return false
    }

    func containsString(_ other: CodeTable) -> Bool {
        //        return self.table.containsString(other)
        if table.range(of: other.table) != nil { return true }
        return false
    }
}

extension CodeTable: Comparable {
    static func == (lhs: CodeTable, rhs: CodeTable) -> Bool {
        return lhs.table == rhs.table
    }

    static func < (lhs: CodeTable, rhs: CodeTable) -> Bool {
        return lhs.weight < rhs.weight
    }
}
