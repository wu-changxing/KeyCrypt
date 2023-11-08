//
//  LXFChatBaseCell.swift
//  LXFWeChat
//
//  Created by 林洵锋 on 2017/1/3.
//  Copyright © 2017年 林洵锋. All rights reserved.
//
//  GitHub: https://github.com/LinXunFeng
//  简书: http://www.jianshu.com/users/31e85e7a22a2

import UIKit

class LXFChatBaseCell: UITableViewCell {
    // MARK: - 模型

    var model: LXFChatMsgModel? {
        didSet {
            baseCellSetModel()
        }
    }

    lazy var nickNameLabel: UILabel = {
        let n = UILabel()
        n.font = UIFont(name: "PingFangSC-Regular", size: 11)
        n.textColor = darkMode ? .lightGray : .darkGray
        n.lineBreakMode = .byTruncatingMiddle
        return n
    }()

    lazy var avatar: UIButton = {
        let avaBtn = UIButton()
        avaBtn.layer.cornerRadius = 19
        avaBtn.layer.masksToBounds = true
        avaBtn.imageView?.contentMode = .scaleAspectFit
        return avaBtn
    }()

    lazy var bubbleView: UIImageView = {
        UIImageView()
    }()

    lazy var tipView: UIView = { [unowned self] in
        let tipV = UIView()
        tipV.addSubview(self.activityIndicator)
        tipV.addSubview(self.resendButton)
        return tipV
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView()
        act.style = darkMode ? .white : .gray
        act.hidesWhenStopped = false
        act.startAnimating()
        return act
    }()

    lazy var resendButton: UIButton = {
        let resendBtn = UIButton(type: .custom)
        resendBtn.setImage(#imageLiteral(resourceName: "resend"), for: .normal)
        resendBtn.contentMode = .scaleAspectFit
        resendBtn.addTarget(self, action: #selector(resend), for: .touchUpInside)
        return resendBtn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundView = UIView()
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(avatar)
        contentView.addSubview(bubbleView)
        contentView.addSubview(tipView)
        contentView.addSubview(nickNameLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.frame = tipView.bounds
        resendButton.frame = tipView.bounds
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LXFChatBaseCell {
    func baseCellSetModel() {
        avatar.setImage(nil, for: .normal)
        tipView.isHidden = false
        activityIndicator.startAnimating()
        if let n = model?.fromUserNickName {
            nickNameLabel.text = n
        } else {
            nickNameLabel.text = ""
        }
        guard let deliveryState = model?.deliveryState else {
            return
        }
        if model?.userType == .me { // 自己
            switch deliveryState {
            case .delivering:
                resendButton.isHidden = true
                activityIndicator.isHidden = false
            case .failed:
                resendButton.isHidden = false
                activityIndicator.isHidden = true
            case .delivered:
                tipView.isHidden = true
            }
        } else { // 对方
            tipView.isHidden = true
        }
    }
}

extension LXFChatBaseCell {
    // MARK: - 获取cell的高度

    func getCellHeight() -> CGFloat {
        layoutSubviews()
        let n = bubbleView.frame.height + nickNameLabel.frame.height + 5
        if avatar.frame.height > n {
            return avatar.frame.height + 10.0
        } else {
            return n + 10.0
        }
    }

    @objc func resend() {
        print("重新发送操作")
        if let t = model?.text {
            ChatEngine.shared.sendMsg(content: t)
        }
    }
}
