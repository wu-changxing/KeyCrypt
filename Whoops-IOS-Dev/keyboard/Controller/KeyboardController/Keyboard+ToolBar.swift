//
//  Keyboard+ToolBar.swift
//  keyboard
//
//  Created by Aaron on 7/12/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

var isPrivacyModeOn: Bool {
    get {
        LocalConfigManager.shared.privacyMode
    }
    set {
        NotificationCenter.default.post(name: .privacyModeWillChangeTo, object: newValue, userInfo: nil)
        LocalConfigManager.shared.privacyMode = newValue
    }
}

extension KeyboardViewController {
    func showRedPackConfirmation(value: Double, tokenType: String) {
        guard isPrivacyModeOn, let inputBar = whoopsInputBar else { return }
        let v = RedpackNoticeView()
        v.setContent(value: value, tokenType: tokenType)
        v.alpha = 0
        view.insertSubview(v, belowSubview: inputBar)
        v.pin.top().left().right().bottom(to: inputBar.edge.vCenter)
        v.layoutSubviews()

        UIView.animateSpring {
            v.alpha = 1
        }
    }

    func acceptInvite(code: String) {
        guard let p = Platform.fromClientID(clientID) else {
            toast(str: "Whoops 暂不支持当前平台")
            return // 仅限支持的平台才能进行隐私聊天
        }
        guard let c = NetLayer.sessionUser(for: p)?.inviteCode,
              c != code.lowercased()
        else {
            return
        }

        func theCallback(_ result: Bool, _ user: Any?, msg: String?) {
            guard result else {
                if let u = user as? WhoopsUser {
                    NetLayer.setSecondRecentUser(u)
                }
                toast(str: msg ?? "网络错误，请重试。")
                return
            }
            let u = user as! WhoopsUser
            DispatchQueue.main.async {
                if !isPrivacyModeOn {
                    self.openPrivacyMode()
                }
                ChatEngine.shared.setTarget(user: u)
                PasteBoard.string = ""
            }
        }

        if code.contains(char: "GROUP:") || code.contains(char: "group:") {
            NetLayer.groupAcceptInvite(code: code, platform: p, callback: theCallback)
        } else {
            NetLayer.acceptInvite(code: code, platform: p, callback: theCallback)
        }
    }

    func toast(str: String) {
        DispatchQueue.main.async {
            let v = UILabel()
            v.font = kBasic34Font
            v.textColor = .white
            v.layer.backgroundColor = UIColor.darkGray.cgColor
            v.layer.cornerRadius = 5
            v.textAlignment = .center
            v.text = str
            v.numberOfLines = 0
            v.sizeToFit()
            v.alpha = 0
            self.view.addSubview(v)
            v.center = self.view.center
            v.width += 20
            v.height += 10

            UIView.animate(withDuration: 0.3, animations: {
                v.alpha = 1
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 2, animations: {
                    v.alpha = 0
                }) { _ in
                    v.removeFromSuperview()
                }
            }
        }
    }

    func updateKeyboardForPrivacyMode() {
        let n = isPrivacyModeOn ? kPrivacyHeight : -kPrivacyHeight
        heightConstraint.constant = heightConstraint.constant + CGFloat(n)
        addConstraintsToKeyboard(customInterface)
        let b = UIView()
        view.addSubview(b)
        b.removeFromSuperview()
    }

    func crashMe() {
        exit(0)
    }

    func openPrivacyMode(atStart _: Bool = false, sender: UIButton? = nil) {
        guard Platform.fromClientID(clientID) != nil else {
            toast(str: "Whoops 暂不支持当前平台")
            sender?.layer.backgroundColor = nil
            return // 仅限支持的平台才能进行隐私聊天
        }
        contactView?.dismiss()
        moreSettingView?.dismiss()
        inviteView?.dismiss()
        dismissEnglishKeyboard()
        isPrivacyModeOn = true
        updateKeyboardForPrivacyMode()
        let chv = ChatHistoryView()
        view.addSubview(chv)
        chatHistoryView = chv
        chv.pin.top().horizontally().height(kPrivacyHeight)

        let inputBar = InputBar()
        whoopsInputBar = inputBar
        view.addSubview(inputBar)
        inputBar.pin.horizontally().bottom(to: chv.edge.bottom).height(40)

        ChatEngine.shared.hook(inputBar: inputBar, chatView: chv)

        DispatchQueue.global().async {
            guard let u = SocketLayer.shared.sessionUser,
                  let address = WalletUtil.getAddress(mode: kAddressModeMain)
            else { return }

            NetLayer.userInfo(user: u) { _, _ in
                guard u.walletAddress != address else {
                    return
                }

                NetLayer.updateWallet(address: address, p: u.platform) { _, _ in
                }
            }
        }
    }

    func closePrivacyMode() {
        dismissEnglishKeyboard()
        chatHistoryView?.removeFromSuperview()
        whoopsInputBar?.removeFromSuperview()
        isPrivacyModeOn = false
        LocalConfigManager.shared.lastChatTarget = nil
        ChatEngine.shared.waittingNewOne = false
        updateKeyboardForPrivacyMode()
        if #available(iOSApplicationExtension 14.0, *) {
            // ios 14 又能正常改变键盘高度了(大多数情况下)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.view.frame.height > ConfigManager.shared.keyboardHeight {
                    self.crashMe()
                }
            }

        } else {
            crashMe()
        }
    }

    @objc func invitePrivacyChat() {
        guard Platform.fromClientID(clientID) != nil else {
            toast(str: "Whoops 暂不支持当前平台")
            NotificationCenter.default.post(name: .inviteViewOpenChanged, object: nil)
            return // 仅限支持的平台才能进行隐私聊天
        }
        dismissEnglishKeyboard()
        if isMoreSettingViewOpening {
            moreSettingView?.dismiss()
            isInviteViewOpening = false
            return
        }

        if isContactViewOpening {
            contactView?.dismiss()
            isInviteViewOpening = false
            return
        }

        if isInviteViewOpening {
            inviteView?.dismiss()
        } else {
            InviteView(keyboard: self).show()
            inviteView?.callback = {
                if !isPrivacyModeOn { self.openPrivacyMode() }
                guard let v = self.chatHistoryView else {
                    self.toast(str: "Whoops 暂不支持当前平台")
                    return
                }
                self.insertToApp($0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    (KeyboardViewController.inputProxy as? KeyboardViewController)?.insertToApp("\n")
                }
                if ChatEngine.shared.targetUser != nil {
                    self.toast(str: "已发送隐私聊天邀请")
                } else {
                    v.showToast(text: "已发送隐私聊天邀请")
                    ChatEngine.shared.waittingNewOne = true
                }
            }
        }
    }

    @objc func contactPrivacy() {
        guard Platform.fromClientID(clientID) != nil else {
            toast(str: "Whoops 暂不支持当前平台")
            NotificationCenter.default.post(name: .contactViewOpenChanged, object: nil)
            return // 仅限支持的平台才能进行隐私聊天
        }
        dismissEnglishKeyboard()
        if isInviteViewOpening {
            inviteView?.dismiss()
            isContactViewOpening = false
            return
        }
        if isMoreSettingViewOpening {
            moreSettingView?.dismiss()
            isContactViewOpening = false
            return
        }

        if isContactViewOpening {
            contactView?.dismiss()
        } else {
            ContactController(keyboard: self).show()
        }
    }

    @objc func moreTool() {
        dismissEnglishKeyboard()
        if isInviteViewOpening {
            inviteView?.dismiss()
            isMoreSettingViewOpening = false
            return
        }
        if isContactViewOpening {
            contactView?.dismiss()
            isMoreSettingViewOpening = false
            return
        }

        if isMoreSettingViewOpening {
            moreSettingView?.dismiss()
        } else {
            MoreSettingView(keyboard: self).show()
        }
    }
}
