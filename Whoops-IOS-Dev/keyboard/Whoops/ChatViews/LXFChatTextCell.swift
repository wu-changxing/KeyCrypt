//
//  LXFChatTextCell.swift
//  LXFWeChat
//
//  Created by 林洵锋 on 2017/1/3.
//  Copyright © 2017年 林洵锋. All rights reserved.
//
//  GitHub: https://github.com/LinXunFeng
//  简书: http://www.jianshu.com/users/31e85e7a22a2

import Kingfisher
import PinLayout
import UIKit

class LXFChatTextCell: LXFChatBaseCell {
    // MARK: - 模型

    override var model: LXFChatMsgModel? { didSet { setModel() } }

    // MARK: - 懒加载

    lazy var contentLabel: UILabel = {
        let contentL = UILabel()
        contentL.numberOfLines = 0
        contentL.textAlignment = .left
        contentL.font = UIFont.systemFont(ofSize: 16.0)
        return contentL
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        bubbleView.addSubview(contentLabel)
        bubbleView.isUserInteractionEnabled = true
        let g = UILongPressGestureRecognizer(target: self, action: #selector(copyText))
        bubbleView.addGestureRecognizer(g)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        // 重新布局
        avatar.frameLayout { $0
            .width.equal(to: 38)
            .height.equal(to: 38)
            .top.equal(to: 6)
            if model?.userType == .me {
                $0.right.equal(to: contentView.width).offset(-12)
            } else {
                $0.left.equal(to: 12)
            }
        }

        let contentSize = contentLabel.sizeThatFits(CGSize(width: 220.0, height: .greatestFiniteMagnitude))
        let bh: CGFloat = contentSize.height + 19 > 38 ? contentSize.height + 19 : 38

        if model?.sessionId == nil {
            if model?.userType == .me {
                bubbleView.pin.left(of: avatar).marginRight(7).top(2).height(bh + 8).width(contentSize.width + 40)

            } else {
                bubbleView.pin.right(of: avatar).marginLeft(7).top(2).height(bh + 8).width(contentSize.width + 40)
            }
        } else {
            if model?.userType == .me {
                nickNameLabel.textAlignment = .right
                nickNameLabel.pin.height(11).left(of: avatar, aligned: .top).marginRight(15).width(220)
                bubbleView.pin.left(of: avatar).marginRight(7).top(to: nickNameLabel.edge.bottom).marginTop(2).height(bh + 8).width(contentSize.width + 40)

            } else {
                nickNameLabel.textAlignment = .left
                nickNameLabel.pin.height(11).right(of: avatar, aligned: .top).marginLeft(15).width(220)
                bubbleView.pin.right(of: avatar).marginLeft(7).top(to: nickNameLabel.edge.bottom).marginTop(2).height(bh + 8).width(contentSize.width + 40)
            }
        }

        if model?.userType == .me {
            contentLabel.pin.height(contentSize.height).width(contentSize.width).centerRight(to: bubbleView.anchor.centerRight).marginRight(16)
            tipView.pin.width(30).height(30).left(of: bubbleView, aligned: .top)
        } else {
            contentLabel.pin.height(contentSize.height).width(contentSize.width).centerLeft(to: bubbleView.anchor.centerLeft).marginLeft(16)
            tipView.pin.width(30).height(30).right(of: bubbleView, aligned: .top)
        }

        super.layoutSubviews()
    }
}

// MARK: - 模型数据

extension LXFChatTextCell {
    @objc func copyText(_ sender: UIGestureRecognizer) {
        guard sender.state == .began, let t = model?.text else { return }
        PasteBoard.string = t
        let a = UIImpactFeedbackGenerator(style: .light)
        a.impactOccurred()
        KeyboardViewController.inputProxy?.toast(str: "内容已复制到剪切板。")
    }

    private func setModel() {
        if let u = model?.senderHeadUrl, let url = URL(string: u) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                let r = try? result.get()

                DispatchQueue.main.async {
                    guard self.model?.senderHeadUrl == r?.originalSource.url?.absoluteString else { return } // 在设置头像前多检查一次模型是否匹配，避免加载完头像发现cell已经被重用到别的地方了
                    self.avatar.setImage(r?.image, for: .normal)
                    self.layoutSubviews()
                }
            }
        } else {
            avatar.setImage(UIImage(named: "noIcon"), for: .normal)
        }
        contentLabel.text = model?.text
        contentLabel.font = kBasic28Font
        contentLabel.textColor = model?.userType == .me ? .white : .darkText
        // 设置泡泡
        let img = model?.userType == .me ? #imageLiteral(resourceName: "message_sender_background_normal") : #imageLiteral(resourceName: "message_receiver_background_normal")
        let normalImg = img.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 35, bottom: 85, right: 35), resizingMode: .stretch)
        bubbleView.image = normalImg
        bubbleView.tintColor = model?.userType == .me ? kColor5c5c5c : UIColor(rgb: 0xE0E0E0)
        model?.cellHeight = getCellHeight()
    }
}
