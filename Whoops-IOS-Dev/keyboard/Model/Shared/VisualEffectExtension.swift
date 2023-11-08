//
//  VisualEffectExtension.swift
//  LoginputKeyboard
//
//  Created by Aaron on 1/9/20.
//  Copyright © 2020 Aaron. All rights reserved.
//

import UIKit
class CustomIntensityVisualEffectView: UIVisualEffectView {
    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator.fractionComplete = intensity
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    // MARK: Private

    private var animator: UIViewPropertyAnimator!
}
