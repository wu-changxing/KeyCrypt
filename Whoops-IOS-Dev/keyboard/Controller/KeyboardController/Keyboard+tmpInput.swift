//
//  Keyboard+tmpInput.swift
//  keyboard
//
//  Created by Aaron on 11/23/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

var isTempInputing = false
var isKeyboardTempHiding = false

extension KeyboardViewController {
    func hideKeyboardTemp() {
        isKeyboardTempHiding = true
        zhInput?.changeBoard(type: .lower)
        UIView.animateSpring {
            self.whoopsInputBar?.isHidden = true
            self.chatHistoryView?.isHidden = true
            self.customInterface.center.y += ConfigManager.shared.keyboardHeight
            self.candidateRowView.center.y += ConfigManager.shared.keyboardHeight
            self.transferView?.pin.all()
        }
    }

    func showKeyboardNormal() {
        guard isKeyboardTempHiding else { return }
        isTempInputing = false
        isKeyboardTempHiding = false
        toolBar.isHidden = false
        UIView.animateSpring {
            self.whoopsInputBar?.isHidden = false
            self.chatHistoryView?.isHidden = false
            self.addConstraintsToKeyboard(self.customInterface)
        }
    }

    func showKeyboard(tmpInput: TempInputBar?) {
        isTempInputing = true
        toolBar.isHidden = true

        if let t = tmpInput {
            for v in view.subviews where v.tag == 892 {
                v.removeFromSuperview()
            }
            // 如果已经有一个临时输入框了，就取消它再显示新的
            t.tag = 892
            t.cancelButton.addTarget(self, action: #selector(dismissTempInputBar), for: .touchUpInside)
            t.confirmButton.addTarget(self, action: #selector(dismissTempInputBar), for: .touchUpInside)

            if isKeyboardTempHiding {
                assert(false)
            } else {
                t.alpha = 0

                view.addSubview(t)
                t.pin.horizontally().height(40).top(180 - 40)
                t.center.y += 20
                UIView.animateSpring {
                    t.alpha = 1
                    t.center.y -= 20
                } completion: { b in
                    guard b else { return }
                    _ = t.becomeFirstResponder()
                }
            }

        } else {
            UIView.animateSpring {
                self.transferView?.pin.top().left().right().bottom(ConfigManager.shared.keyboardHeight)
                if let v = self.commonInputProxy as? CYMTextView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.transferView?.contentView.scrollRectToVisible(v.frame, animated: true)
                    }
                }
                self.addConstraintsToKeyboard(self.customInterface)
            }
        }
    }

    @objc func dismissTempInputBar(_ sender: UIButton) {
        let bar = sender.superview!
        _ = bar.resignFirstResponder()
        isTempInputing = false
        toolBar.isHidden = false
        UIView.animateSpring {
            bar.center.y += 20
            bar.alpha = 0
        } completion: { b in
            guard b else { return }
            bar.removeFromSuperview()
            if let bar = self.whoopsInputBar, !bar.isHidden, !bar.inputField.isHidden {
                bar.inputField.becomeFirstResponder()
            }
        }
    }
}
