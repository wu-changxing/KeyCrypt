//
//  Database+T9.swift
//  keyboard7657
//
//  Created by Aaron on 3/31/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import Foundation
extension Database {
    //从字典中获取九键的词语
    func getWordsFromT9Dict(nums: String) -> CodeTableArray {
        
        var codeTables: CodeTableArray = []
        t9dictQueue?.inDatabase { db in
            var l: CodeTableArray = []
            guard let resultSet = db.executeQuery("SELECT \"Code\",\"Table\" FROM CodeTable WHERE Code=? ", withArgumentsIn: [nums]),
                  resultSet.next(),
                  let s = resultSet.string(forColumnIndex: 1)
            else { return }

            for w in s.components(separatedBy: "_") {
                var codeTable = CodeTable()
                codeTable.table = w
                codeTable.from = .main
                codeTable.code = nums
                l.append(codeTable)
            }

            resultSet.close()
            codeTables = l
        }
        return codeTables
    }
}
