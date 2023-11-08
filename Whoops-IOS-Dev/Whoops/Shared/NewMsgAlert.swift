//
//  NewMsgAlert.swift
//  Whoops
//
//  Created by Aaron on 9/21/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class NewMsgAlert: UIView {
    let whiteView: UIView = {
        let v = UIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 8
        v.layer.shadowColor = UIColor.gray.cgColor
        v.layer.shadowRadius = 5
        return v
    }()

    let title = UILabel()

    let t1 = UILabel()

    let buttonConfirm = UIButton(type: .system)

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(whiteView)

        title.font = UIFont(name: "PingFangSC-Semibold", size: 17)
        title.text = "您有0条未读隐私消息"
        title.textAlignment = .center

        t1.font = kBasic28Font
        addSubview(t1)

        t1.text = "请打开 Whoops 隐私输入法查看"

        buttonConfirm.titleLabel?.font = kBasic34Font
        buttonConfirm.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        buttonConfirm.setTitleColor(.white, for: .normal)
        buttonConfirm.layer.cornerRadius = 20
        buttonConfirm.setTitle("我知道了", for: .normal)
        buttonConfirm.addTarget(self, action: #selector(confirmDidTap), for: .touchUpInside)

        addSubview(title)
        addSubview(buttonConfirm)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        whiteView.frameLayout { $0
            .width.equal(to: 300)
            .centerX.equal(to: self.width / 2)
            .centerY.equal(to: self.height / 2).offset(-layoutMargins.top)
            .height.equal(to: 100)
        }

        title.frameLayout { $0
            .centerX.equal(to: whiteView.centerX)
            .top.equal(to: whiteView.top).offset(10)
            .width.equal(to: whiteView.width).offset(-40)
        }

        t1.frameLayout { $0
            .top.equal(to: title.bottom).offset(23)
            .left.equal(to: whiteView.left).offset(20)
        }

        buttonConfirm.frameLayout { $0
            .height.equal(to: 40)
            .left.equal(to: whiteView.left).offset(20)
            .right.equal(to: whiteView.right).offset(-20)
            .top.equal(to: t1.bottom).offset(20)
        }
        whiteView.height = buttonConfirm.bottom - whiteView.top + 20
    }

    @objc func confirmDidTap() {
        dismissSelf()
    }

    func dismissSelf() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }

    func overlay(to: UIViewController, number: Int) {
        title.text = "您有\(number)条未读隐私消息"
        alpha = 0
        frame = to.view.bounds
        to.view.addSubview(self)
        setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
}
