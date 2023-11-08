//
//  UserModelCodable.swift
//  keyboard
//
//  Created by Aaron on 9/5/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Foundation
import SwiftyJSON

extension WhoopsUser {
    func toJsonCode() -> String {
        var dic: [String: String] = [
            "name": name,
            "platform": platform.rawValue,
            "the_id": "\(the_id)",
            "friend_id": "\(friend_id)",
            "raw_value": raw_value,
            "user_type": "\(userType)",
            "group_color": "\(groupColor)",
            "is_bannd": isBanned ? "1" : "0",
            "member_count": "\(memberCount)",
            "group_sk_cache": groupSecKeyCache,
            "group_pk_cache": groupPriKeyCache,
            "wallet_address": walletAddress,
        ]

        if let r = iconImageUrl {
            dic["iconImageUrl"] = r
        }
        if let n = nickName {
            dic["nickName"] = n
        }
        if let p = try? publicKey.base64String() {
            dic["publicKey"] = p
        }
        if let p1 = try? privateKey?.base64String() {
            dic["privateKey"] = p1
        }
        if let t = token {
            dic["token"] = t
        }
        if let i = inviteCode {
            dic["inviteCode"] = i
        }

        return JSON(dic).rawString(.utf8) ?? ""
    }

    static func fromJsonCode(_ code: String) -> WhoopsUser {
        let json = JSON(parseJSON: code)
        let publicKey = try! PublicKey(base64Encoded: json["publicKey"].string!)
        let platform = Platform(rawValue: json["platform"].string!)!

        let the_id = Int(json["the_id"].string ?? "1") ?? 1

        let u = WhoopsUser(publicKey: publicKey, the_id: the_id, platform: platform)
        u.raw_value = json["raw_value"].string!
        u.iconImageUrl = json["iconImageUrl"].string
        u.nickName = json["nickName"].string
        u.name = json["name"].string!
        u.privateKey = try? PrivateKey(base64Encoded: json["privateKey"].string ?? "")
        u.token = json["token"].string
        u.inviteCode = json["inviteCode"].string
        u.walletAddress = json["wallet_address"].stringValue

        if let s = json["friend_id"].string, let fid = Int(s) {
            u.friend_id = fid
        } else if let s = json["user_id"].string, let fid = Int(s) {
            u.friend_id = fid
        }
        if the_id < 100 {
            u.the_id = u.friend_id
        }

        if let ut = json["user_type"].string, let iut = Int(ut) {
            u.userType = iut
        }

        if let ut = json["group_color"].string, let iut = Int(ut) {
            u.groupColor = iut
        }

        if let ut = json["is_bannd"].string {
            u.isBanned = ut == "1"
        }

        if let ut = json["member_count"].string, let iut = Int(ut) {
            u.memberCount = iut
        }

        if let s = json["group_sk_cache"].string, let ss = json["group_pk_cache"].string {
            u.groupPriKeyCache = ss
            u.groupSecKeyCache = s
            u.loadGroupPrivateKey()
        }
        return u
    }
}

extension Array where Element == WhoopsUser {
    var codedString: String {
        (map { $0.toJsonCode() }).joined(separator: "|")
    }
}

extension String {
    var whoopsUserList: [WhoopsUser] {
        guard !isEmpty else { return [] }
        let l = components(separatedBy: "|")
        return l.map { WhoopsUser.fromJsonCode($0) }
    }
}
