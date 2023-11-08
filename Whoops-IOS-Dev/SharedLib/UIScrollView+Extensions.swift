//
//  UIScrollView+extensions.swift
//  Whoops
//
//  Created by Aaron on 1/18/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        var y: CGFloat = 0.0
        let HEIGHT = frame.size.height
        if contentSize.height > HEIGHT {
            y = contentSize.height - HEIGHT + contentInset.bottom
        }
        setContentOffset(CGPoint(x: 0, y: y), animated: animated)
    }
}
