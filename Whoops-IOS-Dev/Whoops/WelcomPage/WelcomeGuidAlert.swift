//
//  WelcomeGuidAlert.swift
//  Whoops
//
//  Created by Aaron on 7/28/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class WelcomeGuidAlert: UIView {
    let whiteView: UIView = {
        let v = UIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 8
        v.layer.shadowColor = UIColor.gray.cgColor
        v.layer.shadowRadius = 5
        return v
    }()

    let m1 = UIImageView(image: #imageLiteral(resourceName: "mark1"))
    let m2 = UIImageView(image: #imageLiteral(resourceName: "mark2"))
    let m3 = UIImageView(image: #imageLiteral(resourceName: "mark3"))

    let title = UILabel()

    let t1 = UILabel()
    let t2 = UILabel()
    let t3 = UILabel()

    let buttonConfirm = UIButton(type: .system)

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(whiteView)

        title.font = UIFont(name: "PingFangSC-Semibold", size: 17)
        title.text = "如何使用？"
        title.textAlignment = .center

        for m in [m1, m2, m3] {
            m.contentMode = .scaleAspectFit
            addSubview(m)
        }

        for t in [t1, t2, t3] {
            t.font = kBasic28Font
            addSubview(t)
        }

        t1.text = "在聊天时将输入法切换为 Whoops"
        t2.text = "邀请好友成为隐私联系人"
        t3.text = "开启加密聊天"

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

        m1.frameLayout { $0
            .top.equal(to: title.bottom).offset(23)
            .left.equal(to: whiteView.left).offset(20)
            .height.equal(to: 20)
            .width.equal(to: 20)
        }
        m2.frameLayout { $0
            .top.equal(to: m1.bottom).offset(10)
            .left.equal(to: whiteView.left).offset(20)
            .height.equal(to: 20)
            .width.equal(to: 20)
        }
        m3.frameLayout { $0
            .top.equal(to: m2.bottom).offset(10)
            .left.equal(to: whiteView.left).offset(20)
            .height.equal(to: 20)
            .width.equal(to: 20)
        }
        t1.frameLayout { $0
            .top.equal(to: title.bottom).offset(23)
            .left.equal(to: m1.right).offset(6)
        }
        t2.frameLayout { $0
            .top.equal(to: t1.bottom).offset(10)
            .left.equal(to: m2.right).offset(6)
        }
        t3.frameLayout { $0
            .top.equal(to: t2.bottom).offset(10)
            .left.equal(to: m3.right).offset(6)
        }

        buttonConfirm.frameLayout { $0
            .height.equal(to: 40)
            .left.equal(to: whiteView.left).offset(20)
            .right.equal(to: whiteView.right).offset(-20)
            .top.equal(to: t3.bottom).offset(20)
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

    func overlay(to: UIViewController) {
        alpha = 0
        frame = to.view.bounds
        to.view.addSubview(self)
        setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
}
