//
//  UserModel.swift
//  Whoops
//
//  Created by Aaron on 8/5/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Kingfisher
import SwiftyJSON
import UIKit

let kUserTypeSingle = 0
let kUserTypeGroup = 1
let kUserTypeGroupMember = 2

let kIdentityOwner = 0
let kIdentityAdmin = 1
let kIdentityMember = 2

class WhoopsUser {
    var iconImageUrl: String?
    var name: String
    var nickName: String?
    var publicKey: PublicKey
    var platform: Platform
    var anonymous: Bool {
        iconImageUrl?.isEmpty ?? true
    }

    var walletAddress: String = ""

    var the_id: Int
    var friend_id: Int
    var userType = kUserTypeSingle // 0 single user, 1 group chat
    var isGroupAdmin: Bool {
        return identity == kIdentityAdmin || identity == kIdentityOwner
    }

    var groupMembersCache: [WhoopsUser]?

    var isMySelf: Bool {
        privateKey != nil && userType == kUserTypeSingle
    }

    var privateKey: PrivateKey!
    var token: String?
    var inviteCode: String?
    var inviteCount: Int = 0
    var inviteTime = ""
    var selfRanking = 0

//    ===== only group =====

    var groupColor = 0
    var isBanned = false
    var memberCount = 0
    var identity = kIdentityMember // 在群成员时表示成员角色，在群信息时表示当前登录用户角色
    var groupSecKeyCache = ""
    var groupPriKeyCache = ""

    var raw_value: String

    init(keypairs: RSAKeyPairManager) {
        publicKey = keypairs.publicKey
        privateKey = keypairs.privateKey
        platform = keypairs.currentTag
//        anonymous = true
        the_id = -1
        friend_id = -1
        raw_value = ""
        name = ""
    }

    init?(json: JSON, platform: Platform) {
        guard let publicKeys = json["publicKey"].string,
              let publicKey = try? PublicKey(base64Encoded: publicKeys),
              let id = json["id"].int
        else { return nil }

        self.publicKey = publicKey
        self.platform = platform
        the_id = id
        inviteTime = json["createTime"].stringValue
        inviteCount = json["count"].intValue
        selfRanking = json["ranking"].intValue

        if let address = json["walletAddress"].string {
            walletAddress = address
        }

        if let friendId = json["friendId"].int { // 说明是普通用户
            userType = kUserTypeSingle
            friend_id = friendId

            if let n = json["name"].string, !n.isEmpty {
                name = n
            } else {
                name = publicKey.fingerPrint()
            }

            if let nickName = json["nickName"].string, !nickName.isEmpty {
                self.nickName = nickName
            }

            if let headUrl = json["headUrl"].string, !headUrl.isEmpty {
                iconImageUrl = headUrl
            }

            raw_value = json.rawString(.utf8, options: .prettyPrinted) ?? ""
            return
        }
        // 说明是群

        if let sk = json["secretKey"].string,
           let e = json["privateKey"].string
        {
            groupSecKeyCache = sk
            groupPriKeyCache = e

            userType = kUserTypeGroup
            if var color = json["color"].string {
                color.removeFirst()
                groupColor = Int(color, radix: 16) ?? 0
            }
            let n = json["groupName"].stringValue
            name = n.isEmpty ? publicKey.fingerPrint() : n
            
            inviteCode = json["inviteCode"].string
            the_id = json["id"].int ?? 0
            friend_id = the_id
            isBanned = json["isBanned"].stringValue == "1"
            memberCount = json["memberCount"].intValue
            
            identity = json["identity"].int ?? kIdentityMember
            walletAddress = WalletUtil.redpacketAddress
            raw_value = json.rawString(.utf8, options: .prettyPrinted) ?? ""
            return
        }

        if let fi = json["id"].int, let ti = json["userId"].int

        { // 说明是群成员  userid相当于是id，id相当于是friend id 这样的关系
            userType = kUserTypeGroupMember
            friend_id = fi
            the_id = ti
            identity = json["identity"].int ?? kIdentityMember

            let n = json["name"].stringValue
            name = n.isEmpty ? publicKey.fingerPrint() : n
            
            if let nickName = json["nickName"].string, !nickName.isEmpty {
                self.nickName = nickName
            }

            if let headUrl = json["headUrl"].string, !headUrl.isEmpty {
                iconImageUrl = headUrl
            }

            raw_value = json.rawString(.utf8, options: .prettyPrinted) ?? ""
            return
        }

        return nil
    }

    init(publicKey: PublicKey, the_id: Int, platform: Platform) {
        name = ""
        self.publicKey = publicKey
        self.platform = platform
        self.the_id = the_id
        raw_value = ""
        friend_id = 1
    }

    @discardableResult
    func loadGroupPrivateKey() -> Bool {
        guard privateKey == nil else { return true }
        guard let cu = NetLayer.sessionUser(for: platform),
              let pk = cu.decryptString(encryptedContent: groupPriKeyCache, encryptedPwd: groupSecKeyCache),
              let ppk = try? PrivateKey(base64Encoded: pk)
        else {
            return false
        }
        privateKey = ppk
        return true
    }

    func loadGroupMembers(callback: @escaping ((Bool, String?) -> Void)) {
        guard userType == kUserTypeGroup else { return }
        NetLayer.getGroupMembers(group: self) { r, data, m in
            guard r, let l = data as? [WhoopsUser] else {
                DispatchQueue.main.async {
                    callback(false, m)
                }

                return
            }
            self.groupMembersCache = l
            DispatchQueue.main.async {
                callback(true, "")
            }
        }
    }
}

extension WhoopsUser {
    /// 使用这个用户的公钥 配合 AES 加密
    func encryptString(content: String, selfUser: WhoopsUser) -> (encryptedContent: Base64String, encryptedPwd: Base64String, selfEncryptedPwd: Base64String) {
        let (encrypted, pwd) = AES.encrypt(plainText: content)
        let clear = try! ClearMessage(string: pwd, using: .utf8)
        let encryptedPwdData = try! clear.encrypted(with: publicKey, padding: .PKCS1)
        let encryptedPwd = encryptedPwdData.base64String

        let selfEncryptedPwdData = try! clear.encrypted(with: selfUser.publicKey, padding: .PKCS1)
        let selfEnPwd = selfEncryptedPwdData.base64String
        return (encrypted, encryptedPwd, selfEnPwd)
    }

    /// 使用这个用户的私钥 配合 AES 解密（仅限设备登录用户）
    func decryptString(encryptedContent: Base64String, encryptedPwd: Base64String) -> String? {
        guard let en = try? EncryptedMessage(base64Encoded: encryptedPwd),
              let p = privateKey,
              let clear = try? en.decrypted(with: p, padding: .PKCS1),
              let pwd = try? clear.string(encoding: .utf8)
        else { return nil }

        return AES.decrypt(encrypted: encryptedContent, pwd: pwd)
    }
}

extension WhoopsUser: Equatable {
    static func == (lhs: WhoopsUser, rhs: WhoopsUser) -> Bool {
        lhs.friend_id == rhs.friend_id && lhs.the_id == rhs.the_id
    }
}

extension WhoopsUser: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(the_id + friend_id)
    }
}

extension WhoopsUser {
    func getImage(defaultImage: UIImage, _ callback: @escaping (UIImage?) -> Void) {
        if let url = iconImageUrl, url.contains("http"), let u = URL(string: url) {
            KingfisherManager.shared.retrieveImage(with: u) { result in
                guard let r = try? result.get() else {
                    DispatchQueue.main.async {
                        callback(defaultImage)
                    }
                    return
                }

                DispatchQueue.main.async {
                    callback(r.image)
                }
            }

        } else {
            callback(defaultImage)
        }
    }
}
