//
//  env.swift
//  LoginputKeyboard
//
//  Created by Aaron on 8/6/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import DeviceKit
import Foundation
import UIKit

enum DeviceName {
    case iPhone, iPad
}

let deviceName: DeviceName = Device.current.isPad ? .iPad : .iPhone

var kCandidateRowHeight: CGFloat {
    return deviceName == .iPad ? 50 : 42
}

// func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
//
//    #if DEBUG
//
//    var idx = items.startIndex
//    let endIdx = items.endIndex
//
//    repeat {
//        Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
//        idx += 1
//    }
//        while idx < endIdx
//
//    #endif
// }
func getAngle(point: CGPoint) -> CGFloat {
    let rads = atan(point.y / point.x)
    let degrees = (180 * rads / .pi)
    //        LogPrint(log: degrees)
    return degrees
}

var isPortrait: Bool {
    return UIScreen.main.bounds.width < UIScreen.main.bounds.height
}

var isX: Bool {
    guard deviceName == .iPhone else { return false }
    return deviceName == .iPhone && Device.current.hasRoundedDisplayCorners
}

var isPlus: Bool {
    return Device.current.isOneOf([.iPhone6Plus, .iPhone7Plus, .iPhone8Plus, .iPhone11ProMax, .iPhoneXSMax, .iPhone12ProMax])
}

var kPrivacyHeight: CGFloat { isPortrait ? 180 : 80 }

func toChinese(day: Int) -> String {
    let s = ["日", "一", "二", "三", "四", "五", "六"]
    return day < s.count ? s[day] : ""
}

public extension UIApplication {
    static func fuckApplication() -> UIApplication {
        guard UIApplication.responds(to: Selector(("sharedApplication"))) else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication` does not respond to selector `sharedApplication`.")
        }

        guard let unmanagedSharedApplication = UIApplication.perform(Selector(("sharedApplication"))) else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication.sharedApplication()` returned `nil`.")
        }

        guard let sharedApplication = unmanagedSharedApplication.takeUnretainedValue() as? UIApplication else {
            fatalError("UIApplication.sharedKeyboardApplication(): `UIApplication.sharedApplication()` returned not `UIApplication` instance.")
        }

        return sharedApplication
    }

    @discardableResult
    func fuckURL(url: URL) -> Bool {
        return perform("openURL:", with: url) != nil
    }
    //    UIApplication.🚀sharedApplication().🚀openURL(url: URL(string: "app-settings:root=General&path=About")!)
}
