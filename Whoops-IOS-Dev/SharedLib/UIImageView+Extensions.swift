//
//  UIImageView+Extensions.swift
//  Whoops
//
//  Created by Aaron on 8/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(from url: String, whenDone callback: @escaping (() -> Void)) {
        guard let u = URL(string: url) else { return }
        kf.indicatorType = .activity
        kf.setImage(with: u, options: [.transition(.fade(0.3))], completionHandler: { _ in
            callback()
        })
    }
}
