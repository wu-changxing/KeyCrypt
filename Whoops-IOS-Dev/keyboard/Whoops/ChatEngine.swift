//
//  ChatEngine.swift
//  keyboard
//
//  Created by Aaron on 7/30/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import CocoaAsyncSocket
import ConfluxSDK
import FCUUID
import SwiftyJSON
import UIKit

class ChatEngine: NSObject {
    static let shared = ChatEngine()

    let msgHistory = MsgHistory()

    var waittingNewOne = false

    private weak var inputBar: InputBar?
    private weak var chatView: ChatHistoryView?
    weak var toolBar: ToolBar?
    private(set) var targetUser: WhoopsUser?
    private var nextHistoryPage: Int = 1 // 从1开始
    private let backGroundQueue = DispatchQueue(label: "ChatEngineQueue")
    var ready: Bool {
        inputBar != nil && chatView != nil
    }

    override private init() {
        super.init()
        SocketLayer.shared.delegate = self
    }

    private func getOfflineMsg(for u: WhoopsUser) {
        NetLayer.getOfflineMsgs(user: u) { r, d, _ in
            guard r, let arr = d as? [OfflineModel] else { return }

            var msgs: [Int: OfflineModel] = [:]
            var mostRecentOne: OfflineModel?
            for m in arr {
                msgs[m.targetId] = m
                self.msgHistory.unreadAdd(for: m.targetId, n: m.msgCount)
                if let mo = mostRecentOne {
                    mostRecentOne = mo.endTime < m.endTime ? m : mo
                } else {
                    mostRecentOne = m
                }
            }

            guard let m = mostRecentOne else { return }
            self.msgHistory.setOfflineMsg(msgs)
            self.showTheFuckingRedDotIfNeeded(mostRecentId: m.targetId)
        }
    }

    func login() {
        msgHistory.releaseHistory(except: nil)

        guard let platform = Platform.fromClientID(KeyboardViewController.inputProxy!.clientID)
        else { return }

        if let u = NetLayer.sessionUser(for: platform), SocketLayer.shared.connect2Server(platform) {
            SocketLayer.shared.login(session: u) { r, msg in
                guard r else {
                    DispatchQueue.main.async {
                        self.inputBar?.showHintOnly(msg ?? "登录失败")
                    }
                    return
                }
                self.getOfflineMsg(for: u)
            }
        } else {
            var m: RSAKeyPairManager
            if let m1 = RSAKeyPairManager(for: platform) {
                m = m1
            } else {
                DispatchQueue.main.async {
                    self.inputBar?.showHintOnly("证书丢失，错误：8938")
                }
                return
                    // 如果证书不存在，就报个错
            }
            let u = WhoopsUser(keypairs: m)
            NetLayer.loginUser(user: u) { r, msg in
                guard r, let u = NetLayer.sessionUser(for: platform) else {
                    DispatchQueue.main.async {
                        self.inputBar?.showHintOnly(msg ?? "登录失败")
                    }
                    return
                }
                _ = SocketLayer.shared.connect2Server(platform)
                SocketLayer.shared.login(session: u) { r, msg in
                    guard r else {
                        DispatchQueue.main.async {
                            self.inputBar?.showHintOnly(msg ?? "登录失败")
                        }
                        return
                    }
                    self.getOfflineMsg(for: u)
                }
            }
        }
    }

    func hook(inputBar: InputBar, chatView: ChatHistoryView) {
        self.chatView = chatView
        self.inputBar = inputBar
    }

    func setTarget(user: WhoopsUser) {
        targetUser?.groupMembersCache = nil
        targetUser = user
        LocalConfigManager.shared.lastChatTarget = user
        waittingNewOne = false
        inputBar?.userIcon.image = nil
        if targetUser?.userType == kUserTypeGroup {
            inputBar?.userIcon.image = #imageLiteral(resourceName: "GroupIcon").withInset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            inputBar?.userIcon.backgroundColor = UIColor(rgb: user.groupColor)
            user.loadGroupPrivateKey()

        } else {
            user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) { i in
                self.inputBar?.userIcon.image = i
            }
        }

        inputBar?.showInputView()
        chatView?.hideToast()
        backGroundQueue.async {
            NetLayer.setMostRecentUser(user)
        }
        chatView?.prepareForNew()

        nextHistoryPage = 1
        let l = msgHistory.getHistory(for: user) ?? []
        if !l.isEmpty {
            for m in l {
                if targetUser?.userType == kUserTypeSingle {
                    genTransferStringIfNeeded(for: m, with: user)
                    if m.userType == .friend {
                        m.senderHeadUrl = user.iconImageUrl
                    }
                } else {
                    if m.text == nil {
                        m.text = targetUser?.decryptString(encryptedContent: m.encryptedText!, encryptedPwd: m.secretKey!) ?? m.encryptedText
                    }
                    if m.modelType == .redpack {
                        genRedpacketStringIfNeeded(for: m)
                    }
                }
            }
        }

        if user.userType == kUserTypeGroup {
            user.loadGroupMembers(callback: { r, _ in
                guard r else { return }
                let d = self.msgHistory.updateHeadIconAndNickNames(for: user)
                guard user == self.targetUser else { return }
                self.msgHistory.currentHeadUrlCache = d
                self.chatView?.reloadData()
                print("head url loaded")
            })
        }

        if l.isEmpty { // 如果当前用户没缓存聊天记录，就从服务器拉一下试试
            loadMoreHistory(toBottom: true)
        } else {
            chatView?.setHistory(l, toBottom: true)
        }
        msgHistory.confirmUnreadMsg(for: user.friend_id)
        if msgHistory.hasUnreadMsg() {
            toolBar?.hasNewMsg()
        } else {
            toolBar?.newMsgRead()
        }
    }

    func removeTarget() {
        targetUser = nil
        inputBar?.showHintOnly()
        chatView?.cleanup()
    }

    func sendRedPack(value: Double, count: Int, hash: String, token: Token?, textEncrypt: Bool, rootHash: String) {
        guard targetUser?.userType == kUserTypeGroup else { return }

        let data: [String: Any] = [
            "tokenType": token?.mark ?? "CFX",
            "contractAddress": token?.contract as Any,
            "value": value,
            "count": count,
            "transactionId": hash,
            "attachMessage": "",
            "rootHash": rootHash,
        ]
        sendMsg(content: JSON(data).rawString()!, type: .redpack, textEncrypt: textEncrypt, value: value, token: token, count: count, hash: hash, rootHash: rootHash)
    }

    func sendTransfer(value: Double, hash: String, token: Token?, textEncrypt: Bool) {
        guard targetUser?.userType == kUserTypeSingle else { return }

        let data: [String: Any] = [
            "tokenType": token?.mark ?? "CFX",
            "value": value,
            "from": WalletUtil.getAddress()!,
            "to": targetUser!.walletAddress,
            "transactionId": hash,
        ]
        sendMsg(content: JSON(data).rawString()!, type: .transfer, textEncrypt: textEncrypt, value: value, token: token, hash: hash)
    }

    /// 给对应的群或用户发消息
    /// - Parameters:
    ///   - content: 消息的内容
    ///   - type: 消息的类型，文本、红包或者是转账
    ///   - textEncrypt: 发送到微信等平台的消息是否要加密，默认加密
    func sendMsg(content: String, type: LXFChatMsgModelType = .text, textEncrypt: Bool = true, value: Double = 0, token: Token? = nil, count: Int = 0, hash: String = "", rootHash: String = "") {
        guard let u = targetUser, let s = NetLayer.sessionUser(for: u.platform) else { return }

        let (t, p, selfPwd) = u.encryptString(content: content, selfUser: s)

        let m = LXFChatMsgModel()
        m.fromUserId = "\(s.friend_id)"
        m.fromUserNickName = s.nickName ?? s.name
        if u.userType == kUserTypeGroup {
            m.sessionId = "\(u.the_id)"
        }
        m.text = content
        m.encryptedText = t
        m.secretKey = p
        m.selfSecretKey = selfPwd
        m.modelType = type
        switch type {
        case .transfer:
            m.value = value
            m.tokenType = token?.mark ?? "CFX"
            m.senderAddress = u.walletAddress
            m.transactionHash = hash
            genTransferStringIfNeeded(for: m, with: u)
        case .redpack:
            m.value = value
            m.tokenType = token?.mark ?? "CFX"
            m.count = count
            m.transactionHash = hash
//                m.redPacketId = redPacketId
            m.rootHash = rootHash
            genRedpacketStringIfNeeded(for: m)

        default: break
        }

        m.userType = .me
        m.timestamp = UInt64(Date().currentTimeMillis())
        m.toUserId = "\(u.friend_id)"
        m.senderHeadUrl = s.iconImageUrl
        m.tag = Int.random(in: 100_000_000_000 ..< 1_000_000_000_000)

        if m.modelType == .redpack {
            // 红包等待服务器发，本地不再发红包的消息出去了
            DispatchQueue.main.async {
                let tokenType = m.tokenType!
                let keyboard = KeyboardViewController.inputProxy as? KeyboardViewController
                if textEncrypt {
                    keyboard?.insertToApp(t)
                } else {
                    guard let k = keyboard,
                          let p = Platform.fromClientID(k.clientID),
                          let uu = NetLayer.sessionUser(for: p)
                    else {
                        return
                    }
                    let timestamp = "\(Int64(Date().timeIntervalSince1970))"
                    let randomS = timestamp.subString(from: timestamp.count - 6)+AES.randomString(4)
                    NetLayer.convertInviteCode(randomCode: randomS, user: uu) { (b, msg) in
                        guard b else {
                            k.toast(str: msg ?? "")
                            return
                        }
                        DispatchQueue.main.async {
                            
                            let temp = "🎁我在 Whoops【\(u.name)】 群内发了一个价值\(value.whoopsString)\(tokenType)的红包，共\(count)份，点击下载 Whoops 输入法：https://whoops.world/ime-web/short/agree?code=\(randomS)\r长按复制这条信息加群₳\(u.inviteCode!.uppercased())₳\n"
                                
                            keyboard?.insertToApp(temp)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                keyboard?.insertToApp("\n")
                            }
                        }
                    }
                    
                }

                

                let d = WhoopsAlertView(title: "红包已发出", detail: "交易已经发出，待后台交易完成后红包将自动发送到群，24小时后若红包还有余额则会自动返还到您的钱包。", confirmText: "好", confirmOnly: true)
                d.overlay(to: keyboard!.view)
            }
            return
        }

        msgHistory.appendHistory(for: u.friend_id, history: m)

        SocketLayer.shared.sendMessage(msg: m, isGroup: u.userType == kUserTypeGroup) { login, _ in
            m.deliveryState = .delivered // 发送的时候默认成功，出问题再显示
            DispatchQueue.main.async {
                let keyboard = KeyboardViewController.inputProxy as? KeyboardViewController
                if textEncrypt {
                    keyboard?.insertToApp(t)
                } else {
                    let tokenType = m.tokenType!
                    switch type {
                    case .transfer:
                        keyboard?.insertToApp("我向\(u.nickName ?? u.name)转账\(value.whoopsString)\(tokenType)，打开 Whoops 查收。")
                    default:
                        keyboard?.insertToApp(t)
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    keyboard?.insertToApp("\n")
                }

                self.chatView?.displayMsg(m)
            }

            if !login {
                // 用户没登录，跳转app
            }
        }
    }

    func loadMoreHistory(toBottom: Bool) {
        guard let u = targetUser, let s = NetLayer.sessionUser(for: u.platform), nextHistoryPage > 0 else {
            DispatchQueue.main.async {
                self.chatView?.insertHistory([])
            }
            return
            
        }
        NetLayer.chatHistoryWith(user: u, pageNumber: nextHistoryPage, pageSize: 5) { r, d, msg in
            guard r, let data = d as? SwiftyJSON.JSON, let l = data["list"].array, let n = data["nextPage"].int, n >= 0 else {
                //"nextPage" == 0 说明是最后一页了
                DispatchQueue.main.async {
                    self.chatView?.insertHistory([])
                }
                return
            }
            var h: [LXFChatMsgModel] = []
            let headUrlDic = self.msgHistory.currentHeadUrlCache

            for m in l {
                let fromId = m["fromId"].int!
                let msg = LXFChatMsgModel()
                let msgType = m["msgType"].int

                msg.encryptedText = m["message"].string
                msg.secretKey = m["secretKey"].string
                msg.selfSecretKey = m["selfSecretKey"].string

                msg.deliveryState = .delivered
                msg.timestamp = m["time"].uInt64
                let isGroup = m["type"].int == 1

                if fromId == u.friend_id {
                    msg.fromUserId = "\(fromId)"
                    msg.toUserId = "\(s.friend_id)"
                    msg.userType = .friend
                    msg.senderHeadUrl = u.iconImageUrl
                    msg.text = s.decryptString(encryptedContent: msg.encryptedText!, encryptedPwd: msg.secretKey!) ?? "[消息解密失败！]"

                } else {
                    if isGroup {
                        msg.fromUserNickName = headUrlDic[fromId]?.name
                        msg.sessionId = "\(u.friend_id)"
                        msg.fromUserId = "\(fromId)"
                        msg.toUserId = "\(s.friend_id)"
                        if fromId != s.the_id { // 群聊里，不是自己，那就是群友了
                            msg.userType = .friend
                            msg.senderHeadUrl = headUrlDic[fromId]?.icon
                        } else {
                            msg.userType = .me
                            msg.senderHeadUrl = s.iconImageUrl
                        }
                        if [4, 6, 7].contains(msgType) {
                            msg.text = msg.encryptedText
                        } else {
                            msg.text = u.decryptString(encryptedContent: msg.encryptedText!, encryptedPwd: msg.secretKey!) ?? msg.encryptedText
                        }

                    } else {
                        msg.fromUserId = "\(s.friend_id)"
                        msg.toUserId = "\(fromId)"
                        msg.userType = .me
                        msg.senderHeadUrl = s.iconImageUrl
                        msg.text = s.decryptString(encryptedContent: msg.encryptedText!, encryptedPwd: msg.selfSecretKey!)
                    }
                }

                if msgType == 0 {
                    msg.modelType = .text
                }
                if msgType == 6 || msgType == 7 { continue }
                if msgType == 4 {
                    msg.modelType = .redpack
                    let j = try! JSON(data: msg.text!.data(using: .utf8, allowLossyConversion: false)!)

                    let v = j["value"].string ?? "-1"
                    let de = j["tokenDecimals"].int ?? 1
                    msg.value = Drip(v)?.gDripIn(decimals: de) ?? -1
                    msg.tokenType = j["tokenType"].string
                    msg.count = j["count"].int ?? 1
                    msg.redPacketId = j["redPacketId"].int

                    let t = j["msgType"].string ?? "redpacket"
                    switch t {
                    case "rob":
                        let v = j["robed"].stringValue
                        msg.robed = Drip(v)?.gDripIn(decimals: de) ?? 0
                        msg.timestamp = j["timestamp"].uInt64Value
                        msg.redpacketType = .rob

                    case "release":
                        let v = j["rest"].stringValue
                        msg.rest = Drip(v)?.gDripIn(decimals: de) ?? 0
                        msg.robCount = j["robCount"].intValue
                        msg.redpacketType = .release

                    default:
                        msg.redpacketType = .redpacket
                        msg.rootHash = j["rootHash"].string
                        msg.transactionHash = j["transactionId"].string
                    }
                    self.genRedpacketStringIfNeeded(for: msg)
                }
                if msgType == 5 {
                    msg.modelType = .transfer
                    let j = try! JSON(data: msg.text!.data(using: .utf8, allowLossyConversion: false)!)
                    msg.value = j["value"].double
                    msg.tokenType = j["tokenType"].string
                    msg.senderAddress = j["from"].string
                    msg.transactionHash = j["transactionId"].string
                    self.genTransferStringIfNeeded(for: msg, with: u)
                }

                h.append(msg)
            }

            guard u == self.targetUser else { return } // 如果当前显示的还是同一个用户的话就加载更多历史
            var history = self.msgHistory.getHistory(for: u) ?? []
            history.insert(contentsOf: h.reversed(), at: 0)
            history = history.unique
            self.msgHistory.setHistory(for: u, history: history)
            self.nextHistoryPage = n

            DispatchQueue.main.async {
                self.chatView?.setHistory(history, toBottom: toBottom)
            }
        }
    }
}

extension ChatEngine: SocketMessageLayerDelegate {
    func msgSentStatus(for tag: Int, status: Bool, msg _: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            if status {
                self.chatView?.confirmMsgSent(withTag: tag)
                //            暂时不做消息状态追踪了，就默认全都发送成功
            } else {
                self.chatView?.failedMsgSent(withTag: tag)
            }
        }
    }

    func showTheFuckingRedDotIfNeeded(mostRecentId: Int) {
        if msgHistory.hasUnreadMsg() {
            toolBar?.hasNewMsg()
        } else {
            toolBar?.newMsgRead()
        }

        backGroundQueue.async {
            guard let p = KeyboardViewController.inputProxy?.clientID,
                  let platform = Platform.fromClientID(p)
            else { return }

            var users = NetLayer.recentUserList(for: platform)

            if let i = users.firstIndex(where: { $0.friend_id == mostRecentId }) {
                // 如果用户在最近列表就挪到前面
                let tmp = users.remove(at: i)
                users.insert(tmp, at: users.isEmpty || self.targetUser == nil ? 0 : 1)
                NetLayer.setRecentUser(list: users, forPlatform: platform)

            } else {
                // 如果用户不在就重新拉取一下好友列表找找
                NetLayer.getFriendList(for: platform) { _, data, _ in
                    guard let l = data as? [WhoopsUser],
                          let i = l.firstIndex(where: { $0.friend_id == mostRecentId })
                    else { return }

                    if self.targetUser == nil, self.waittingNewOne {
                        // 到这说明用户刚发了一个邀请，如果他没切换聊天的话，收到消息就自动开启
                        DispatchQueue.main.async {
                            self.setTarget(user: l[i])
                        }

                    } else {
                        // 找到了就添加到最近列表的次优
                        users.insert(l[i], at: users.isEmpty || self.targetUser == nil ? 0 : 1)
                        NetLayer.setRecentUser(list: users, forPlatform: platform)
                    }
                }
            }
        }
    }

    func newMsgArrived(msg: LXFChatMsgModel) {
        let fromId = Int(msg.sessionId ?? msg.fromUserId!)!

        if msg.sessionId != nil, let s = SocketLayer.shared.sessionUser { // 是群组消息
            if let d = msg.fromUserId, let i = Int(d) {
                msg.fromUserNickName = msgHistory.currentHeadUrlCache[i]?.name
            }

            if msg.modelType == .redpack {
                if msg.fromUserId == "\(s.the_id)" {
                    msg.userType = .me
                } else {
                    msg.userType = .friend
                }
                msg.text = msg.encryptedText
            }
        }

        backGroundQueue.async {
            self.msgHistory.appendHistory(for: fromId, history: msg)
        }

        if let u = targetUser, fromId == u.friend_id, let s = NetLayer.sessionUser(for: u.platform) {
            // 如果是给当前用户发的，就直接显示就完了。
            if targetUser?.userType == kUserTypeGroup {
                if msg.modelType == .redpack {
                    genRedpacketStringIfNeeded(for: msg)
                } else {
                    if let t = targetUser?.decryptString(encryptedContent: msg.encryptedText!, encryptedPwd: msg.secretKey!) {
                        msg.text = t
                    } else {
                        msg.text = msg.encryptedText
                        if msg.fromUserId == "\(s.the_id)" {
                            msg.userType = .me
                        } else {
                            msg.userType = .friend
                        }
                    }
                }
                msg.senderHeadUrl = msgHistory.currentHeadUrlCache[fromId]?.icon

            } else {
                msg.senderHeadUrl = u.iconImageUrl

                genTransferStringIfNeeded(for: msg, with: targetUser!)
            }

            DispatchQueue.main.async {
                self.chatView?.displayMsg(msg)
            }
            return
        }

        msgHistory.unreadAdd(for: fromId, n: 1)
        showTheFuckingRedDotIfNeeded(mostRecentId: fromId)
    }
}

extension ChatEngine {
    func genTransferStringIfNeeded(for msg: LXFChatMsgModel, with user: WhoopsUser) {
        guard msg.modelType == .transfer, msg.text4transferAndRedpack == nil else { return }
        let n: String
        if let s = user.nickName {
            n = s
        } else {
            n = "\(user.name.prefix(4))...\(user.name.suffix(4))"
        }

        if msg.userType == .friend {
            msg.text4transferAndRedpack = "\(n) 向我转账\((msg.value ?? -1).whoopsString)\(msg.tokenType ?? "CFX")，请查收。"
        } else {
            let s = "\(msg.senderAddress!.prefix(8))...\(msg.senderAddress!.suffix(4))"
            msg.text4transferAndRedpack = "我向\(n) (\(s)) 转账\((msg.value ?? -1).whoopsString)\(msg.tokenType ?? "CFX")，请查收。"
        }
    }

    func genRedpacketStringIfNeeded(for msg: LXFChatMsgModel) {
        guard msg.modelType == .redpack, msg.text4transferAndRedpack == nil else { return }
        let n: String
        let userName = msg.fromUserNickName ?? "---"
        if userName.count <= 10 {
            n = userName
        } else {
            n = "\(userName.prefix(4))...\(userName.suffix(4))"
        }

        switch msg.redpacketType {
        case .redpacket:
            if msg.userType == .friend {
                msg.text4transferAndRedpack = "\(n) 发了一个价值\((msg.value ?? -1).whoopsString)\(msg.tokenType ?? "CFX")的红包，共\(msg.count)份，点击领取。"
            } else {
                msg.text4transferAndRedpack = "我发了一个价值\((msg.value ?? -1).whoopsString)\(msg.tokenType ?? "CFX")的红包，共\(msg.count)份，点击领取。"
            }
        case .release:
            if msg.userType == .friend {
                msg.text4transferAndRedpack = "\(n) 的红包24小时未抢完已退回。"
            } else {
                msg.text4transferAndRedpack = "你的红包超24小时未抢完已退回。"
            }
        case .rob:
            if msg.userType == .friend {
                msg.text4transferAndRedpack = "\(n) 抢到了\(msg.robed.whoopsString) \(msg.tokenType ?? "CFX")"
            } else {
                msg.text4transferAndRedpack = "你抢到了\(msg.robed.whoopsString) \(msg.tokenType ?? "CFX")"
            }
        }
    }
}
