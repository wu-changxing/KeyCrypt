//
//  LoginputEngineLib.swift
//  LoginputEngineLib
//
//  Created by Aaron on 5/19/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import Foundation

public class LoginputEngineLib {
    private weak var configManager: LEConfigDelegate?
    var loginputEngine: LoginputEngine?
    public var old_Device = false
    private init() {}
    public static var shared: LoginputEngineLib = LoginputEngineLib()
    public func cleanCache() {
        loginputEngine?.database.cleanCache()
    }
    public func initEngine(emissionDBPath: String, transitionDBPath: String, configDelegate: LEConfigDelegate?) {
        if loginputEngine != nil {
            print("LoginputEngineLib warning: you have already initialized engine, are you really want to do this again?!")
        }
        configManager = configDelegate
        loginputEngine = LoginputEngine(db: LEDatabase(emissionPath: emissionDBPath, transitionPath: transitionDBPath, configDelegate: configManager))
    }
    
    /// 拆分拼音串，返回字符串数组，【不】包含模糊音，拆不出来则返回空数组
    public func segment_loss(from: String) -> [String] {
        guard let result = FSegment(from, config: configManager) else {return []}
        return PyString.pyList2s(from: result).map{$0.first ?? ""}
    }
    
    /// 拆分拼音串，返回字符串数组，包含模糊音和修正，拆不出来则返回空数组
    public func segment(from: String) -> [[String]] {
        guard let result = FSegment(from, config: configManager) else {return []}
        return PyString.py2fuzzy(pyList: result, config: configManager)
    }
    
    /// 拆分拼音串，返回数字编码拼音串，包含模糊音和修正，拆不出来则返回空数组
    public func segment_i(from: String) -> PyList {
        guard let result = FSegment(from, config: configManager) else {return []}
        return PyString.py2fuzzy_i(pyList: result, config: configManager)
    }
    
    /// 直接从拼音串计算整句
    public func getPhrase(from py: String) -> String {
        let pylist = segment_i(from: py)
        return getPhrase(from: pylist)
    }
    
    /// 从数字编码的拼音串计算整句
    public func getPhrase(from pylist: PyList) -> String {
        guard let r = loginputEngine?.getCandidate(from: pylist, pathNumber: old_Device ? 5 : 10, log: true).first else {
            return ""
        }
        return r.path.joinWith(sep: "") //r:path score
    }
    
    /// 从数字编码拼音串获取词汇候选，不自动生成模糊音
    public func  getWords(from pylist: PyList, plus_one:Bool = false) -> [String] {
        guard let words = loginputEngine?.getWords(from: pylist, plus_one: plus_one) else { return [] }
        return words
    }
    
    /// 从拼音串获取词汇候选，自动生成模糊音
    public func getWords(from py: String) -> [String] {
        let pylist = segment_i(from: py)
        return getWords(from: pylist)
    }
}
