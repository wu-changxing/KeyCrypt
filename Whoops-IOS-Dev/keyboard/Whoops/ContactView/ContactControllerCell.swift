//
//  ContactControllerCell.swift
//  keyboard
//
//  Created by Aaron on 10/7/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class ContactControllerCell: UITableViewCell {
    var userIcon = UIImageView(image: #imageLiteral(resourceName: "noIcon"))
    var onlineDot = UIView()
    var userName = UILabel()
    var grayLabel = UILabel()
    var unReadCount = UILabel()

    var chattingLabel = UILabel()

    weak var user: WhoopsUser?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white.withAlphaComponent(0.001)

        onlineDot.backgroundColor = UIColor(rgb: kOnlineDotColor)
        onlineDot.layer.cornerRadius = 5.5
        onlineDot.layer.masksToBounds = true
        onlineDot.layer.borderWidth = 2
        onlineDot.layer.borderColor = UIColor(rgb: 0xF7F7F7).cgColor

        userIcon.layer.cornerRadius = 20
        userIcon.layer.masksToBounds = true

        chattingLabel.text = "正与其聊天..."
        chattingLabel.textColor = darkMode ? .lightGray : UIColor(rgb: 0x292929)

        grayLabel.font = UIFont(name: "PingFangSC-Regular", size: 11)!
        grayLabel.textColor = darkMode ? .lightGray : .darkGray

        userName.font = kBold28Font
        userName.textColor = darkMode ? UIColor.white : UIColor(red: 0.169, green: 0.173, blue: 0.176, alpha: 1)
        chattingLabel.font = kBasic28Font

        unReadCount.text = "00条新消息"
        unReadCount.font = UIFont(name: "PingFangSC-Regular", size: 11)!
        unReadCount.textAlignment = .center
        unReadCount.textColor = .white
        unReadCount.layer.backgroundColor = UIColor.red.cgColor
        unReadCount.layer.cornerRadius = 10

        addSubview(userIcon)
        addSubview(onlineDot)
        addSubview(userName)
        addSubview(grayLabel)
        addSubview(chattingLabel)
        addSubview(unReadCount)

        NotificationCenter.default.addObserver(self, selector: #selector(checkOnline), name: .onlineStatusUpdated, object: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userIcon.pin.height(40).width(40).centerLeft(to: contentView.anchor.centerLeft).marginLeft(14)

        onlineDot.frameLayout { $0
            .width.equal(to: 11)
            .height.equal(to: 11)
            .bottom.equal(to: userIcon.bottom)
            .right.equal(to: userIcon.right)
        }
        chattingLabel.frameLayout { $0
            .right.equal(to: contentView.width).offset(-contentView.layoutMargins.right)
            .centerY.equal(to: contentView.centerY)
        }
        if grayLabel.isHidden {
            userName.frameLayout { $0
                .centerY.equal(to: userIcon.centerY)
                .left.equal(to: userIcon.right).offset(7.6)
                if !chattingLabel.isHidden {
                    $0.right.equal(to: chattingLabel.left)
                }
            }
        } else {
            userName.frameLayout { $0
                .top.equal(to: userIcon.top)
                .left.equal(to: userIcon.right).offset(7.6)
                if !chattingLabel.isHidden {
                    $0.right.equal(to: chattingLabel.left)
                }
            }
            grayLabel.frameLayout { $0
                .left.equal(to: userName.left)
                .top.equal(to: userName.bottom).offset(5)
                if !chattingLabel.isHidden {
                    $0.right.equal(to: chattingLabel.left)
                }
            }
        }

        unReadCount.frameLayout { $0
            .height.equal(to: 20)
            .width.equal(to: 63)
            .centerY.equal(to: contentView.centerY)
            .right.equal(to: chattingLabel.right)
        }
    }

    func setContent(user: WhoopsUser, isChatting: Bool, unread: Int) {
        self.user = user

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

        chattingLabel.isHidden = !isChatting
//        backgroundColor = isChatting ? UIColor.gray.withAlphaComponent(0.3) : UIColor.white.withAlphaComponent(0.001)

        unReadCount.isHidden = unread == 0

        if unread > 0 {
            unReadCount.text = "\(unread)条新消息"
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
}
