//
//  RankButtonView.swift
//  Whoops
//
//  Created by Aaron on 2/11/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class RankButtonView: UIView {
    let image = UIImageView(image: #imageLiteral(resourceName: "主榜单 1"))
    let label = UILabel()
    init() {
        super.init(frame: .zero)
        addSubview(image)
        label.text = "拉新榜"
        label.font = kBold34Font
        label.textColor = UIColor(red: 0.961, green: 0.373, blue: 0.373, alpha: 1)
        addSubview(label)
        backgroundColor = UIColor(red: 1, green: 0.904, blue: 0.904, alpha: 1)
        isUserInteractionEnabled = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        image.pin.center(to: anchor.center).marginRight(image.frame.width + 10)
        label.pin.sizeToFit().centerLeft(to: image.anchor.centerRight).marginLeft(13)
    }
}
