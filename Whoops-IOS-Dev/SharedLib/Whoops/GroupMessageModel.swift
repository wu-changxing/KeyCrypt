//
//  GroupMessageModel.swift
//  Whoops
//
//  Created by Aaron on 10/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Foundation
import SwiftyJSON

enum GroupMessageStatus: Int {
    case pending = 0
    case approve = 1
    case refuse = 2
}

class GroupMessageModel {
    let platform: Platform
    let applyId: Int
    let applyName: String
    let groupId: Int
    let groupName: String
    let headUrl: String
    let id: Int
    var status: GroupMessageStatus

    init(json: JSON, platform: Platform) {
        self.platform = platform
        applyId = json["applyId"].intValue
        let pubk = json["publicKey"].stringValue
        let k = try! PublicKey(base64Encoded: pubk)
        let n = json["applyName"].stringValue
        applyName = n.isEmpty ? k.fingerPrint() : n
        groupId = json["groupId"].intValue
        groupName = json["groupName"].stringValue
        headUrl = json["headUrl"].stringValue
        id = json["id"].intValue
        status = GroupMessageStatus(rawValue: json["status"].int!)!
    }
}
