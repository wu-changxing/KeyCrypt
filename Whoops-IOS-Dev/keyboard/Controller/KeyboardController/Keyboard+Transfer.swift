//
//  Keyboard+Transfer.swift
//  keyboard
//
//  Created by Aaron on 11/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

extension KeyboardViewController {
    func startTransferOrRedpacket(redpacket: Bool) {
        let t = WhoopsNavigationController(title: redpacket ? "发红包" : "转账")

        view.insertSubview(t, belowSubview: customInterface)
        t.pin.all()

        let c = TransferViewA(redpacket: redpacket)
        c.toUser = ChatEngine.shared.targetUser
        t.push(view: c)

        t.center.x += t.frame.width
        UIView.animateSpring {
            t.center.x -= t.frame.width
        } completion: { _ in
            self.transferView = t
        }
    }

    func openRedpacketHistory(redpacketId: Int) {
        guard let group = ChatEngine.shared.targetUser else { return }
        hideKeyboardTemp()
        let t = WhoopsNavigationController(title: "")

        view.insertSubview(t, belowSubview: customInterface)
        t.pin.all()

        let c = RedpacketHistoryView(redpacketId: redpacketId, group: group)
        t.push(view: c)

        t.center.x += t.frame.width
        UIView.animateSpring {
            t.center.x -= t.frame.width
        } completion: { _ in
            self.transferView = t
        }
    }
}
