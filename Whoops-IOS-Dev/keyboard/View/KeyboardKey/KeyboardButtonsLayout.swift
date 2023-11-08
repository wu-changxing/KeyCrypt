//
//  KeyboardButtonsLayout.swift
//  LoginputKeyboard
//
//  Created by Aaron on 6/18/20.
//  Copyright © 2020 Aaron. All rights reserved.
//

import UIKit

protocol KeyboardButtonsLayout {
    var basicSpacing: CGFloat { get }
    var rowRL: CGFloat { get }
    var row1Top: CGFloat { get }
    var row1Bottom: CGFloat { get }
    var row2Top: CGFloat { get }
    var row2Bottom: CGFloat { get }
    var row3Top: CGFloat { get }
    var row3Bottom: CGFloat { get }
    var row4Top: CGFloat { get }
    var row4Bottom: CGFloat { get }
    var row1Height: CGFloat { get }
    var row2Height: CGFloat { get }
    var row3Height: CGFloat { get }
    var row4Height: CGFloat { get }
    var buttonWidth: CGFloat { get }
}

extension KeyboardButtonsLayout {
    var basicSpacing: CGFloat { return 0 }
    var rowRL: CGFloat { return 0 }
    var row1RL: CGFloat { return 0 }
    var row2RL: CGFloat { return 0 }

    var row3RL: CGFloat { return 0 }

    var row4RL: CGFloat { return 0 }
    var row1Top: CGFloat { return 0 }
    var row1Bottom: CGFloat { return 0 }
    var row2Top: CGFloat { return 0 }
    var row2Bottom: CGFloat { return 0 }
    var row3Top: CGFloat { return 0 }
    var row3Bottom: CGFloat { return 0 }
    var row4Top: CGFloat { return 0 }
    var row4Bottom: CGFloat { return 0 }
    var row1Height: CGFloat { return 0 }
    var row2Height: CGFloat { return 0 }
    var row3Height: CGFloat { return 0 }
    var row4Height: CGFloat { return 0 }
    var buttonWidth: CGFloat { return 0 }
}
