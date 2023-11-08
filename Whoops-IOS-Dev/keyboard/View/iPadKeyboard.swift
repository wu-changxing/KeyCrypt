//
//  iPadKeyboard.swift
//  fly
//
//  Created by Aaron on 9/18/17.
//  Copyright © 2017 Aaron. All rights reserved.
//

import UIKit
import UITextView_Placeholder

final class UILabelPadding: UILabel {
    private var padding = UIEdgeInsets.zero

    @IBInspectable
    var paddingLeft: CGFloat {
        get { return padding.left }
        set { padding.left = newValue }
    }

    @IBInspectable
    var paddingRight: CGFloat {
        get { return padding.right }
        set { padding.right = newValue }
    }

    @IBInspectable
    var paddingTop: CGFloat {
        get { return padding.top }
        set { padding.top = newValue }
    }

    @IBInspectable
    var paddingBottom: CGFloat {
        get { return padding.bottom }
        set { padding.bottom = newValue }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = padding
        var rect = super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
}

final class iPadKeyboard: UIView {
    var candidateBarController: CandidateBarController!
    let candidateRowView = UIView()
    let buffer = UILabelPadding()
    var blurView: CustomIntensityVisualEffectView?
    var imageView: UIImageView?
    var toolBar: ToolBar!

    let whiteBlock = UIView()

    var noteInputView: CYMTextView?
    var noteSaveButton: UIButton?
    var noteCleanButton: UIButton?

    let moveCurserGestureRecognizer = UIPanGestureRecognizer()
    let swipeDownDismissKeyboard = UISwipeGestureRecognizer()
    let tapBufferArea = UITapGestureRecognizer()
    let moreCandidate = UIButton()
    let shadowLine = UIView()
    let VODismissButton = KeyboardKey(tag: 1, isOrphan: true)
    init(keyboard: KeyboardViewController) {
        super.init(frame: CGRect())
        //        candidateView =
        candidateRowView.backgroundColor = UIColor.clear
        candidateBarController = CandidateBarController()
        whiteBlock.backgroundColor = UIColor.clear

        addGestureRecognizer(moveCurserGestureRecognizer)
        candidateRowView.addGestureRecognizer(swipeDownDismissKeyboard)
        buffer.addGestureRecognizer(tapBufferArea)
        moreCandidate.isHidden = !ConfigManager.shared.thinking

        shadowLine.isAccessibilityElement = false
        shadowLine.isHidden = !ConfigManager.shared.thinking
        shadowLine.backgroundColor = UIColor.clear
        shadowLine.layer.shadowColor = UIColor.gray.cgColor
        shadowLine.layer.shadowOffset = CGSize(width: -1, height: 0)
        shadowLine.layer.shadowRadius = 0
        shadowLine.layer.shadowOpacity = 0.5

        swipeDownDismissKeyboard.direction = .down
        tapBufferArea.addTarget(keyboard, action: #selector(keyboard.tapBufferArea))
        swipeDownDismissKeyboard.addTarget(keyboard, action: #selector(keyboard.SwipeDownDismissKeyboard))
        moveCurserGestureRecognizer.addTarget(keyboard, action: #selector(keyboard.KeyboardPanGestureRecognizer))
        VODismissButton.addTarget(keyboard, action: #selector(keyboard.SwipeDownDismissKeyboard), for: .touchUpInside)
        moreCandidate.addTarget(keyboard, action: #selector(keyboard.openMoreCandidateMode), for: .touchUpInside)
        moreCandidate.accessibilityElementsHidden = true
        toolBar = ToolBar(keyboard: keyboard)

//        keyboard.emojiSwitcher = segmentControl
        keyboard.swipeDownGestureRecognizer = swipeDownDismissKeyboard
        keyboard.moveCursorGestureRecognizer = moveCurserGestureRecognizer
        keyboard.candidateRowView = candidateRowView
        keyboard.inputBuffer = buffer
        keyboard.VODismissKeyboardButton = VODismissButton
        keyboard.moreCandidate = moreCandidate
        keyboard.shadowLine = shadowLine
        keyboard.candidateBackground = whiteBlock
        keyboard.candidateBarController = candidateBarController
        keyboard.toolBar = toolBar

        moveCurserGestureRecognizer.cancelsTouchesInView = false
        tapBufferArea.delaysTouchesEnded = false

        candidateBarController.barDelegate = keyboard
        buffer.isUserInteractionEnabled = true
        buffer.font = UIFont.systemFont(ofSize: 18)
        buffer.paddingLeft = 5
        buffer.paddingRight = 10

        VODismissButton.setTitle("收起键盘", for: .normal)
        VODismissButton.isHidden = true

        candidateRowView.addSubview(whiteBlock)
        candidateRowView.addSubview(candidateBarController)
        candidateRowView.addSubview(buffer)
        candidateRowView.addSubview(moreCandidate)
        candidateRowView.addSubview(shadowLine)
        candidateRowView.addSubview(VODismissButton)
        candidateRowView.addSubview(toolBar)

        addSubview(candidateRowView)

        if ConfigManager.shared.imgBg, ConfigManager.shared.imgBgFull {
            if ConfigManager.shared.imgBgBlur {
                blurView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .light), intensity: 0.3)
                candidateRowView.addSubview(blurView!)
                candidateRowView.sendSubviewToBack(blurView!)
            }
            FileSyncCheck.copyImageBG()
            imageView = UIImageView(image: UIImage(contentsOfFile: FileSyncCheck.bgImageLocalPath))
            imageView!.alpha = CGFloat(ConfigManager.shared.imgBgAlpha)
            addSubview(imageView!)
            sendSubviewToBack(imageView!)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        if frame.isEmpty {
            var frame = self.frame
            frame.size.width = UIScreen.main.bounds.width
            self.frame = frame
        }

        let h: CGFloat = isPrivacyModeOn && Platform.fromClientID(KeyboardViewController.inputProxy!.clientID) != nil ? 180 : 0
        candidateRowView.frame = CGRect(x: 0, y: h + 1, width: frame.width, height: kCandidateRowHeight)
        toolBar.frame = candidateRowView.bounds
        imageView?.frame = CGRect(x: 0, y: h + 1, width: frame.width, height: frame.height - h - 1)
        blurView?.frame = candidateRowView.bounds

        buffer.sizeToFit()
        let f = buffer.frame
        var s = CGRect(x: 0, y: 0, width: f.width, height: kCandidateRowHeight)
        if ConfigManager.shared.inLineBuffer {
            s.size.width = 0
        }
        buffer.frame = s
        let n: CGFloat = moreCandidate.isHidden ? 0 : kCandidateRowHeight + 0.5
        whiteBlock.frame = CGRect(x: 0, y: 0, width: frame.width - n, height: kCandidateRowHeight)
        candidateBarController.frame = CGRect(x: buffer.frame.maxX, y: 0, width: frame.width - buffer.frame.width - n, height: kCandidateRowHeight)
        moreCandidate.frame = CGRect(x: frame.width - kCandidateRowHeight, y: 0, width: kCandidateRowHeight, height: kCandidateRowHeight)
        shadowLine.frame = CGRect(x: frame.width - kCandidateRowHeight, y: 5, width: 0.5, height: kCandidateRowHeight - 5)
        shadowLine.layer.shadowPath = UIBezierPath(roundedRect: shadowLine.bounds, cornerRadius: 0).cgPath

        VODismissButton.frame = CGRect(x: Int(frame.width - 74 - 10), y: 8, width: 74, height: 34)
    }
}

extension iPadKeyboard: UITextViewDelegate {
    func unloadNoteViews() {
        noteInputView?.removeFromSuperview()
        noteSaveButton?.removeFromSuperview()
        noteCleanButton?.removeFromSuperview()

        noteInputView = nil
        noteSaveButton = nil
        noteCleanButton = nil
    }

    func generateNoteViewsIfNeeded() {
        guard noteInputView == nil else { return }
        noteInputView = CYMTextView()
        noteSaveButton = UIButton(type: .system)
        noteCleanButton = UIButton(type: .system)

        noteInputView?.isHidden = true
        noteInputView?.font = kBasic28Font
        noteInputView?.delegate = self
        noteInputView?.backgroundColor = UIColor.clear
        noteInputView?.placeholder = "点击这里输入便签内容……"

        noteSaveButton?.isHidden = true
        noteSaveButton?.setImage(#imageLiteral(resourceName: "enclosure"), for: .normal)
        noteSaveButton?.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        noteSaveButton?.contentHorizontalAlignment = .left
        noteSaveButton?.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
        noteCleanButton?.isHidden = true
        noteCleanButton?.setImage(#imageLiteral(resourceName: "eraser"), for: .normal)

        noteCleanButton?.addTarget(self, action: #selector(cleanButtonDidTap), for: .touchUpInside)

        addSubview(noteInputView!)
        addSubview(noteSaveButton!)
        addSubview(noteCleanButton!)
    }

    @objc func cleanButtonDidTap(_: UIButton) {
        noteInputView?.text = ""
    }

    @objc func saveButtonDidTap(_: UIButton) {
        let s = noteInputView!.text!
        if !ConfigManager.shared.lockNote {
            noteInputView?.endEditing(true)
            noteInputView?.resignFirstResponder()
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            KeyboardViewController.inputProxy?.saveNote(with: s, directly: false)
            self.noteInputView?.text = ""
        }
    }

    func textViewDidBeginEditing(_: UITextView) {
        needDismissKeyboard = true
    }
}
