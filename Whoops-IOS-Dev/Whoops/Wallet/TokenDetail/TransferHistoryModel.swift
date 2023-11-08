//
// Created by Aaron on 4/5/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import Foundation

struct TransferHistoryModel: Codable {
    let total: Int
    let list: [TransferHistoryModelItem]
}

struct TransferHistoryModelItem: Codable {
    let transactionHash: String
    let from: String
    let to: String
    let value: String
    let timestamp: Double
    let address: String?
}

extension TransferHistoryModelItem {
    var fromAddress: ConfluxAddress? {
        ConfluxAddress(string: from)
    }

    var toAddress: ConfluxAddress? {
        ConfluxAddress(string: to)
    }

    var valueDrip: Drip {
        Drip(value) ?? 0
    }
}
