//
//  KeySoundFeedbackGenerator.swift
//  LoginputKeyboard
//
//  Created by Aaron on 9/18/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import AudioToolbox
import Foundation

final class KeySoundFeedbackGenerator {
    private var soundID: SystemSoundID = 0
    private var soundQueue = DispatchQueue(label: "KeySoundFeedbackQueue", qos: .userInteractive)
    init() {}

    //        AudioServicesPlaySystemSound(1519) // Peek feedback
    //        AudioServicesPlaySystemSound(1520) // Pop feedback
    //        AudioServicesPlaySystemSound(1521) // Three pulses feedback
    //        Press Click - ID: 1123
    //
    //        Press Delete - ID: 1155
    //
    //        Press Modifier - ID: 1156
    func makeSound(for button: KeyboardKeyID) {
        soundQueue.async {
            if !ConfigManager.shared.clickSoundName.isEmpty {
                AudioServicesPlaySystemSound(self.soundID)
            } else {
                switch button {
                case 100 ... 127, 200: AudioServicesPlaySystemSound(1123)
                case 4: AudioServicesPlaySystemSound(1155)
                default: AudioServicesPlaySystemSound(1156)
                }
            }
        }
    }

    deinit {
        AudioServicesDisposeSystemSoundID(soundID)
    }
}
