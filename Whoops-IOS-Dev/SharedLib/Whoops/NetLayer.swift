//
//  NetLayer.swift
//  Whoops
//
//  Created by Aaron on 8/5/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import FCUUID
import Foundation
import SwiftyJSON

let kSuccess = 20001
let kError = 10001

let kNoHandlerFound = 40001
let kBindException = 40002
let kNotLogin = 40003
let kParameterInvalid = 10003
let kUnknown = 50001

let kUserNotExist = 60001
let kUserLocked = 60002
let kLoginExpired = 60003
let kInvalidToken = 60004

let kErrCurrentUserNotLogin = "CurrentUserNotLogin"
let kErrDataInvalid = "DataInvalid"

enum NetLayerStatus: Int {
    case ok = 200
    case created = 201
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404

    case unKnownStatus = 999
}

typealias CallbackInfoOnlyType = ((_ resut: Bool, _ errMsg: String?) -> Void)?
typealias CallbackWithDataType = ((_ resut: Bool, _ data: Any?, _ errMsg: String?) -> Void)?
extension NetLayer {
    static var deviceUUID: String {
        let shareDefault = UserDefaults(suiteName: kGroupIdentifier)!
        if let id = shareDefault.string(forKey: "FCUUID") {
            return id
        } else {
            let id = FCUUID.uuidForDevice()!
            shareDefault.set(id, forKey: "FCUUID")
            return id
        }
    }
}

enum NetLayer {
    private static let sharedDefault = UserDefaults(suiteName: kGroupIdentifier)!

//    private static let endPoint = "https://whoops.world/ime-web/api/v0.1"
    private static let endPoint = "http://127.0.0.1:8080"
    private static let lockTokens = DispatchSemaphore(value: 1)

    private static var loginUser: [String: String] = {
        if let d = sharedDefault.dictionary(forKey: kNetLayerUser) as? [String: String] {
            return d
        } else {
            return [:]
        }
    }() {
        didSet {
            sharedDefault.set(loginUser, forKey: kNetLayerUser)
            sharedDefault.synchronize()
        }
    }

    private static var recent_userList_dic: [String: String] = {
        if let d = sharedDefault.dictionary(forKey: kNetLayerRecentUserList) as? [String: String] {
            return d
        } else {
            return [:]
        }

    }() {
        didSet {
            sharedDefault.set(recent_userList_dic, forKey: kNetLayerRecentUserList)
            sharedDefault.synchronize()
        }
    }

    private static func getPlatformCode(for p: Platform) -> String {
        return "\(p.intValue)"
    }

    private static func getPlatform(for code: Int) -> Platform {
        return Platform.fromCode(code) ?? .apple
    }

    private static var commonBatchRequestData: [[String: String]]? {
        var data: [[String: String]] = []

        for p in Platform.allCases {
            guard let token = sessionUser(for: p)?.token else {
                return nil
            }
            data.append([
                "platform": getPlatformCode(for: p),
                "token": token,
            ])
        }
        return data
    }

    private static func delete(from url: URL, withToken token: String, callback: @escaping ((_ json: JSON, _ status: NetLayerStatus) -> Void)) {
        var rq = URLRequest(url: url)
        rq.httpMethod = "DELETE"
        rq.addValue(token, forHTTPHeaderField: "Authorization")
        rq.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: rq) { data, response, _ in
            guard let r = response as? HTTPURLResponse,
                  let data = data,
                  let dic = try? JSON(data: data),
                  let status = NetLayerStatus(rawValue: r.statusCode)
            else {
                callback(JSON(), .unKnownStatus)
                return
            }
            callback(dic, status)
        }
        task.resume()
    }

    private static func put(_ query: [String: String], to url: URL, withToken token: String, callback: @escaping ((_ json: JSON, _ status: NetLayerStatus) -> Void)) {
        var rq = URLRequest(url: url)
        rq.httpMethod = "PUT"
        rq.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        rq.addValue(token, forHTTPHeaderField: "Authorization")
        let data = query.queryString.data(using: .utf8)
        let task = URLSession.shared.uploadTask(with: rq, from: data) { data, response, _ in
            guard let r = response as? HTTPURLResponse,
                  let data = data,
                  let dic = try? JSON(data: data),
                  let status = NetLayerStatus(rawValue: r.statusCode)
            else {
                callback(JSON(), .unKnownStatus)
                return
            }

            callback(dic, status)
        }

        task.resume()
    }

    private static func putJson(_ query: [String: Any], to url: URL, withToken token: String, callback: @escaping ((_ json: JSON, _ status: NetLayerStatus) -> Void)) {
        var rq = URLRequest(url: url)
        rq.httpMethod = "PUT"
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue(token, forHTTPHeaderField: "Authorization")
        let data = try! JSON(query).rawData()

        let task = URLSession.shared.uploadTask(with: rq, from: data) { data, response, _ in
            guard let r = response as? HTTPURLResponse,
                  let data = data,
                  let dic = try? JSON(data: data),
                  let status = NetLayerStatus(rawValue: r.statusCode)
            else {
                callback(JSON(), .unKnownStatus)
                return
            }

            callback(dic, status)
        }

        task.resume()
    }

    private static func get(from url: URL, withToken token: String, callback: @escaping ((_ json: JSON, _ status: NetLayerStatus) -> Void)) {
        var rq = URLRequest(url: url)
        rq.httpMethod = "GET"
        rq.addValue(token, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: rq) { data, response, _ in
            guard let r = response as? HTTPURLResponse,
                  let data = data,
                  let dic = try? JSON(data: data),
                  let status = NetLayerStatus(rawValue: r.statusCode)
            else {
                callback(JSON(), .unKnownStatus)
                return
            }

            callback(dic, status)
        }
        task.resume()
    }

    private static func post(_ data: [String: Any], to url: URL, withToken: String? = nil, callback: @escaping ((_ json: JSON, _ status: NetLayerStatus) -> Void)) {
        var rq = URLRequest(url: url)
        rq.httpMethod = "POST"
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        rq.httpBody = try! JSON(data).rawData(options: .prettyPrinted)

        if let token = withToken {
            rq.addValue(token, forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: rq) { data, response, _ in
            guard let r = response as? HTTPURLResponse,
                  let data = data,
                  let dic = try? JSON(data: data),
                  let status = NetLayerStatus(rawValue: r.statusCode)
            else {
                callback(JSON(), .unKnownStatus)
                return
            }
            callback(dic, status)
        }
        task.resume()
    }

    static func refreshToken() {
        var us: [WhoopsUser] = []

        for p in Platform.allCases {
            guard let m = RSAKeyPairManager(for: p) else { return }
            us.append(WhoopsUser(keypairs: m))
        }

        NetLayer.loginBatch(users: us, callback: nil)
    }
}

// MARK: - Proxy

extension NetLayer {
    static func proxy(method: String, url: String, data: [String: String]? = nil, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: .weChat),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let data: [String: Any] = [
            "params": data,
            "type": method,
            "url": url,
        ]
        let url = URL(string: "\(endPoint)/conFluxScan")!
        post(data, to: url, withToken: token) { data, status in
            guard status == .ok,
                  data["success"].bool == true

            else {
                callback?(false, nil, data["message"].string)
                return
            }
            callback?(true, data["data"], nil)
        }
    }
}

// MARK: - Rank

extension NetLayer {
    static func myInviteRankingList(callback: CallbackWithDataType) {
        guard let su = sessionUser(for: .weChat),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/invite/myInviteRanking")!
        post(["inviteStartTime": ""], to: url, withToken: token) { data, status in
            guard status == .ok,
                  data["success"].bool == true,
                  let array = data["data"]["inviteRankingLis"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }

            var users: [WhoopsUser] = []
            for g in array {
                guard let gg = WhoopsUser(json: g, platform: .weChat) else {
                    callback?(false, users, kErrDataInvalid)
                    return
                }
                users.append(gg)
            }
            callback?(true, users, "")
        }
    }

    static func inviteRankingList(callback: CallbackWithDataType) {
        guard let su = sessionUser(for: .weChat),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/invite/inviteRankingList")!
        post(["inviteStartTime": ""], to: url, withToken: token) { data, status in
            guard status == .ok,
                  data["success"].bool == true,
                  let array = data["data"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }

            var users: [WhoopsUser] = []
            for g in array {
                var g = g
                g["friendId"] = 0
                guard let gg = WhoopsUser(json: g, platform: .weChat) else {
                    callback?(false, users, kErrDataInvalid)
                    return
                }
                users.append(gg)
            }
            callback?(true, users, "")
        }
    }
}

// MARK: - Wallet

extension NetLayer {
    static func updateWalletBatch(address: String, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: .weChat),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        var tks: [String] = []
        for p in Platform.allCases {
            guard let tk = sessionUser(for: p)?.token else {
                callback?(false, kErrDataInvalid)
                return
            }
            tks.append(tk)
        }
        let url = URL(string: "\(endPoint)/user/wallet/batch")!
        putJson(["walletAddress": address, "tokens": tks], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func updateWallet(address: String, p: Platform, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: p),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/user/wallet")!
        putJson(["walletAddress": address], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }
}

// MARK: - Group

extension NetLayer {
    static func getRedpacketHistory(for id: Int, in group: WhoopsUser, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/redPacket/\(id)/redPacketRobbedRecords")!
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true,
                  let d = try? data["data"].rawData(),
                  let r = try? JSONDecoder().decode(RedPacketHistory.self, from: d)
            else {
                callback?(false, nil, data["message"].string)
                return
            }

            callback?(true, r, "")
        }
    }

    static func getRedpacketInfo(for hash: String, in group: WhoopsUser, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/redPacket/\(hash)/redPacketInfo")!
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true,
                  let dic = data["data"].array?.first?.dictionary
            else {
                if data["code"].intValue == 80003 {
                    callback?(false, -1, data["message"].string)
                } else {
                    callback?(false, -2, data["message"].string)
                }
                return
            }

            callback?(true, dic["redPacketId"]?.int ?? -2, "")
        }
    }

    /// 返回 groupid memberCount root
    static func getRedpacketRoot(for group: WhoopsUser, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/redPacket/\(group.the_id)")!
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true,
                  let dic = data["data"].dictionary
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            if let root = dic["root"]?.string, let id = dic["groupId"]?.int, let count = dic["memberCount"]?.int {
                callback?(true, (id, count, root), "")
            } else {
                callback?(false, "", kErrDataInvalid)
            }
        }
    }

    static func getRedpacketProof(for group: WhoopsUser, rootHash: String, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/redPacket/\(rootHash)/verified")!
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true,
                  let dic = data["data"].dictionary
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            if let location = dic["location"]?.int, let hashList = dic["hashList"]?.arrayObject {
                callback?(true, (hashList: hashList, location: location), "")
            } else {
                callback?(false, (), kErrDataInvalid)
            }
        }
    }

    static func createGroup(with name: String, p: Platform, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: p),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group")!
        post(["groupName": name], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func getGroupList(for p: Platform, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: p),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group")!
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true,
                  let array = data["data"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            var groups: [WhoopsUser] = []
            for g in array {
                guard let gg = WhoopsUser(json: g, platform: p) else {
                    callback?(false, groups, kErrDataInvalid)
                    return
                }
                groups.append(gg)
            }
            callback?(true, groups, "")
        }
    }

    static func getGroupListBatch(callback: CallbackWithDataType) {
        guard let su = sessionUser(for: .apple),
              let token = su.token,
              let data = commonBatchRequestData
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/group/batch")!

        post(["batchVOList": data], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true,
                  let array = data["data"]["groupList"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            var groups: [WhoopsUser] = []
            for p in array {
                let p1 = getPlatform(for: Int(p["platform"].intValue))
                let groupList = p["groupList"].array ?? []
                for d in groupList {
                    if let u = WhoopsUser(json: d, platform: p1) {
                        groups.append(u)
                    }
                }
            }
            callback?(true, groups, nil)
        }
    }

    static func addMembersToGroup(group: WhoopsUser, members: [WhoopsUser], callback: CallbackInfoOnlyType) {
        guard group.isGroupAdmin else {
            callback?(false, kErrDataInvalid)
            return
        }

        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/addGroupMembers")!

        let mList = members.map { $0.friend_id }
        let data: [String: Any] = ["id": "\(group.the_id)", "userIds": mList]
        post(data, to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func getGroupMembers(group: WhoopsUser, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/group/\(group.the_id)/member")!
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true,
                  let array = data["data"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            var list: [WhoopsUser] = []
            for d in array {
                guard let m = WhoopsUser(json: d, platform: group.platform) else {
                    callback?(false, nil, kErrDataInvalid)
                    return
                }
                list.append(m)
            }
            callback?(true, list, "")
        }
    }

    static func dismissGroup(group: WhoopsUser, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/group/\(group.the_id)/dissolve")!

        delete(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func leaveGroup(group: WhoopsUser, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/group/\(group.the_id)/refundGroup/delete")!

        post(["id": "\(group.the_id)"], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func renameGroup(group: WhoopsUser, newName: String, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/\(group.the_id)/group")!

        putJson(["groupName": newName], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func setGroupNickname(group: WhoopsUser, nickName: String, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/\(group.the_id)/member")!

        put(["nickName": nickName], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func removeMember(group: WhoopsUser, memberToRemove: WhoopsUser, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: group.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/group/\(memberToRemove.friend_id)/kickOut/delete")!

        post([:], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func getGroupApplyMessage(for p: Platform, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: p),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/applyGroupList")!
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true, let array = data["data"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            let m: [GroupMessageModel] = array.map { GroupMessageModel(json: $0, platform: p) }
            callback?(true, m, "")
        }
    }

    static func getGroupApplyMessageBatch(callback: CallbackWithDataType) {
        guard let su = sessionUser(for: .weChat),
              let token = su.token,
              let data = commonBatchRequestData
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/applyGroupList/batch")!

        post(["batchVOList": data], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true,
                  let array = data["data"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            var list: [GroupMessageModel] = []
            for p in array {
                let p1 = getPlatform(for: Int(p["platform"].intValue))
                let l1 = p["applyGroupInfoDTO"].array ?? []
                for d in l1 {
                    list.append(GroupMessageModel(json: d, platform: p1))
                }
            }
            callback?(true, list, nil)
        }
    }

    static func groupApproveApply(apply: GroupMessageModel, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: apply.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/agreeApply2Group")!
        let data = [
            "id": apply.groupId,
            "userId": apply.applyId,
        ]
        post(data, to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func groupRefuseApply(apply: GroupMessageModel, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: apply.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/\(apply.id)/ignore/delete")!

        delete(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }
}

// MARK: - Invite

extension NetLayer {
    static func groupAcceptInvite(code: String, platform: Platform, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: platform),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/group/\(code)/agree2Group")!

        post([:], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }

            NetLayer.getGroupList(for: platform) { _, data, m in
                guard let array = data as? [WhoopsUser],
                      let new = array.last
                else {
                    callback?(false, nil, m)
                    return
                }
                setMostRecentUser(new)
                callback?(true, new, "")
            }
        }
    }

    static func acceptInvite(code: String, platform: Platform, callback: CallbackWithDataType) {
        let url = URL(string: "\(endPoint)/friends/agree/new")!

        guard let token = sessionUser(for: platform)?.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }

        putJson(["inviteCode": code.lowercased()], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }
            guard let d = data["data"].dictionary,
                  let id = d["id"]?.int,
                  let publicKeyS = d["publicKey"]?.string,
                  let pk = try? PublicKey(base64Encoded: publicKeyS)
            else {
                callback?(false, nil, kErrDataInvalid)
                return
            }
            let u = WhoopsUser(publicKey: pk, the_id: id, platform: platform)
            u.raw_value = data.rawString(.utf8, options: .prettyPrinted) ?? ""
            u.friend_id = id
            u.iconImageUrl = d["headUrl"]?.string
            u.name = d["name"]?.string ?? pk.fingerPrint()
            setMostRecentUser(u)
            callback?(true, u, "")
        }
    }
    
    static func convertInviteCode(randomCode:String, user:WhoopsUser, callback:CallbackInfoOnlyType) {
        guard let token = user.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/invite/convert")!

        let data = [
            "clientCode": deviceUUID,
            "code": randomCode,
            "inviteCode": user.inviteCode!
        ]
        post(data, to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }

            callback?(true, nil)
        }
    }
}

// MARK: - IM

extension NetLayer {
    static func getIMServerInfo(for p: Platform, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: p),
              let token = su.token
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/balance")!

        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }
            callback?(true, (data["data"]["host"].string!, data["data"]["port"].int!), "")
        }
    }
}

// MARK: Report

extension NetLayer {
    static func report(user: WhoopsUser, content: String, fileId: String?, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: user.platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/inform")!

        let d: [String: Any] = [
            "content": content,
            "informUserId": user.friend_id,
            "fileId": fileId ?? "",
        ]
        NetLayer.post(d, to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func uploadImage(data: Data, from user: WhoopsUser, callback: CallbackWithDataType) {
        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/file")!

        let boundary = "Boundary-\(UUID().uuidString)"

        var rq = URLRequest(url: url)
        rq.httpMethod = "POST"
        rq.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        rq.addValue(token, forHTTPHeaderField: "Authorization")

        var d = "--\(boundary)\r\nContent-Disposition: form-data; name=\"multipartFile\";filename=\"\(AES.randomString(16)).jpg\"\r\nContent-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!
        d.append(data)
        d.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        rq.httpBody = d
        rq.addValue("\(d.count)", forHTTPHeaderField: "Content-Length")

        let task = URLSession.shared.dataTask(with: rq) { data, response, _ in
            guard let r = response as? HTTPURLResponse,
                  let data = data,
                  let dic = try? JSON(data: data),
                  let status = NetLayerStatus(rawValue: r.statusCode),
                  status == .ok
            else {
                callback?(false, nil, "unKnownStatus")
                return
            }

            guard dic["success"].bool == true, let d = dic["data"].dictionaryObject as? [String: Any] else {
                callback?(false, nil, dic["message"].string)
                return
            }

            callback?(true, d, "")
        }
        task.resume()
    }

    static func deleteImage(fileId: String, user: WhoopsUser, callback: CallbackInfoOnlyType) {
        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/file?fileId=\(fileId)")!

        delete(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }
}

// MARK: Session User

extension NetLayer {
    static func setSessionUser(user: WhoopsUser) {
        _ = lockTokens.wait(timeout: .now() + 30)
        loginUser[user.platform.rawValue] = user.toJsonCode()
        lockTokens.signal()
    }

    static func removeSessionUser(for p: Platform) {
        _ = lockTokens.wait(timeout: .now() + 30)
        loginUser[p.rawValue] = nil
        lockTokens.signal()
    }

    static func sessionUser(for p: Platform) -> WhoopsUser? {
        if let s = loginUser[p.rawValue] {
            return WhoopsUser.fromJsonCode(s)
        }
        return nil
    }

    static func recentUserList(for platform: Platform) -> [WhoopsUser] {
        let s = recent_userList_dic[platform.rawValue] ?? ""
        return s.whoopsUserList
    }

    /// 注意，这个方法很慢，要在后台线程执行
    static func setMostRecentUser(_ user: WhoopsUser) {
        var l = recentUserList(for: user.platform)
        if let n = l.firstIndex(of: user) {
            l.remove(at: n)
        }
        l.insert(user, at: 0)
        setRecentUser(list: l, forPlatform: user.platform)
    }

    /// 注意，这个方法很慢，要在后台线程执行
    static func setSecondRecentUser(_ user: WhoopsUser) {
        var l = recentUserList(for: user.platform)
        if let n = l.firstIndex(of: user) {
            l.remove(at: n)
        }
        if l.isEmpty {
            l.insert(user, at: 0)
        } else {
            l.insert(user, at: 1)
        }
        setRecentUser(list: l, forPlatform: user.platform)
    }

    static func setRecentUser(list: [WhoopsUser], forPlatform p: Platform) {
        recent_userList_dic[p.rawValue] = list.codedString
    }
}

extension NetLayer {
    static func checkAllTokensAvailable(callback: CallbackInfoOnlyType) {
        guard let token = sessionUser(for: Platform.weChat)?.token,
              let data = commonBatchRequestData
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/user/token/check")!
        post(["batchVOList": data], to: url, withToken: token) { data, status in
            guard status == .ok,
                  data["success"].bool == true,
                  let arr = data["data"].array
            else {
                callback?(false, data["message"].string)
                return
            }
            let s = arr.reduce(0) { (r, j) -> Int in
                j["isOnline"].intValue + r
            }
            callback?(s == Platform.allCases.count, nil)
        }
    }

    static func revoke(user: WhoopsUser, callback: CallbackInfoOnlyType) {
        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/user/revokeSecretKey")!
        putJson(["publicKey": try! user.publicKey.base64String()], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            recent_userList_dic[user.platform.rawValue] = nil
            callback?(true, "")
        }
    }

    static func revokeBatch(callback: CallbackInfoOnlyType) {
        guard let token = sessionUser(for: .weChat)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/user/revokeSecretKey/batch")!
        var pks: [String] = []
        for p in Platform.allCases {
            guard let su = sessionUser(for: p),
                  let pk = try? su.publicKey.base64String()
            else { continue }
            pks.append(pk)
        }

        putJson(["publicKeys": pks], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            recent_userList_dic = [:]
            callback?(true, "")
        }
    }

    static func bind(platform: Platform, headURL: String, name: String, id: String, callback: CallbackInfoOnlyType) {
        guard let token = sessionUser(for: platform)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/user/bindPlatform")!
        let form = [
            "headUrl": headURL,
            "platform": getPlatformCode(for: platform),
            "name": name,
            "applyId": id,
        ]

        putJson(form, to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true, let u = sessionUser(for: platform) else {
                callback?(false, data["message"].string)
                return
            }
            u.iconImageUrl = headURL
            u.name = name
            setSessionUser(user: u)
            callback?(true, "")
        }
    }

    static func unbind(platform: Platform, callback: CallbackInfoOnlyType) {
        guard let su = sessionUser(for: platform),
              let token = su.token
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/user/unbindPlatform/\(su.the_id)")!

        put([:], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            su.iconImageUrl = ""
            su.name = su.publicKey.fingerPrint()
            setSessionUser(user: su)
            callback?(true, "")
        }
    }
}

extension NetLayer {
    static func chatHistoryWith(user: WhoopsUser, pageNumber: Int, pageSize: Int, callback: CallbackWithDataType) {
        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }

        var query: [String: Any] = [
            "pageNumber": pageNumber,
            "pageSize": pageSize,
        ]
        if user.userType == kUserTypeSingle {
            query["friendId"] = user.friend_id
            query["type"] = 0
        } else {
            query["groupId"] = user.the_id
            query["type"] = 1
        }
        let url = URL(string: "\(endPoint)/msg?" + query.queryString)!

        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }

            callback?(true, data["data"], "")
        }
    }

    static func checkOnlineBatchBatch(allContacts: [WhoopsUser], callback: CallbackWithDataType) {
        guard let token = sessionUser(for: .weChat)?.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }

        var data: [[String: Any]] = []
        for p in Platform.allCases {
            let contacts = allContacts.filter { $0.platform == p }
            let l = contacts.map { "\($0.friend_id)" }

            let d: [String: Any] = [
                "friendIds": l,
                "platform": getPlatformCode(for: p),
            ]
            data.append(d)
        }
        let url = URL(string: "\(endPoint)/friends/online/batch/new")!

        post(["onlineVOS": data], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true, let array = data["data"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            var onlineIds: [Int] = []
            for p in array {
                for f in p["friendInfo"].arrayValue where f["status"].intValue == 1 {
                    onlineIds.append(f["friendId"].intValue)
                }
            }
            callback?(true, onlineIds, nil)
        }
    }

    static func checkOnlineBatch(contacts: [WhoopsUser], p: Platform, callback: CallbackWithDataType) {
        guard let token = sessionUser(for: p)?.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        let l = contacts.map { "\($0.friend_id)" }
        let s = l.joined(separator: "&friendIds=")

        let url = URL(string: "\(endPoint)/friends/online/batch?friendIds=\(s)")!

        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true, let array = data["data"].array
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            var ids: [Int] = []
            for j in array {
                guard j["status"].int == 1 else { continue }
                ids.append(j["friendId"].int!)
            }
            callback?(true, ids, "")
        }
    }

    static func checkOnline(user: WhoopsUser, callback: CallbackWithDataType) {
        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/friends/online/\(user.friend_id)")!

        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }
            callback?(true, (data["data"].int ?? 0) == 1, "")
        }
    }

    static func deleteContact(_ user: WhoopsUser, callback: CallbackInfoOnlyType) {
        let url = URL(string: "\(endPoint)/friends/\(user.the_id)")!

        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        delete(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            var l = recentUserList(for: user.platform)
            if let i = l.firstIndex(of: user) {
                l.remove(at: i)
                setRecentUser(list: l, forPlatform: user.platform)
            }
            callback?(true, "")
        }
    }

    static func setNickName(name: String, for user: WhoopsUser, callback: CallbackInfoOnlyType) {
        guard user.the_id != 0 else {
            callback?(false, kErrDataInvalid)
            return
        }

        let url = URL(string: "\(endPoint)/friends/\(user.the_id)")!

        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        put(["note": name], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func deleteBlackList(user: WhoopsUser, callback: CallbackInfoOnlyType) {
        let url = URL(string: "\(endPoint)/blackList/\(user.the_id)")!

        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        delete(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            callback?(true, "")
        }
    }

    static func setBlackList(user: WhoopsUser, callback: CallbackInfoOnlyType) {
        let data: [String: Int] = [
            "hitUserId": user.friend_id,
        ]
        let url = URL(string: "\(endPoint)/blackList")!

        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        post(data, to: url, withToken: token) {
            guard $1 == .ok, $0["success"].bool == true
            else {
                callback?(false, $0["message"].string)
                return
            }
            var l = recentUserList(for: user.platform)
            if let i = l.firstIndex(of: user) {
                l.remove(at: i)
                setRecentUser(list: l, forPlatform: user.platform)
            }
            callback?(true, nil)
        }
    }

    static func getBlackList(for p: Platform, callback: CallbackWithDataType) {
        let url = URL(string: "\(endPoint)/blackList")!
        guard let token = sessionUser(for: p)?.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }

            let blackListData = data["data"].array ?? []
            var blackList: [WhoopsUser] = []
            for d in blackListData {
                guard let publicKeys = d["publicKey"].string,
                      let publicKey = try? PublicKey(base64Encoded: publicKeys)
                else { continue }
                let u = WhoopsUser(publicKey: publicKey, the_id: d["id"].int!, platform: p)
                u.iconImageUrl = d["headUrl"].string
                u.name = u.anonymous ? publicKey.fingerPrint() : d["name"].string!
                u.friend_id = d["friendId"].int!
                blackList.append(u)
            }
            callback?(true, blackList, nil)
        }
    }

    static func getFriendList(for p: Platform, callback: CallbackWithDataType) {
        let url = URL(string: "\(endPoint)/friends")!

        guard let token = sessionUser(for: p)?.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }

            let friendList = data["data"]["friendInfoList"].array ?? []
            var userList: [WhoopsUser] = []
            for d in friendList {
                if let u = WhoopsUser(json: d, platform: p) {
                    userList.append(u)
                }
            }

            guard userList.count == friendList.count else {
                callback?(false, nil, kErrDataInvalid)
                return
            }
            callback?(true, userList, nil)
        }
    }

    static func getFriendListBatch(callback: CallbackWithDataType) {
        guard let token = sessionUser(for: .weChat)?.token,
              let data = commonBatchRequestData
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }

        let url = URL(string: "\(endPoint)/friends/friends/batch")!
        post(["batchVOList": data], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }
            var userList: [WhoopsUser] = []
            let platforms = data["data"]["friendsList"].array ?? []

            for p in platforms {
                let p1 = getPlatform(for: Int(p["platform"].intValue))
                let friendList = p["friendsList"].array ?? []
                for d in friendList {
                    if let u = WhoopsUser(json: d, platform: p1) {
                        userList.append(u)
                    }
                }
            }

            callback?(true, userList, nil)
        }
    }

    static func getBlackListBatch(callback: CallbackWithDataType) {
        let url = URL(string: "\(endPoint)/blackList/batch")!
        guard let token = sessionUser(for: .weChat)?.token,
              let data = commonBatchRequestData
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }
        post(["batchVOList": data], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, nil, data["message"].string)
                return
            }
            guard let platforms = data["data"].array else {
                callback?(false, nil, kErrDataInvalid)
                return
            }

            var blackList: [WhoopsUser] = []

            for p in platforms {
                let p1 = getPlatform(for: Int(p["platform"].intValue))
                let friendList = p["blackList"].array ?? []
                for d in friendList {
                    guard let publicKeys = d["publicKey"].string,
                          let publicKey = try? PublicKey(base64Encoded: publicKeys)
                    else { continue }
                    let u = WhoopsUser(publicKey: publicKey, the_id: d["id"].int!, platform: p1)
                    u.iconImageUrl = d["headUrl"].string
                    u.name = u.anonymous ? publicKey.fingerPrint() : d["name"].string!
                    u.friend_id = d["friendId"].int!
                    blackList.append(u)
                }
            }
            callback?(true, blackList, "")
        }
    }
}

extension NetLayer {
    static func regNewUser(user: WhoopsUser, callback: CallbackInfoOnlyType) {
        let data: [String: String] = [
            "publicKey": try! user.publicKey.base64String(),
            "platform": getPlatformCode(for: user.platform),
            "isAnonymous": "0",
            "imei": deviceUUID,
            "channel": "ios",
            "clientCode": deviceUUID,
            "applyId": "",
            "headUrl": "",
            "name": "",
        ]

        let url = URL(string: "\(endPoint)/user/register")!

        post(data, to: url) {
            guard $1 == .ok, $0["success"].bool == true,
                  let token = $0["data"]["token"].string
            else {
                callback?(false, $0["message"].string)
                return
            }

            user.token = token
            setSessionUser(user: user)

            userInfo(user: user) { r, msg in
                if r {
                    setSessionUser(user: user)
                    if let addr = WalletUtil.getAddress(mode: kAddressModeMain) {
                        updateWallet(address: addr, p: user.platform, callback: nil)
                    }
                } else {
                    removeSessionUser(for: user.platform)
                }
                callback?(r, msg)
            }
        }
    }

    static func loginUser(user: WhoopsUser, callback: CallbackInfoOnlyType) {
        let data: [String: String] = [
            "publicKey": try! user.publicKey.base64String(),
            "imei": deviceUUID,
        ]
        let url = URL(string: "\(endPoint)/user/login")!
        post(data, to: url) {
            guard $1 == .ok, $0["success"].bool == true,
                  let token = $0["data"]["token"].string
            else {
                callback?(false, $0["message"].string)
                return
            }

            user.token = token
            setSessionUser(user: user)

            userInfo(user: user) { r, msg in
                if r {
                    setSessionUser(user: user)
                    if let addr = WalletUtil.getAddress(mode: kAddressModeMain) {
                        updateWallet(address: addr, p: user.platform, callback: nil)
                    }
                } else {
                    removeSessionUser(for: user.platform)
                }

                callback?(r, msg)
            }
        }
    }

    static func loginBatch(users: [WhoopsUser], callback: CallbackInfoOnlyType) {
        var arrData: [[String: String]] = []
        let uuid = deviceUUID
        for user in users {
            let data: [String: String] = [
                "publicKey": try! user.publicKey.base64String(),
                "imei": uuid,
                "channel": "ios",
                "platform": getPlatformCode(for: user.platform),
            ]
            arrData.append(data)
        }
        let url = URL(string: "\(endPoint)/user/login/batch")!
        post(["loginRequestList": arrData], to: url) {
            guard $1 == .ok, $0["success"].bool == true,
                  let tokens = $0["data"].dictionaryObject as? [String: String]
            else {
                callback?(false, $0["message"].string)
                return
            }
            for user in users {
                let c = getPlatformCode(for: user.platform)
                user.token = tokens[c]
                setSessionUser(user: user)
            }

            userInfoBatch { r, _ in
                callback?(r, nil)
                if r { return }

                for user in users {
                    removeSessionUser(for: user.platform)
                }
            }

            if let addr = WalletUtil.getAddress(mode: kAddressModeMain) {
                updateWalletBatch(address: addr, callback: nil)
            }
        }
    }

    static func regNewUserBatch(users: [WhoopsUser], callback: CallbackInfoOnlyType) {
        var arrData: [[String: String]] = []
        let uuid = deviceUUID
        for user in users {
            let data: [String: String] = [
                "publicKey": try! user.publicKey.base64String(),
                "platform": getPlatformCode(for: user.platform),
                "isAnonymous": "0",
                "imei": uuid,
                "channel": "ios",
                "clientCode": uuid,
                "applyId": "",
                "headUrl": "",
                "name": "",
            ]
            arrData.append(data)
        }

        let url = URL(string: "\(endPoint)/user/register/batch")!

        post(["registerRequests": arrData], to: url) {
            guard $1 == .ok, $0["success"].bool == true,
                  let tokens = $0["data"].dictionaryObject as? [String: String]
            else {
                callback?(false, $0["message"].string)
                return
            }

            for user in users {
                let c = getPlatformCode(for: user.platform)
                user.token = tokens[c]
                setSessionUser(user: user)
            }
            userInfoBatch { r, _ in
                callback?(r, nil)
                if r { return }

                for user in users {
                    removeSessionUser(for: user.platform)
                }
            }
            if let addr = WalletUtil.getAddress(mode: kAddressModeMain) {
                updateWalletBatch(address: addr, callback: nil)
            }
        }
    }

    static func logoutAll() {
        guard let token = sessionUser(for: .weChat)?.token,
              let data = commonBatchRequestData
        else {
            return
        }
        let url = URL(string: "\(endPoint)/user/logOut/batch")!

        post(["batchVOList": data], to: url, withToken: token) { _, _ in
        }

        for p in Platform.allCases {
            setRecentUser(list: [], forPlatform: p)
            recent_userList_dic.removeAll()
            loginUser.removeAll()
        }
    }

    static func userInfoBatch(callback: CallbackInfoOnlyType) {
        guard let token = sessionUser(for: .weChat)?.token,
              let data = commonBatchRequestData
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        let url = URL(string: "\(endPoint)/user/info/batch")!

        post(["batchVOList": data], to: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            guard let users = data["data"].array
            else {
                callback?(false, kErrDataInvalid)
                return
            }

            for user in users {
                let p1 = getPlatform(for: Int(user["platform"].intValue))
                let userData = user["userInfo"]
                guard let su = sessionUser(for: p1),
                      let the_id = userData["id"].int,
                      let inviteCode = userData["inviteCode"].string
                else { continue }
                su.name = userData["name"].string ?? su.publicKey.fingerPrint()
                su.the_id = the_id
                su.inviteCode = inviteCode
                su.iconImageUrl = userData["headUrl"].string
                su.walletAddress = userData["walletAddress"].stringValue
                su.raw_value = data.rawString([.castNilToNSNull: true]) ?? ""
                if su.anonymous {
                    su.name = su.publicKey.fingerPrint()
                }
                setSessionUser(user: su)
            }
            callback?(true, nil)
        }
    }

    static func userInfo(user: WhoopsUser, callback: CallbackInfoOnlyType) {
        let url = URL(string: "\(endPoint)/user/info")!
        guard user.isMySelf else {
            assertionFailure("Only Login User Allow")
            return
        }
        guard let token = sessionUser(for: user.platform)?.token else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }

        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true else {
                callback?(false, data["message"].string)
                return
            }
            guard let the_id = data["data"]["id"].int,
                  let inviteCode = data["data"]["inviteCode"].string
            else {
                callback?(false, kErrDataInvalid)
                return
            }
            user.name = data["data"]["name"].string ?? user.publicKey.fingerPrint()
            user.the_id = the_id
            user.inviteCode = inviteCode
            user.iconImageUrl = data["data"]["headUrl"].string
            user.walletAddress = data["data"]["walletAddress"].stringValue
            user.raw_value = data.rawString([.castNilToNSNull: true]) ?? ""
            if user.anonymous {
                user.name = user.publicKey.fingerPrint()
            }
            callback?(true, nil)
        }
    }
}

// MARK: - Offlines

extension NetLayer {
    static func confirmOfflineMsg(_ msg: OfflineModel) {
        guard let su = sessionUser(for: msg.platform),
              let token = su.token
        else {
            return
        }
        for id in msg.sessionIdList {
            let url = URL(string: "\(endPoint)/msg/\(id)/ack/offline")!
            delete(from: url, withToken: token) { _, _ in
            }
        }
    }

    static func getOfflineMsgs(user: WhoopsUser, callback: CallbackWithDataType) {
        let url = URL(string: "\(endPoint)/msg/session/offline")!

        guard let token = user.token else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }

        get(from: url, withToken: token) { data, status in
            guard status == .ok, data["success"].bool == true
            else {
                callback?(false, nil, data["message"].string)
                return
            }
            let singleArr = data["data"]["p2pSessionList"].array ?? []
            let groupArr = data["data"]["groupSessionList"].array ?? []

            var msgList: [OfflineModel] = []
            for d in singleArr + groupArr {
                let isGroup = d["type"].int! == 1

                let targetId = isGroup ? d["groupId"].int! : d["fromId"].int!
                let id = d["id"].int!
                let count = d["count"].int!
                let endTime = d["endTime"].int!
                let o = OfflineModel(platform: user.platform, targetId: targetId, isGroupMsg: false, msgCount: count, sessionIdList: [id], endTime: endTime)
                if let i = msgList.firstIndex(of: o) {
                    msgList[i].add(o)
                } else {
                    msgList.append(o)
                }
            }

            callback?(true, msgList, "")
        }
    }

    static func getOfflineMsgConutOnly(platform: Platform, callback: CallbackWithDataType) {
        guard let su = sessionUser(for: platform)
        else {
            callback?(false, nil, kErrCurrentUserNotLogin)
            return
        }

        getOfflineMsgs(user: su) { success, data, msg in
            guard success, let s = data as? [OfflineModel] else {
                callback?(false, nil, msg)
                return
            }
            let c = s.reduce(0) { (r, o) -> Int in
                r + o.msgCount
            }

            callback?(true, c, nil)
        }
    }

    static func getOfflineMsgConutOnlyBatch(platforms: [Platform], callback: CallbackWithDataType) {
        let cache = NSCache<NSNumber, NSObject>()
        let group = DispatchGroup()
        var result = true
        var msg = ""
        for (i, p) in platforms.enumerated() {
            group.enter()
            getOfflineMsgConutOnly(platform: p) { _, c, m in
                guard let l = c as? Int else {
                    result = false
                    msg = m ?? ""
                    group.leave()
                    return
                }
                cache.setObject(NSNumber(value: l), forKey: NSNumber(value: i))
                group.leave()
            }
        }

        group.notify(queue: .global()) {
            var c: Int = 0
            for i in 0 ..< platforms.count {
                if let l1 = cache.object(forKey: NSNumber(value: i)) as? NSNumber {
                    c += l1.intValue
                }
            }
            callback?(result, c, msg)
        }
    }
}
