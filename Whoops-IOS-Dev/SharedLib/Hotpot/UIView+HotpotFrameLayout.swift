//
//  UIView+HotpotFrameLayout.swift
//  HotpotLayout
//
//  Created by Aaron on 2018/4/1.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit

public extension UIView {
    var left: CGFloat {
        get { return frame.minX }
        set { frame.origin.x = newValue }
    }

    var top: CGFloat {
        get { return frame.minY }
        set { frame.origin.y = newValue }
    }

    var right: CGFloat {
        get { return frame.maxX }
        set { frame.origin.x = newValue - frame.size.width }
    }

    var bottom: CGFloat {
        get { return frame.maxY }
        set { frame.origin.y = newValue - frame.size.height }
    }

    var width: CGFloat {
        get { return frame.width }
        set { frame.size.width = newValue }
    }

    var height: CGFloat {
        get { return frame.height }
        set { frame.size.height = newValue }
    }

    var centerX: CGFloat {
        get { return center.x }
        set { center = CGPoint(x: newValue, y: center.y) }
    }

    var centerY: CGFloat {
        get { return center.y }
        set { center = CGPoint(x: center.x, y: newValue) }
    }

    var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }

    var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }

    internal func frameLayout(_ block: (HotpotFrameLayout) -> Void) {
        let layout = HotpotFrameLayout(view: self)
        sizeToFit() // get default info before layout to avoid any of self size usage return zero
        block(layout)
        layout.render()
    }
}
