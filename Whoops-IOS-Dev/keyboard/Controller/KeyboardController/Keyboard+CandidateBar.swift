//
//  Keyboard+CandidateBar.swift
//  LoginputKeyboard
//
//  Created by Aaron on 5/16/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit

// show candidate bar
extension KeyboardViewController {
    /// show candidateBar if not shown, if already shown, do nothing
    func showCandidateBarIfNeeded() {
        guard candidateRowView.isHidden else { return }

        firstSet = false
        if #available(iOSApplicationExtension 12.0, *) {
        } else {
            moveCursorGestureRecognizer.isEnabled = false
            heightConstraint.constant = ConfigManager.shared.keyboardHeight
            addConstraintsToKeyboard(customInterface)
            let v = UIView()
            view.addSubview(v)
            v.removeFromSuperview()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            self.candidateRowView.isHidden = false
            self.moveCursorGestureRecognizer.isEnabled = true
        }
    }
}
