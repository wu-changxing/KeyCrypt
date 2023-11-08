//
//  ContactCell.swift
//  Whoops
//
//  Created by Aaron on 7/16/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import SwipeCellKit
import UIKit

class ContactCell: SwipeTableViewCell {
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var onlineDot: UIView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var grayLabel: UILabel!
    
    @IBOutlet var nameConstraint:NSLayoutConstraint!

    weak var user: WhoopsUser?

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // "contactCell"
        onlineDot.backgroundColor = UIColor(rgb: kOnlineDotColor)
        onlineDot.layer.cornerRadius = 5.5
        onlineDot.layer.masksToBounds = true
        onlineDot.layer.borderWidth = 2
        onlineDot.layer.borderColor = UIColor(rgb: 0xF7F7F7).cgColor

        userIcon.layer.cornerRadius = 25
        userIcon.layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(checkOnline), name: .onlineStatusUpdated, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setContent(user: WhoopsUser) {
        self.user = user
        if user.userType == kUserTypeGroup {
            userIcon.backgroundColor = UIColor(rgb: user.groupColor)
            userIcon.image = #imageLiteral(resourceName: "GroupIcon").withInset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        } else {
            user.getImage(defaultImage: #imageLiteral(resourceName: "noIcon")) {
                self.userIcon.image = $0
            }
        }

        if user.userType == kUserTypeSingle, let c = user.nickName {
            nameConstraint.constant = -10
            userName.text = c
            grayLabel.text = user.name
            grayLabel.isHidden = false
        } else {
            nameConstraint.constant = 0
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
}
