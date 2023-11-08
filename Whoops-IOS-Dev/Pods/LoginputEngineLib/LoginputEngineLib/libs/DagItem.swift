//
//  PriorityStackItem.swift
//  LMDB Test
//
//  Created by R0uter on 5/5/20.
//  Copyright © 2020 com.logcg. All rights reserved.
//

import Foundation
struct DagItem:CustomStringConvertible, Comparable {
    static func < (lhs: DagItem, rhs: DagItem) -> Bool {
        return lhs.score < rhs.score
    }
    
    var description: String {
        return "<score:\(score)>, path:\(path)"
    }
    
    var path:[GBString] = []
    var score:Double = 0
    
}
struct WordsNode:Comparable {
    static func < (lhs: WordsNode, rhs: WordsNode) -> Bool {
        return lhs.score < rhs.score
    }
    
    var path:GBString?
    var score:Double = 0
}
struct FSegmentNode {
    var path:[String] = []
    var weight:Double = 0.0
    
    var hashValue: Int {
        
        return weight.hashValue
    }
    func getString() ->String {
        return path.joined()
    }
    
}
extension FSegmentNode:Comparable {
    static func ==(lhs: FSegmentNode, rhs: FSegmentNode) -> Bool {
        return lhs.weight == rhs.weight
    }
    static func > (lhs: FSegmentNode, rhs: FSegmentNode) -> Bool {
        return lhs.weight > rhs.weight
    }
    static func <(lhs: FSegmentNode, rhs: FSegmentNode) -> Bool {
        return lhs.weight < rhs.weight
    }
    public static func <=(lhs: FSegmentNode, rhs: FSegmentNode) -> Bool {
        return lhs.weight <= rhs.weight
    }
    public static func >=(lhs: FSegmentNode, rhs: FSegmentNode) -> Bool {
        return lhs.weight >= rhs.weight
    }
}
