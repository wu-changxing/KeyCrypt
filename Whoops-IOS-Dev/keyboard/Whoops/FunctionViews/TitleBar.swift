//
//  TitleBar.swift
//  keyboard
//
//  Created by Aaron on 10/7/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class TitleBar: UIView {
    let title = UILabel()
    var titleOnCenter = true

    let backButton = UIButton()
    var rightButton: UIButton?
    let bottomLine = UIView()

    var customRightButtonShape = false

    init(title: String, customRightButtonShape: Bool = false) {
        self.customRightButtonShape = customRightButtonShape
        super.init(frame: .zero)
        self.title.text = title

        addSubview(self.title)
        addSubview(backButton)
        self.title.font = kBold28Font
        self.title.textColor = darkMode ? .white : kColor5c5c5c

        backButton.titleLabel?.font = kBasic28Font
        backButton.setImage(UIImage(named: "backImage"), for: .normal)
        backButton.imageView?.tintColor = darkMode ? .white : kColor5c5c5c

        bottomLine.backgroundColor = UIColor(rgb: 0xBBBEC2)
        addSubview(bottomLine)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview _: UIView?) {
        if let r = rightButton {
            addSubview(r)
        }

        if !titleOnCenter {
            backButton.removeFromSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backButton.frameLayout { $0
            .centerY.equal(to: self.height / 2)
            .left.equal(to: 14)
        }

        if titleOnCenter {
            title.frameLayout { $0
                .centerX.equal(to: self.width / 2)
                .centerY.equal(to: self.height / 2)
            }
        } else {
            title.frameLayout { $0
                .centerY.equal(to: self.height / 2)
                .left.equal(to: 14)
            }
        }

        rightButton?.frameLayout { $0
            .centerY.equal(to: self.height / 2)
            .right.equal(to: self.width).offset(-14)
            guard !customRightButtonShape else {
                return
            }
            $0.height.equal(to: 32)
            $0.width.equal(to: 136 / 2)
        }

        bottomLine.frameLayout { $0
            .height.equal(to: 0.5)
            .bottom.equal(to: self.height)
            .left.equal(to: 0)
            .right.equal(to: self.width)
        }
    }
}
