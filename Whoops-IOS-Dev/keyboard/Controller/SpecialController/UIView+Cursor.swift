//
//  UIView+Cursor.swift
//  cym-keyboard
//
//  Created by Aaron on 4/2/19.
//  Copyright © 2019 CYM Solutions Limited. All rights reserved.
//

import UIKit

extension UIView {
    func addOpacityAnimation() {
        let key = "opacity"
        let animation = CABasicAnimation(keyPath: key)
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.autoreverses = true
        animation.repeatCount = Float.greatestFiniteMagnitude
        layer.add(animation, forKey: key)
    }

    func removeOpacityAnimation() {
        let key = "opacity"
        layer.removeAnimation(forKey: key)
    }
}
