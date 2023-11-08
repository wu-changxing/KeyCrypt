//
//  UITextDocumentProxy.swift
//  keyboard
//
//  Created by Aaron on 2/28/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import UIKit
extension UITextDocumentProxy {
    var returnKeyTypeSafe: UIReturnKeyType {
        if responds(to: #selector(getter: returnKeyType)) {
            return self.returnKeyType ?? .default
        } else {
            return .default
        }
    }

    var keyboardTypeSafe: UIKeyboardType {
        if responds(to: #selector(getter: keyboardType)) {
            return self.keyboardType ?? .default
        } else {
            return .default
        }
    }
}
