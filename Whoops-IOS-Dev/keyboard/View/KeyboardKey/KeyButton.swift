//
//  KeyButton.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/27/20.
//  Copyright © 2020 Aaron. All rights reserved.
//

import UIKit

class KeyButton: UIControl {
    let titleLabel: LILabel! = LILabel()
    var imageView: UIImageView! = UIImageView()
    var titleEdgeInsets = UIEdgeInsets.zero
    private var _tag = 0
    private var disabledTitle: String?
    var highlitedColor: UIColor?
    var normalColor: UIColor?

    /// 不使用系统的 tag， 很慢
    override var tag: Int {
        get { return _tag }
        set { _tag = newValue }
    }

    override init(frame _: CGRect) {
        super.init(frame: .zero)
        myInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        myInit()
    }

    private func myInit() {
        addSubview(imageView)
        addSubview(titleLabel)
        titleLabel.textAlignment = .center
        clipsToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0, y: -4 - titleEdgeInsets.bottom, width: width, height: height)
        imageView.frame = bounds
        titleLabel.setNeedsDisplay()
    }
}

extension KeyButton {
    func setTitle(_ text: String?, for state: UIButton.State) {
        guard state != .disabled else {
            disabledTitle = text
            return
        }

        titleLabel.text = text ?? ""
        setNeedsLayout()
    }

    func setTitleColor(_ color: UIColor?, for state: UIButton.State) {
        guard state != .highlighted else {
            highlitedColor = color
            return
        }
        if let c = color {
            titleLabel.textColor = c
            normalColor = c
        } else {
            titleLabel.textColor = .black
            normalColor = nil
        }
        titleLabel.setNeedsDisplay()
    }

    func setAttributedTitle(_ att: NSAttributedString?, for _: UIButton.State) {
        titleLabel.attributedString = att
        setNeedsLayout()
    }

    func title(for state: UIControl.State) -> String? {
        if state == .disabled { return disabledTitle }
        return titleLabel.text
    }

    func titleColor(for state: UIControl.State) -> UIColor? {
        if state == .highlighted { return highlitedColor }
        return normalColor
    }

    func setImage(_ image: UIImage?, for _: UIControl.State) {
        imageView.image = image
    }

    func image(for _: UIControl.State) -> UIImage? {
        return imageView.image
    }

    func attributedTitle(for _: UIControl.State) -> NSAttributedString? {
        return titleLabel.attributedString
    }

    var currentTitleColor: UIColor {
        return titleLabel.textColor
    } // normal/highlighted/selected/disabled. always returns non-nil. default is white(1,1)
    var currentTitle: String {
        return titleLabel.attributedString?.string ?? titleLabel.text
    }

    var currentImage: UIImage? {
        return imageView.image
    } // normal/highlighted/selected/disabled. can return nil

    var currentAttributedTitle: NSAttributedString? {
        return titleLabel.attributedString
    }
}

extension KeyButton {
    override var isAccessibilityElement: Bool { get { true } set {}}
    override var accessibilityLabel: String? {
        get {
            super.accessibilityLabel ?? titleLabel.text
        }
        set {
            super.accessibilityLabel = newValue
        }
    }

    override var accessibilityHint: String? {
        get {
            super.accessibilityHint
        }
        set {
            super.accessibilityHint = newValue
        }
    }
}

extension KeyButton {
    func addTarget(keyboard: KeyboardViewController) {
        addTarget(keyboard, action: #selector(keyboard.keyboardKeyUp), for: .touchUpInside)
        addTarget(keyboard, action: #selector(keyboard.keyboardKeyDown), for: .touchDown)
        addTarget(keyboard, action: #selector(keyboard.keyboardKeyUp), for: .touchUpOutside)
        addTarget(keyboard, action: #selector(keyboard.keyboardKeyOther), for: .touchDragOutside)
        addTarget(keyboard, action: #selector(keyboard.keyboardKeyOther), for: .touchCancel)
    }
}
