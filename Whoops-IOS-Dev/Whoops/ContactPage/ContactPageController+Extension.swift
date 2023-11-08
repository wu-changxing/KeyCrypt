//
//  ContactPageController+Extension.swift
//  Whoops
//
//  Created by Aaron on 12/7/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

extension ContactPageController {
    func isKeyboardExtensionEnabled() -> Bool {
        guard let appBundleIdentifier = Bundle.main.bundleIdentifier else {
            return false
        }

        guard let keyboards = UserDefaults.standard.dictionaryRepresentation()["AppleKeyboards"] as? [String] else {
            // There is no key `AppleKeyboards` in NSUserDefaults. That happens sometimes.
            return false
        }

        let keyboardExtensionBundleIdentifierPrefix = appBundleIdentifier + "."
        for keyboard in keyboards {
            if keyboard.hasPrefix(keyboardExtensionBundleIdentifierPrefix) {
                return true
            }
        }

        return false
    }
}
