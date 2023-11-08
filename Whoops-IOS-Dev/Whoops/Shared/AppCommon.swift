//
//  GradientLayer.swift
//  Whoops
//
//  Created by Aaron on 3/26/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import Foundation

func genGradientLayer(isVertical: Bool = true) -> CALayer {
    let layer0 = CAGradientLayer()
    layer0.colors = isVertical ? [
        UIColor(red: 0.233, green: 0.814, blue: 0.93, alpha: 1).cgColor,
        UIColor(red: 0.174, green: 0.638, blue: 0.87, alpha: 1).cgColor,
    ] : [
        UIColor(red: 0.231, green: 0.812, blue: 0.929, alpha: 1).cgColor,
        UIColor(red: 0.174, green: 0.638, blue: 0.87, alpha: 1).cgColor,
    ]
    layer0.locations = [0, 1]
    layer0.startPoint = isVertical ? CGPoint(x: 0.5, y: 0.25) : CGPoint(x: 0.25, y: 0.5)
    layer0.endPoint = isVertical ? CGPoint(x: 0.5, y: 0.75) : CGPoint(x: 0.75, y: 0.5)
    return layer0
}

func settingNavigationBarBlue(controller: UINavigationController?) {
    controller?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    controller?.navigationBar.shadowImage = UIImage()
    controller?.navigationBar.isTranslucent = true
    controller?.view.backgroundColor = .clear
}

func settingNavigationBarWhite(controller: UINavigationController?) {
    controller?.navigationBar.setBackgroundImage(nil, for: .default)
    controller?.navigationBar.shadowImage = UIImage()
    controller?.navigationBar.isTranslucent = false
    controller?.view.backgroundColor = .white
    controller?.navigationBar.titleTextAttributes = [.font: kBold34Font]
}
