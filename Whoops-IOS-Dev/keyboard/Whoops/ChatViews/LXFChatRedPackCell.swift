//
//  LXFChatRedPackCell.swift
//  keyboard
//
//  Created by Aaron on 11/10/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Kingfisher
import PinLayout
import UIKit

class LXFChatRedPackCell: LXFChatBaseCell {
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

    let circleView = UIView()
    let redpackImage = UIImageView(image: #imageLiteral(resourceName: "redpack"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        circleView.layer.cornerRadius = 20
        circleView.layer.backgroundColor = UIColor(red: 1, green: 0.899, blue: 0.879, alpha: 1).cgColor
        bubbleView.addSubview(circleView)
        bubbleView.addSubview(redpackImage)

        bubbleView.addSubview(contentLabel)
        bubbleView.isUserInteractionEnabled = true
        let g = UITapGestureRecognizer(target: self, action: #selector(robRedpacket))
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

        let contentSize = contentLabel.sizeThatFits(CGSize(width: 220.0 - 60, height: .greatestFiniteMagnitude))
        let bh: CGFloat = contentSize.height + 19 > 38 ? contentSize.height + 19 : 38

        if model?.userType == .me {
            nickNameLabel.textAlignment = .right
            nickNameLabel.pin.height(11).left(of: avatar, aligned: .top).marginRight(15).width(220)
            bubbleView.pin.left(of: avatar).marginRight(7).top(to: nickNameLabel.edge.bottom).marginTop(2).height(bh + 8).width(contentSize.width + 85)

        } else {
            nickNameLabel.textAlignment = .left
            nickNameLabel.pin.height(11).right(of: avatar, aligned: .top).marginLeft(15).width(220)
            bubbleView.pin.right(of: avatar).marginLeft(7).top(to: nickNameLabel.edge.bottom).marginTop(2).height(bh + 8).width(contentSize.width + 85)
        }
        if model?.userType == .me {
            contentLabel.pin.height(contentSize.height).width(contentSize.width).centerRight(to: bubbleView.anchor.centerRight).marginRight(16)
            tipView.pin.width(30).height(30).left(of: bubbleView, aligned: .top)
        } else {
            contentLabel.pin.height(contentSize.height).width(contentSize.width).centerLeft(to: bubbleView.anchor.centerLeft).marginLeft(16)
            tipView.pin.width(30).height(30).right(of: bubbleView, aligned: .top)
        }

        circleView.frameLayout { $0
            .height.equal(to: 40)
            .width.equal(to: 40)
            .top.equal(to: contentLabel.top)
            if model?.userType == .me {
                $0.right.equal(to: contentLabel.left).offset(-10)
            } else {
                $0.left.equal(to: contentLabel.right).offset(10)
            }
        }

        redpackImage.center = circleView.center

        super.layoutSubviews()
    }
}

// MARK: - 模型数据

private extension LXFChatRedPackCell {
    func confirmPwd(pwd: String) {
        guard let w = WalletUtil.getWalletObj(pwd: pwd),
              let keyboard = KeyboardViewController.inputProxy as? KeyboardViewController
        else {
            KeyboardViewController.inputProxy?.toast(str: "钱包密码错误！")
            return
        }

        keyboard.view.loadingWith(string: "获取证明...")
        NetLayer.getRedpacketProof(for: ChatEngine.shared.targetUser!, rootHash: model?.rootHash ?? "") { _, d, m in

            guard let d = d as? ([String], Int),
                  let id = self.model?.redPacketId
            else {
                DispatchQueue.main.async {
                    keyboard.view.hideLoadingWith(string: "获取失败")
                }
                keyboard.toast(str: "获取证明出错：\(m ?? "请重试")。")
                return
            }
            DispatchQueue.main.async {
                keyboard.view.loadingWith(string: "抢红包中...")
            }

            let hl: [Data] = d.0.map { Data(hexString: $0)! }

            WalletUtil.robRedpacket(id: id, location: d.1, proof: hl, wallet: w) { value in
                DispatchQueue.main.async {
                    if value <= 0 {
                        keyboard.view.hideLoadingWith(string: "")
                        keyboard.showRedPackConfirmation(value: value, tokenType: "")

                    } else {
                        keyboard.view.hideLoadingWith(string: "完成！")
                        let d = WhoopsAlertView(title: "正在抢红包", detail: "抢红包交易已经发出，交易完成后结果会自动显示在群中。", confirmText: "好", confirmOnly: true)
                        d.overlay(to: keyboard.view)
                    }
                }
            }
        }
    }

    @objc func robRedpacket() {
        guard WalletUtil.getAddress() != nil else {
            KeyboardViewController.inputProxy?.showRedPackConfirmation(value: -4, tokenType: model?.tokenType ?? "CFX")
            return
        }
        let input = TempInputBar(hint: "请输入钱包密码解锁钱包。", isPasswordField: true)
        input.isPasswordField = true
        input.successCallback = confirmPwd
        (KeyboardViewController.inputProxy as! KeyboardViewController).showKeyboard(tmpInput: input)
    }

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
        contentLabel.textColor = .darkText
        // 设置泡泡
        let img = model?.userType == .me ? #imageLiteral(resourceName: "redpack_sender_background_normal") : #imageLiteral(resourceName: "redpack_receiver_background_normal")
        let normalImg = img.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 35, bottom: 85, right: 35), resizingMode: .stretch)
        bubbleView.image = normalImg
        model?.cellHeight = getCellHeight()
    }
}
