//
//  PageViewBasic.swift
//  keyboard
//
//  Created by Aaron on 10/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

protocol PageViewBasic: UIView {
    var keyboard: KeyboardViewController! { get }
    func beforeShowUp()
    func beforeDismiss()
}

extension PageViewBasic {
    func show() {
        keyboard.view.addSubview(self)
        keyboard.addConstraintsToKeyboard(self)
        frame.size.height = 0
        beforeShowUp()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                self.frame.size.height = self.keyboard.customInterface.frame.height

                if self.keyboard.isNumbericBoardOpening {
                    self.keyboard.numbericBoard!.frame.origin.y += self.keyboard.numbericBoard!.frame.height
                } else {
                    self.keyboard.customInterface.frame.origin.y += self.keyboard.customInterface.frame.height
                }
            }, completion: nil)
        }
    }

    func dismiss() {
        beforeDismiss()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.frame.size.height = 0
            if self.keyboard.isNumbericBoardOpening {
                self.keyboard.numbericBoard!.frame.origin.y -= self.keyboard.numbericBoard!.frame.height
            } else {
                self.keyboard.customInterface.frame.origin.y -= self.keyboard.customInterface.frame.height
            }
        }, completion: { [weak self] b in
            if b, self != nil, !self!.keyboard.isCandidateModifyViewOpening {
                self?.removeFromSuperview()
            }
        })
    }
}
