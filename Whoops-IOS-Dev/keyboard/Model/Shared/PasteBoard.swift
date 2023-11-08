//
//  PasteBoard.swift
//  LogInput
//
//  Created by Aaron on 2016/11/16.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import MMKVAppExtension
import UIKit

let kPasteBoard = "PasteBoard"
let kPasteBoardStr = "PasteBoardStr"

final class PasteBoard {
    static let shared = PasteBoard()
//    private let userDefault = UserDefaults.standard
//    private let mmkvDefault = MMKV.default()
    private let queue = DispatchQueue(label: "PasteBoardSaving")
    private(set) var pasteBoardData: [String] = []
    private(set) var pastBoardCount = -1
    var timer: Timer?

    private init() {}

    func start() {
        queue.async {
//            self.loadData()
            DispatchQueue.main.async {
                self.watchDog()
            }
        }
    }

    static var string: String {
        get {
            if KeyboardViewController.inputProxy?.keyboardHasFullAccess() ?? false {
                guard UIPasteboard.general.hasStrings,
                      let s = UIPasteboard.general.string else { return "" }
                return s
            }
            return MMKV.default()?.string(forKey: kPasteBoardStr) ?? ""
        }
        set {
            if KeyboardViewController.inputProxy?.keyboardHasFullAccess() ?? false {
                UIPasteboard.general.string = newValue
            } else {
                MMKV.default()?.set(newValue, forKey: kPasteBoardStr)
            }
        }
    }

//    func loadData() {
//        guard ConfigManager.shared.pasteBoardHistory else {return}
//        if let arr = mmkvDefault?.object(of: NSArray.self, forKey: kPasteBoard) as? [String] {
//            pasteBoardData = arr
//        } else
//        if let arr = userDefault.array(forKey: "PasteBoardData") as? [String] {
//            pasteBoardData = arr
//            mmkvDefault?.set(pasteBoardData as NSArray, forKey: kPasteBoard)
//            userDefault.removeObject(forKey: "PasteBoardData")
//        }
//
//    }

    func watchDog() {
        timer?.invalidate()
        timer = nil
        timer = Timer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }

    deinit {
        timer?.invalidate()
    }

    @objc func update() {
        guard UIPasteboard.general.changeCount != pastBoardCount else { return }
        pastBoardCount = UIPasteboard.general.changeCount
        let s = PasteBoard.string
        queue.async {
            guard let r = s.range(of: "₳(GROUP:|group:)?[0-9a-zA-Z]+₳", options: .regularExpression, range: nil, locale: nil) else {
                NotificationCenter.default.post(name: .PasteBoardNewString, object: s)
                return
            }

            let code = s[r].replacingOccurrences(of: "₳", with: "")
            (KeyboardViewController.inputProxy as! KeyboardViewController).acceptInvite(code: code)
        }
    }
}
