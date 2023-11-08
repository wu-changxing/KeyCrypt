//
//  SocketLayer.swift
//  keyboard
//
//  Created by Aaron on 8/25/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import CocoaAsyncSocket
import ConfluxSDK
import FCUUID
import Foundation
import SwiftyJSON

class SocketLayer: NSObject {
    static let shared = SocketLayer()

    private let kMagicStringData = "WHOOPS".data(using: .utf8, allowLossyConversion: true)!

    private let kSocketAddress = "www.whoops.world"
    private let kSocketPort = 8090

    private var heartBeatTimer: Timer?

    private var session: String?

    private(set) var sessionUser: WhoopsUser?

    private let processQueue = DispatchQueue(label: "DecryptQueue")

    private lazy var socket = GCDAsyncSocket(delegate: self, delegateQueue: .main)

    var connected: Bool {
        return socket.isConnected
    }

    override private init() {
        super.init()
        session = nil
        sessionUser = nil
    }

    private var callback: CallbackInfoOnlyType = nil
    var delegate: SocketMessageLayerDelegate?

    private func watchDog() {
        heartBeatTimer?.invalidate()
        heartBeatTimer = nil
        heartBeatTimer = Timer(timeInterval: 30, target: self, selector: #selector(heartBeat), userInfo: nil, repeats: true)
        RunLoop.current.add(heartBeatTimer!, forMode: .common)
    }

    @objc func heartBeat() { // 心跳包必须在登录后才发
        guard let sessionId = session, let u = sessionUser else {
            heartBeatTimer?.invalidate()
            heartBeatTimer = nil
            return
        }
        var h = MessageHeartBeat()
        h.userID = "\(u.the_id)"
        h.seq = 1
        h.json = "{\"from\":\"client\"}"
        var rq = Message()
        rq.type = .keepaliveRequest
        rq.heartBeat = h
        rq.sequence = 0
        rq.sessionID = sessionId

        sendMsg(data: try! rq.serializedData(partial: true), withTag: 1)
    }

    private func producePacket(payload: Data) -> Data {
        var packet = kMagicStringData
        var version = Int16(bigEndian: 34)
        packet.append(Data(bytes: &version, count: MemoryLayout<Int16>.size))
        var length = Int32(bigEndian: Int32(payload.count))
        packet.append(Data(bytes: &length, count: MemoryLayout<Int32>.size))
        packet.append(payload)
//        packet.append("\n".data(using: .ascii, allowLossyConversion: true)!)

        return packet
    }

    func connect2Server(_ p: Platform) -> Bool {
        if connected {
            socket.disconnect()
        }
        let s = DispatchSemaphore(value: 0)
        NetLayer.getIMServerInfo(for: p) { _, d, _ in
            if let d = d as? (String, Int) {
                try? self.socket.connect(toHost: d.0, onPort: UInt16(d.1))
                print("connecting")
                s.signal()
            }
        }

        let r = s.wait(timeout: DispatchTime.now() + 10)
        return r == .success
    }

    private func sendMsg(data: Data, withTag tag: Int = 0) {
        let p = producePacket(payload: data)
        socket.write(p, withTimeout: -1, tag: tag)
    }

    func goFuckYourSelf() {
        socket.disconnect()
    }
}

extension SocketLayer {
    func login(session: WhoopsUser, callback: CallbackInfoOnlyType) {
        self.callback = callback
        sessionUser = session

        var r = LoginRequest()
        r.deviceID = FCUUID.uuidForDevice()
        r.token = session.token!
        r.userID = "\(session.the_id)"
        r.platform = UInt32(1)
        r.appVersion = "0.1"

        var m = Message()
        m.type = .loginRequest
        m.loginRequest = r
        m.sequence = 0
        m.sessionID = "0"
        SocketLayer.shared.sendMsg(data: try! m.serializedData(partial: true), withTag: 99)
    }

    func sendMessage(msg: LXFChatMsgModel, isGroup: Bool = false, callback: CallbackInfoOnlyType) {
        guard let the_id = sessionUser?.the_id,
              let sessionId = session
        else {
            callback?(false, kErrCurrentUserNotLogin)
            return
        }
        callback?(true, "")

        var r = MessageRequest()
        r.type = isGroup ? 1 : 0 // 0 是单聊 1 群聊
        switch msg.modelType {
        case .transfer: r.msgType = 5
        case .redpack: r.msgType = 4
        default: r.msgType = 0
        }
        // 消息类型：0-文字、1-视频、2-音频、3-文件、4-红包、 5-转账
        r.fromID = "\(the_id)"
        r.groupID = msg.toUserId!
        r.toID = msg.toUserId!
        r.time = msg.timestamp!
        r.message = msg.encryptedText!
        r.selfSecretKey = msg.selfSecretKey!
        r.secretKey = msg.secretKey!
//        r.groupID = ""

        var rq = Message()
        rq.messageRequest = r
        rq.type = .messageRequest
        rq.sequence = 0
        rq.sessionID = sessionId

        sendMsg(data: try! rq.serializedData(partial: true), withTag: msg.tag)
    }
}

extension SocketLayer: GCDAsyncSocketDelegate {
    func socket(_: GCDAsyncSocket, didConnectToHost _: String, port _: UInt16) {
        print("connected!")
        callback?(true, nil)
        callback = nil
    }

    func socket(_: GCDAsyncSocket, didAcceptNewSocket _: GCDAsyncSocket) {
        // 开始接受数据
        print("开始接受数据")
        socket.readData(withTimeout: -1, tag: 0)
    }

    func socket(_: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("\(tag), sent!")
        delegate?.msgSentStatus(for: tag, status: true, msg: "")
        socket.readData(withTimeout: -1, tag: tag)
    }

    func socket(_: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed _: TimeInterval, bytesDone _: UInt) -> TimeInterval {
        delegate?.msgSentStatus(for: tag, status: false, msg: "timeout")
        return 0
    }

    func socket(_: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let magic = data[0 ..< 6]
//        let version = data[6..<8]
        let length = data[8 ..< 12]
        let package = data[12 ..< data.endIndex]

        guard magic == kMagicStringData,
              let l = Int32(data: length),
              package.count == Int32(bigEndian: l)
        else {
            socket.readData(withTimeout: -1, tag: 0)
            return
        }

        let respond = try! Message(serializedData: package)

        if respond.type == .loginResponse {
            session = respond.sessionID
            heartBeat()
            DispatchQueue.main.async {
                self.watchDog()
            }
            callback?(respond.response.result, respond.response.result ? "" : respond.response.info)
            callback = nil
        }

        if respond.type == .messageResponse {
            DispatchQueue.main.async {
                if respond.response.result {
                    self.delegate?.msgSentStatus(for: tag, status: true, msg: "")
                } else {
                    self.delegate?.msgSentStatus(for: tag, status: false, msg: respond.response.info)
                }
            }
        }

        if respond.type == .messageRequest {
            processQueue.async {
                let rq = respond.messageRequest
                let msg = LXFChatMsgModel()
                msg.deliveryState = .delivered
                msg.encryptedText = rq.message
                msg.secretKey = rq.secretKey
                msg.userType = .friend
                msg.timestamp = rq.time
                msg.toUserId = "\(self.sessionUser?.the_id ?? 0)"
                msg.fromUserNickName = rq.fromNick.isEmpty ? nil : rq.fromNick
                msg.tag = Int.random(in: 100_000_000_000 ..< 1_000_000_000_000)
                msg.fromUserId = rq.fromID
                if rq.type == 0 { // 这里是私聊
                    msg.text = self.sessionUser?.decryptString(encryptedContent: rq.message, encryptedPwd: rq.secretKey)

                    switch rq.msgType {
                    case 5:
                        msg.modelType = .transfer
                        let j = try! JSON(data: msg.text!.data(using: .utf8, allowLossyConversion: false)!)
                        msg.value = j["value"].double
                        msg.tokenType = j["tokenType"].string
                        msg.senderAddress = j["from"].string
                        msg.transactionHash = j["transactionId"].string

                    default: msg.modelType = .text
                    }
                } else { // 这里是群
                    msg.sessionId = rq.groupID
                    guard ![6, 7].contains(rq.msgType) else {
                        return
                    }
                    if rq.msgType == 4 { // 是红包相关消息
                        msg.text = rq.message
                    }
                    switch rq.msgType {
                    case 4:
                        msg.modelType = .redpack
                        let j = try! JSON(data: msg.text!.data(using: .utf8, allowLossyConversion: false)!)
                        let v = j["value"].string ?? "-1"
                        let de = j["tokenDecimals"].int ?? 1
                        msg.value = Drip(v)?.gDripIn(decimals: de) ?? -1
                        msg.tokenType = j["tokenType"].string
                        msg.count = j["count"].int ?? 1
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
                            msg.redPacketId = j["redPacketId"].int
                            msg.rootHash = j["rootHash"].string
                            msg.transactionHash = j["transactionId"].string
                        }

                    default: msg.modelType = .text
                    }
                    // 群消息要到显示的时候再用对应的群解密
                }

                DispatchQueue.main.async {
                    self.delegate?.newMsgArrived(msg: msg)
                }
            }
        }
        socket.readData(withTimeout: -1, tag: 0)
    }

    func socketDidDisconnect(_: GCDAsyncSocket, withError err: Error?) {
        session = nil
        if err != nil, sessionUser != nil {
            print(err.debugDescription)
            _ = connect2Server(sessionUser!.platform)
            login(session: sessionUser!, callback: nil) // 重新登录
        }
    }
}
