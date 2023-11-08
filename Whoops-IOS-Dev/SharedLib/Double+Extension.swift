//
//  Double+Extension.swift
//  keyboard
//
//  Created by Aaron on 12/30/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Foundation
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    var whoopsString: String {
        if self == 0 {
            return "0"
        }
        if self < 0.0001 {
            return "<0.0001"
        }
        return "\(rounded(toPlaces: 4))"
    }
}
