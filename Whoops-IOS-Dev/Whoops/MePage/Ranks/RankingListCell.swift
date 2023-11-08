//
//  RankingListCell.swift
//  Whoops
//
//  Created by Aaron on 2/11/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

let colors = [
    UIColor(red: 1, green: 0.498, blue: 0.45, alpha: 1),
    UIColor(red: 1, green: 0.812, blue: 0.451, alpha: 1),
    UIColor(red: 1, green: 0.647, blue: 0.451, alpha: 1),
    UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1),
]

class RankingListCell: UITableViewCell {
    let numberViewBg = UIView()
    let numberText = UILabel()
    let userIcon = UIImageView(image: #imageLiteral(resourceName: "noIcon"))
    let userName = UILabel()
    let numbers = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        numberViewBg.layer.cornerRadius = 5
        numberViewBg.layer.masksToBounds = true
        contentView.addSubview(numberViewBg)
        numberText.textColor = .white
        numberText.text = "10"
        numberText.textAlignment = .center
        numberText.font = kBold28Font
        contentView.addSubview(numberText)
        userIcon.layer.cornerRadius = 20
        userIcon.layer.masksToBounds = true
        contentView.addSubview(userIcon)
        userName.font = kBasic34Font
        userName.numberOfLines = 1
        userName.lineBreakMode = .byTruncatingMiddle
        contentView.addSubview(userName)
        numbers.font = kBasic34Font
        contentView.addSubview(numbers)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        numberViewBg.pin.centerLeft(to: contentView.anchor.centerLeft).marginLeft(-5).height(20).width(45)
        numberText.pin.sizeToFit().center(to: numberViewBg.anchor.center).marginLeft(5)

        userIcon.pin.height(40).width(40).right(of: numberViewBg, aligned: .center).marginLeft(10)
        numbers.pin.sizeToFit(.content).centerRight(to: contentView.anchor.centerRight).marginRight(20)
        userName.pin.height(of: numbers).left(to: userIcon.edge.right).marginLeft(10).right(to: numbers.edge.left).marginRight(20).vCenter(to: contentView.edge.vCenter)
    }

    func setContent(user: WhoopsUser, index: Int) {
        let color = index >= 3 ? colors[3] : colors[index]
        numberViewBg.backgroundColor = color
        userName.text = user.nickName ?? user.name
        numberText.text = index == 0 ? "99+" : "\(index)"
        numbers.text = "\(user.inviteCount)人"
        userIcon.image = #imageLiteral(resourceName: "noIcon")
        user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) { i in
            self.userIcon.image = i
        }
        if user.isMySelf {
            contentView.backgroundColor = UIColor(red: 0.85, green: 0.975, blue: 1, alpha: 1)
        } else {
            contentView.backgroundColor = nil
        }
    }
}
