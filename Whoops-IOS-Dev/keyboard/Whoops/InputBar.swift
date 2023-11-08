//
//  InputBar.swift
//  keyboard
//
//  Created by Aaron on 7/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class InputBar: UIView {
    let infoLabel = UILabel()
    let userIcon = UIImageView()
    let userIconBorderBg = UIView()
    let inputLockImageView = UIImageView(image: #imageLiteral(resourceName: "lock"))
    let inputField = CYMTextView()
    let sendButton = UIButton()
    private let moreBg = UIView()
    private var textViewEmptyCache = true
    let pasteButton = UIButton()

    let gradientLayer = CAGradientLayer()
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear

        moreBg.isUserInteractionEnabled = false
        moreBg.backgroundColor = kColor5c5c5c
        addSubview(moreBg)

        userIconBorderBg.layer.cornerRadius = 21
        userIconBorderBg.layer.masksToBounds = true
        gradientLayer.colors = darkMode ? [UIColor.black.cgColor, kColor5c5c5c.cgColor] : [UIColor.white.cgColor, kColor5c5c5c.cgColor]
        gradientLayer.locations = [0, 0.5]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        userIconBorderBg.layer.addSublayer(gradientLayer)
        addSubview(userIconBorderBg)

        infoLabel.text = "“邀请”或从“联系人/群”选择隐私聊天对象"
        infoLabel.textColor = UIColor.white
        infoLabel.textAlignment = .center
        infoLabel.font = kBasic28Font
        addSubview(infoLabel)

        userIcon.layer.masksToBounds = true
        userIcon.layer.cornerRadius = 20
        addSubview(userIcon)

        inputLockImageView.contentMode = .scaleAspectFit
        addSubview(inputLockImageView)

        inputField.placeholder = "在此输入信息，聊天已加密"
        inputField.placeholderColor = .gray
        inputField.backgroundColor = .clear
        inputField.textColor = UIColor.white
        inputField.font = kBasic28Font
        inputField.delegate = self
        inputField.contentMode = .center
        addSubview(inputField)

        pasteButton.setTitleColor(darkMode ? .white : .lightGray, for: .normal)
        pasteButton.setTitle("粘贴", for: .normal)
        pasteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        pasteButton.alpha = 0
        pasteButton.addTarget(self, action: #selector(pasteString), for: .touchUpInside)
        addSubview(pasteButton)
        sendButton.layer.cornerRadius = 4
        if #available(iOSApplicationExtension 13.0, *) {
            sendButton.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        sendButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        sendButton.setTitle("发送", for: .normal)
        sendButton.titleLabel?.font = kBasic28Font
        sendButton.clipsToBounds = true
        sendButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        addSubview(sendButton)

        showHintOnly()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        moreBg.pin.horizontally().top().height(42)
        userIconBorderBg.pin.height(42).width(42).left(14).bottom(4)
        gradientLayer.frame = userIconBorderBg.bounds
        infoLabel.pin.sizeToFit().center(to: anchor.center)

        userIcon.pin.width(40).height(40).center(to: userIconBorderBg.anchor.center)
        inputLockImageView.pin.sizeToFit().right(of: userIconBorderBg).marginLeft(8).vCenter(to: edge.vCenter)

        if inputField.text.isEmpty {
            sendButton.setTitle("", for: .normal)
            sendButton.alpha = 0
        } else {
            sendButton.setTitle("发送", for: .normal)
            sendButton.alpha = 1
        }
        sendButton.pin.height(32).width(inputField.text.isEmpty ? 0 : 68).right(4).vCenter(to: edge.vCenter)
        pasteButton.pin.sizeToFit().left(of: sendButton, aligned: .center).marginRight(10)
        inputField.pin.right(of: inputLockImageView, aligned: .center).marginLeft(5).marginTop(2).right(to: pasteButton.edge.left).marginRight(20).height(of: self)
    }

    @objc func pasteString() {
        UIView.animateSpring {
            self.pasteButton.alpha = 0
        }
        inputField.text = PasteBoard.string
    }

    func showInputView() {
        userIcon.isHidden = false
        userIconBorderBg.isHidden = false
        inputLockImageView.isHidden = false
        inputField.isHidden = false
        infoLabel.isHidden = true
        inputField.becomeFirstResponder()
        inputField.text = ""
        if sendButton.width > 0 {
            UIView.animateSpring {
                self.layoutSubviews()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(newStringFromPasteboard), name: .PasteBoardNewString, object: nil)
    }

    @objc func newStringFromPasteboard(_: Notification) {
        DispatchQueue.main.async {
            UIView.animateSpring {
                self.pasteButton.alpha = 1
            }
        }
    }

    func showHintOnly(_ hint: String = "“邀请”或从“联系人”选择隐私聊天对象") {
        NotificationCenter.default.removeObserver(self, name: .PasteBoardNewString, object: nil)
        userIcon.isHidden = true
        userIconBorderBg.isHidden = true
        inputLockImageView.isHidden = true
        inputField.isHidden = true
        infoLabel.isHidden = false
        infoLabel.text = hint
        inputField.endEditing(true)
        inputField.text = ""
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .PasteBoardNewString, object: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InputBar: UITextViewDelegate {
    func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText _: String) -> Bool {
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        if textViewEmptyCache != textView.text.isEmpty {
            // 用户从空白输入了内容 或者有内容删除到空
            textViewEmptyCache = textView.text.isEmpty
            UIView.animateSpring {
                self.layoutSubviews()
            }
        }
    }
}

extension InputBar {
    @objc func sendButtonDidTap() {
        ChatEngine.shared.sendMsg(content: inputField.text)
        inputField.text = ""
        textViewDidChange(inputField)
    }

    @objc func buttonDown(_: UIButton) {}

    @objc func buttonUp(_: UIButton) {}
}
