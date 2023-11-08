//
//  Keyboard+OneHand.swift
//  LoginputKeyboard
//
//  Created by Aaron on 5/16/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

enum OneHand: Int {
    case none = 0, left, right
}

import AudioToolbox
import UIKit
let oneHandButton = UIButton()

// MARK: one hand

extension KeyboardViewController {
    var leftHandButtonID: KeyboardKeyID {
        return 100
    }

    var rightHandButtonID: KeyboardKeyID {
        let rTag = 111

        return rTag
    }

    func oneHandMode(_ mode: OneHand) {
        showCandidateBarIfNeeded()
        let currentMode = LocalConfigManager.shared!.handMode
        customInterface.removeConstraints(customInterface.constraints)
        switch mode {
        case .none:
            candidateModifyView?.dismiss()
            if isMoreCandidateViewOpening { openMoreCandidateMode(oneHandButton) }
            LocalConfigManager.shared?.setHandMode(0)
            for subview in view.subviews {
                if subview == customInterface {
                    addConstraintsToKeyboard(subview)
                }

                if subview == emojiBoard {
                    addConstraintsToKeyboard(subview)
                    break
                }
                if subview == numbericBoard {
                    addConstraintsToKeyboard(subview)
                    break
                }
                if subview is PuncController {
                    addConstraintsToKeyboard(subview, full: true)
                    break
                }
            }

        case .left:
            switch currentMode {
            case 0:
                LocalConfigManager.shared?.setHandMode(1)
                addConstraintsToKeyboard(customInterface)

            case 1:
                LocalConfigManager.shared?.setHandMode(0)
                addConstraintsToKeyboard(customInterface)

            case 2:
                LocalConfigManager.shared?.setHandMode(1)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
                    self.addConstraintsToKeyboard(self.customInterface)
                }, completion: nil)
                UIView.animate(withDuration: 0.2, animations: {
                    self.addConstraintsToKeyboard(self.customInterface)
                })
            default: break
            }
        case .right:
            switch currentMode {
            case 0:
                LocalConfigManager.shared?.setHandMode(2)
                addConstraintsToKeyboard(customInterface)

            case 1:
                LocalConfigManager.shared?.setHandMode(2)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
                    self.addConstraintsToKeyboard(self.customInterface)
                }, completion: nil)

            case 2:
                LocalConfigManager.shared?.setHandMode(0)
                addConstraintsToKeyboard(customInterface)

            default: break
            }
        }
    }

    @objc func outOneHand(_: UIButton) {
        if ConfigManager.shared.clickVibrate {
            if iphone7UP, keyboardHasFullAccess() {
                let g = UIImpactFeedbackGenerator(style: .heavy)
                g.impactOccurred()
            } else {
                AudioServicesPlaySystemSound(1519)
                // Fallback on earlier versions
            }
        }
        oneHandMode(.none)
    }

    func updateOneHandOutButton() {
        oneHandButton.removeFromSuperview()
        let currentMode = OneHand(rawValue: LocalConfigManager.shared!.handMode)!
        guard currentMode != .none else {
            return
        }
        oneHandButton.addTarget(self, action: #selector(outOneHand), for: .touchUpInside)
        let frame = customInterface.frame
        let width: CGFloat = (view.width - frame.width - 10) / 2
        let offset = width
        let height = frame.height
        oneHandButton.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        oneHandButton.accessibilityLabel = "退出单手键盘"
        view.insertSubview(oneHandButton, at: 1)
        switch currentMode {
        case .none: break
        case .left:
            oneHandButton.setImage(#imageLiteral(resourceName: "rightAshape"), for: .normal)
            oneHandButton.contentHorizontalAlignment = .right
            oneHandButton.alpha = darkMode ? 0.5 : 1
            oneHandButton.frame = CGRect(x: frame.maxX + offset, y: frame.minY, width: width, height: height)
        case .right:
            oneHandButton.setImage(#imageLiteral(resourceName: "leftAshape"), for: .normal)
            oneHandButton.contentHorizontalAlignment = .left
            oneHandButton.alpha = darkMode ? 0.5 : 1
            oneHandButton.frame = CGRect(x: frame.minX - width - offset, y: frame.minY, width: width, height: height)
        }
    }
}
