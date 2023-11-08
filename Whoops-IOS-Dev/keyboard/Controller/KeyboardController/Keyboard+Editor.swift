//
// Created by Aaron on 2018-11-20.
// Copyright (c) 2018 Aaron. All rights reserved.
//

import AudioToolbox
import UIKit

extension KeyboardViewController {
    func openEditor() {
//        let view1 = EditorController()
//        view1.alpha = 0
//        self.view.addSubview(view1)
//        addConstraintsToKeyboard(view1, full: true)
//        UIView.animateSpring {
//            view1.alpha = 1
//        }
    }

    @objc func longPressChangeKeyboardHeight(_ sender: UILongPressGestureRecognizer) {
        // MARK: one hand

        guard sender.state == .began else { return }
        pendingKey = nil
        if let list = KeyboardKey.keyboardButtons[KeyboardKey.currentKeyboardKeyID] {
            for b in list {
                b.buttonUp()
            }
        }

        if ConfigManager.shared.clickVibrate {
            if keyboardHasFullAccess(), iphone7UP {
                let g = UIImpactFeedbackGenerator(style: .heavy)
                g.impactOccurred()
            } else {
                AudioServicesPlaySystemSound(1519)
                // Fallback on earlier versions
            }
        }

        // ---特殊处理长按a l 和 空格

        let location = sender.location(ofTouch: 0, in: sender.view)

        if let list = KeyboardKey.keyboardButtons[leftHandButtonID] {
            for but in list where but.point(inside: sender.view!.convert(location, to: but), with: nil) {
                oneHandMode(.left)
                return
            }
        }

        if let list = KeyboardKey.keyboardButtons[rightHandButtonID] {
            for but in list where but.point(inside: sender.view!.convert(location, to: but), with: nil) {
                oneHandMode(.right)
                return
            }
        }

        if ConfigManager.shared.spaceUpThink, let list = KeyboardKey.keyboardButtons[126] {
            for but in list where but.point(inside: sender.view!.convert(location, to: but), with: nil) {
                insertText(str: " ")
                return
            }
        }

        // ----特殊处理完毕

        showCandidateBarIfNeeded()
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "快捷面板已打开")
        isQuickEditorFunctionsOpening = true
        zhInput?.cleanUp()
        guard isVoiceOverOn else {
            openEditor()
            return
        }

        let kView = keyboardAdjustViewVO
        addConstraintsToKeyboard(kView!, full: true)
        let value = Float(heightConstraint.constant)
        slider.value = value
        label3.text = String(Int(value))
        label4.text = String(Int(value))
        if darkMode {
            label3.textColor = UIColor.white
            label4.textColor = UIColor.white
        } else {
            label3.textColor = UIColor.darkText
            label4.textColor = UIColor.darkText
        }
        //            if configManager.spPlan > 0 {tmpRe.isEnabled = false}
        var content = ""
        if let before = textDocumentProxy.documentContextBeforeInput { content = before }
        if let after = textDocumentProxy.documentContextAfterInput { content += after }

        if ConfigManager.shared.revealCode { tmpRe?.setTitle("临时反查:开", for: .normal) }
        if ConfigManager.shared.s2t { tmp2T.setTitle("临时出繁:开", for: .normal) }

        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            [unowned self] in
            self.view.addSubview(kView!)
        }, completion: nil)
    }
}
