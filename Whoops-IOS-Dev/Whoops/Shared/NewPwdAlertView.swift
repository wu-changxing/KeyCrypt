//
//  NewPwdAlertView.swift
//  Whoops
//
//  Created by Aaron on 4/2/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class NewPwdAlertView: UIView {
    let whiteView: UIView = {
        let v = UIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 6
        return v
    }()

    private var thePwd = ""
    let title = UILabel()

    let inputBgView1 = UIView()
    let inputBgView2 = UIView()
    let pwd1 = UITextField()
    let pwd2 = UITextField()
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
        b.layer.backgroundColor = UIColor.gray.cgColor
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 10
        b.setTitle("确认", for: .normal)
        b.addTarget(self, action: #selector(confirmDidTap), for: .touchUpInside)
        return b
    }()

    var confirmCallback: ((Bool, String) -> Void)?
    private func settingPwdField(_ f: UITextField) {
        f.delegate = self
        f.keyboardType = .alphabet
        f.font = kBasic34Font
        f.autocapitalizationType = .none
        f.backgroundColor = .groupTableViewBackground
        f.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
    }

    @objc func valueDidChange() {
        guard pwd1.text!.count >= 8, pwd2.text!.count >= 8,
              pwd1.text == pwd2.text
        else {
            buttonConfirm.isEnabled = false
            buttonConfirm.layer.backgroundColor = UIColor.gray.cgColor
            return
        }

        thePwd = pwd2.text!
        buttonConfirm.isEnabled = true
        buttonConfirm.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
    }

    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(whiteView)

        self.title.font = kBold34Font
        self.title.text = title
        self.title.textAlignment = .center
        addSubview(self.title)
        inputBgView1.layer.cornerRadius = 10
        inputBgView2.layer.cornerRadius = 10
        inputBgView1.layer.masksToBounds = true
        inputBgView2.layer.masksToBounds = true
        inputBgView1.backgroundColor = UIColor.groupTableViewBackground
        inputBgView2.backgroundColor = UIColor.groupTableViewBackground
        addSubview(inputBgView1)
        addSubview(inputBgView2)

        settingPwdField(pwd1)
        settingPwdField(pwd2)

        pwd1.placeholder = placeholder
        pwd2.placeholder = "确认密码"
        addSubview(pwd1)
        addSubview(pwd2)

        addSubview(buttonCancel)
        buttonConfirm.isEnabled = false
        addSubview(buttonConfirm)
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
        inputBgView1.pin.height(40).top(to: title.edge.bottom).left(to: whiteView.edge.left).right(to: whiteView.edge.right).margin(20)
        inputBgView2.pin.size(of: inputBgView1).below(of: inputBgView1, aligned: .center).marginTop(10)

        pwd1.pin.height(of: inputBgView1).centerStart(to: inputBgView1.anchor.centerLeft).centerEnd(to: inputBgView1.anchor.centerRight).marginLeft(10).marginRight(10)
        pwd2.pin.height(of: inputBgView2).centerStart(to: inputBgView2.anchor.centerLeft).centerEnd(to: inputBgView2.anchor.centerRight).marginLeft(10).marginRight(10)

        buttonCancel.pin.width(128).height(40).topLeft(to: inputBgView2.anchor.bottomLeft).marginTop(20)

        buttonConfirm.pin.width(128).height(40).topRight(to: inputBgView2.anchor.bottomRight).marginTop(20)

        whiteView.pin.top(to: title.edge.top).marginTop(-10).bottom(to: buttonConfirm.edge.bottom).marginBottom(-30)

        whiteView.pin.width(300).hCenter(to: edge.hCenter).top(to: title.edge.top).marginTop(-20).bottom(to: buttonConfirm.edge.bottom).marginBottom(-25)
    }

    @objc func confirmDidTap() {
        confirmCallback?(true, thePwd)
        dismissSelf()
    }

    @objc func cancelDidTap() {
        confirmCallback?(false, "")
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

    func overlay(to: UIViewController) {
        alpha = 0
        frame = to.view.bounds
        to.view.addSubview(self)
        setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        } completion: { _ in
            self.pwd1.becomeFirstResponder()
        }
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
}

extension NewPwdAlertView: UITextFieldDelegate {
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
