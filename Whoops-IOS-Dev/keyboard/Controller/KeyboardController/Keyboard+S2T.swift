//
//  Keyboard+S2T.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/9/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import Foundation

extension KeyboardViewController {
    func s2tIfNeeded(_: inout String) {
        guard ConfigManager.shared.s2t else { return }

        return
    }
}
