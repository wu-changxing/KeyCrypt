//
//  AccountIconView.swift
//  Whoops
//
//  Created by Aaron on 7/18/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class AccountIconView: UITableViewCell {
    let userIcon = UIImageView()
    let appIcon = UIImageView()
    let userName = UILabel()
    let platformName = UILabel()
    let bg = UIView()
    var type: Platform = .weChat
    var action: ((Platform, UIButton) -> Void)?
    let bindSupported: [Platform] = [.weChat, .weibo, .qq]

    lazy var bindButton: UIButton = {
        let t = UIButton(type: .system)
        t.setTitle("绑定", for: .normal)
        t.titleLabel?.font = kBold28Font
        t.setTitleColor(.white, for: .normal)
        t.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        t.layer.cornerRadius = 6
        t.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        return t
    }()

    lazy var menuButton: UIButton = {
        let t = UIButton()
        t.setImage(#imageLiteral(resourceName: "moreButton"), for: .normal)
        t.titleLabel?.font = kBold28Font
        t.imageView?.tintColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        t.tintColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        t.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        return t
    }()

    lazy var noBindingLabel: UILabel = {
        let l = UILabel()
        l.text = "不支持\n绑定"
        l.textAlignment = .center
        l.numberOfLines = 2
        l.font = kBold28Font
        l.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        return l
    }()

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        bg.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        bg.layer.shadowOpacity = 0.5
        bg.layer.shadowRadius = 6
        bg.layer.shadowOffset = CGSize(width: 0.5, height: 1)
        bg.layer.backgroundColor = UIColor.white.cgColor
        bg.layer.cornerRadius = 20
        if #available(iOS 13.0, *) {
            bg.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }

        userIcon.layer.cornerRadius = 25
        userIcon.layer.masksToBounds = true
        userIcon.contentMode = .scaleAspectFit

        appIcon.layer.cornerRadius = 12.5
        appIcon.layer.masksToBounds = true
        appIcon.contentMode = .scaleAspectFit

        userName.font = kBold34Font
        userName.lineBreakMode = .byTruncatingMiddle

        platformName.font = kBasicFont(size2x: 22)
        platformName.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)

        contentView.addSubview(bg)
        contentView.addSubview(userIcon)
        contentView.addSubview(appIcon)
        contentView.addSubview(userName)
        contentView.addSubview(platformName)
        contentView.addSubview(bindButton)
        contentView.addSubview(menuButton)
        contentView.addSubview(noBindingLabel)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setContent(user: WhoopsUser) {
        type = user.platform
        appIcon.image = UIImage(named: user.platform.rawValue)
        platformName.text = user.platform.rawValue
        userName.text = user.name

        if let url = user.iconImageUrl, !url.isEmpty {
            userIcon.loadImage(from: url) {}
            bindButton.isHidden = true
            noBindingLabel.isHidden = true
            menuButton.isHidden = false
        } else {
            userIcon.image = UIImage(named: "noIcon")
            menuButton.isHidden = true
            if bindSupported.contains(user.platform) {
                noBindingLabel.isHidden = true
                bindButton.isHidden = false
            } else {
                noBindingLabel.isHidden = false
                bindButton.isHidden = true
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bg.pin.all().marginVertical(5)
        let shadowPath0 = UIBezierPath(roundedRect: bg.bounds, cornerRadius: 20)
        bg.layer.shadowPath = shadowPath0.cgPath

        userIcon.pin.width(50).height(50).centerLeft(to: bg.anchor.centerLeft).marginLeft(10)
        appIcon.pin.width(25).height(25).bottomRight(to: userIcon.anchor.bottomRight)
        bindButton.pin.width(104 / 2).height(30).centerRight(to: bg.anchor.centerRight).marginRight(20)
        menuButton.pin.sizeToFit().centerRight(to: bindButton.anchor.centerRight)
        noBindingLabel.pin.sizeToFit().center(to: bindButton.anchor.center).height(of: bg)
        userName.pin.sizeToFit(.width).right(of: userIcon).marginLeft(20).bottom(to: userIcon.edge.vCenter).right(to: bindButton.edge.left).marginRight(24)
        platformName.pin.sizeToFit().below(of: userName, aligned: .left).marginTop(4)
    }

    @objc func buttonDidTap(_ sender: UIButton) {
        action?(type, sender)
    }
}
