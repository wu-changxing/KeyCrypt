//
//  LXFChatTransferCell.swift
//  keyboard
//
//  Created by Aaron on 11/10/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Kingfisher
import UIKit

class LXFChatTransferCell: LXFChatBaseCell {
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

    let transferIcon = UIImageView(image: #imageLiteral(resourceName: "Group 707"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleView.addSubview(transferIcon)
        bubbleView.addSubview(contentLabel)
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

        let contentSize = contentLabel.sizeThatFits(CGSize(width: 220.0 - 60, height: .greatestFiniteMagnitude))
        let bh: CGFloat = contentSize.height + 19 > 38 ? contentSize.height + 19 : 38

        bubbleView.frameLayout { $0
            .top.equal(to: 2)
            .height.equal(to: bh).offset(8)
            .width.equal(to: contentSize.width).offset(85)
            if model?.userType == .me {
                $0.right.equal(to: avatar.left).offset(-7)
            } else {
                $0.left.equal(to: avatar.right).offset(7)
            }
        }
        if model?.userType == .me {
            contentLabel.pin.height(contentSize.height).width(contentSize.width).centerRight(to: bubbleView.anchor.centerRight).marginRight(16)
            tipView.pin.width(30).height(30).left(of: bubbleView, aligned: .top)
        } else {
            contentLabel.pin.height(contentSize.height).width(contentSize.width).centerLeft(to: bubbleView.anchor.centerLeft).marginLeft(16)
            tipView.pin.width(30).height(30).right(of: bubbleView, aligned: .top)
        }

        transferIcon.frameLayout { $0
            .height.equal(to: 40)
            .width.equal(to: 40)
            .top.equal(to: contentLabel.top)
            if model?.userType == .me {
                $0.right.equal(to: contentLabel.left).offset(-10)
            } else {
                $0.left.equal(to: contentLabel.right).offset(10)
            }
        }

        super.layoutSubviews()
    }
}

// MARK: - 模型数据

private extension LXFChatTransferCell {
    func setModel() {
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
            avatar.setImage(#imageLiteral(resourceName: "noIcon"), for: .normal)
        }
        contentLabel.text = model?.text4transferAndRedpack
        contentLabel.font = kBasic28Font
        contentLabel.textColor = .black
        // 设置泡泡
        let img = model?.userType == .me ? #imageLiteral(resourceName: "transfer_sender_background_normal") : #imageLiteral(resourceName: "transfer_receiver_background_normal")
        let normalImg = img.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 35, bottom: 85, right: 35), resizingMode: .stretch)
        bubbleView.image = normalImg
        model?.cellHeight = getCellHeight()
    }
}
