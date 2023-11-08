//
//  PwdAlertView.swift
//  Whoops
//
//  Created by Aaron on 11/14/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class PwdAlertView: UIView {
    let whiteView: UIView = {
        let v = UIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 6
        return v
    }()

    let title = UILabel()
    let forgetLabel = UILabel()
    let forgetButton = UIButton(type: .system)

    let inputBgView = UIView()
    let inputField = UITextField()
    private var keyboardOffset: CGFloat = 0
    let buttonCancel: UIButton = {
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

    let buttonConfirm: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = kBold34Font
        b.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 10
        b.setTitle("确认", for: .normal)
        b.addTarget(self, action: #selector(confirmDidTap), for: .touchUpInside)
        return b
    }()

    var confirmCallback: ((Bool, String) -> Void)?
    var forgetCallback: (() -> Void)?

    var showRestore: Bool = true

    init(title: String, placeholder: String, showRestore: Bool) {
        super.init(frame: .zero)
        self.showRestore = showRestore
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(whiteView)

        self.title.font = kBold34Font
        self.title.text = title
        self.title.textAlignment = .center
        addSubview(self.title)

        inputBgView.layer.cornerRadius = 10
        inputBgView.layer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        addSubview(inputBgView)

        inputField.placeholder = placeholder
        inputField.font = kBasic34Font
        inputField.autocapitalizationType = .none
        inputField.delegate = self
        inputField.autocapitalizationType = .none
        addSubview(inputField)

        addSubview(buttonCancel)
        addSubview(buttonConfirm)

        forgetLabel.text = "忘记密码？"
        forgetLabel.font = kBasic28Font
        forgetLabel.textColor = .gray

        addSubview(forgetLabel)

        forgetButton.addTarget(self, action: #selector(forgetPwd), for: .touchUpInside)
        forgetButton.setTitleColor(UIColor(rgb: kWhoopsBlue), for: .normal)
        forgetButton.setTitle("重新导入钱包", for: .normal)
        forgetButton.titleLabel?.font = kBasic28Font
        addSubview(forgetButton)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidUp), name: UIApplication.keyboardDidShowNotification, object: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        whiteView.pin.width(300).height(100).center().marginTop(-pin.layoutMargins.top - keyboardOffset)

        title.pin.sizeToFit().topCenter(to: whiteView.anchor.topCenter).marginTop(10)

        inputBgView.pin.height(40).top(to: title.edge.bottom).left(to: whiteView.edge.left).right(to: whiteView.edge.right).margin(20)

        inputField.pin.height(of: inputBgView).centerStart(to: inputBgView.anchor.centerLeft).centerEnd(to: inputBgView.anchor.centerRight).marginLeft(10).marginRight(10)

        buttonCancel.pin.width(128).height(40).topLeft(to: inputBgView.anchor.bottomLeft).marginTop(20)

        buttonConfirm.pin.width(128).height(40).topRight(to: inputBgView.anchor.bottomRight).marginTop(20)
        if showRestore {
            forgetLabel.pin.sizeToFit().top(to: buttonCancel.edge.bottom).marginTop(25).right(to: whiteView.edge.hCenter).marginRight(10)
            forgetButton.pin.sizeToFit().right(of: forgetLabel, aligned: .center)
            whiteView.pin.bottom(to: forgetButton.edge.bottom).marginBottom(-30)
        } else {
            whiteView.pin.top(to: title.edge.top).marginTop(-10).bottom(to: buttonConfirm.edge.bottom).marginBottom(-30)
        }

        whiteView.pin.width(300).hCenter(to: edge.hCenter).top(to: title.edge.top).marginTop(-20).bottom(to: forgetButton.edge.bottom).marginBottom(-25)
    }

    @objc func keyboardDidUp(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              superview != nil else { return }
        let keyboardLine = superview!.frame.height - keyboardSize.height
        let selfLine = whiteView.frame.maxY
        if selfLine - keyboardLine > 0 {
            keyboardOffset = selfLine - keyboardLine + 20
            UIView.animateSpring { self.layoutSubviews() }
        }
    }

    @objc func forgetPwd(_: UIButton) {
        forgetCallback?()
        dismissSelf()
    }

    @objc func confirmDidTap() {
        confirmCallback?(true, inputField.text ?? "")
        dismissSelf()
    }

    @objc func cancelDidTap() {
        confirmCallback?(false, "")
        dismissSelf()
    }

    func dismissSelf() {
        confirmCallback = nil
        forgetCallback = nil
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
        } completion: { _ in
            self.inputField.becomeFirstResponder()
        }
    }
}

extension PwdAlertView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if !textField.isSecureTextEntry {
            textField.isSecureTextEntry = true
        }
        if string == "\n" {
            textField.endEditing(true)
            confirmDidTap()
            return false
        }
        return true
    }
}
