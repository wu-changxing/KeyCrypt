//
//  Keyboard+Gestures.swift
//  LoginputKeyboard
//
//  Created by Aaron on 9/23/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import AudioToolbox
import UIKit

extension KeyboardViewController {
    @objc func continueDelete(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            isContinueDelete = true
            continueDeleteTimer = Timer.scheduledTimer(timeInterval: 0.08, target: self, selector: #selector(vback), userInfo: nil, repeats: true)
        } else if sender.state == .ended || sender.state == .cancelled {
            continueDeleteTimer.invalidate()
            isContinueDelete = false
            vback()
        }
    }

    @objc func softReturn(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if ConfigManager.shared.clickVibrate {
                if keyboardHasFullAccess(), iphone7UP {
                    let g = UIImpactFeedbackGenerator(style: .medium)
                    g.impactOccurred()
                } else {
                    AudioServicesPlaySystemSound(1519)
                    // Fallback on earlier versions
                }
            }
            let r = ConfigManager.shared.compatibleReturn ? "\r" : "\u{2028}"
            KeyboardViewController.inputProxy?.insertText(str: r) // 这个换行符来自 Pages 里的“软回车”，比 /r 更具有兼容性

            guard let b = pendingKey else { return }
            b.buttonUp()
            pendingKey = nil
        }
    }

    @objc func capsLock(_: UITapGestureRecognizer) {
        guard ConfigManager.shared.shiftMode == kShiftModeNone || !engineHasBuffer else { return }
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "锁定大写")
        DispatchQueue.global(qos: .userInitiated).async {
            self.zhInput?.changeBoard(type: .upper)
        }
        CapsLock = true
        pendingKey = nil
    }

    @objc func cleanInputBuffer() {
        let ct = CodeTable(Code: zhInput!.inputBuffer)
        zhInput?.tracebackStack.append(ct)
        zhInput?.cleanUp()
    }

    @objc func traceback() {
        zhInput?.doTraceback()
    }

    @objc func tapBufferArea(_: Any) {
        let b = KeyboardKey(tag: kReturnButtonID, isOrphan: true)
        b.setTitle("换行", for: .normal)
        keyboardKeyUp(b)
    }

    @objc func longPressChangeLayout(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        if let b = pendingKey {
            b.buttonUp()
            pendingKey = nil
        }
        let sharedDefaults = UserDefaults(suiteName: kGroupIdentifier)
        KeyboardKey.keyboardButtons.removeAll()
        customInterface.removeFromSuperview()

        if keyboardLayout == .qwerty {
            keyboardLayout = .key9
            customInterface = NKeyButtons(keyboard: self, layout: keyboardLayout)

            sharedDefaults?.set(8, forKey: "Layout")
        } else {
            dismissEnglishKeyboard()
            keyboardLayout = .qwerty
            if deviceName == .iPad {
                customInterface = iPadAlphaButtons(keyboard: self, layout: keyboardLayout)
            } else {
                customInterface = AlphaButtons(keyboard: self, layout: keyboardLayout)
            }
            sharedDefaults?.set(0, forKey: "Layout")
        }
        sharedDefaults?.synchronize()
        addConstraintsToKeyboard(customInterface)
        view.addSubview(customInterface)
        CapsLock = false
        keyboardMode = .lower
        isEnMode = false
        okToUse = true
        zhInput = ZhInput(self)
        zhInput?.changeBoard(type: .lower)
    }
}
