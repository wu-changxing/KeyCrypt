//
//  iPadAlphaButtons.swift
//  fly
//
//  Created by Aaron on 9/19/17.
//  Copyright © 2017 Aaron. All rights reserved.
//

import UIKit

final class iPadAlphaButtons: KeyboardButtonsAbstract {
//    var ret:KeyboardKey = KeyboardKey( tag:  kReturnButtonID)

    var punc1: KeyboardKey = { let b = KeyboardKey(tag: 128); b.setTitle("，", for: .normal); return b }()
    var punc2: KeyboardKey = { let b = KeyboardKey(tag: 128); b.setTitle("。", for: .normal); return b }()
    var punc3: KeyboardKey = { let b = KeyboardKey(tag: 128); b.setTitle("、", for: .normal); return b }()
    var shift2 = KeyboardKey(tag: 2)
    var num2: KeyboardKey = { let b = KeyboardKey(tag: kNumberButtonID); b.setTitle("123", for: .normal); return b }()
    var dismissKey: KeyboardKey = {
        let b = KeyboardKey(tag: kiPadDismissButtonID)
        b.accessibilityLabel = "收起键盘"
        return b
    }()

    override func keyboardDidLoad() {
        switch keyboardLayout {
        case .qwerty:
            row1Buttons = [q, w, e, r, t, y, u, i, o, p, delete]
            row2Buttons = [a, s, d, f, g, h, j, k, l, ret]
            row3Buttons = [shift, z, x, c, v, b, n, m, punc1, punc2]
            row4Buttons = [num, earth, blankSpace, num2, dismissKey]
        case .key9:
            break
        }
        if #available(iOSApplicationExtension 12, *) {
            row3Buttons.append(shift2)
        } else {
            row3Buttons.append(punc3)
        }
        if let keyboard = keyboard {
//            settingGestures(keyboard: keyboard)
            keyboard.earthKey = earth
            keyboard.cleanButton = delete
            keyboard.shiftKey = shift
            keyboard.ipadShortCutButton2 = shift2
            keyboard.returnKey = ret
            keyboard.puncKey = num
            keyboard.puncKey2 = num2
            keyboard.ipadDismissButton = dismissKey
        }
    }

    func settingGestures(keyboard: KeyboardViewController) {
        guard isVoiceOverOn else { return }

        let longPressContinueDelete = UILongPressGestureRecognizer()
        let swipeLeftClear = UISwipeGestureRecognizer()
        let doubleTapCapslock = UITapGestureRecognizer()
        let doubleTapCapslock2 = UITapGestureRecognizer()
        let longPressSoftReturn = UILongPressGestureRecognizer()
        let swipeLeftTraceback = UISwipeGestureRecognizer()

        longPressSoftReturn.addTarget(keyboard, action: #selector(keyboard.softReturn))
        longPressContinueDelete.addTarget(keyboard, action: #selector(keyboard.continueDelete))
        swipeLeftClear.addTarget(keyboard, action: #selector(keyboard.cleanInputBuffer))
        doubleTapCapslock.addTarget(keyboard, action: #selector(keyboard.capsLock))
        doubleTapCapslock2.addTarget(keyboard, action: #selector(keyboard.capsLock))
        swipeLeftTraceback.addTarget(keyboard, action: #selector(keyboard.traceback))

        doubleTapCapslock.numberOfTapsRequired = 2
        doubleTapCapslock.delaysTouchesEnded = false
        doubleTapCapslock2.numberOfTapsRequired = 2
        doubleTapCapslock2.delaysTouchesEnded = false
        swipeLeftClear.direction = .left
        swipeLeftTraceback.direction = .left

        ret.addGestureRecognizer(longPressSoftReturn)
        ret.addGestureRecognizer(swipeLeftTraceback)
        delete.addGestureRecognizer(longPressContinueDelete)
        delete.addGestureRecognizer(swipeLeftClear)
        shift.addGestureRecognizer(doubleTapCapslock)
        shift2.addGestureRecognizer(doubleTapCapslock2)
    }

    override func didMoveToSuperview() {
        keyboard?.earthKey = earth
        keyboard?.cleanButton = delete
        keyboard?.shiftKey = shift
        keyboard?.ipadShortCutButton2 = shift2
        keyboard?.returnKey = ret
        keyboard?.puncKey = num
        keyboard?.puncKey2 = num2
        keyboard?.ipadDismissButton = dismissKey
    }

    override func layoutSubviews() {
        if frame.width == 0 {
            frame = CGRect(x: 0, y: 50,
                           width: UIScreen.main.bounds.width,
                           height: ConfigManager.shared.keyboardHeight - 50)
        }
        row1.frame = CGRect(x: 0, y: 0, width: frame.width, height: row1Height)
        row2.frame = CGRect(x: 0, y: row1Height, width: frame.width, height: row2Height)
        row3.frame = CGRect(x: 0, y: row1Height + row2Height, width: frame.width, height: row3Height)
        row4.frame = CGRect(x: 0, y: row1Height + row2Height + row3Height, width: frame.width, height: row4Height)
//        print("---AlphaButtons-frame->\(self.frame)")
        switch keyboardLayout {
        case .qwerty: layoutForQwerty()
        case .key9:
            break
        }
        backButton.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        touchLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
}

extension iPadAlphaButtons {
    func layoutBottomLine() {
        num.frame = CGRect(x: row4RL, y: row4Top, width: buttonWidth, height: row4Height - row4Top - row4Bottom)
        earth.frame = CGRect(x: row4RL + buttonWidth + basicSpacing, y: row4Top, width: buttonWidth, height: row4Height - row4Top - row4Bottom)
        dismissKey.frame = CGRect(x: row4.frame.width - buttonWidth - row4RL, y: row4Top, width: buttonWidth, height: row4Height - row4Top - row4Bottom)
        num2.frame = CGRect(x: row4.frame.width - buttonWidth * 1.5 - dismissKey.frame.width - basicSpacing - row4RL, y: row4Top, width: buttonWidth * 1.5, height: row4Height - row4Top - row4Bottom)
        blankSpace.frame = CGRect(x: row4RL + buttonWidth * 2 + basicSpacing * 2, y: row4Top, width: num2.frame.minX - num.frame.width - earth.frame.width - row4RL - basicSpacing * 3, height: row4Height - row4Top - row4Bottom)
    }

    func layoutForQwerty() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            if b.tag == ret.tag, keyboardLayout == .qwerty {
                b.frame = CGRect(x: l.frame.maxX + basicSpacing, y: row2Top, width: frame.width - l.frame.maxX - (basicSpacing + row1RL), height: row2Height - row2Top - row2Bottom)
                continue
            }
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row2RL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row3RL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
        }
        layoutBottomLine()
    }

    func layoutForDvorak() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row2RL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            if b.tag == shift.tag {
                b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row3RL, y: row3Top, width: buttonWidth * 1.5, height: row3Height - row3Top - row3Bottom)
                continue
            }
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row3RL + buttonWidth * 0.5, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
        }
        layoutBottomLine()
    }

    func layoutForMac() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            if b.tag == ret.tag {
                b.frame = CGRect(x: l.frame.maxX + basicSpacing, y: row2Top, width: frame.width - l.frame.maxX - (basicSpacing + row1RL), height: row2Height - row2Top - row2Bottom)
                continue
            }
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row2RL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            if b == shift {
                b.frame = CGRect(x: row1RL, y: row3Top, width: buttonWidth * 0.8, height: row3Height - row3Top - row3Bottom)
            } else if b == shift2 || b == punc3 {
                b.frame = CGRect(x: punc2.frame.maxX + basicSpacing, y: row3Top, width: width - (punc2.frame.maxX + basicSpacing + row1RL), height: row3Height - row3Top - row3Bottom)
            } else {
                b.frame = CGRect(x: (CGFloat(index - 1) * (buttonWidth + basicSpacing)) + shift.width + basicSpacing + row3RL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
            }
        }
        layoutBottomLine()
    }
}

extension iPadAlphaButtons {
    var basicSpacing: CGFloat {
        return isPortrait ? 12 : 14
    }

    var row1RL: CGFloat { return frame.width < 500 ? 3 : 8 }
    var row2RL: CGFloat {
        switch keyboardLayout {
        case .qwerty: return frame.width < 500 ? 10 : 40
        case .key9:
            return 0
        }
    }

    var row3RL: CGFloat { return frame.width < 500 ? 3 : 8 }
    var row4RL: CGFloat { return frame.width < 500 ? 3 : 8 }
    var row1Top: CGFloat { return isPortrait ? 5 : 6 }
    var row1Bottom: CGFloat { return isPortrait ? 5 : 6 }
    var row2Top: CGFloat { return isPortrait ? 5 : 6 }
    var row2Bottom: CGFloat { return isPortrait ? 5 : 6 }
    var row3Top: CGFloat { return isPortrait ? 5 : 6 }
    var row3Bottom: CGFloat { return isPortrait ? 5 : 6 }
    var row4Top: CGFloat { return isPortrait ? 5 : 6 }
    var row4Bottom: CGFloat { return 8 }
    var row1Height: CGFloat { return (frame.height - 1) / 4 }
    var row2Height: CGFloat { return (frame.height - 1) / 4 }
    var row3Height: CGFloat { return (frame.height - 1) / 4 }
    var row4Height: CGFloat { return (frame.height - 1) / 4 }
    var buttonWidth: CGFloat { return (frame.width - 2) / 11 - basicSpacing }
}
