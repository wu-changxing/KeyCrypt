//
//  RankFooter.swift
//  Whoops
//
//  Created by Aaron on 2/11/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class RankFooterView: UIView {
    let l1 = UIView()
    let l2 = UIView()
    let l = UILabel()

    init() {
        super.init(frame: .zero)
        addSubview(l1)
        addSubview(l2)
        addSubview(l)
        l.text = "最多展示榜单前100人"
        l.font = kBasic28Font
        l.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        l1.backgroundColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
        l2.backgroundColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        l.pin.sizeToFit().center(to: anchor.center)
        l1.pin.width(100).height(1).left(of: l, aligned: .center).marginRight(10)
        l2.pin.width(100).height(1).right(of: l, aligned: .center).marginLeft(10)
    }
}
