//
//  NKeyButtonsAbstract.swift
//  LoginputKeyboard
//
//  Created by Aaron on 3/8/20.
//  Copyright © 2020 Aaron. All rights reserved.
//

import UIKit

class KeyboardButtonsAbstract: UIView, KeyboardButtonsLayout {
    var a = KeyboardKey(tag: 100)
    var b = KeyboardKey(tag: 101)
    var c = KeyboardKey(tag: 102)
    var d = KeyboardKey(tag: 103)
    var e = KeyboardKey(tag: 104)
    var f = KeyboardKey(tag: 105)
    var g = KeyboardKey(tag: 106)
    var h = KeyboardKey(tag: 107)
    var i = KeyboardKey(tag: 108)
    var j = KeyboardKey(tag: 109)
    var k = KeyboardKey(tag: 110)
    var l = KeyboardKey(tag: 111)
    var m = KeyboardKey(tag: 112)
    var n = KeyboardKey(tag: 113)
    var o = KeyboardKey(tag: 114)
    var p = KeyboardKey(tag: 115)
    var q = KeyboardKey(tag: 116)
    var r = KeyboardKey(tag: 117)
    var s = KeyboardKey(tag: 118)
    var t = KeyboardKey(tag: 119)
    var u = KeyboardKey(tag: 120)
    var v = KeyboardKey(tag: 121)
    var w = KeyboardKey(tag: 122)
    var x = KeyboardKey(tag: 123)
    var y = KeyboardKey(tag: 124)
    var z = KeyboardKey(tag: 125)

    var key0 = KeyboardKey(tag: 299)
    var key1 = KeyboardKey(tag: 201)
    var key2 = KeyboardKey(tag: 202)
    var key3 = KeyboardKey(tag: 203)
    var key4 = KeyboardKey(tag: 204)
    var key5 = KeyboardKey(tag: 205)
    var key6 = KeyboardKey(tag: 206)
    var key7 = KeyboardKey(tag: 207)
    var key8 = KeyboardKey(tag: 208)
    var key9 = KeyboardKey(tag: 209)
    var key10 = KeyboardKey(tag: 210)
    var key11 = KeyboardKey(tag: 211)
    var key12 = KeyboardKey(tag: 212)
    var key13 = KeyboardKey(tag: 213)
    var key14 = KeyboardKey(tag: 214)
    var key15 = KeyboardKey(tag: 215)
    var key16 = KeyboardKey(tag: 216)
    var key17 = KeyboardKey(tag: 217)

    var column = KeyboardKey(tag: 127)

    var blankSpace: KeyboardKey = {
        let b = KeyboardKey(tag: kSpaceButtonID)
        if !isVoiceOverOn,
           #available(iOSApplicationExtension 11.0, *),
           ConfigManager.shared.spaceAnimation
        {
            b.setTitle("Whoops", for: .normal)
        } else if ConfigManager.shared.persistedEnMode {
            let s = LocalConfigManager.shared.currentEnMode ? "Space" : "空格"
            b.setTitle(s, for: .normal)
        } else {
            b.setTitle("空格", for: .normal)
        }
        return b
    }()

    var num: KeyboardKey = { let b = KeyboardKey(tag: kNumberButtonID); b.setTitle("123", for: .normal); return b }()

    var shift = KeyboardKey(tag: kShiftButtonID)

    var earth: KeyboardKey = {
        let b = KeyboardKey(tag: kEarthButtonID)
        b.accessibilityLabel = "切换键盘"
        return b
    }()

    var delete: KeyboardKey = {
        let b = KeyboardKey(tag: kDeleteButtonID)
        b.accessibilityLabel = "退格"
        b.accessibilityHint = "长按连续删除"
        return b
    }()

    var ret: KeyboardKey = {
        let b = KeyboardKey(tag: kReturnButtonID)
        b.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return b
    }()

    var keyboardLayout: KeyboardLayout = .qwerty

    let backButton = UIButton() // 必须加这个背景按钮否则键盘扩展生效范围无效
    var touchLayer: TouchLayer
    weak var keyboard: KeyboardViewController?
    var isOrphan = false

    var row1 = UIView()
    var row2 = UIView()
    var row3 = UIView()
    var row4 = UIView()

    @objc var row1Buttons: [KeyboardKey] = []
    @objc var row2Buttons: [KeyboardKey] = []
    @objc var row3Buttons: [KeyboardKey] = []
    @objc var row4Buttons: [KeyboardKey] = []

    init(keyboard: KeyboardViewController, layout: KeyboardLayout, isOrphan: Bool = false) {
        touchLayer = TouchLayer(keyboard: keyboard)
        super.init(frame: .zero)
        self.keyboard = keyboard
        touchLayer.buttonView = self
        self.isOrphan = isOrphan
        keyboardLayout = layout

        keyboardDidLoad()

        addSubview(backButton)

        addSubview(row1)
        addSubview(row2)
        addSubview(row3)
        addSubview(row4)

        for b in row1Buttons {
            b.noMapHint = isOrphan
            row1.addSubview(b)
            b.addTarget(keyboard: keyboard)
        }
        for b in row2Buttons {
            b.noMapHint = isOrphan
            row2.addSubview(b)
            b.addTarget(keyboard: keyboard)
        }
        for b in row3Buttons {
            b.noMapHint = isOrphan
            row3.addSubview(b)
            b.addTarget(keyboard: keyboard)
        }
        for b in row4Buttons {
            row4.addSubview(b)
            b.addTarget(keyboard: keyboard)
        }

        addSubview(touchLayer)

        backButton.accessibilityElementsHidden = true
        backButton.tag = 999

        if ConfigManager.shared.imgBg {
            FileSyncCheck.copyImageBG()
            let image = UIImage(contentsOfFile: FileSyncCheck.bgImageLocalPath)
            backButton.setBackgroundImage(image, for: .normal)
            backButton.alpha = CGFloat(ConfigManager.shared.imgBgAlpha)
        } else {
            backButton.backgroundColor = UIColor.white.withAlphaComponent(0.001) // 必须加这个颜色否则按钮不生效
        }

        if !isOrphan {
            NotificationCenter.default.addObserver(self, selector: #selector(animate), name: .KeyboardDidPopUp, object: nil)
        }
        keyboardAfterLoad()
    }

    func keyboardAfterLoad() {}
    func keyboardDidLoad() {
        fatalError("Subclass must implement this method!")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension KeyboardButtonsAbstract {
    @objc func animate() {
        let s: String
        if ConfigManager.shared.persistedEnMode {
            s = LocalConfigManager.shared.currentEnMode ? "Space" : "空格"
        } else {
            s = "空格"
        }
        guard !isVoiceOverOn, blankSpace.title(for: .normal) != s, #available(iOSApplicationExtension 11.0, *),
              ConfigManager.shared.spaceAnimation else { return }
        UIView.animate(withDuration: 0.3, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.blankSpace.titleLabel?.alpha = 0

        }) { b in
            if b {
                self.blankSpace.setTitle(s, for: .normal)
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                    self.blankSpace.titleLabel?.alpha = 1
                }, completion: nil)
            }
        }
    }
}

extension KeyboardButtonsAbstract {}
