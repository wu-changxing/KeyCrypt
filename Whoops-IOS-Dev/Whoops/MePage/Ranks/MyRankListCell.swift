//
//  MyRankListCell.swift
//  Whoops
//
//  Created by Aaron on 2/11/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class MyRankListBigCell: UITableViewCell {
    let bgView = UIView()
    let line = UIView()
    let userIcon = UIImageView(image: #imageLiteral(resourceName: "noIcon"))
    let userName = UILabel()
    let label = UILabel()
    let numbers = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        bgView.layer.borderWidth = 0.5
        bgView.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1).cgColor
        bgView.layer.cornerRadius = 10
        bgView.layer.backgroundColor = UIColor.white.cgColor
        contentView.addSubview(bgView)
        line.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
        contentView.addSubview(line)
        userIcon.layer.cornerRadius = 20
        userIcon.layer.masksToBounds = true
        contentView.addSubview(userIcon)
        numbers.text = "--人"
        numbers.font = UIFont(name: "PingFangSC-Semibold", size: 20)
        contentView.addSubview(numbers)
        label.text = "拉新"
        label.font = UIFont(name: "PingFangSC-Regular", size: 11)
        label.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        contentView.addSubview(label)
        userName.font = kBasic34Font
        userName.text = "我"
        userName.numberOfLines = 1
        contentView.addSubview(userName)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.pin.all(20)
        line.pin.below(of: bgView, aligned: .left).marginLeft(10).width(0.5).bottom()
        userIcon.pin.centerLeft(to: bgView.anchor.centerLeft).marginLeft(20).height(40).width(40)
        numbers.pin.sizeToFit(.content).centerRight(to: bgView.anchor.centerRight).marginRight(20)
        label.pin.sizeToFit().left(of: numbers, aligned: .center).marginRight(10)
        userName.pin.sizeToFit().right(of: userIcon, aligned: .center).right(to: label.edge.left).marginHorizontal(10)
    }

    func setContent(user: WhoopsUser) {
        user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) { i in
            self.userIcon.image = i
        }
        numbers.text = "\(user.inviteCount)人"
        if user.inviteCount == 0 {
            line.isHidden = true
        }
    }
}

class MyRankListCell: UITableViewCell {
    let line1 = UIView()
    let line2 = UIView()
    let numberText = UILabel()
    let userIcon = UIImageView(image: #imageLiteral(resourceName: "noIcon"))
    let userName = UILabel()
    let numbers = UILabel()

    var isBottomOne = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        line1.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
        line2.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)
        contentView.addSubview(line1)
        contentView.addSubview(line2)

        userIcon.layer.cornerRadius = 15
        userIcon.layer.masksToBounds = true
        contentView.addSubview(userIcon)
        numbers.text = "------"
        numbers.font = UIFont(name: "PingFangSC-Regular", size: 11)
        contentView.addSubview(numbers)

        userName.font = kBasic28Font
        userName.text = "我"
        userName.numberOfLines = 1
        userName.lineBreakMode = .byTruncatingMiddle
        contentView.addSubview(userName)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isBottomOne {
            line1.pin.width(0.5).top().bottom(to: contentView.edge.vCenter).left(30)
        } else {
            line1.pin.width(0.5).top().bottom().left(30)
        }

        line2.pin.height(0.5).left(30).width(24).vCenter(to: contentView.edge.vCenter)

        userIcon.pin.centerLeft(to: contentView.anchor.centerLeft).marginLeft(40).height(30).width(30)
        numbers.pin.sizeToFit(.content).centerRight(to: contentView.anchor.centerRight).marginRight(20)
        userName.pin.sizeToFit().right(of: userIcon, aligned: .center).right(to: numbers.edge.left).marginHorizontal(10)
    }

    func setContent(user: WhoopsUser, isEnd: Bool) {
        user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) { i in
            self.userIcon.image = i
        }
        isBottomOne = isEnd
        numbers.text = "\(user.inviteTime)"
        userName.text = user.name
    }
}
