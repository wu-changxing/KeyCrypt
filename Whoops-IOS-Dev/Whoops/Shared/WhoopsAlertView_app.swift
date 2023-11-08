//
//  DeleteAlertView.swift
//  Whoops
//
//  Created by Aaron on 7/16/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class WhoopsAlertView: UIView {
    static func badAlert(msg: String?, vc: UIViewController) {
        DispatchQueue.main.async {
            let alert = WhoopsAlertView(title: "网络错误，请重试", detail: msg ?? "", confirmText: "好", confirmOnly: true)
            if vc is UITabBarController {
                alert.overlay(to: vc)
            } else if let tabbar = vc.tabBarController {
                alert.overlay(to: tabbar)
            } else {
                alert.overlay(to: vc)
            }
        }
    }

    let whiteView: UIView = {
        let v = UIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 6
        return v
    }()

    let title = UILabel()
    let detail = UILabel()
    var confirmOnly = false

    lazy var buttonCancel: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("取消", for: .normal)
        b.backgroundColor = .white
        b.setTitleColor(.black, for: .normal)
        b.layer.cornerRadius = 10
        b.layer.borderColor = UIColor(rgb: kButtonBorderColor).cgColor
        b.layer.borderWidth = 1
        b.titleLabel?.font = kBold34Font
        b.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
        return b
    }()

    lazy var buttonConfirm: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = kBold34Font
        b.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 10
        b.addTarget(self, action: #selector(confirmDidTap), for: .touchUpInside)
        return b
    }()

    let backupConfirmButton = UIButton()

    var confirmCallback: ((Bool) -> Void)?

    init(title: String, detail: String, confirmText: String, confirmButtonText: String = "", confirmOnly: Bool) {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.confirmOnly = confirmOnly

        self.title.font = kBold34Font
        self.title.text = title
        self.title.textAlignment = .center
        self.title.textColor = .darkText
        self.title.numberOfLines = 5
        self.detail.lineBreakMode = .byCharWrapping

        self.detail.font = kBasic28Font
        self.detail.text = detail
        self.detail.textColor = .gray
        self.detail.lineBreakMode = .byCharWrapping
        self.detail.numberOfLines = 5

        backupConfirmButton.setImage(UIImage(named: "unselect"), for: .normal)
        backupConfirmButton.setTitle("  " + confirmButtonText, for: .normal)
        backupConfirmButton.setTitleColor(.gray, for: .normal)
        backupConfirmButton.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 12)
        backupConfirmButton.addTarget(self, action: #selector(backupd), for: .touchUpInside)
        backupConfirmButton.imageView?.contentMode = .scaleAspectFit
        backupConfirmButton.adjustsImageWhenDisabled = false

        addSubview(whiteView)
        addSubview(self.title)
        addSubview(self.detail)
        if !confirmOnly {
            if confirmButtonText == "是" {
                buttonCancel.setTitle("否", for: .normal)
            }
            addSubview(buttonCancel)
        }
        buttonConfirm.setTitle(confirmText, for: .normal)
        addSubview(buttonConfirm)
        if !confirmButtonText.isEmpty {
            buttonConfirm.isEnabled = false
            buttonConfirm.layer.backgroundColor = UIColor.gray.cgColor
            addSubview(backupConfirmButton)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        whiteView.pin.height(100).width(300).center().marginTop(-layoutMargins.top)
        title.pin.sizeToFit(.width).hCenter().width(whiteView.frame.width - 40).top(to: whiteView.edge.top).marginTop(20)

        detail.frameLayout { $0
            .centerX.equal(to: whiteView.centerX)
            .top.equal(to: title.bottom).offset(10)
            .width.equal(to: whiteView.width).offset(-40)
        }
        detail.sizeToFit()
        var a: UIView = detail.text?.isEmpty ?? true ? title : detail
        if !buttonConfirm.isEnabled {
            backupConfirmButton.frameLayout { $0
                .left.equal(to: detail.left)
                .top.equal(to: detail.bottom).offset(10)
            }
            a = backupConfirmButton
        }
        if confirmOnly {
            buttonConfirm.frameLayout { $0
                .height.equal(to: 40)
                .width.equal(to: 128)
                .centerX.equal(to: whiteView.centerX)
                .top.equal(to: a.bottom).offset(20)
            }
        } else {
            buttonCancel.frameLayout { $0
                .height.equal(to: 40)
                .width.equal(to: 128)
                .left.equal(to: whiteView.left).offset(20)
                .top.equal(to: a.bottom).offset(20)
            }
            buttonConfirm.frameLayout { $0
                .height.equal(to: 40)
                .width.equal(to: 128)
                .right.equal(to: whiteView.right).offset(-20)
                .top.equal(to: a.bottom).offset(20)
            }
        }

        whiteView.height = buttonConfirm.bottom - whiteView.top + 20
    }

    @objc func backupd(_ sender: UIButton) {
        sender.setImage(UIImage(named: "selected"), for: .normal)
        sender.isEnabled = false
        buttonConfirm.layer.backgroundColor = UIColor.red.cgColor
        buttonConfirm.isEnabled = true
    }

    @objc func confirmDidTap() {
        confirmCallback?(true)
        dismissSelf()
    }

    @objc func cancelDidTap() {
        confirmCallback?(false)
        dismissSelf()
    }

    func dismissSelf() {
        confirmCallback = nil
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }

    func overlay(to: UIView) {
        alpha = 0
        frame = to.bounds
        to.addSubview(self)
        setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    func overlay(to: UIViewController) {
        overlay(to: to.view)
    }
}
