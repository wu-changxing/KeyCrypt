//
//  WhoopsTabbarController.swift
//  Whoops
//
//  Created by Aaron on 7/14/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class WhoopsTabbarController: UITabBarController {
    override func viewDidLoad() {
        tabBar.tintColor = .darkText
        let attrsNormal = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1),
                           NSAttributedString.Key.font: kBasicFont(size2x: 22, semibold: true)]
        UITabBarItem.appearance().setTitleTextAttributes(attrsNormal,
                                                         for: .normal)

        let attrsSelected = [NSAttributedString.Key.foregroundColor: UIColor.darkText,
                             NSAttributedString.Key.font: kBasicFont(size2x: 22, semibold: true)]
        UITabBarItem.appearance().setTitleTextAttributes(attrsSelected,
                                                         for: .selected)
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? .default
    }

    override open var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
//    let kBarHeight:CGFloat = 100
//    override func viewDidLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//
//        tabBar.frame.size.height = kBarHeight
//        tabBar.frame.origin.y = view.frame.height - kBarHeight
//    }
}

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }

    override open var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}
