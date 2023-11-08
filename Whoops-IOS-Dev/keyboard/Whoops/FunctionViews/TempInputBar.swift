//
//  TmpInputBar.swift
//  keyboard
//
//  Created by Aaron on 10/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import KeychainAccess
import PinLayout
import UIKit

class TempInputBar: UIView {
    let inputField = CYMTextView()
    let confirmButton = UIButton()
    let cancelButton = UIButton()
    let pasteButton = UIButton()
    var isPasswordField = false
    var successCallback: ((String) -> Void)?
    private var _tag = 0

    /// 不使用系统的 tag， 很慢
    override var tag: Int {
        get { return _tag }
        set { _tag = newValue }
    }

    private let moreBg = UIView()
    private var textViewEmptyCache = true

    init(hint: String, isPasswordField: Bool) {
        super.init(frame: .zero)
        self.isPasswordField = isPasswordField
        backgroundColor = .clear
        clipsToBounds = false
        moreBg.isUserInteractionEnabled = false
        moreBg.backgroundColor = kColor5c5c5c
        addSubview(moreBg)

        inputField.placeholder = hint
        inputField.isSecureTextEntry = isPasswordField
        inputField.placeholderColor = .gray
        inputField.backgroundColor = .clear
        inputField.textColor = UIColor.white
        inputField.returnKeyType = .done
        inputField.font = kBasic28Font
        inputField.delegate = self
        inputField.contentMode = .center
        addSubview(inputField)

        confirmButton.layer.cornerRadius = 4
        if #available(iOSApplicationExtension 13.0, *) {
            confirmButton.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        confirmButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.titleLabel?.font = kBasic28Font
        confirmButton.clipsToBounds = true
        confirmButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        addSubview(confirmButton)

        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = kBasic28Font
        addSubview(cancelButton)

        pasteButton.setTitleColor(darkMode ? .white : .lightGray, for: .normal)
        pasteButton.setTitle("粘贴", for: .normal)
        pasteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        pasteButton.alpha = 0
        pasteButton.addTarget(self, action: #selector(pasteString), for: .touchUpInside)
        addSubview(pasteButton)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showPasteButtonIfNeeded()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(newStringFromPasteboard), name: .PasteBoardNewString, object: nil)
    }

    @objc func newStringFromPasteboard(_: Notification) {
        DispatchQueue.main.async {
            self.showPasteButtonIfNeeded()
        }
    }

    func showPasteButtonIfNeeded() {
        if !isPasswordField, UIPasteboard.general.hasStrings {
            UIView.animateSpring {
                self.pasteButton.alpha = 1
            }
        }
        if isPasswordField {
            let keychain = Keychain(service: "life.whoops.app", accessGroup: "group.life.whoops.app")
            DispatchQueue.global().async {
                do {
                    let password = try keychain
                        .authenticationPrompt("认证以解锁钱包")
                        .get(WalletUtil.getCurrentWallet()!.id)
                    DispatchQueue.main.async {
                        self.inputField.text = password
                    }
//                    print("password: \(password)")
                } catch {
//                    print(error,11111)
                    // Error handling if needed...
                }
            }
        }
    }

    @objc func pasteString() {
        UIView.animateSpring {
            self.pasteButton.alpha = 0
        }
        inputField.text = PasteBoard.string
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        moreBg.pin.horizontally().top().height(42)
        confirmButton.pin.height(32).width(68).right(4).vCenter(to: edge.vCenter)
        cancelButton.pin.height(32).width(68).centerLeft(to: anchor.centerLeft).marginRight(24)
        pasteButton.pin.sizeToFit().left(of: confirmButton, aligned: .center).marginRight(10)
        inputField.pin.horizontallyBetween(cancelButton, and: pasteButton).marginRight(10).vCenter(to: moreBg.edge.vCenter).height(38)
    }

    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        inputField.becomeFirstResponder()
        return true
    }

    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        inputField.resignFirstResponder()
        return true
    }

    deinit {
        successCallback = nil
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TempInputBar: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            confirmButton.sendActions(for: .touchUpInside)
            return false
        }
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

extension TempInputBar {
    @objc func sendButtonDidTap() {
        guard let content = inputField.text, !content.isEmpty else { return }
        successCallback?(content)
    }

    @objc func buttonDown(_: UIButton) {}

    @objc func buttonUp(_: UIButton) {}
}
