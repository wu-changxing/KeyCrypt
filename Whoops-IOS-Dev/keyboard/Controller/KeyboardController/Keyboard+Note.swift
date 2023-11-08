//
//  Keyboard+Note.swift
//  LoginputKeyboard
//
//  Created by Aaron on 5/16/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import MMKVAppExtension
import UIKit

// MARK: note

var needDismissKeyboard = false

extension KeyboardViewController {
    func noteMode() {}

    var sharedApplication: UIApplication? {
        var responder: UIResponder? = self
        while responder != nil {
            responder?.resignFirstResponder()
            if let application = responder as? UIApplication {
                return application
            }

            responder = responder?.next
        }
        return nil
    }

    @objc func saveNote(with _: String, directly _: Bool) {}
}
