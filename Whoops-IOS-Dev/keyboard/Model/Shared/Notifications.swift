//
//  Notifications.swift
//  LogInput
//
//  Created by Aaron on 2017/4/2.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import Foundation
extension Notification.Name {
    static let EnglishModeChanged = Notification.Name(rawValue: "EnglishModeChanged")
    static let MessageBoardDismiss = Notification.Name(rawValue: "MessageBoardDismiss")
    static let MorePuncMode = Notification.Name(rawValue: "MorePuncMode")
    static let AdvanceToNextInputMode = Notification.Name(rawValue: "AdvanceToNextInputMode")
    static let EmojiInputModeDismiss = Notification.Name(rawValue: "EmojiInputModeDismiss")
    static let ReloadFirstSection = Notification.Name(rawValue: "ReloadFirstSections")
    static let ScrollToFirstItem = Notification.Name(rawValue: "ScrollToFirstItem")
    static let DidRotate = Notification.Name(rawValue: "DidRotate")
    static let KeyboardModeChanged = Notification.Name(rawValue: "KeyboardModeChanged")
    static let NoteSaveButtonDidTap = Notification.Name(rawValue: "NoteSaveButtonDidTap") // use `object` to pass the `String`
    static let DidTapButton = Notification.Name(rawValue: "DidTapButton") // use `object` to pass the `UIButton`
    static let KeyboardDidPopUp = Notification.Name(rawValue: "KeyboardDidPopUp") // use `object` to pass the `Int`

    static let PasteBoardWillUpdate = Notification.Name(rawValue: "PasteBoardWillUpdate")
    static let PasteBoardDidUpdate = Notification.Name(rawValue: "PasteBoardDidUpdate")
    static let PasteBoardNewString = Notification.Name(rawValue: "PasteBoardNewString")

    static let privacyModeWillChangeTo = Notification.Name("PrivacyModeWillChangeTo")

    static let contactViewOpenChanged = Notification.Name("ContactViewOpenChanged")
    static let moreViewOpenChanged = Notification.Name("MoreViewOpenChanged")
    static let inviteViewOpenChanged = Notification.Name("InviteViewOpenChanged")
}
