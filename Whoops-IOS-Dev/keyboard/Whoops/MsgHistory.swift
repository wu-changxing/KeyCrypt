//
//  MsgHistory.swift
//  keyboard
//
//  Created by Aaron on 10/28/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Foundation

class MsgHistory {
    private var offlineDict: [Int: OfflineModel] = [:]
    private var unreadCount: [Int: Int] = [:]

    private var msgHistory: [Int: [LXFChatMsgModel]] = [:]
    private var writeQueue = DispatchQueue(label: "MsgHistoryWriteQueue")
    var currentHeadUrlCache: [Int: (name: String, icon: String?)] = [:]
    func releaseHistory(except u: WhoopsUser?) {
        var his: [LXFChatMsgModel]? = []
        if let u = u {
            his = msgHistory[u.friend_id]
        }
        currentHeadUrlCache.removeAll()
        writeQueue.async {
            self.msgHistory.removeAll()
            if let u = u {
                self.msgHistory[u.friend_id] = his
            } else {
                self.offlineDict.removeAll()
                self.unreadCount.removeAll()
            }
        }
    }

    func getHistory(for u: WhoopsUser) -> [LXFChatMsgModel]? {
        return msgHistory[u.friend_id]
    }

    func setHistory(for u: WhoopsUser, history: [LXFChatMsgModel]) {
        writeQueue.sync {
            self.msgHistory[u.friend_id] = history
        }
    }

    func appendHistory(for friend_id: Int, history: LXFChatMsgModel) {
        writeQueue.sync {
            var l = self.msgHistory[friend_id] ?? []
            l.append(history)
            self.msgHistory[friend_id] = l
        }
    }

    func updateHeadIconAndNickNames(for g: WhoopsUser) -> [Int: (name: String, icon: String?)] {
        guard g.userType == kUserTypeGroup else { return [:] }
        var headUrlDic: [Int: (name: String, icon: String?)] = [:]

        for m in g.groupMembersCache ?? [] {
            headUrlDic[m.the_id] = (m.nickName ?? m.name, m.iconImageUrl)
        }

        for m in getHistory(for: g) ?? [] {
            m.senderHeadUrl = headUrlDic[Int(m.fromUserId!)!]?.icon
            m.fromUserNickName = headUrlDic[Int(m.fromUserId!)!]?.name
        }
        return headUrlDic
    }
}

// MARK: - Unread Msg

extension MsgHistory {
    func setOfflineMsg(_ msgs: [Int: OfflineModel]) {
        writeQueue.sync {
            self.offlineDict = msgs
        }
    }

    func unreadAdd(for target: Int, n: Int) {
        writeQueue.sync {
            self.unreadCount[target] = (self.unreadCount[target] ?? 0) + n
        }
    }

    func hasUnreadMsg() -> Bool {
        return unreadCount.values.reduce(0,+) > 0 || !offlineDict.isEmpty
    }

    func confirmUnreadMsg(for targetId: Int) {
        writeQueue.sync {
            self.unreadCount[targetId] = nil
        }
        guard let m = offlineDict[targetId] else { return }
        writeQueue.sync {
            self.offlineDict[targetId] = nil
        }
        NetLayer.confirmOfflineMsg(m)
    }

    func getUnreadMsgCount(for targetId: Int) -> Int {
        let u = unreadCount[targetId] ?? 0
        let o = offlineDict[targetId]?.msgCount ?? 0
        return u + o
    }
}
