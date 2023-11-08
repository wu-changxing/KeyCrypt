//
//  Keyboard+ModesController.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/19/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

extension KeyboardViewController {
    @objc func openMoreCandidateMode(_: UIButton) {
        candidateModifyView?.dismiss()
        if isMoreCandidateViewOpening {
            moreCandidateView?.dismiss()
        } else {
            MoreCandidateController(keyboard: self).show()
        }
    }

    func openEmojiOrMessageBoard() {
        showCandidateBarIfNeeded()
        emojiInputMode()
    }

    func openPuncKeyboard() {}

    func dismissPuncKeyboard() {}

    func openEnglishKeyboard() {
        isEnglishKeyboardOpening = true
        isEnMode = true
        zhInput?.cleanUp()
        showCandidateBarIfNeeded()
        keyboardNeedHidden(true)
        englishKeyboard = AlphaButtons(keyboard: self, layout: .qwerty, isOrphan: true)
        view.addSubview(englishKeyboard!)
        addConstraintsToKeyboard(englishKeyboard!)
        zhInput?.changeBoard(type: .lower)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.zhInput?.englishModeChanged()
        }
    }

    @objc func dismissEnglishKeyboard() {
        guard isEnglishKeyboardOpening else { return }
        isEnMode = false
        isEnglishKeyboardOpening = false
        KeyboardKey.isPuncDragMode = false
        zhInput?.changeBoard(type: .lower)
        keyboardNeedHidden(false)
        englishKeyboard?.removeFromSuperview()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.zhInput?.englishModeChanged()
        }
    }

    // 打开表情输入键盘
    func emojiInputMode() {
        dismissNumberKeyboard()
        zhInput?.cleanUp()
        emojiBoard = EmojiKeyboardController(keyboard: self)
        updateCandidates([])
        keyboardNeedHidden(true)
        isEmojiBoardOpening = true
        view.addSubview(emojiBoard!)
        addConstraintsToKeyboard(emojiBoard!, full: true)
    }

    // 关闭表情输入键盘
    @objc func emojiInputModeDismiss() {
        guard isEmojiBoardOpening else { return }
        toolBar.isHidden = false
        emojiBoard?.setModeTo(LocalConfigManager.shared!.emojiMode)
        keyboardNeedHidden(false)
        isEmojiBoardOpening = false
        emojiBoard?.removeFromSuperview()
        emojiBoard = nil
    }

    func openNumberKeyboard() {
//        isNumbericBoardOpening = true
//        numbericBoard = NumbericBoard(keyboard: self)
//        zhInput?.cleanUp()
//        zhInput?.displaySmartHint(for: "0")
//        showCandidateBarIfNeeded()
//        keyboardNeedHidden(true)
//        view.addSubview(self.numbericBoard!)
//        addConstraintsToKeyboard(self.numbericBoard!)
//        LightManager.shared.setKeyboard(board: numbericBoard!)
//
    }

    @objc func dismissNumberKeyboard() {
//        guard isNumbericBoardOpening else {return}
//        isNumbericBoardOpening = false
//        KeyboardKey.isPuncDragMode = false
//        puncKey.buttonUp()
//        keyboardNeedHidden(false)
//        numbericBoard?.removeFromSuperview()
//        LightManager.shared.setKeyboard(board: customInterface)
//        numbericBoard = nil
    }

    // 打开更多符号键盘
    @objc func morePuncMode() {
        let view1 = PuncController()
        view1.alpha = 0
        view.addSubview(view1)
        addConstraintsToKeyboard(view1, full: true)
        UIView.animateSpring {
            view1.alpha = 1
        }
    }
}
