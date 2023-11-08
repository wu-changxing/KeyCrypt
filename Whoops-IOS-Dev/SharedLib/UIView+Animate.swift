//
//  UIView+Animate.swift
//  LogInput2
//
//  Created by Aaron on 8/13/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit

extension UIView {
    static func animateSpring(withDuration: TimeInterval = 0.3, animations: @escaping (() -> Void), completion: @escaping ((Bool) -> Void) = { _ in }) {
        UIView.animate(withDuration: withDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: animations, completion: completion)
    }
}
