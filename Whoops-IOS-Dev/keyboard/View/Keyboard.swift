//
//  Keyboard.swift
//  fly
//
//  Created by Aaron on 9/17/17.
//  Copyright © 2017 Aaron. All rights reserved.
//

import AudioToolbox
import DeviceKit
import UIKit
import UITextView_Placeholder
final class Keyboard: UIView {
//    let candidateRowHeight:CGFloat = 42
    var candidateBarController: CandidateBarController!
    let candidateRowView = UIView()
    let buffer = UILabel()
    var blurView: CustomIntensityVisualEffectView?
    var imageView: UIImageView?

    var toolBar: ToolBar!

    var noteInputView: CYMTextView?
    var noteSaveButton: UIButton?
    var noteCleanButton: UIButton?

    let moveCurserGestureRecognizer = UIPanGestureRecognizer()
    let swipeDownDismissKeyboard = UISwipeGestureRecognizer()
    let tapBufferArea = UITapGestureRecognizer()

    let VODismissButton = KeyboardKey(tag: 1, isOrphan: true)
    let moreCandidate = UIButton()
    let shadowLine = UIView()
    var notificationGenerator: UINotificationFeedbackGenerator?

    init(keyboard: KeyboardViewController) {
        super.init(frame: CGRect())

        candidateBarController = CandidateBarController()
        candidateRowView.backgroundColor = UIColor.clear
        addGestureRecognizer(moveCurserGestureRecognizer)
        candidateRowView.addGestureRecognizer(swipeDownDismissKeyboard)
        buffer.addGestureRecognizer(tapBufferArea)
        moreCandidate.isHidden = !ConfigManager.shared.thinking
        moreCandidate.accessibilityElementsHidden = true

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

        toolBar = ToolBar(keyboard: keyboard)
//        keyboard.emojiSwitcher = segmentControl
        keyboard.swipeDownGestureRecognizer = swipeDownDismissKeyboard
        keyboard.moveCursorGestureRecognizer = moveCurserGestureRecognizer
        keyboard.candidateBarController = candidateBarController
        keyboard.candidateRowView = candidateRowView
        keyboard.inputBuffer = buffer
        keyboard.VODismissKeyboardButton = VODismissButton
        keyboard.moreCandidate = moreCandidate
        keyboard.shadowLine = shadowLine
        keyboard.candidateBarController = candidateBarController
        keyboard.toolBar = toolBar

        moveCurserGestureRecognizer.cancelsTouchesInView = false

        candidateBarController.barDelegate = keyboard
//        candidateView.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        buffer.font = UIFont.systemFont(ofSize: 9)
        VODismissButton.setTitle("收键盘", for: .normal)
        VODismissButton.isHidden = true

        candidateRowView.addSubview(candidateBarController)
        candidateRowView.addSubview(buffer)
        candidateRowView.addSubview(moreCandidate)
        candidateRowView.addSubview(VODismissButton)
        candidateRowView.addSubview(shadowLine)
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
        if frame.size.width >= 660 || frame.size.width == 0, !isPortrait, !isX {
            let n: CGFloat = 660
            let x = (frame.size.width - n) / 2
            frame.size.width = n
            frame.origin.x += x
        } else if isPortrait, frame.isEmpty {
            frame.size.width = UIScreen.main.bounds.width
        }

        let h: CGFloat = isPrivacyModeOn && Platform.fromClientID(KeyboardViewController.inputProxy!.clientID) != nil ? kPrivacyHeight : 0
        candidateRowView.frame = CGRect(x: 0, y: h + 1, width: frame.width, height: kCandidateRowHeight)
        toolBar.frame = candidateRowView.bounds
        toolBar.setNeedsLayout()
        imageView?.frame = CGRect(x: 0, y: h + 1, width: frame.width, height: frame.height - h - 1)
        blurView?.frame = candidateRowView.bounds
        let n = moreCandidate.isHidden ? 0 : kCandidateRowHeight + 0.5
        candidateBarController.frame = CGRect(x: 0, y: 0, width: frame.width - n, height: kCandidateRowHeight)
        buffer.frame = CGRect(x: 12, y: 0, width: frame.width, height: 12)
        VODismissButton.frame = CGRect(x: Int(frame.width - 65), y: 2, width: 60, height: Int(kCandidateRowHeight - 4))
        moreCandidate.frame = CGRect(x: candidateRowView.frame.width - kCandidateRowHeight, y: 0, width: kCandidateRowHeight, height: kCandidateRowHeight)
        shadowLine.frame = CGRect(x: candidateRowView.frame.width - kCandidateRowHeight, y: 5, width: 0.5, height: kCandidateRowHeight - 5)
        shadowLine.layer.shadowPath = UIBezierPath(roundedRect: shadowLine.bounds, cornerRadius: 0).cgPath
    }
}

extension Keyboard: UITextViewDelegate {
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
        noteInputView?.font = UIFont(name: "PingFangSC-Regular", size: 12)
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
        if iphone7UP {
            impactGenerator?.trigger()
        }
    }

    @objc func saveButtonDidTap(_: UIButton) {
        if !ConfigManager.shared.lockNote {
            noteInputView?.endEditing(true)
            noteInputView?.resignFirstResponder()
        }
        if iphone7UP {
            if KeyboardViewController.inputProxy!.keyboardHasFullAccess() {
                notificationGenerator?.notificationOccurred(.success)
            } else {
                AudioServicesPlaySystemSound(1519)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            KeyboardViewController.inputProxy?.saveNote(with: self.noteInputView!.text!, directly: false)
            self.noteInputView?.text = ""
        }
    }

    func textViewDidBeginEditing(_: UITextView) {
        needDismissKeyboard = true
    }
}
