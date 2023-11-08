//
//  LXFChatRedPacketMsgCell.swift
//  keyboard
//
//  Created by Aaron on 3/17/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class LXFChatRedPacketMsgCell: LXFChatBaseCell {
    // MARK: - 模型

    override var model: LXFChatMsgModel? { didSet { setModel() } }

    // MARK: - 懒加载

    lazy var contentLabel: UILabel = {
        let contentL = UILabel()
        contentL.numberOfLines = 0
        contentL.textAlignment = .center
        contentL.font = kBasic28Font
        contentL.textColor = darkMode ? .lightGray : UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        contentL.adjustsFontSizeToFitWidth = true
        contentL.minimumScaleFactor = 0.5
        return contentL
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        bubbleView.layer.backgroundColor = darkMode ? UIColor.darkGray.cgColor : UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        bubbleView.layer.cornerRadius = 4
        bubbleView.addSubview(contentLabel)
        bubbleView.isUserInteractionEnabled = true
        let g = UITapGestureRecognizer(target: self, action: #selector(msgDidTap))
        bubbleView.addGestureRecognizer(g)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        // 重新布局

        let contentSize = contentLabel.sizeThatFits(CGSize(width: contentView.frame.width - 30, height: .greatestFiniteMagnitude))
        let bh: CGFloat = 16
        avatar.frame = .zero
        nickNameLabel.frame = .zero
        bubbleView.pin.center(to: contentView.anchor.center).marginBottom(4).height(bh + 8).width(contentSize.width + 20)
        contentLabel.pin.height(contentSize.height).width(contentSize.width).center(to: bubbleView.anchor.center)

        super.layoutSubviews()
    }
}

// MARK: - 模型数据

private extension LXFChatRedPacketMsgCell {
    @objc func msgDidTap() {
        guard let id = model?.redPacketId else { return }
        (KeyboardViewController.inputProxy as! KeyboardViewController).openRedpacketHistory(redpacketId: id)
    }

    func setModel() {
        contentLabel.text = model?.text4transferAndRedpack

        if model?.userType == .me, model?.redpacketType == .rob {
            contentLabel.textColor = UIColor(red: 0.95, green: 0.329, blue: 0.329, alpha: 1)
            bubbleView.layer.backgroundColor = UIColor(red: 1, green: 0.918, blue: 0.898, alpha: 1).cgColor
        }

        model?.cellHeight = getCellHeight()
    }
}
