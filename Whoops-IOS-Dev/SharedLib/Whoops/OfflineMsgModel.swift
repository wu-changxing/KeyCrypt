//
//  OfflineMsgModel.swift
//  Whoops
//
//  Created by Aaron on 10/31/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Foundation

struct OfflineModel {
    let platform: Platform
    let targetId: Int
    let isGroupMsg: Bool
    var msgCount: Int
    var sessionIdList: [Int]
    var endTime: Int

    mutating func add(_ o: OfflineModel) {
        guard targetId == o.targetId else { return }
        msgCount += o.msgCount
        sessionIdList.append(contentsOf: o.sessionIdList)
        endTime = max(endTime, o.endTime)
    }
}

extension OfflineModel: Equatable, Hashable {
    static func == (lhs: OfflineModel, rhs: OfflineModel) -> Bool {
        lhs.targetId == rhs.targetId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(targetId)
    }
}
