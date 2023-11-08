//
//  LXFChatMsgModel.swift
//  LXFWeChat
//
//  Created by 林洵锋 on 2017/1/4.
//  Copyright © 2017年 林洵锋. All rights reserved.
//
//  GitHub: https://github.com/LinXunFeng
//  简书: http://www.jianshu.com/users/31e85e7a22a2

import UIKit

enum RedPacketType: String {
    case rob, release, redpacket
}

enum LXFChatMsgUserType: Int {
    case me
    case friend
}

enum LXFChatMsgModelType: Int {
    case text
    case image
    case time
    case audio
    case video
    case transfer
    case redpack
}

enum LXFDeliveryState: Int {
    case delivering, delivered, failed
}

class LXFChatMsgModel {
    var cellHeight: CGFloat = UITableView.automaticDimension
    // 会话类型
    var modelType: LXFChatMsgModelType = .text
    // 会话来源
    var userType: LXFChatMsgUserType = .me

//    var message: NIMMessage? {
//        didSet {
//            guard let message = message else {
//                return
//            }
//            self.fromUserId = message.from
//            self.sessionId = message.session?.sessionId
//            self.messageId = message.messageId
//            self.text = message.text
//            self.time = message.timestamp
//            switch message.messageType {
//            case .text:
//                modelType = .text
//            case .image:
//                modelType = .image
//                let imgObj = message.messageObject as! NIMImageObject
//                thumbPath = imgObj.thumbPath
//                thumbUrl = imgObj.thumbUrl
//                imgPath = imgObj.path
//                imgUrl = imgObj.url
//                imgSize = imgObj.size
//                fileLength = imgObj.fileLength
//
//            default:
//                modelType = .text
//                self.text = "直播请求消息"
//                break
//            }
//
//            userType = message.from ?? "" == "" ? .me : .friend
//        }
//    }
    /// 消息的标签，用于追踪状态，数值大一点避免和别的冲突
    var tag: Int = 0
    var deliveryState: LXFDeliveryState?
    var senderHeadUrl: String?
    // 信息目标id
    var toUserId: String?
    // 信息来源id
    var fromUserId: String?
    // 信息来源昵称
    var fromUserNickName: String?
    // 会话id 如果是群组这里写群组id
    var sessionId: String?
    // 信息id
    var messageId: String?
    // 附件
    var messageObject: Any?
    // 信息时间辍
    var timestamp: UInt64?
    var time: TimeInterval?
    var timeStr: String?

    var secretKey: String?
    var selfSecretKey: String?
    /* ============================== 文字 ============================== */
    // 文字
    var encryptedText: String?
    var text: String?
    /* ============================== 红包和转账 ============================== */

    var count: Int = 1
    var tokenType: String?
    var value: Double?
    var senderAddress: String?
    var transactionHash: String?
    var redPacketId: Int?
    var text4transferAndRedpack: String?
    var rootHash: String?

    var sender: String?
    var robed: Double = 0

    var rest: Double = 0
    var robCount: Int = 0
    var redpacketType: RedPacketType = .redpacket

    /* ============================== 图片 ============================== */
    // 本地原图地址
    var imgPath: String?
    // 云信原图地址
    var imgUrl: String?
    // 本地缩略图地址
    var thumbPath: String?
    // 云信缩略图地址
    var thumbUrl: String?
    // 图片size
    var imgSize: CGSize?
    // 文件大小
    var fileLength: Int64?
    /* ============================== 语音 ============================== */
    // 语音的本地路径
    var audioPath: String?
    // 语音的远程路径
    var audioUrl: String?
    // 语音时长，毫秒为单位
    var audioDuration: CGFloat = 0
    /* ============================== 视频 ============================== */
    // 视频展示名
    var videoDisplayName: String?
    // 视频的本地路径
    var videoPath: String?
    // 视频的远程路径
    var videoUrl: String?
    // 视频封面的远程路径
    var videoCoverUrl: String?
    // 视频封面的本地路径
    var videoCoverPath: String?
    // 封面尺寸
    var videoCoverSize: CGSize?
    // 视频时长，毫秒为单位
    var videoDuration: Int?

//    override init() {
//        super.init()
//    }
}

/*
 message.deliveryState
 /**
 *  消息发送失败
 */
 NIMMessageDeliveryStateFailed,
 /**
 *  消息发送中
 */
 NIMMessageDeliveryStateDelivering,
 /**
 *  消息发送成功
 */
 NIMMessageDeliveryStateDeliveried
 */

/* ============================================================ */

/*
 message.messageType
 /**
 *  文本类型消息
 */
 NIMMessageTypeText          = 0,
 /**
 *  图片类型消息
 */
 NIMMessageTypeImage         = 1,
 /**
 *  声音类型消息
 */
 NIMMessageTypeAudio         = 2,
 /**
 *  视频类型消息
 */
 NIMMessageTypeVideo         = 3,
 /**
 *  位置类型消息
 */
 NIMMessageTypeLocation      = 4,
 /**
 *  通知类型消息
 */
 NIMMessageTypeNotification  = 5,
 /**
 *  文件类型消息
 */
 NIMMessageTypeFile          = 6,
 /**
 *  提醒类型消息
 */
 NIMMessageTypeTip           = 10,
 /**
 *  自定义类型消息
 */
 NIMMessageTypeCustom        = 100
 */
extension LXFChatMsgModel: Hashable {
    static func == (lhs: LXFChatMsgModel, rhs: LXFChatMsgModel) -> Bool {
        lhs.timestamp == rhs.timestamp
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
    }
}
