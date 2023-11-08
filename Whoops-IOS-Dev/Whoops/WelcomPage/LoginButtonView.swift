//
//  LoginButtonView.swift
//  Whoops
//
//  Created by Aaron on 3/23/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import UIKit

class LoginButtonView: UIButton {
    let arrow = UIImageView(image: #imageLiteral(resourceName: "Vector 56"))
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(arrow)
        arrow.tintColor = .darkText
        titleLabel?.font = kBold34Font
        setTitleColor(.darkText, for: .normal)
        contentHorizontalAlignment = .left
        imageView?.contentMode = .scaleAspectFit
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !frame.isEmpty, superview != nil else { return }
        arrow.pin.sizeToFit().centerRight(to: anchor.centerRight)
    }
}
