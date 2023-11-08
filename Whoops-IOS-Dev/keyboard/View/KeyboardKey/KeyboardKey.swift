//
//  ButtonStyle.swift
//  flyinput
//
//  Created by Aaron on 16/7/29.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import AudioToolbox
import UIKit

var whiteColor = UIColor.white
var darkColor = UIColor(red: 172 / 255.0, green: 179 / 255.0, blue: 188 / 255.0, alpha: 1)
var darkModeLetterColor = UIColor(rgb: ConfigManager.shared.darkLetterColor)
var whiteModeLetterColor = UIColor(rgb: ConfigManager.shared.whiteLetterColor)
var sbBlue = UIColor(red: 40 / 255, green: 122 / 255, blue: 1, alpha: 1)

let popView = UINib(nibName: "PopView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PopView

typealias KeyboardKeyID = Int

let kSpaceButtonID: KeyboardKeyID = 126
let kShiftButtonID: KeyboardKeyID = 2
let kReturnButtonID: KeyboardKeyID = 5
let kNumberButtonID: KeyboardKeyID = 3
let kEarthButtonID: KeyboardKeyID = 6
let kiPadDismissButtonID: KeyboardKeyID = 7
let kEmojiButtonID: KeyboardKeyID = 8
let kDeleteButtonID: KeyboardKeyID = 4
let kNormalFunctionButtonID: KeyboardKeyID = 1

final class KeyboardKey: KeyButton {
    static var keyboardButtons: [KeyboardKeyID: [KeyboardKey]] = [:]
    var noMapHint = false // 目前专门给17键使用，避免英文键盘时也显示按键映射皮肤
    static var currentKeyboardKeyID = 0
    static var isPuncDragMode = false
    private var _tag = 0

    /// 不使用系统的 tag， 很慢
    @IBInspectable override var tag: Int {
        get { return _tag }
        set { _tag = newValue }
    }

    override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        guard tag != 999 else { return false }
        switch deviceName {
        case .iPhone:
            return iPhoneButtonFrame().contains(point)
        case .iPad:
            let char = title(for: .normal) ?? ""
            return iPadButtonFrame(title: char).contains(point)
        }
    }

    func iPhoneButtonFrame() -> CGRect {
        var b = UIEdgeInsets(top: -6, left: -3, bottom: -6, right: -3)
        let top: Set<Int> = [116, 122, 104, 117, 119, 124, 120, 108, 114, 115]
        let bottom: Set<Int> = [kNormalFunctionButtonID, kNumberButtonID, kReturnButtonID, kSpaceButtonID]
        var row2left: Int = -1
        var row2right: Int = -1
        var row3left: Int = -1
        var row3right: Int = -1

        switch keyboardLayout {
        case .qwerty:
            row2left = 100
            row2right = 111
            row3left = 125
            row3right = 112

        default: break
        }

        if top.contains(tag) {
            b = UIEdgeInsets(top: -10, left: -3, bottom: -6, right: -3)
        } else if row2left == tag {
            b = UIEdgeInsets(top: -6, left: -20, bottom: -6, right: -3)
        } else if row2right == tag {
            b = UIEdgeInsets(top: -6, left: -3, bottom: -6, right: -20)
        } else if bottom.contains(tag) {
            b = UIEdgeInsets(top: -4, left: -3, bottom: -3, right: -3)
        } else if row3left == tag {
            b = UIEdgeInsets(top: -6, left: -13, bottom: -6, right: -3)
        } else if row3right == tag {
            b = UIEdgeInsets(top: -6, left: -3, bottom: -6, right: -13)
        }

        return bounds.inset(by: b)
    }

    func iPadButtonFrame(title: String) -> CGRect {
        let up_down: CGFloat = isPortrait ? 5 : 6
        let l_r: CGFloat = isPortrait ? 6 : 7
        var b = UIEdgeInsets(top: -up_down, left: -l_r, bottom: -up_down, right: -l_r)
        let L: Set<Int> = [116, 2]
        let R: Set<Int> = [6, 7]
        let bottom: Set<Int> = [1, 3, 5, 126]
        let a: Set<String> = ["A", "a", "-"]

        if L.contains(tag) {
            b = UIEdgeInsets(top: -up_down, left: -l_r, bottom: -up_down, right: -l_r)
        } else if a.contains(title) {
            b = UIEdgeInsets(top: -up_down, left: -40, bottom: -up_down, right: -l_r)
        } else if title == "、" {
            b = UIEdgeInsets(top: -up_down, left: -l_r, bottom: -up_down, right: -30)
        } else if R.contains(tag) {
            b = UIEdgeInsets(top: -up_down, left: -l_r, bottom: -up_down, right: -6)
        } else if bottom.contains(tag) {
            b = UIEdgeInsets(top: -up_down, left: -l_r, bottom: -8, right: -l_r)
        }
        return bounds.inset(by: b)
    }

    var textUpColorDark: UIColor? = UIColor(rgb: ConfigManager.shared.darkRevLetterColor)
    var textUpColorLight: UIColor? = UIColor(rgb: ConfigManager.shared.whiteRevLetterColor)

    lazy var textUp: LILabel = {
        let t = LILabel(verticalCenter: false)

        let fontSize: CGFloat = deviceName == .iPhone ? 8 : 11
        t.font = UIFont.systemFont(ofSize: fontSize)

        t.textAlignment = .right
        return t
    }()

    var textDown: UILabel?
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
        processMapHint()
    }

    let shadowColor: UIColor = {
        if isX {
            return UIColor(red: 142 / 255.0, green: 143 / 255.0, blue: 147 / 255.0, alpha: 1)
        } else {
            return UIColor(red: 140 / 255.0, green: 141 / 255.0, blue: 145 / 255.0, alpha: 1)
        }
    }()

    var letterColor: UIColor {
        if ConfigManager.shared.keyboardNoPattern {
            return UIColor.clear
        } else if darkMode {
            return darkModeLetterColor
        } else {
            return whiteModeLetterColor
        }
    }

    @available(*, deprecated, message: "Use init(tag:Int, isOrphan:Bool = false) instead.")
    init() {
        super.init(frame: CGRect.zero)
    }

    @IBInspectable var isOrphan: Bool = false

    init(tag: Int, isOrphan: Bool = false) {
        super.init(frame: CGRect.zero)
        self.tag = tag
        self.isOrphan = isOrphan

        if tag == 999 { return } // 如果是999说明是背景button，为穿透手势识别而生，不用管了。

        if !isOrphan {
            if let _ = KeyboardKey.keyboardButtons[self.tag] {
                KeyboardKey.keyboardButtons[self.tag]!.append(self)
            } else {
                KeyboardKey.keyboardButtons[self.tag] = [self]
            }
        }
        regNotifications()
        regTargets()
        settingMyButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

//        self.tag = super.tag

        if tag == 999 { return } // 如果是999说明是背景button，为穿透手势识别而生，不用管了。

        if !isOrphan {
            if let _ = KeyboardKey.keyboardButtons[tag] {
                KeyboardKey.keyboardButtons[tag]!.append(self)
            } else {
                KeyboardKey.keyboardButtons[tag] = [self]
            }
        }
        regNotifications()
        regTargets()
        settingMyButton()
    }

    func regNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeMode), name: NSNotification.Name.KeyboardModeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate), name: NSNotification.Name.DidRotate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(engModeSwitch), name: NSNotification.Name.EnglishModeChanged, object: nil)
    }

    func regTargets() {
        addTarget(self, action: #selector(playTock), for: .touchDown)

        if tag != kShiftButtonID { // 对于shift来说，不自动设定黑白颜色
            addTarget(self, action: #selector(buttonDown), for: .touchDown)
            addTarget(self, action: #selector(buttonUp), for: .touchUpInside)
            if tag != kNumberButtonID {
                addTarget(self, action: #selector(buttonUp), for: .touchCancel)
                addTarget(self, action: #selector(buttonUp), for: .touchUpOutside)
                addTarget(self, action: #selector(buttonUp), for: .touchDragOutside)
                addTarget(self, action: #selector(buttonDown), for: .touchDragInside)
            }
        }
    }

    func processMapHint() {
        guard tag >= 100 && tag < 126 || tag == 127 || tag >= 201 && tag <= 217, ConfigManager.shared.mapHint else { return }

        textUp.text = getMapString()
        textUp.frame = CGRect(x: -1, y: 0, width: width, height: height)
        textUp.setNeedsDisplay()
    }

    func settingMyButton() {
        layer.cornerRadius = deviceName == .iPhone || isPortrait ? 5.0 : 7.0
        if #available(iOSApplicationExtension 13.0, *) {
            layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        if !ConfigManager.shared.keyTransparent {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowRadius = 0
            layer.shadowOpacity = 1
        }

        layer.masksToBounds = false
        isAccessibilityElement = true

        if tag == kNormalFunctionButtonID || tag == kReturnButtonID || tag == kEarthButtonID {
            accessibilityTraits = UIAccessibilityTraits.button
        } else {
            accessibilityTraits = [.keyboardKey, .playsSound]
        }

        setTitleColor(letterColor, for: .normal)

        if tag == kNumberButtonID || tag == kShiftButtonID {
            titleLabel?.font = UIFont.systemFont(ofSize: 16)
            titleLabel.setNeedsDisplay()
            titleEdgeInsets.bottom = -2
        }
        if tag >= 100 && tag < 126 || tag == 127 || tag >= 201 && tag <= 217, ConfigManager.shared.mapHint {
            addSubview(textUp)
            textUp.text = getMapString()
        }

        if tag == 200 {
            let size = titleLabel?.font?.pointSize
            titleLabel?.font = UIFont(name: fontName, size: size ?? 20)
        }
        if tag == kDeleteButtonID, !ConfigManager.shared.keyboardNoPattern { setImage(UIImage(named: "backWard_white"), for: .normal)
            tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
        }
        if tag == kEarthButtonID, !ConfigManager.shared.keyboardNoPattern {
            setImage(UIImage(named: "earth_white"), for: .normal)
            tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
        }
        if tag == kiPadDismissButtonID, !ConfigManager.shared.keyboardNoPattern {
            setImage(UIImage(named: "key_white"), for: .normal)
            tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
        }

        changeMode(Notification(name: .KeyboardModeChanged))
    }

    deinit {
        print(tag, "deinit!")
        NotificationCenter.default.removeObserver(self)
    }

    func cancelTouch(sender: UIControl? = nil) {
        if let sender = sender {
            sender.cancelTracking(with: nil)
        } else {
            cancelTracking(with: nil)
        }
    }

    @objc func didRotate(_: Notification) {
        if tag >= 100 && tag < 126 || tag == 127 || tag >= 201 && tag <= 217, ConfigManager.shared.mapHint {
            let fontSize: CGFloat = deviceName == .iPhone ? 8 : 11
            let s = getMapString()
            let size = s.size(of: .systemFont(ofSize: fontSize))
            textUp.frame = CGRect(x: -1, y: 0, width: bounds.width, height: size.height)
        }
    }

    @objc func engModeSwitch() {
        guard tag == kSpaceButtonID else { return }
        if isEnMode {
            setTitle("Space", for: .normal)
        } else {
            setTitle("空格", for: .normal)
        }
        UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func changeMode(_: Notification) {
        if keyboardMode == .upper, !CapsLock { return }
        if tag == kDeleteButtonID {
            tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
        }
        if tag == kReturnButtonID {
//            layer.backgroundColor = sbBlue.cgColor

            switch returnKeyType {
            case .done: setTitle("完成", for: .normal)
            case .continue: setTitle("继续", for: .normal)
            case .go: setTitle("前往", for: .normal)
            case .google: setTitle("谷歌", for: .normal)
            case .join: setTitle("加入", for: .normal)
            case .next: setTitle("下一项", for: .normal)
            case .emergencyCall: setTitle("紧急", for: .normal)
            case .yahoo: setTitle("雅虎", for: .normal)
            case .send: setTitle("发送", for: .normal)
            case .search: setTitle("搜索", for: .normal)
            case .route: setTitle("路线", for: .normal)
            default:
                setTitle("换行", for: .normal)
                layer.backgroundColor = darkColor.cgColor
            }
            let name = title(for: .normal)
            setTitle(name, for: .disabled)
        }
        setTitleColor(letterColor, for: .normal)

        if darkMode {
            if !ConfigManager.shared.keyTransparent {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.2
            }
        } else {
            if ConfigManager.shared.keyGlass {
                layer.shadowOpacity = 0.2
            } else if !ConfigManager.shared.keyTransparent {
                layer.shadowColor = shadowColor.cgColor
                layer.shadowOpacity = 1
            }
        }
        if ConfigManager.shared.mapHint {
            textUp.textColor = darkMode ? textUpColorDark! : textUpColorLight!
            textUp.isHidden = LocalConfigManager.shared.tempHideHint
            textUp.setNeedsDisplay()
        }

        changeColorToUp()

        if tag == kReturnButtonID, returnKeyType != .default, !ConfigManager.shared.keyTransparent, !ConfigManager.shared.keyGlass {
            let titleColor = ConfigManager.shared.keyboardNoPattern ? UIColor.clear : UIColor.white
            setTitleColor(titleColor, for: .normal)
        }
    }
}

extension KeyboardKey {
    func getMapString() -> String {
        var result = ""
        if !noMapHint, let title = title(for: .normal)?.first?.lowercased() {
            result = ConfigManager.shared.spScheme_rev[title] ?? ""
        }
        return result
    }
}

extension KeyboardKey {
    @objc func buttonDown(_: UIControl? = nil) {
        KeyboardKey.currentKeyboardKeyID = tag
        popView.pop(fromButton: self)

        if [2, 3].contains(tag) { KeyboardKey.isPuncDragMode = true }

        UIView.performWithoutAnimation {
            self.changeColorToDown()
        }
    }

    @objc func buttonUp(_: UIControl? = nil) {
        popView.close(self)
        if [2, 3].contains(tag) { KeyboardKey.isPuncDragMode = false }

        UIView.performWithoutAnimation {
            self.changeColorToUp()
        }
    }

    func updateTextUpColor() {}

    func changeColorToDown() {
        if tag == kReturnButtonID, let c = highlitedColor {
            setTitleColor(c, for: .normal)
        }
        if tag > 10 {
            layer.backgroundColor = darkColor.cgColor
        } else if !ConfigManager.shared.keyTransparent, !ConfigManager.shared.keyGlass {
            layer.backgroundColor = whiteColor.cgColor
            if tag == kReturnButtonID, !darkMode {
                setTitleColor(.darkText, for: .normal)
            }
            if tag == kShiftButtonID {
                layer.backgroundColor = UIColor.white.cgColor
            }
        } else {
            layer.backgroundColor = darkColor.cgColor
        }
    }

    func changeColorToUp() {
        if tag == kReturnButtonID, let _ = highlitedColor {
            setTitleColor(normalColor, for: .normal)
        }

        if tag > 10 {
            layer.backgroundColor = whiteColor.cgColor
        } else if tag <= 10, tag != kReturnButtonID, !ConfigManager.shared.keyTransparent, !ConfigManager.shared.keyGlass {
            layer.backgroundColor = darkColor.cgColor
        } else if tag == kReturnButtonID, returnKeyType != .default, !ConfigManager.shared.keyTransparent, !ConfigManager.shared.keyGlass {
            layer.backgroundColor = sbBlue.cgColor
            if !darkMode {
                setTitleColor(.white, for: .normal)
            }
        } else if ConfigManager.shared.keyTransparent || ConfigManager.shared.keyGlass {
            layer.backgroundColor = whiteColor.cgColor
        } else {
            layer.backgroundColor = darkColor.cgColor
        }
        if tag == kShiftButtonID, keyboardMode == .upper {
            layer.backgroundColor = UIColor.white.cgColor
        }
    }
}

extension KeyboardKey {
    @objc func playTock(_ sender: UIButton) {
        let canVibrate = ConfigManager.shared.clickVibrate && !ConfigManager.shared.onlyBootVibrate
        if iphone7UP, canVibrate {
            impactGenerator?.trigger()
        }
        if ConfigManager.shared.clickSound {
            keySoundFeedbackGenerator?.makeSound(for: sender.tag)
        }
    }
}

var keyboardFontCache: UIFont?

extension KeyboardKey {
    func changeFont(for t: KeyboardType) {
        guard tag >= 100 && tag < 126 || tag == 127 || tag == 200 || tag >= 201 && tag <= 217 else { return }
        var size: CGFloat = 0
        var bottom: CGFloat = 0
        switch t {
        case .lower:
            size = ConfigManager.shared.lockUpperCase ? 22.5 : 24.5
            bottom = ConfigManager.shared.lockUpperCase ? 0 : 4
        case .upper, .punc:
            size = 22.5
            bottom = 0
        }
        let fn = t == .punc ? fontNamePunc : fontName
        if let f = keyboardFontCache, f.fontName == fn, f.pointSize == size {
            titleLabel?.font = f
        } else {
            keyboardFontCache = UIFont(name: fn, size: size)
            titleLabel?.font = keyboardFontCache
        }
        titleEdgeInsets.bottom = bottom
        setNeedsLayout()
        titleLabel.setNeedsDisplay()
    }

    var fontName: String {
        return ConfigManager.shared.keyboardKeyFontName
    }

    var fontNamePunc: String {
        let possibleTypes = ["Regular", "Light", "Medium", "Thin", "Ultralight", "Semibold"]
        let names = fontName.split(separator: "-")
        if names.count <= 1 { return "PingFangHK-Regular" }
        if possibleTypes.firstIndex(of: String(names[1])) != nil {
            return "PingFangHK-\(names[1])"
        }
        if names[1] == "Bold" {
            return "PingFangHK-Semibold"
        }
        return "PingFangHK-Regular"
    }
}

extension KeyboardKey {
    func removeSelfFromButtons() {
        if let i = KeyboardKey.keyboardButtons[tag]?.firstIndex(of: self) {
            KeyboardKey.keyboardButtons[tag]?.remove(at: i)
        }
    }
}
