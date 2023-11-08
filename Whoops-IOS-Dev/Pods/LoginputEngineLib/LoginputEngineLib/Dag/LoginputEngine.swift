//
//  Dag.swift
//  LMDB Test
//
//  Created by Aaron on 5/4/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import Foundation

class LoginputEngine {
    let database: LEDatabase
    
    init(db: LEDatabase) {
        database = db
    }
    
    func getWords(from pylist: PyList, plus_one: Bool = false) -> [String] {
        guard let gbWords = database.getWords(from: pylist, plus_one: plus_one, sortHeads: true) else { return [] }
        return gbWords.joinWith(sep: "_").components(separatedBy: "_")
    }
    
    func getCandidate(from py: PyList, pathNumber: Int = 10, log: Bool = true) -> [DagItem] {
        guard database.dagAvaliable else { return [] }
        let pinyinList = py
        let pinyinNum = pinyinList.count
        guard pinyinNum > 0 else { return [] }
        var wordsCache: [Int: [GBString]] = [:]
        var Graph: [PriorityStack<DagItem>] = []
        for _ in 0..<pinyinNum {
            Graph.append(PriorityStack<DagItem>(Length: pathNumber))
        }
        
        var fromIndex = 0
        // 第一个词的处理
        autoreleasepool {
            for toIndex in fromIndex..<pinyinNum {
                let cut = Array(pinyinList[fromIndex...toIndex])
                guard let words_weights = database.getWordsWithGram1Weight(from: cut) else { continue }
                
                for (word, weight) in words_weights {
                    Graph[toIndex].push(DagItem(path: [word], score: weight))
                }
            }
            
            // 第二个词的处理
            if pinyinNum >= 2 {
                for (lastIndex, prevPaths) in Graph.enumerated() {
//                    guard lastIndex > 0 else { continue } 不能加这个过滤，加了的话某些低频整句就会被裁切
                    
                    fromIndex = lastIndex &+ 1
                    for toIndex in fromIndex..<pinyinNum {
                        var words: [GBString] = []
                        let key = fromIndex &* 100 &+ toIndex
                        if let w = wordsCache[key] {
                            words = w
                        } else {
                            let cut = Array(pinyinList[fromIndex...toIndex]) //cut 为pinyin
                            guard let w = database.getWords(from: cut) else { continue }
                            words = w
                            wordsCache[key] = w
                        }
                        
                        for prevItem in prevPaths {
                            guard prevItem.path.count == 1 else { continue }
                            let lastOne = prevItem.path[0]
                            
                            for word in words {
                                let newPath = prevItem.path + [word]
                                var newScore:Double
                                if log {
                                    newScore = database.getGram2WeightFrom(lastOne: lastOne, one: word) + database.getGram1WeightFrom(word: word)
                                    newScore += prevItem.score
                                } else {
                                    newScore = database.getGram2WeightFrom(lastOne: lastOne, one: word) * database.getGram1WeightFrom(word: word)
                                    newScore *= prevItem.score
                                }
                                Graph[toIndex].push(DagItem(path: newPath, score: newScore))
                            }
                        }
                    }
                }
            }
            // 第三个词往后处理 gram3
            
            if pinyinNum >= 3 {
                for (lastIndex, prevPaths) in Graph.enumerated() {
//                    guard lastIndex >= 2 else { continue } 不能加这个过滤，加了的话某些低频整句就会被裁切
                    
                    fromIndex = lastIndex &+ 1
                    for toIndex in fromIndex..<pinyinNum {
                        var words: [GBString] = []
                        let key = fromIndex &* 100 &+ toIndex
                        if let w = wordsCache[key] {
                            words = w
                        } else {
                            let cut = Array(pinyinList[fromIndex...toIndex])
                            guard let w = database.getWords(from: cut) else { continue }
                            words = w
                            wordsCache[key] = w
                        }
                        
                        for prevItem in prevPaths {
                            guard prevItem.path.count >= 2 else { continue }
                            let i = prevItem.path.endIndex
                            let lastOne = prevItem.path[i &- 1]
                            let lastLastOne = prevItem.path[i &- 2]
                            for word in words {
                                let newPath = prevItem.path + [word]
                                var newScore:Double
                                if log {
                                    newScore = database.getGram3WeightFrom(lastLastOne: lastLastOne, lastOne: lastOne, one: word) + database.getGram2WeightFrom(lastOne: lastOne, one: word) + database.getGram1WeightFrom(word: word)
                                    newScore += prevItem.score
                                } else {
                                    newScore = database.getGram3WeightFrom(lastLastOne: lastLastOne, lastOne: lastOne, one: word) * database.getGram2WeightFrom(lastOne: lastOne, one: word) * database.getGram1WeightFrom(word: word)
                                    newScore *= prevItem.score
                                }
                                Graph[toIndex].push(DagItem(path: newPath, score: newScore))
                            }
                        }
                    }
                }
            }
        }
        var result: [DagItem] = []
        for stack in Graph.last! {
            result.append(stack)
        }
        return result.sorted(by:>)
    }
    
    func getEvaluate(from words: String, pathNumber: Int = 3, log: Bool = true) -> [DagItem] {
        guard database.dagAvaliable else { return [] }
        let pinyinList = words.encode()
        let pinyinNum = words.count / 2
        guard pinyinNum > 0 else { return [] }
        
        var Graph: [PriorityStack<DagItem>] = []
        for _ in 0..<pinyinNum {
            Graph.append(PriorityStack<DagItem>(Length: pathNumber))
        }
        
        var fromIndex = 0
        autoreleasepool {
            // 第一个词的处理
            for toIndex in fromIndex..<pinyinNum {
                let cut = Data(pinyinList[fromIndex &* 2...toIndex &* 2])
                Graph[toIndex].push(DagItem(path: [cut], score: database.getGram1WeightFrom(word: cut)))
            }
            
            // 第二个词的处理
            if pinyinNum >= 2 {
                for (lastIndex, prevPaths) in Graph.enumerated() {
                    fromIndex = lastIndex &+ 1
                    for toIndex in fromIndex..<pinyinNum {
                        let cut = Data(pinyinList[fromIndex &* 2...toIndex &* 2])
                        
                        for prevItem in prevPaths {
                            guard prevItem.path.count == 1 else { continue }
                            let lastOne = prevItem.path[0]
                            let newPath = prevItem.path + [cut]
                            var newScore:Double
                            if log {
                                newScore = database.getGram2WeightFrom(lastOne: lastOne, one: cut) + database.getGram1WeightFrom(word: cut)
                                newScore += prevItem.score
                            } else {
                                newScore = database.getGram2WeightFrom(lastOne: lastOne, one: cut) * database.getGram1WeightFrom(word: cut)
                                newScore *= prevItem.score
                            }
                            Graph[toIndex].push(DagItem(path: newPath, score: newScore))
                        }
                    }
                }
            }
            
            // 第三个词往后处理 gram3
            
            if pinyinNum >= 3 {
                for (lastIndex, prevPaths) in Graph.enumerated() {
                    fromIndex = lastIndex &+ 1
                    for toIndex in fromIndex..<pinyinNum {
                        let cut = Data(pinyinList[fromIndex &* 2...toIndex &* 2])
                        for prevItem in prevPaths {
                            guard prevItem.path.count >= 2 else { continue }
                            let i = prevItem.path.endIndex
                            let lastOne = prevItem.path[i &- 1]
                            let lastLastOne = prevItem.path[i &- 2]
                            let newPath = prevItem.path + [cut]
                            var newScore:Double
                            if log {
                                newScore = database.getGram3WeightFrom(lastLastOne: lastLastOne, lastOne: lastOne, one: cut) + database.getGram2WeightFrom(lastOne: lastOne, one: cut) + database.getGram1WeightFrom(word: cut)
                                newScore += prevItem.score
                            } else {
                                newScore = database.getGram3WeightFrom(lastLastOne: lastLastOne, lastOne: lastOne, one: cut) * database.getGram2WeightFrom(lastOne: lastOne, one: cut) * database.getGram1WeightFrom(word: cut)
                                newScore *= prevItem.score
                            }
                            Graph[toIndex].push(DagItem(path: newPath, score: newScore))
                        }
                    }
                }
            }
        }
        var result: [DagItem] = []
        for stack in Graph.last! {
            result.append(stack)
        }
        return result.sorted(by:>)
    }
}
