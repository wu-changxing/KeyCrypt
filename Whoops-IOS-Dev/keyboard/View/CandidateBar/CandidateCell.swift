//
//  CandidateCellButton.swift
//  LoginputKeyboard
//
//  Created by Aaron on 4/21/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit
/// 候选字模板类

var VoiceOverLib: NSDictionary?
var VoiceOverLibVersion = 0

final class CandidateCell: UIControl {
    private let titleLabel: LILabel! = LILabel()
    private var _tag = 0

    /// 不使用系统的 tag， 很慢
    @IBInspectable override var tag: Int {
        get { return _tag }
        set { _tag = newValue }
    }

    override init(frame _: CGRect) {
        super.init(frame: CGRect())
        isUserInteractionEnabled = true
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.adjustable
        //        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        isOpaque = true
        backgroundColor = UIColor.clear
        if #available(iOSApplicationExtension 12, *) {
            layer.cornerRadius = 5
        }
        contentHorizontalAlignment = .center
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .middle
        NotificationCenter.default.addObserver(self, selector: #selector(modeChange), name: NSNotification.Name.KeyboardModeChanged, object: nil)
        addSubview(titleLabel)
    }

    private var boldFont = UIFont.systemFont(ofSize: deviceName == .iPad ? userSize + 2 : userSize, weight: .medium)
    private var normalFont = UIFont.systemFont(ofSize: deviceName == .iPad ? userSize + 2 : userSize)
    private var revealFont = UIFont.systemFont(ofSize: (deviceName == .iPad ? userSize + 2 : userSize) - 5)
    override func accessibilityIncrement() {
        if let cell = KeyboardViewController.inputProxy?.candidateBarController?.cellForIndex(at: tag - 1) {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: cell)
        } else {
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: accessibilityLabel)
        }
    }

    override func accessibilityDecrement() {
        if let cell = KeyboardViewController.inputProxy?.candidateBarController?.cellForIndex(at: tag + 1) {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: cell)
        } else {
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: accessibilityLabel)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        titleLabel.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }

    @objc func modeChange() {
        titleLabel.textColor = darkMode ? UIColor.white : UIColor.darkText
    }

    private var tRange = NSRange(location: 0, length: 0)
    private var cRange = NSRange(location: 0, length: 0)

    func displayText(_ t: String, c: String = "", r _: CodeTable = CodeTable()) {
        let textColor = darkMode ? UIColor.white : UIColor.darkText
        let codeColor = darkMode ? UIColor.lightGray : UIColor.darkGray
        let att = NSMutableAttributedString(string: t + " " + c)

        tRange.length = t.utf16.count
        cRange.length = c.utf16.count
        cRange.location = t.utf16.count + 1

        if ConfigManager.shared.firstBold, tag == 0, !KeyboardViewController.inputProxy!.zhInput!.isThinking {
            att.addAttributes([NSAttributedString.Key.font: boldFont], range: tRange)
        } else {
            att.addAttributes([NSAttributedString.Key.font: normalFont], range: tRange)
        }
        if ConfigManager.shared.firstColor, tag == 0, !KeyboardViewController.inputProxy!.zhInput!.isThinking {
            let value = ConfigManager.shared.firstColorValue
            att.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(rgb: value)], range: tRange)
        } else {
            att.addAttributes([NSAttributedString.Key.foregroundColor: textColor], range: tRange)
        }

        att.addAttributes(
            [
                NSAttributedString.Key.foregroundColor: codeColor,
                NSAttributedString.Key.font: revealFont,
            ],
            range: cRange
        )

        titleLabel.attributedString = att
        let size = att.size()
        frame.size.height = size.height.rounded()
        frame.size.width = size.width.rounded()
        setNeedsLayout()
        titleLabel.setNeedsDisplay()

        guard isVoiceOverOn else { return }
        if VoiceOverLibVersion != ConfigManager.shared.voiceOverLibVersion || VoiceOverLib == nil {
            let nameList = ["VoiceOverLib 2", "VoiceOverLib"]
            VoiceOverLibVersion = ConfigManager.shared.voiceOverLibVersion
            let libName = nameList[VoiceOverLibVersion]
            VoiceOverLib = NSDictionary(contentsOfFile: Bundle.main.path(forResource: libName, ofType: "plist")!)
        }

        var hint = ""
        let first = t.count > 2 ? t + "，" : ""
        for char in t {
            guard let lib = VoiceOverLib else { break }
            if let content = lib.object(forKey: String(char)) as? String {
                hint += content
                hint += "，"
            }
        }
        var result: String

        switch ConfigManager.shared.voiceOverReadStyle {
        case kVoiceOverPhraseWord:
            result = first + hint
        case kVoiceOverOnlyWord:
            result = hint
        case kVoiceOverOnlyPhrase:
            result = first
        default:
            result = ""
        }
        if result.isEmpty { result = String(t) }
        accessibilityLabel = result
        if tag == 0 {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self)
        }
    }
}

extension CandidateCell {
    override var isAccessibilityElement: Bool { get { true } set {}}
    override var accessibilityLabel: String? {
        get {
            super.accessibilityLabel ?? titleLabel.text
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
}
