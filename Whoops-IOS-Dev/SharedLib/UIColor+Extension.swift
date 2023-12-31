//
//  UIColor+Extension.swift
//  LogInput2
//
//  Created by Aaron on 8/13/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit
extension UIColor {
    public var hexCode: String {
        let colorComponents = cgColor.components!
        if colorComponents.count < 4 {
            return String(format: "%02x%02x%02x", Int(colorComponents[0] * 255.0), Int(colorComponents[0] * 255.0), Int(colorComponents[0] * 255.0)).uppercased()
        }
        return String(format: "%02x%02x%02x", Int(colorComponents[0] * 255.0), Int(colorComponents[1] * 255.0), Int(colorComponents[2] * 255.0)).uppercased()
    }

    public var int: Int {
        if let n = Int(hexCode, radix: 16) {
            return n
        }
        return 0
    }

    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
