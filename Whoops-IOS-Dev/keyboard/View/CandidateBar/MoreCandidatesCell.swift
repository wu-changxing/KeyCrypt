//
//  CandidatesCell.swift
//  flyinput
//
//  Created by Aaron on 16/7/23.
//  Copyright © 2016年 Aaron. All rights reserved.
//

import Foundation
import UIKit
/// 候选字模板类

var userSize: CGFloat {
    return CGFloat(ConfigManager.shared.candidateFontSize)
}

final class MoreCandidatesCell: UICollectionViewCell {
    let candidate = LILabel()
    private var _tag = 0

    /// 不使用系统的 tag， 很慢
    @IBInspectable override var tag: Int {
        get { return _tag }
        set { _tag = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.none
//        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        isOpaque = true
        backgroundView = nil
        backgroundColor = UIColor.clear
//        candidate.backgroundColor = UIColor.clear
        candidate.textAlignment = .center
//        candidate.adjustsFontSizeToFitWidth = true
//        candidate.minimumScaleFactor = 0.5
        candidate.lineBreakMode = .middle
        addSubview(candidate)
        NotificationCenter.default.addObserver(self, selector: #selector(modeChange), name: NSNotification.Name.KeyboardModeChanged, object: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        candidate.pin.all()
    }

    private var boldFont = UIFont.systemFont(ofSize: deviceName == .iPad ? userSize + 2 : userSize, weight: .medium)
    private var normalFont = UIFont.systemFont(ofSize: deviceName == .iPad ? userSize + 2 : userSize)
    private var revealFont = UIFont.systemFont(ofSize: (deviceName == .iPad ? userSize + 2 : userSize) - 5)
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private var tRange = NSRange(location: 0, length: 0)
    private var cRange = NSRange(location: 0, length: 0)

    @objc func modeChange() {
        candidate.textColor = darkMode ? UIColor.white : UIColor.darkText
    }

    func displayText(_ t: String, index: Int, c: String = "", raw _: CodeTable = CodeTable()) {
        let textColor = darkMode ? UIColor.white : UIColor.darkText
        let codeColor = darkMode ? UIColor.lightGray : UIColor.darkGray
        let att = NSMutableAttributedString(string: t + " " + c)

        tRange.length = t.utf16.count
        cRange.length = c.utf16.count
        cRange.location = t.utf16.count + 1

        if ConfigManager.shared.firstBold, index == 0, !KeyboardViewController.inputProxy!.zhInput!.isThinking {
            att.addAttributes([NSAttributedString.Key.font: boldFont], range: tRange)
        } else {
            att.addAttributes([NSAttributedString.Key.font: normalFont], range: tRange)
        }

        att.addAttributes([NSAttributedString.Key.foregroundColor: textColor], range: tRange)
        att.addAttributes(
            [
                NSAttributedString.Key.foregroundColor: codeColor,
                NSAttributedString.Key.font: revealFont,
            ],
            range: cRange
        )

        candidate.attributedString = att
        var size = att.size()
        size.height.round()
        size.width.round()
        candidate.frame.size = size
        setNeedsLayout()
        candidate.setNeedsDisplay()
    }

    func getText() -> String {
        return candidate.text
    }
}
