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
        v.layer.cornerRadius = 8
        v.layer.shadowColor = UIColor.gray.cgColor
        v.layer.shadowRadius = 5
        return v
    }()

    let title = UILabel()
    let detail = UILabel()
    var confirmOnly = false

    let buttonCancel: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("取消", for: .normal)
        b.backgroundColor = .white
        b.setTitleColor(.black, for: .normal)
        b.layer.cornerRadius = 20
        b.layer.borderColor = UIColor(rgb: kButtonBorderColor).cgColor
        b.layer.borderWidth = 1

        return b
    }()

    let buttonConfirm = UIButton(type: .system)

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

        self.detail.font = kBasic28Font
        self.detail.text = detail
//        self.detail.textAlignment = .center
        self.detail.textColor = .gray
        self.detail.lineBreakMode = .byCharWrapping
        self.detail.numberOfLines = 5

        buttonCancel.titleLabel?.font = kBasic34Font
        buttonCancel.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
        buttonConfirm.titleLabel?.font = kBasic34Font
        buttonConfirm.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        buttonConfirm.setTitleColor(.white, for: .normal)
        buttonConfirm.layer.cornerRadius = 20
        buttonConfirm.setTitle(confirmText, for: .normal)
        buttonConfirm.addTarget(self, action: #selector(confirmDidTap), for: .touchUpInside)

        backupConfirmButton.setImage(UIImage(named: "unselect"), for: .normal)
        backupConfirmButton.setTitle("  " + confirmButtonText, for: .normal)
        backupConfirmButton.setTitleColor(.gray, for: .normal)
        backupConfirmButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 12)
        backupConfirmButton.addTarget(self, action: #selector(backupd), for: .touchUpInside)
        backupConfirmButton.imageView?.contentMode = .scaleAspectFit
        backupConfirmButton.adjustsImageWhenDisabled = false

        addSubview(whiteView)
        addSubview(self.title)
        addSubview(self.detail)
        if !confirmOnly {
            addSubview(buttonCancel)
        }
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

        detail.frameLayout { $0
            .centerX.equal(to: title.centerX)
            .top.equal(to: title.bottom).offset(10)
            .width.equal(to: title.width)
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
                .centerX.equal(to: title.centerX)
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
