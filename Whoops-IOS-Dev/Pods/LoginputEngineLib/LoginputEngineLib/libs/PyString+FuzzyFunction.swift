//
//  Database+FuzzyFunction.swift
//  LoginputKeyboard
//
//  Created by R0uter on 11/29/18.
//  Copyright © 2018 R0uter. All rights reserved.
//

import Foundation
public extension PyString {
    static func py2fuzzy_i_y(py: Py, config: LEConfigDelegate?) -> [Py] {
        guard let m = config else { return [] }
        var part: [Py] = []
        
        if m.an2ang {
            switch py {
            case YunMu.uan: part.append(YunMu.uang)
            case YunMu.uang: part.append(YunMu.uan)
            case YunMu.an: part.append(YunMu.ang)
            case YunMu.ang: part.append(YunMu.an)
            default: break
            }
        }
        if m.en2eng {
            switch py {
            case YunMu.en: part.append(YunMu.eng)
            case YunMu.eng: part.append(YunMu.en)
            default: break
            }
        }
        if m.in2ing {
            switch py {
            case YunMu.in: part.append(YunMu.ing)
            case YunMu.ing: part.append(YunMu.in)
            default: break
            }
        }
        return part
    }
    
    static func py2fuzzy_i_s(py: Py, config: LEConfigDelegate?) -> [Py] {
        guard let m = config else { return [] }
        var part: [Py] = []
        if m.c2ch {
            switch py {
            case ShengMu.ch: part.append(ShengMu.c)
            case ShengMu.c: part.append(ShengMu.ch)
            default: break
            }
        }
        if m.s2sh {
            switch py {
            case ShengMu.sh: part.append(ShengMu.s)
            case ShengMu.s: part.append(ShengMu.sh)
            default: break
            }
        }
        if m.z2zh {
            switch py {
            case ShengMu.zh: part.append(ShengMu.z)
            case ShengMu.z: part.append(ShengMu.zh)
            default: break
            }
        }
        if m.l2n {
            switch py {
            case ShengMu.l: part.append(ShengMu.n)
            case ShengMu.n: part.append(ShengMu.l)
            default: break
            }
        }
        if m.r2l {
            switch py {
            case ShengMu.r: part.append(ShengMu.l)
            case ShengMu.l: part.append(ShengMu.r)
            default: break
            }
        }
        if m.f2h {
            switch py {
            case ShengMu.f: part.append(ShengMu.h)
            case ShengMu.h: part.append(ShengMu.f)
            default: break
            }
        }
        
        return part
    }
    
    static func py2fuzzy_i(pyList: PyList, config: LEConfigDelegate?) -> PyList {
        guard let m = config else { return pyList }
        var fuzzy_list: PyList = []
        for sounds in pyList {
            var part = sounds
            for sound in sounds {
                let s = PyString.getShengMu(from: sound)
                let y = PyString.getYunMu(from: sound)
                if m.c2ch {
                    switch s {
                    case ShengMu.ch: part.append(ShengMu.c | y)
                    case ShengMu.c: part.append(ShengMu.ch | y)
                    default: break
                    }
                }
                if m.s2sh {
                    switch s {
                    case ShengMu.sh: part.append(ShengMu.s | y)
                    case ShengMu.s: part.append(ShengMu.sh | y)
                    default: break
                    }
                }
                if m.z2zh {
                    switch s {
                    case ShengMu.zh: part.append(ShengMu.z | y)
                    case ShengMu.z: part.append(ShengMu.zh | y)
                    default: break
                    }
                }
                if m.l2n {
                    switch s {
                    case ShengMu.l: part.append(ShengMu.n | y)
                    case ShengMu.n: part.append(ShengMu.l | y)
                    default: break
                    }
                }
                if m.r2l {
                    switch s {
                    case ShengMu.r: part.append(ShengMu.l | y)
                    case ShengMu.l: part.append(ShengMu.r | y)
                    default: break
                    }
                }
                if m.f2h {
                    switch s {
                    case ShengMu.f: part.append(ShengMu.h | y)
                    case ShengMu.h: part.append(ShengMu.f | y)
                    default: break
                    }
                }
            }
            let tmp = part
            for sound in tmp {
                let s = PyString.getShengMu(from: sound)
                let y = PyString.getYunMu(from: sound)
                
                if m.an2ang {
                    switch y {
                    case YunMu.uan: part.append(s | YunMu.uang)
                    case YunMu.uang: part.append(s | YunMu.uan)
                    case YunMu.an: part.append(s | YunMu.ang)
                    case YunMu.ang: part.append(s | YunMu.an)
                    default: break
                    }
                }
                if m.en2eng {
                    switch y {
                    case YunMu.en: part.append(s | YunMu.eng)
                    case YunMu.eng: part.append(s | YunMu.en)
                    default: break
                    }
                }
                if m.in2ing {
                    switch y {
                    case YunMu.in: part.append(s | YunMu.ing)
                    case YunMu.ing: part.append(s | YunMu.in)
                    default: break
                    }
                }
            }
            fuzzy_list.append(part)
        }
        return fuzzy_list
    }
    
    static func py2fuzzy(pyList: [[String]], config: LEConfigDelegate?) -> [[String]] {
        guard let config = config else {return pyList}
        let s = PyString.pyList2i(from: pyList)
        let result = PyString.py2fuzzy_i(pyList: s, config: config)
        return PyString.pyList2s(from: result)
    }
    
    static func py2fuzzy(pyList: PyList, config: LEConfigDelegate?) -> [[String]] {
        guard let config = config else {return PyString.pyList2s(from: pyList)}
        let result = PyString.py2fuzzy_i(pyList: pyList, config: config)
        return PyString.pyList2s(from: result)
    }
}
