//
//  LEUtil.swift
//  LoginputEngineLib
//
//  Created by R0uter on 6/9/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import Foundation

public func getSql4dagDB(fromPy pylist:PyList)-> String {
    var condition = " "
    for i in 0..<pylist.count {
        if let a = pylist[i].first, PyString.isShengMu(a) {
            let range = PyString.getShengMuRange(from: a)
            condition = condition + "p\(i+1) >= '\(range.min)' and p\(i+1) < '\(range.max)' and "
        } else {
            let row = pylist[i].map{String($0)}
            condition = condition + "p\(i+1) in ('\(row.joined(separator: "','"))') and "
        }
        
    }
    return condition.subString(to: -4)
}
