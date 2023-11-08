//
//  NineKeyButtons.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/16/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

final class NKeyButtons: KeyboardButtonsAbstract {
    lazy var tableView = UITableView()
    let commonFont = UIFont(name: "PingFangSC-Regular", size: 16)

    lazy var bpoint: KeyboardKey = {
        let b = KeyboardKey(tag: 100, isOrphan: true)
        b.setTitle(".", for: .normal)
        b.titleLabel.font = commonFont
        return b

    }()

    lazy var at: KeyboardKey = {
        let b = KeyboardKey(tag: 1, isOrphan: true)
        b.titleLabel.font = commonFont
        b.setTitle("@", for: .normal)
        return b

    }()

    lazy var more: KeyboardKey = {
        let b = KeyboardKey(tag: 1, isOrphan: true)
        b.titleLabel.font = commonFont
        b.setTitle("符", for: .normal)
        return b

    }()

    lazy var emoji: KeyboardKey = {
        let b = KeyboardKey(tag: kEmojiButtonID, isOrphan: true)
        b.setTitle(":)", for: .normal)
        b.titleLabel.font = .systemFont(ofSize: 16)
        return b

    }()

    override func keyboardDidLoad() {
        key0.titleLabel.font = commonFont
        switch keyboardLayout {
        case .key9:
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none

            tableView.register(NineKeyPyCell.self, forCellReuseIdentifier: "cell")
            tableView.showsVerticalScrollIndicator = false

            row1Buttons = [key1, key2, key3, delete]
            row2Buttons = [key4, key5, key6, emoji]
            row3Buttons = [key7, key8, key9, more]
            row4Buttons = [num, earth, key0, blankSpace, bpoint, ret]

            addSubview(tableView)

        default: break
        }

        if let keyboard = keyboard {
            keyboard.earthKey = earth
            keyboard.cleanButton = delete
            keyboard.returnKey = ret
            keyboard.puncKey = num
            keyboard.shiftKey = more

//            settingGestures(keyboard: keyboard)
        }
    }

    override func keyboardAfterLoad() {
        guard keyboardLayout == .key9 else { return }
        bringSubviewToFront(tableView)
    }

    func settingGestures(keyboard: KeyboardViewController) {
        guard isVoiceOverOn else { return }

        let longPressContinueDelete = UILongPressGestureRecognizer()
        let swipeLeftClear = UISwipeGestureRecognizer()
        let swipeLeftTraceback = UISwipeGestureRecognizer()
        let longPressSoftReturn = UILongPressGestureRecognizer()

        longPressSoftReturn.addTarget(keyboard, action: #selector(keyboard.softReturn))
        longPressContinueDelete.addTarget(keyboard, action: #selector(keyboard.continueDelete))
        swipeLeftClear.addTarget(keyboard, action: #selector(keyboard.cleanInputBuffer))
        swipeLeftTraceback.addTarget(keyboard, action: #selector(keyboard.traceback))

        swipeLeftClear.direction = .left
        swipeLeftTraceback.direction = .left

        ret.addGestureRecognizer(longPressSoftReturn)
        ret.addGestureRecognizer(swipeLeftTraceback)
        delete.addGestureRecognizer(longPressContinueDelete)
        delete.addGestureRecognizer(swipeLeftClear)
    }

    override func didMoveToSuperview() {
        keyboard?.earthKey = earth
        keyboard?.cleanButton = delete
        keyboard?.returnKey = ret
        keyboard?.puncKey = num
    }

    override func layoutSubviews() {
        row1.frame = CGRect(x: 0, y: 0, width: frame.width, height: row1Height)
        row2.frame = CGRect(x: 0, y: row1Height, width: frame.width, height: row2Height)
        row3.frame = CGRect(x: 0, y: row1Height + row2Height, width: frame.width, height: row3Height)
        row4.frame = CGRect(x: 0, y: row1Height + row2Height + row3Height, width: frame.width, height: row4Height)
        //        print("---AlphaButtons-frame->\(self.frame)")
        switch keyboardLayout {
        case .key9:
            layoutForKey9()

        default: break
        }
        backButton.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        touchLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
}

extension NKeyButtons {
    func layoutBottomLine() {
        let ratio: CGFloat = isPortrait ? 1.5 : 1.2
        ret.frame = CGRect(x: frame.width - buttonWidth * ratio - rowRL, y: row4Top, width: buttonWidth * ratio, height: row4Height - row4Top - row4Bottom)

        if isX || isOrphan {
            num.frame = CGRect(x: rowRL, y: row4Top, width: ret.width / 2, height: ret.height)
            earth.frame = CGRect.zero
            key0.frame = CGRect(x: num.right + basicSpacing, y: row4Top, width: num.width, height: ret.height)
            blankSpace.frame = CGRect(x: key0.right + basicSpacing, y: row4Top, width: ret.left - key0.right - 12, height: ret.height)
        } else {
            num.frame = CGRect(x: rowRL, y: row4Top, width: buttonWidth * 0.7, height: ret.height)
            earth.frame = CGRect(x: num.right + basicSpacing, y: row4Top, width: num.width, height: ret.height)
            key0.frame = CGRect(x: ret.left - basicSpacing - num.width, y: row4Top, width: num.width, height: ret.height)
            blankSpace.frame = CGRect(x: earth.right + basicSpacing, y: row4Top, width: key0.left - earth.right - 12, height: ret.height)
        }
    }

    func layoutForKey17() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + rowRL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + rowRL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index) * (buttonWidth + basicSpacing)) + rowRL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
        }
//        for (index, b) in row3Buttons.enumerated() {
//            if b.tag == 299 {
//                b.frame = CGRect(x: rowRL, y: row3Top, width: buttonWidth * 0.5, height: row3Height - row3Top - row3Bottom)
//            } else if b.tag == delete.tag {
//                b.frame = CGRect(x: frame.width - buttonWidth * 0.7 - 3, y: row3Top, width: buttonWidth * 0.7, height: row3Height - row3Top - row3Bottom)
//            } else {
//                b.frame = CGRect(x: (CGFloat(index - 1) * (buttonWidth * 0.9 + basicSpacing)) + row3RL, y: row3Top, width: buttonWidth*0.9, height: row3Height - row3Top - row3Bottom)
//            }
//        }
        layoutBottomLine()
    }

    func layoutForKey9() {
        for (index, b) in row1Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index + 1) * (buttonWidth + basicSpacing)) + rowRL, y: row1Top, width: buttonWidth, height: row1Height - row1Top - row1Bottom)
        }
        for (index, b) in row2Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index + 1) * (buttonWidth + basicSpacing)) + rowRL, y: row2Top, width: buttonWidth, height: row2Height - row2Top - row2Bottom)
        }
        for (index, b) in row3Buttons.enumerated() {
            b.frame = CGRect(x: (CGFloat(index + 1) * (buttonWidth + basicSpacing)) + rowRL, y: row3Top, width: buttonWidth, height: row3Height - row3Top - row3Bottom)
        }

        ret.frame = CGRect(x: width - buttonWidth - rowRL, y: row4Top, width: buttonWidth, height: row4Height - row4Top - row4Bottom)

        if isX {
            num.frame = CGRect(x: rowRL, y: row4Top, width: buttonWidth, height: row4Height - row4Top - row4Bottom)
            earth.frame = CGRect.zero
            key0.frame = CGRect(x: num.frame.maxX + basicSpacing, y: row4Top, width: buttonWidth * 0.6 - 3, height: row4Height - row4Top - row4Bottom)

        } else {
            num.frame = CGRect(x: rowRL, y: row4Top, width: (buttonWidth / 2) - 3, height: row4Height - row4Top - row4Bottom)
            earth.frame = CGRect(x: rowRL + num.width + basicSpacing, y: row4Top, width: (buttonWidth / 2) - 3, height: row4Height - row4Top - row4Bottom)
            key0.frame = CGRect(x: earth.frame.maxX + basicSpacing, y: row4Top, width: buttonWidth * 0.6 - 3, height: row4Height - row4Top - row4Bottom)
        }
        blankSpace.frame = CGRect(x: key0.frame.maxX + basicSpacing, y: row4Top, width: frame.width - (ret.width + key0.frame.maxX + basicSpacing * 2 + 3), height: row4Height - row4Top - row4Bottom)

        tableView.frame = CGRect(x: rowRL, y: row1Top, width: buttonWidth, height: row3.bottom - row1Top - row3Bottom)
    }
}

extension NKeyButtons {
    var basicSpacing: CGFloat { return 6 }
    var rowRL: CGFloat { return 3 }
    var row3RL: CGFloat {
        return 0
    }

    var row1Top: CGFloat { return isPortrait ? 6 : 8 }
    var row1Bottom: CGFloat { return isPortrait ? 3 : 4 }
    var row2Top: CGFloat { return isPortrait ? 3 : 4 }
    var row2Bottom: CGFloat { return isPortrait ? 3 : 4 }
    var row3Top: CGFloat { return isPortrait ? 3 : 4 }
    var row3Bottom: CGFloat { return isPortrait ? 3 : 4 }
    var row4Top: CGFloat { return isPortrait ? 3 : 3 }
    var row4Bottom: CGFloat { return isPortrait ? 4 : 3 }
    var row1Height: CGFloat { return frame.height / 4 + 4 }
    var row2Height: CGFloat { return frame.height / 4 }
    var row3Height: CGFloat { return frame.height / 4 }
    var row4Height: CGFloat { return frame.height / 4 - 4 }
    var buttonWidth: CGFloat {
        return frame.width / 5 - 6
    }
}
