//
//  TouchLayer.swift
//  LoginputKeyboard
//
//  Created by Aaron on 9/22/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit
final class TouchLayer: UIView {
    private var tapGR = UITapGestureRecognizer()
    private var otherGR: [UIGestureRecognizer] = []
    weak static var current: TouchLayer?
    private weak var keyboard: KeyboardViewController?
    weak var buttonView: UIView?

    private let earthMaskKey = UIButton()

    init(keyboard: KeyboardViewController) {
        super.init(frame: CGRect.zero)
        self.keyboard = keyboard
        tapGR.delegate = self
        tapGR.numberOfTouchesRequired = 10
        backgroundColor = UIColor.white.withAlphaComponent(0.0001)
        addGestureRecognizer(tapGR)
        settingGestureRecognizers()
        TouchLayer.current = self
        accessibilityElementsHidden = true
        earthMaskKey.tag = kEarthButtonID
        earthMaskKey.backgroundColor = UIColor.clear
        addSubview(earthMaskKey)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEarthKeyMask), name: .KeyboardDidPopUp, object: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func updateEarthKeyMask() {
        guard let key = keyboard?.earthKey else { return }
        earthMaskKey.frame = convert(key.bounds, from: key)
        if #available(iOSApplicationExtension 11.0, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.keyboard?.needsInputModeSwitchKey ?? true {
                    self.earthMaskKey.addTarget(self.keyboard, action: #selector(self.keyboard?.handleInputModeList(from:with:)), for: .allTouchEvents)
                } else {
                    self.earthMaskKey.isHidden = true
                }
            }

        } else {
            earthMaskKey.addTarget(keyboard, action: #selector(keyboard?.handleInputModeList(from:with:)), for: .allTouchEvents)
        }
    }

    let longPressBoom = UILongPressGestureRecognizer()
    let longPressContinueDelete = UILongPressGestureRecognizer()
    let longPressSoftReturn = UILongPressGestureRecognizer()
    let doubleTapCapslock = UITapGestureRecognizer()

    let longPressChangeLayout = UILongPressGestureRecognizer()

    func settingGestureRecognizers() {
        guard let keyboard = self.keyboard else { return }
        longPressBoom.delegate = self
        longPressBoom.addTarget(keyboard, action: #selector(keyboard.longPressChangeKeyboardHeight))
        addGestureRecognizer(longPressBoom)

        longPressContinueDelete.delegate = self
        longPressContinueDelete.addTarget(keyboard, action: #selector(keyboard.continueDelete))
        addGestureRecognizer(longPressContinueDelete)

        longPressChangeLayout.delegate = self
        longPressChangeLayout.addTarget(keyboard, action: #selector(keyboard.longPressChangeLayout))
        addGestureRecognizer(longPressChangeLayout)

        longPressSoftReturn.delegate = self
        longPressSoftReturn.addTarget(keyboard, action: #selector(keyboard.softReturn))
        addGestureRecognizer(longPressSoftReturn)

        doubleTapCapslock.numberOfTapsRequired = 2
        doubleTapCapslock.delaysTouchesEnded = false
        doubleTapCapslock.delegate = self
        doubleTapCapslock.addTarget(keyboard, action: #selector(keyboard.capsLock))
        addGestureRecognizer(doubleTapCapslock)
    }

    @objc func maskTapd(_: UIButton) {
        print(1)
    }

    func touchCancel() {
        if let touch = currentTouch, let k = getKeyboardKey(from: touch) {
            k.sendActions(for: UIControl.Event.touchCancel)
        }
        currentTouch = nil
    }

    func touchDown(_ touch: UITouch) {
        currentTouch = touch
        if let k = getKeyboardKey(from: touch) {
            k.sendActions(for: UIControl.Event.touchDown)
        }
    }

    func touchUpInside(_ touch: UITouch) {
        if currentTouch == touch { currentTouch = nil }
        if let k = getKeyboardKey(from: touch) {
            k.sendActions(for: UIControl.Event.touchUpInside)
        }
    }

    private var touchCache: UITouch?
    private weak var keyCache: KeyboardKey?
    func getKeyboardKey(from touch: UITouch) -> KeyboardKey? {
        let location = touch.location(in: self)
        guard let view = buttonView else { return nil }

        guard touchCache != touch else { return keyCache }
        touchCache = touch
        for index in 1 ... 4 {
            let list = view.value(forKeyPath: "row\(index)Buttons") as! [KeyboardKey]
            for key in list {
                if key.point(inside: convert(location, to: key), with: nil) {
                    keyCache = key
                    return key
                }
            }
        }
        keyCache = nil
        return nil
    }

    var currentTouch: UITouch?

//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard gestureRecognizer != tapGR else {return super.gestureRecognizerShouldBegin(gestureRecognizer)}
//
//        return false
//    }
    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        if let t = currentTouch {
            touchUpInside(t)
        }
    }
}

extension TouchLayer: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if touch.view?.tag == kEarthButtonID {return false}
        guard let keyboard = self.keyboard else { return true }
        if gestureRecognizer == longPressBoom {
            if let k = getKeyboardKey(from: touch) {
                if k.tag == keyboard.rightHandButtonID || k.tag == keyboard.leftHandButtonID { return true }
                guard ConfigManager.shared.longPressSettings else { return false }
                return k.tag >= 100
            }
            return false
        }

        if gestureRecognizer == longPressContinueDelete {
            if let k = getKeyboardKey(from: touch) {
                return k.tag == kDeleteButtonID
            }
            return false
        }

        if gestureRecognizer == longPressSoftReturn {
            if let k = getKeyboardKey(from: touch) {
                return k.tag == kReturnButtonID
            }
            return false
        }

        if gestureRecognizer == doubleTapCapslock {
            if let k = getKeyboardKey(from: touch) {
                return k.tag == kShiftButtonID
            }
            return false
        }

        if gestureRecognizer == longPressChangeLayout {
            if let k = getKeyboardKey(from: touch) {
                return k.tag == 299
            }
            return false
        }

        if let t = currentTouch {
            touchUpInside(t)
        }
        touchDown(touch)
        return true
    }

//        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    //        return otherGR.contains(otherGestureRecognizer)
//            if otherGestureRecognizer == longPressContinueDelete {
//                return true
//
//            }
//            return false
//        }
}
