//
//  RedpacketHistoryModel.swift
//  Whoops
//
//  Created by Aaron on 3/22/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import ConfluxSDK

struct RedPacketHistory: Codable {
    let decimals: Int
    let fromId: Int
    let fromName: String
    let groupId: Int
    let number: Int
    let redPacketRecords: [RedPacketHistoryRecord]
    let remainNum: Int
    let tokenType: String
    let total: String
}

struct RedPacketHistoryRecord: Codable {
    let headUrl: String?
    let robed: String
    let userId: Int
    let userName: String
}

extension RedPacketHistoryRecord: Comparable {
    static func < (lhs: RedPacketHistoryRecord, rhs: RedPacketHistoryRecord) -> Bool {
        Drip(lhs.robed) ?? 0 < Drip(rhs.robed) ?? 0
    }
}
