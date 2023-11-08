//
//  GroupMemberCell.swift
//  Whoops
//
//  Created by Aaron on 10/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import SwipeCellKit
import UIKit

class GroupMemberCell: SwipeTableViewCell {
    let userIcon = UIImageView(image: #imageLiteral(resourceName: "noIcon"))
    let onlineDot = UIView()
    let userName = UILabel()
    let grayLabel = UILabel()
    let selectedIcon = UIImageView(image: #imageLiteral(resourceName: "unselect"))

    weak var user: WhoopsUser?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white.withAlphaComponent(0.001)

        detailTextLabel?.layer.cornerRadius = 2
        detailTextLabel?.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        detailTextLabel?.font = kBasicFont(size2x: 22, semibold: true)
        detailTextLabel?.textColor = UIColor.darkGray
        detailTextLabel?.textAlignment = .center

        onlineDot.backgroundColor = UIColor(rgb: kOnlineDotColor)
        onlineDot.layer.cornerRadius = 5.5
        onlineDot.layer.masksToBounds = true
        onlineDot.layer.borderWidth = 2
        onlineDot.layer.borderColor = UIColor(rgb: 0xF7F7F7).cgColor

        userIcon.layer.cornerRadius = 25
        userIcon.layer.masksToBounds = true

        grayLabel.font = UIFont(name: "PingFangSC-Regular", size: 11)!
        grayLabel.textColor = .darkGray

        userName.font = kBold28Font
        userName.lineBreakMode = .byTruncatingMiddle
        selectedIcon.contentMode = .scaleAspectFit

        addSubview(userIcon)
        addSubview(onlineDot)
        addSubview(userName)
        addSubview(grayLabel)
        addSubview(selectedIcon)
        selectedIcon.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(checkOnline), name: .onlineStatusUpdated, object: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userIcon.pin.left(contentView.pin.layoutMargins.left).vCenter().height(50).width(50)
        onlineDot.pin.width(11).height(11).bottomRight(to: userIcon.anchor.bottomRight)

        if grayLabel.isHidden {
            userName.pin.sizeToFit(.width).right(of: userIcon, aligned: .center).marginLeft(20).right(contentView.pin.layoutMargins.right + 50)

        } else {
            userName.pin.sizeToFit(.width).right(of: userIcon, aligned: .top).marginLeft(20).right(contentView.pin.layoutMargins.right + 50)
            grayLabel.pin.sizeToFit(.width).right(of: userIcon, aligned: .bottom).marginLeft(20).right(contentView.pin.layoutMargins.right + 50)
        }
        selectedIcon.pin.height(20).width(20).right(contentView.pin.layoutMargins.right).marginRight(5).vCenter()
        if detailTextLabel?.text?.count == 2 {
            detailTextLabel?.pin.width(34).height(20).center(to: selectedIcon.anchor.center)
        } else {
            detailTextLabel?.pin.width(45).height(20).center(to: selectedIcon.anchor.center)
        }

        detailTextLabel?.textAlignment = .center
    }

    func setContent(user: WhoopsUser, selection: Bool) {
        self.user = user
        selectedIcon.isHidden = !selection

        if user.userType == kUserTypeGroup {
            userIcon.image = #imageLiteral(resourceName: "GroupIcon").withInset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            userIcon.backgroundColor = UIColor(rgb: user.groupColor)
        } else {
            user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) {
                self.userIcon.image = $0
            }
        }

        if user.userType == kUserTypeSingle, let c = user.nickName {
            userName.text = c
            grayLabel.text = user.name
            grayLabel.isHidden = false
        } else {
            userName.text = user.name
            grayLabel.isHidden = true
        }

        checkOnline()
    }

    @objc func checkOnline() {
        guard let u = user, u.userType == kUserTypeSingle else {
            DispatchQueue.main.async {
                self.onlineDot.alpha = 0
            }
            return
        }
        DispatchQueue.main.async {
            UIView.animateSpring {
                self.onlineDot.alpha = onlineID.contains(u.friend_id) ? 1 : 0
            }
        }
    }

    override var isSelected: Bool {
        get { return super.isSelected }
        set {
            selectedIcon.image = newValue ? #imageLiteral(resourceName: "selected") : #imageLiteral(resourceName: "unselect")
        }
    }
}
