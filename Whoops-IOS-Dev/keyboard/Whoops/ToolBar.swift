//
//  ToolBar.swift
//  keyboard
//
//  Created by Aaron on 7/12/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class ToolBar: UIView {
    let privacySwitchButton = UIButton(type: .custom)

    let inviteButton = UIButton(type: .custom)
    let contactButton = UIButton(type: .custom)
    let moreButton = UIButton(type: .custom)
    let redDot = UIView()

    let hideKeyboardButton = UIButton(type: .custom)

    weak var keyboard: KeyboardViewController?

    init(keyboard: KeyboardViewController) {
        super.init(frame: .zero)
        self.keyboard = keyboard
        let buttonImageLeftOffset: CGFloat = 4

        privacySwitchButton.setImage(#imageLiteral(resourceName: "privacy_off"), for: .normal)
        privacySwitchButton.setTitle("隐私模式 ", for: .normal)
        privacySwitchButton.addTarget(self, action: #selector(switchPrivacyMode), for: .touchUpInside)
        setButtons(privacySwitchButton)
        privacySwitchButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: buttonImageLeftOffset, bottom: 0, right: -buttonImageLeftOffset)

        inviteButton.setImage(#imageLiteral(resourceName: "invite"), for: .normal)
        inviteButton.setTitle("邀请 ", for: .normal)
        inviteButton.addTarget(keyboard, action: #selector(keyboard.invitePrivacyChat), for: .touchUpInside)
        setButtons(inviteButton)
        inviteButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: buttonImageLeftOffset, bottom: 0, right: -buttonImageLeftOffset)

        contactButton.setImage(#imageLiteral(resourceName: "contacts"), for: .normal)
        contactButton.setTitle("联系人/群 ", for: .normal)
        contactButton.addTarget(keyboard, action: #selector(keyboard.contactPrivacy), for: .touchUpInside)
        setButtons(contactButton)
        contactButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: buttonImageLeftOffset, bottom: 0, right: -buttonImageLeftOffset)

        moreButton.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        moreButton.setTitle("", for: .normal)
        moreButton.addTarget(keyboard, action: #selector(keyboard.moreTool), for: .touchUpInside)
        moreButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: buttonImageLeftOffset, bottom: 0, right: -buttonImageLeftOffset)
        setButtons(moreButton)

        hideKeyboardButton.setImage(#imageLiteral(resourceName: "closeKeyboard"), for: .normal)
        hideKeyboardButton.addTarget(keyboard, action: #selector(keyboard.dismissKeyboard), for: .touchUpInside)
        setButtons(hideKeyboardButton)

        redDot.isUserInteractionEnabled = false
        redDot.backgroundColor = .red
        redDot.layer.cornerRadius = 2.5
        redDot.layer.masksToBounds = true
        if #available(iOSApplicationExtension 13.0, *) {
            redDot.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        redDot.alpha = 0
        addSubview(redDot)

        layer.masksToBounds = true
        layer.cornerRadius = 8

        NotificationCenter.default.addObserver(self, selector: #selector(changeMode), name: NSNotification.Name.KeyboardModeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(privacyModeChange), name: .privacyModeWillChangeTo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(inviteChanged), name: .inviteViewOpenChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactChanged), name: .contactViewOpenChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moreChanged), name: .moreViewOpenChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(modeChange), name: .KeyboardModeChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func modeChange() {
        let tintColor = darkMode ? UIColor.white : kColor5c5c5c
        inviteButton.imageView?.tintColor = tintColor
        contactButton.imageView?.tintColor = tintColor
        moreButton.imageView?.tintColor = tintColor
        hideKeyboardButton.imageView?.tintColor = tintColor
    }

    @objc func moreChanged() {
        if keyboard?.isMoreSettingViewOpening ?? false {
            moreButton.layer.backgroundColor = darkMode ? UIColor.darkGray.cgColor : UIColor.lightGray.cgColor
        } else {
            moreButton.layer.backgroundColor = nil
        }
    }

    @objc func inviteChanged() {
        if keyboard?.isInviteViewOpening ?? false {
            inviteButton.layer.backgroundColor = darkMode ? UIColor.darkGray.cgColor : UIColor.lightGray.cgColor
        } else {
            inviteButton.layer.backgroundColor = nil
        }
    }

    @objc func contactChanged() {
        if keyboard?.isContactViewOpening ?? false {
            contactButton.layer.backgroundColor = darkMode ? UIColor.darkGray.cgColor : UIColor.lightGray.cgColor
        } else {
            contactButton.layer.backgroundColor = nil
        }
    }

    @objc func privacyModeChange(_ notification: Notification) {
        guard let b = notification.object as? Bool else { return }
        if !b {
            privacySwitchButton.setImage(#imageLiteral(resourceName: "privacy_off"), for: .normal)
            privacySwitchButton.layer.backgroundColor = nil
        } else {
            privacySwitchButton.setImage(#imageLiteral(resourceName: "privacy_on"), for: .normal)
        }
    }

    func setButtons(_ but: UIButton) {
        but.imageView?.contentMode = .scaleAspectFit
        but.titleLabel?.font = kBasic28Font
        but.addTarget(self, action: #selector(buttonUp), for: .touchUpInside)
        but.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        but.layer.cornerRadius = 10
        addSubview(but)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonOffset: CGFloat = 16
        privacySwitchButton.sizeToFit()
        inviteButton.sizeToFit()
        contactButton.sizeToFit()
        moreButton.sizeToFit()
        hideKeyboardButton.sizeToFit()
        let space = (width - privacySwitchButton.width - hideKeyboardButton.width - inviteButton.width - contactButton.width - moreButton.width - 28 - buttonOffset * 5) / 4

        privacySwitchButton.pin.centerLeft(to: anchor.centerLeft).marginLeft(14).marginTop(2).height(26).width(privacySwitchButton.frame.width + buttonOffset)

        inviteButton.pin.right(of: privacySwitchButton, aligned: .center).marginLeft(space).height(of: privacySwitchButton).width(inviteButton.frame.width + buttonOffset)

        contactButton.pin.right(of: inviteButton, aligned: .center).marginLeft(space).height(of: inviteButton).width(contactButton.frame.width + buttonOffset)

        moreButton.pin.right(of: contactButton, aligned: .center).marginLeft(space).height(of: contactButton).width(moreButton.frame.width + buttonOffset)

        hideKeyboardButton.pin.centerRight(to: anchor.centerRight).marginRight(14).marginTop(2).height(26).width(hideKeyboardButton.frame.width + buttonOffset)

        redDot.pin.width(5).height(5).topRight(to: contactButton.anchor.topRight)
    }

    @objc func changeMode(_: Notification) {
        let c = darkMode ? UIColor.white : UIColor.darkText
        privacySwitchButton.setTitleColor(c, for: .normal)
        inviteButton.setTitleColor(c, for: .normal)
        contactButton.setTitleColor(c, for: .normal)
        moreButton.setTitleColor(c, for: .normal)
    }

    func hasNewMsg() {
        DispatchQueue.main.async {
            UIView.animateSpring {
                self.redDot.alpha = 1
            }
        }
    }

    func newMsgRead() {
        DispatchQueue.main.async {
            UIView.animateSpring {
                self.redDot.alpha = 0
            }
        }
    }
}

extension ToolBar {
    @objc func switchPrivacyMode(_ sender: UIButton) {
        guard let keyboard = keyboard else { return }

        if isPrivacyModeOn, Platform.fromClientID(keyboard.clientID) != nil {
            keyboard.closePrivacyMode()
        } else {
            keyboard.openPrivacyMode(sender: sender)
        }
    }

    @objc func buttonDown(_ sender: UIButton) {
        sender.layer.backgroundColor = darkMode ? UIColor.gray.cgColor : UIColor(rgb: kToolBarButtonDownColor).cgColor
    }

    @objc func buttonUp(_: UIButton) {
//        if sender == contactButton || sender == moreButton {return}
//        sender.layer.backgroundColor = nil
    }
}
