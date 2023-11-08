//
//  KeyFeedBackGenerator.swift
//  LoginputKeyboard
//
//  Created by Aaron on 8/10/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import AudioToolbox
import UIKit

final class KeyFeedbackGenerator {
    private var generator: UIFeedbackGenerator?

    init() { // ios 13+ 线性马达不可用了
        if #available(iOSApplicationExtension 13.0, *), !(KeyboardViewController.inputProxy?.keyboardHasFullAccess() ?? false) { return }

        if ConfigManager.shared.keyFeedBackType == -1 {
            generator = UISelectionFeedbackGenerator()
        } else {
            generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle(rawValue: ConfigManager.shared.keyFeedBackType)!)
        }
        generator?.prepare()
    }

    func prepare() {
        generator?.prepare()
    }

    func trigger() {
        generator?.prepare()
        if ConfigManager.shared.keyFeedBackType == -1 {
            if #available(iOSApplicationExtension 13.0, *), !(KeyboardViewController.inputProxy?.keyboardHasFullAccess() ?? false) {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
                    AudioServicesPlaySystemSound(1519)
                }
            } else {
                (generator as? UISelectionFeedbackGenerator)?.selectionChanged()
            }
        } else {
            if #available(iOSApplicationExtension 13.0, *), !(KeyboardViewController.inputProxy?.keyboardHasFullAccess() ?? false) {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
                    AudioServicesPlaySystemSound(1520)
                }
            } else {
                (generator as? UIImpactFeedbackGenerator)?.impactOccurred()
            }
        }
        generator?.prepare()
    }

    deinit {
        generator = nil
    }
}
