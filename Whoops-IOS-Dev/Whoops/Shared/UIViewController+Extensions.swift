//
//  UIViewController+Extensions.swift
//  Whoops
//
//  Created by Aaron on 7/14/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

extension UIViewController {
    func setLeftAlignedNavigationItemTitle(text: String,
                                           color: UIColor,
                                           margin left: CGFloat,
                                           font: UIFont)
    {
        let titleLabel = UILabel()
        titleLabel.textColor = color
        titleLabel.text = text
        titleLabel.textAlignment = .left
        titleLabel.font = font
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        navigationItem.titleView = titleLabel

        guard let containerView = navigationItem.titleView?.superview else { return }

        // NOTE: This always seems to be 0. Huh??
        let leftBarItemWidth = navigationItem.leftBarButtonItems?.reduce(0) { $0 + $1.width }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor,
                                             constant: (leftBarItemWidth ?? 0) + left),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor),
        ])
    }
}
