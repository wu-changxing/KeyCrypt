//
//  CYMTextView.swift
//  cym-keyboard
//
//  Created by Aaron on 4/2/19.
//  Copyright © 2019 CYM Solutions Limited. All rights reserved.
//

import UIKit
/// 获取一个没用的 UUID，主要给 CYMField 等控件使用
///
/// - Returns: UUID
func getUUID() -> UUID {
    let uuid = CFUUIDCreate(kCFAllocatorDefault)
    let string = CFUUIDCreateString(kCFAllocatorDefault, uuid)
    return UUID(uuidString: string! as String)!
}

typealias CYMTextViewDelegate = UITextViewDelegate

class CYMTextView: UITextView, UITextDocumentProxy {
    let kPasswordMask = "●"
    let cursor = UIView()

    private var secureText = ""
    private var cursorObserve: Any?
    private var _tag = 0

    /// 不使用系统的 tag， 很慢
    @IBInspectable override var tag: Int {
        get { return _tag }
        set { _tag = newValue }
    }

    var documentContextBeforeInput: String? {
        guard !text.isEmpty, text.utf16.count >= selectedRange.location else { return nil }
        let s = (text as NSString).substring(with: NSRange(location: 0, length: selectedRange.location))
        return s.isEmpty ? nil : s
    }

    var documentContextAfterInput: String? {
        let s = (text as NSString).substring(with: NSRange(location: selectedRange.location, length: text.utf16.count - selectedRange.location))
        return s.isEmpty ? nil : s
    }

    var selectedText: String?

    var documentInputMode: UITextInputMode?

    var documentIdentifier: UUID = getUUID()

    override var isFirstResponder: Bool {
        KeyboardViewController.inputProxy?.commonInputProxy?.isEqual(self) ?? false
    }

    func adjustTextPosition(byCharacterOffset offset: Int) {
        selectedRange.location += offset
        layoutSubviews()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        myInit()
    }

    override var text: String! {
        get {
            return isSecureTextEntry ? secureText : super.text
        }
        set {
            if isSecureTextEntry, let s = newValue {
                secureText = s
                let a = String(repeating: kPasswordMask, count: newValue.count)
                super.text = a
            } else {
                super.text = newValue
            }

            if !cursor.isHidden {
                setNeedsLayout()
            }
        }
    }

    func myInit() {
        tag = 991
        let gr = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(gr)
        if ConfigManager.shared.firstColor {
            let color = UIColor(rgb: ConfigManager.shared.firstColorValue)
            cursor.backgroundColor = color
        } else {
            cursor.backgroundColor = tintColor
        }
        autocapitalizationType = .none
    }

    func reg() {
        addSubview(cursor)
        cursor.isHidden = true
        cursor.addOpacityAnimation()
        cursorObserve = (KeyboardViewController.inputProxy as! KeyboardViewController).observe(\KeyboardViewController.commonInputProxy, options: [.new]) { _, change in

            var isMe = false
            if let field = change.newValue as? CYMTextView,
               field == self
            {
                isMe = true
                self.updateCursor()
            }
            self.cursor.isHidden = !isMe
        }
        autocapitalizationType = .none
    }

    func unreg() {
        cursorObserve = nil
        cursor.removeOpacityAnimation()
        cursor.removeFromSuperview()
    }

    deinit {
        cursorObserve = nil
    }

    func updateCursor() {
        guard let position = selectedTextRange else { return }
        let rect = caretRect(for: position.start)
        cursor.frame = rect
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        if let should = delegate?.textViewShouldBeginEditing?(self), !should {
            return false
        }
        reg()
        let keyboard = KeyboardViewController.inputProxy!
        keyboard.commonInputProxy = self
        delegate?.textViewDidBeginEditing?(self)
        return false
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        KeyboardViewController.inputProxy?.commonInputProxy = nil
        unreg()
        delegate?.textViewDidEndEditing?(self)
        return true
    }

    @discardableResult
    override func endEditing(_: Bool) -> Bool {
        return resignFirstResponder()
    }

    override var selectedRange: NSRange {
        get {
            return super.selectedRange
        }
        set {
            super.selectedRange = newValue
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCursor()
        UIView.performWithoutAnimation {
            guard !text.isEmpty else { return }
            let location = text.utf8.count - 1
            let bottom = NSMakeRange(location, 1)
            self.scrollRangeToVisible(bottom)
        }
    }

    override func insertText(_ text: String) {
        guard delegate?.textView?(self, shouldChangeTextIn: NSRange(location: NSNotFound, length: NSNotFound), replacementText: text) ?? true else {
            return
        }
        if let _ = markedTextRange {
            setMarkedText(nil, selectedRange: NSRange(location: 0, length: 0))
        }
        if let currentPosition = selectedTextRange, !isSecureTextEntry {
            super.replace(currentPosition, withText: text)
        } else {
            if isSecureTextEntry {
                secureText += text
                super.insertText(String(repeating: kPasswordMask, count: text.count))
            } else {
                super.insertText(text)
            }
        }
        setNeedsLayout()
        delegate?.textViewDidChange?(self)
    }

    override func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        super.setMarkedText(markedText, selectedRange: selectedRange)
        setNeedsLayout()
    }

    override func unmarkText() {
        super.unmarkText()
        setNeedsLayout()
    }

    override func deleteBackward() {
        super.deleteBackward()
        if isSecureTextEntry {
            secureText = secureText.subString(to: -1)
        }
        setNeedsLayout()
        delegate?.textViewDidChange?(self)
    }

    @objc func didTap() {
        _ = becomeFirstResponder()
    }
}
