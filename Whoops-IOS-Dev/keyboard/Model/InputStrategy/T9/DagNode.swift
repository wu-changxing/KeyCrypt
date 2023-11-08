//
//  DagNode.swift
//  LogInput
//
//  Created by Aaron on 2016/10/18.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import Foundation
final class DagNode {
    var path: [String] = []
    var weight: Double = 0.0

    var hashValue: Int {
        return weight.hashValue
    }

    func getString() -> String {
        return path.joined()
    }
}

extension DagNode: Comparable {
    static func == (lhs: DagNode, rhs: DagNode) -> Bool {
        return lhs.weight == rhs.weight
    }

    static func > (lhs: DagNode, rhs: DagNode) -> Bool {
        return lhs.weight > rhs.weight
    }

    static func < (lhs: DagNode, rhs: DagNode) -> Bool {
        return lhs.weight < rhs.weight
    }

    public static func <= (lhs: DagNode, rhs: DagNode) -> Bool {
        return lhs.weight <= rhs.weight
    }

    public static func >= (lhs: DagNode, rhs: DagNode) -> Bool {
        return lhs.weight >= rhs.weight
    }
}
