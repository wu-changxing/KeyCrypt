//
//  SocketMessageLayerDelegate.swift
//  keyboard
//
//  Created by Aaron on 9/5/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import Foundation

protocol SocketMessageLayerDelegate {
    func msgSentStatus(for tag: Int, status: Bool, msg: String)
    func newMsgArrived(msg: LXFChatMsgModel)
}
