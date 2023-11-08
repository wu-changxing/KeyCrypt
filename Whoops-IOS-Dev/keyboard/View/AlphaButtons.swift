//
//  AlphaButtons.swift
//  fly
//
//  Created by Aaron on 9/17/17.
//  Copyright © 2017 Aaron. All rights reserved.
//

import UIKit

final class AlphaButtons: KeyboardButtonsAbstract {
    lazy var emoji: KeyboardKey = {
        let b = KeyboardKey(tag: kEmojiButtonID, isOrphan: true)
        b.setTitle(":)", for: .normal)
        b.titleLabel.font = .systemFont(ofSize: 16)
        return b

    }()

    override func keyboardDidLoad() {
        if isOrphan {
            num.removeSelfFromButtons()
            num.setTitle("返回", for: .normal)
            num.tag = 1
        }
        switch keyboardLayout {
        case .qwerty:
            row1Buttons = [q, w, e, r, t, y, u, i, o, p]
            row2Buttons = [a, s, d, f, g, h, j, k, l]
            row3Buttons = [shift, z, x, c, v, b, n, m, delete]
            row4Buttons = [num, earth, key0, blankSpace, emoji, ret]
        case .key9:
            break
        }
        if let keyboard = keyboard {
            keyboard.earthKey = earth
            keyboard.cleanButton = delete
            keyboard.shiftKey = shift
            keyboard.returnKey = ret
            keyboard.puncKey = num

//            settingGestures(keyboard: keyboard)
        }
    }

    func settingGestures(keyboard: KeyboardViewController) {
        guard isVoiceOverOn else { return }

        let longPressContinueDelete = UILongPressGestureRecognizer()
        let swipeLeftClear = UISwipeGestureRecognizer()
        let swipeLeftTraceback = UISwipeGestureRecognizer()
        let doubleTapCapslock = UITapGestureRecognizer()
        let longPressSoftReturn = UILongPressGestureRecognizer()

        longPressSoftReturn.addTarget(keyboard, action: #selector(keyboard.softReturn))
        longPressContinueDelete.addTarget(keyboard, action: #selector(keyboard.continueDelete))
        swipeLeftClear.addTarget(keyboard, action: #selector(keyboard.cleanInputBuffer))
        swipeLeftTraceback.addTarget(keyboard, action: #selector(keyboard.traceback))
        doubleTapCapslock.addTarget(keyboard, action: #selector(keyboard.capsLock))

        doubleTapCapslock.numberOfTapsRequired = 2
        doubleTapCapslock.delaysTouchesEnded = false
        swipeLeftClear.direction = .left
        swipeLeftTraceback.direction = .left

        ret.addGestureRecognizer(longPressSoftReturn)
        ret.addGestureRecognizer(swipeLeftTraceback)
        delete.addGestureRecognizer(longPressContinueDelete)
        delete.addGestureRecognizer(swipeLeftClear)
        shift.addGestureRecognizer(doubleTapCapslock)
    }

    override func didMoveToSuperview() {
        if isOrphan {
            oldDeleteButton = keyboard?.cleanButton
            oldReturnButton = keyboard?.returnKey
            oldEarthButton = keyboard?.earthKey
            oldShiftButton = keyboard?.shiftKey
            oldPuncButton = keyboard?.puncKey
            num.addTarget(keyboard, action: #selector(keyboard!.dismissEnglishKeyboard), for: .touchUpInside)
        }

        keyboard?.earthKey = earth
        keyboard?.cleanButton = delete
        keyboard?.shiftKey = shift
        keyboard?.returnKey = ret
        keyboard?.puncKey = num
    }

    private var oldDeleteButton: KeyboardKey?
    private var oldReturnButton: KeyboardKey?
    private var oldEarthButton: KeyboardKey?
    private var oldShiftButton: KeyboardKey?
    private var oldPuncButton: KeyboardKey?

    override func removeFromSuperview() {
        super.removeFromSuperview()

        if isOrphan {
            keyboard?.cleanButton = oldDeleteButton
            keyboard?.returnKey = oldReturnButton

            keyboard?.earthKey = oldEarthButton
            keyboard?.shiftKey = oldShiftButton
            keyboard?.puncKey = oldPuncButton

            for b in row1Buttons {
                b.removeSelfFromButtons()
            }
            for b in row2Buttons {
                b.removeSelfFromButtons()
            }
            for b in row3Buttons {
                b.removeSelfFromButtons()
            }
            for b in row4Buttons {
                b.removeSelfFromButtons()
            }
        }
    }

    override func layoutSubviews() {
        if frame.width == 0, isOrphan {
            frame = CGRect(x: 0, y: 42,
                           width: UIScreen.main.bounds.width,
                           height: ConfigManager.shared.keyboardHeight - 42)
            if frame.size.width >= 660 || frame.size.width == 0, !isPortrait {
                let x = (frame.size.width - 660) / 2
                frame.size.width = 660
                frame.origin.x += x
            } else if isPortrait {
                frame.size.width = UIScreen.main.bounds.width
            }
        }
//        print(frame)

        row1.frame = CGRect(x: 0, y: 0, width: frame.width, height: row1Height)
        row2.frame = CGRect(x: 0, y: row1Height, width: frame.width, height: row2Height)
        row3.frame = CGRect(x: 0, y: row1Height + row2Height, width: frame.width, height: row3Height)
        row4.frame = CGRect(x: 0, y: row1Height + row2Height + row3Height, width: frame.width, height: row4Height)
//        print("---AlphaButtons-frame->\(self.frame)")
        switch keyboardLayout {
        case .qwerty: layoutForQwerty()
        case .key9: break
        }
        backButton.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        touchLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
}

extension AlphaButtons {
    func layoutBottomLine() {
        let ratio: CGFloat = isPortrait ? 2.8 : 2.2
        ret.frame = CGRect(x: frame.width - buttonWidth * ratio - row4RL, y: row4Top, width: buttonWidth * ratio, height: row4Height - row4Top - row4Bottom)
        emoji.frame = CGRect(x: ret.left - buttonWidth - basicSpacing, y: row4Top, width: buttonWidth, height: ret.height)

        if isX || isOrphan {
            num.frame = CGRect(x: row4RL, y: row4Top, width: ret.width, height: row4Height - row4Top - row4Bottom)
            earth.frame = CGRect.zero
            key0.frame = CGRect(x: num.right + basicSpacing, y: row4Top, width: buttonWidth, height: num.height)
            blankSpace.frame = CGRect(x: key0.right + basicSpacing, y: row4Top, width: frame.width - key0.right - emoji.width - ret.width - 21, height: num.height)
        } else {
            num.frame = CGRect(x: row4RL, y: row4Top, width: buttonWidth * 1.3, height: row4Height - row4Top - row4Bottom)
            earth.frame = CGRect(x: row4RL + buttonWidth * 1.3 + basicSpacing, y: row4Top, width: buttonWidth * 1.3, height: row4Height - row4Top - row4Bottom)
            key0.frame = CGRect(x: earth.right + basicSpacing, y: row4Top, width: buttonWidth, height: earth.height)
            blankSpace.frame = CGRect(x: key0.right + basicSpacing, y: row4Top, width: frame.width - key0.right - emoji.width - ret.width - 21, height: num.height)
        }
    }

    func layoutForQwerty() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row2RL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            if b.tag == shift.tag {
                b.frame = CGRect(x: 3, y: row3Top, width: buttonWidth * 1.35, height: row3Height - row3Top - row3Bottom)
            } else if b.tag == delete.tag {
                b.frame = CGRect(x: frame.width - buttonWidth * 1.35 - 3, y: row3Top, width: buttonWidth * 1.35, height: row3Height - row3Top - row3Bottom)
            } else {
                b.frame = CGRect(x: (CGFloat(index - 1) * (buttonWidth + basicSpacing)) + row3RL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
            }
        }
        layoutBottomLine()
    }

    func layoutForDvorak() {
        for (index, b) in row1Buttons.enumerated() {
            if b.tag == delete.tag {
                b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL, y: row1Top, width: buttonWidth * 2, height: row1Height - row1Top - row1Bottom)
                continue
            }
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL + buttonWidth + 20, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row2RL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row3RL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
        }
        layoutBottomLine()
    }

    func layoutForColemak() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row2RL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            if b.tag == shift.tag {
                b.frame = CGRect(x: 3, y: row3Top, width: buttonWidth * 1.35, height: row3Height - row3Top - row3Bottom)
            } else if b.tag == delete.tag {
                b.frame = CGRect(x: frame.width - buttonWidth * 1.35 - 3, y: row3Top, width: buttonWidth * 1.35, height: row3Height - row3Top - row3Bottom)
            } else {
                b.frame = CGRect(x: (CGFloat(index - 1) * (buttonWidth + basicSpacing)) + row3RL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
            }
        }
        layoutBottomLine()
    }

    func layoutForWorkman() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row2RL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            if b.tag == shift.tag {
                b.frame = CGRect(x: 3, y: row3Top, width: buttonWidth * 1.35, height: row3Height - row3Top - row3Bottom)
            } else if b.tag == delete.tag {
                b.frame = CGRect(x: frame.width - buttonWidth * 1.35 - 3, y: row3Top, width: buttonWidth * 1.35, height: row3Height - row3Top - row3Bottom)
            } else {
                b.frame = CGRect(x: (CGFloat(index - 1) * (buttonWidth + basicSpacing)) + row3RL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
            }
        }
        layoutBottomLine()
    }

    func layoutForMac() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row1RL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + row2RL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            if b.tag == shift.tag {
                b.frame = CGRect(x: row3RL, y: row3Top, width: (buttonWidth * 0.8).rounded(), height: row3Height - row3Top - row3Bottom)
            } else if b.tag == delete.tag {
                b.frame = CGRect(x: m.frame.maxX + basicSpacing * 3, y: row3Top, width: frame.width - (m.frame.maxX + basicSpacing * 3 + row3RL), height: row3Height - row3Top - row3Bottom)
            } else {
                b.frame = CGRect(x: (CGFloat(index - 1) * (buttonWidth + basicSpacing)) + shift.width + basicSpacing + row3RL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
            }
        }
        layoutBottomLine()
    }
}

extension AlphaButtons {
    var basicSpacing: CGFloat { return 6 }
    var row1RL: CGFloat { return 3 }
    var row2RL: CGFloat {
        switch keyboardLayout {
        case .qwerty: return ((width - (buttonWidth * 9 + basicSpacing * 8)) / 2).rounded()
        case .key9:
            return 0
        }
    }

    var row3RL: CGFloat {
        switch keyboardLayout {
        case .qwerty: return ((width - (buttonWidth * 7 + basicSpacing * 6)) / 2).rounded()
        case .key9:
            return 0
        }
    }

    var row4RL: CGFloat { return 3 }
    var row1Top: CGFloat { return isPortrait ? 10 : 8 }
    var row1Bottom: CGFloat { return isPortrait ? 6 : 4 }
    var row2Top: CGFloat { return isPortrait ? 6 : 4 }
    var row2Bottom: CGFloat { return isPortrait ? 6 : 4 }
    var row3Top: CGFloat { return isPortrait ? 6 : 4 }
    var row3Bottom: CGFloat { return isPortrait ? 6 : 4 }
    var row4Top: CGFloat { return isPortrait ? 5 : 3 }
    var row4Bottom: CGFloat { return isPortrait ? 4 : 3 }
    var row1Height: CGFloat { return frame.height / 4 + 4 }
    var row2Height: CGFloat { return frame.height / 4 }
    var row3Height: CGFloat { return frame.height / 4 }
    var row4Height: CGFloat { return frame.height / 4 - 4 }
    var buttonWidth: CGFloat { return (frame.width / 10 - 6) }
}

extension AlphaButtons {}
