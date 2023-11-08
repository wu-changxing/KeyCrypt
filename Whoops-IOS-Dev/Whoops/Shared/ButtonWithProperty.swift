//
//  DotedTabBarItem.swift
//  Whoops
//
//  Created by Aaron on 10/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class ButtonWithProperty: UIButton {
    var isRead: Bool = false {
        didSet {
            setBadge()
        }
    }

    lazy var badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = .red
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badgeView.rightAnchor.constraint(equalTo: rightAnchor, constant: 3),
            badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            badgeView.heightAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius * 2),
            badgeView.widthAnchor.constraint(equalToConstant: badgeView.layer.cornerRadius * 2),
        ])

        setBadge()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setBadge() {
        badgeView.isHidden = isRead
    }
}
