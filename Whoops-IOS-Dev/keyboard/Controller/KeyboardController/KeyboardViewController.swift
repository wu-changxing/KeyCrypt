//
//  KeyboardViewController.swift
//  keyboard
//
//  Created by Aaron on 7/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import AudioToolbox
import DeviceKit
import Firebase
import Kingfisher
import LoginputEngineLib
import MMKVAppExtension
import UIKit

var iphone7UP = false
var darkMode = false
var returnKeyType = UIReturnKeyType.default
var keyboardLayout: KeyboardLayout = .qwerty

var isVoiceOverOn: Bool { return UIAccessibility.isVoiceOverRunning }
var isContinueDelete = false
var lastInputedString = "" // 记录上一次输入的内容，为;u引导符提供字符串长度

enum KeyboardLayout: Int {
    case qwerty = 0, key9 = 8
}

var impactGenerator: KeyFeedbackGenerator?
var keySoundFeedbackGenerator: KeySoundFeedbackGenerator?

class KeyboardViewController: UIInputViewController {
    /// 内部输入源，如果为空则正常输入，如果不为空，则输入到此而不是系统API
    @objc dynamic weak var commonInputProxy: UITextDocumentProxy?
    lazy var clientID: String = {
        self.parent?.value(forKey: "_hostBundleID") as? String ?? ""
    }()

    lazy var marsWordDict = NSDictionary(contentsOf: Bundle.main.url(forResource: "jt2hx", withExtension: "plist")!)

    var isQuickEditorFunctionsOpening = false
    var isMorePuncControllerOpening = false
    var isCandidateModifyViewOpening = false
    weak var candidateModifyView: CandidateModifyController?

    var isMoreCandidateViewOpening = false
    weak var moreCandidateView: MoreCandidateController?
    weak var moreCandidate: UIButton!
    weak var shadowLine: UIView!

    var isEnglishKeyboardOpening = false
    var englishKeyboard: UIView?

//    var isMessageBoardOpening = false
//    var messageBoard: MessageBoard?

    var isEmojiBoardOpening = false
    var emojiBoard: EmojiKeyboardController?

    var isNumbericBoardOpening = false
    var numbericBoard: UIView?

    weak var toolBar: ToolBar!
    weak var whoopsInputBar: InputBar?
    weak var chatHistoryView: ChatHistoryView?

    var isInviteViewOpening = false {
        didSet {
            NotificationCenter.default.post(name: .inviteViewOpenChanged, object: nil, userInfo: nil)
        }
    }

    var inviteView: InviteView?

    var transferView: WhoopsNavigationController?

    var isContactViewOpening = false {
        didSet {
            NotificationCenter.default.post(name: .contactViewOpenChanged, object: nil, userInfo: nil)
        }
    }

    var contactView: ContactController?

    var isMoreSettingViewOpening = false {
        didSet {
            NotificationCenter.default.post(name: .moreViewOpenChanged, object: nil, userInfo: nil)
        }
    }

    var moreSettingView: MoreSettingView?

    lazy var heightConstraint: NSLayoutConstraint! = { [unowned self] in
        let constraint = NSLayoutConstraint(item: self.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: ConfigManager.shared.keyboardHeight)
        constraint.priority = UILayoutPriority(rawValue: 999.0)
        return constraint
    }()

    public weak static var inputProxy: InputProxy?
    var customInterface: UIView!

    var zhInput: ZhInput?
    var engineHasBuffer: Bool { !(zhInput?.isThinking ?? true) }

    fileprivate lazy var inLineController = InLineController()

    fileprivate var configManager: ConfigManager {
        return ConfigManager.shared
    }

    var candidates: CodeTableArray = []

    weak var candidateRowView: UIView!

    weak var inputBuffer: UILabel!

    var candidateBarController: CandidateBarController!

    //    @IBOutlet weak var bufferRow: UIView!
    @IBOutlet var keyboardView: UIView!

    @IBOutlet var shiftKey: KeyboardKey! // 分号引导按钮

    /// 根据条件集中控制键盘的显示
    ///
    /// - parameter hidden: 是否隐藏
    func keyboardNeedHidden(_ hidden: Bool) {
        if hidden {
            customInterface?.isHidden = true
        } else {
            customInterface?.isHidden = false
            addConstraintsToKeyboard(customInterface)
        }
    }

    @IBAction func closeEmojiKeyboard(_: Any) {
        emojiInputModeDismiss()
    }

    weak var moveCursorGestureRecognizer: UIPanGestureRecognizer!

    var recognizerCount = 0
    var punc: KeyboardKey?
    private var cursorDidMove = false
    /// 键盘手势识别，根据手势不同将动作分发给不同的函数
    @objc func KeyboardPanGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        guard !isQuickEditorFunctionsOpening else { return }

        if sender.state == .ended {
            sender.cancelsTouchesInView = false
        }

        let angle = getAngle(point: sender.translation(in: sender.view)) /// 获取手指拖动的角度
        //        let velocity = sender.velocity(in: sender.view)
        let translation = sender.translation(in: sender.view)
        guard KeyboardKey.currentKeyboardKeyID != kDeleteButtonID else {
            if angle < 45 || angle > -45, translation.x < -25, !cursorDidMove, sender.state == .ended {
                TouchLayer.current?.touchCancel()
                cleanInputBuffer()
            }
            return
        }
        guard KeyboardKey.currentKeyboardKeyID != kReturnButtonID else {
            if angle < 45 || angle > -45, translation.x < -25, !cursorDidMove, sender.state == .ended {
                TouchLayer.current?.touchCancel()
                traceback()
            }
            return
        }
        if keyboardMode == .punc { dragMode(sender); return } // 此处应当第一个判定避免被其他手势覆盖！
        if keyboardMode == .upper, !CapsLock { dragMode(sender); return } // 此处应当第一个判定避免被其他手势覆盖！
        //        if let b = inLineController?.isBuffering {if b {return}}
        //

//        if angle < -45 || angle > 45, translation.y < -25, KeyboardKey.currentKeyboardKeyID >= 100, !cursorDidMove {
//            guard !isNumbericBoardOpening else { return }
//            pendingKey = nil
//            TouchLayer.current?.touchCancel()
//            if configManager.reverseSwipe { swipeDownMode(sender) }
//            else { swipeUpMode(sender) }
//            return
//        }
//        if angle < -45 || angle > 45, translation.y > 25, KeyboardKey.currentKeyboardKeyID >= 100, !cursorDidMove {
//            guard !isNumbericBoardOpening else { return }
//            pendingKey = nil
//            TouchLayer.current?.touchCancel()
//            if configManager.reverseSwipe { swipeUpMode(sender) }
//            else { swipeDownMode(sender) }
//            return
//        }

        //        guard abs(sender.velocity(in: sender.view).y) < 200 else {return}//避免识别了上下滑动的同时还识别为左右
        if engineHasBuffer, !candidates.isEmpty, !configManager.moveCursorWhenInput { return }
        if sender.state == .ended {
            zhInput?.displaySmartHint()
        }
        if #available(iOSApplicationExtension 13.0, *),
           configManager.inLineBuffer,
           engineHasBuffer
        {
            if sender.state == .began {
                textDocumentProxy.setMarkedText("", selectedRange: NSRange(location: 0, length: 0))
            }
            if sender.state == .ended {
                zhInput?.bufferChanged()
            }
        }
        if configManager.moveCursorOnlySpace, sender.state != .ended {
            guard sender.numberOfTouches > 0 else { return }
            let location = sender.location(ofTouch: 0, in: sender.view)
            var pointInside = false
            for but in KeyboardKey.keyboardButtons[126] ?? [] {
                let buttonRect = but.convert(but.bounds, to: sender.view)
                pointInside = buttonRect.contains(location)
            }
            guard pointInside else { return }

            pendingKey = nil
            sender.cancelsTouchesInView = true
        }
        moveCursorMode(sender)
    }

    func swipeDownMode(_ sender: UIPanGestureRecognizer) {
        //        guard abs(sender.translation(in: keyboardView).x) < 20 else {return}
        guard sender.state == .ended,
              !isEmojiBoardOpening,
              !isMoreCandidateViewOpening,
              !isCandidateModifyViewOpening,
              !isEnglishKeyboardOpening
        else { return }
        if configManager.clickVibrate {
            if keyboardHasFullAccess(), iphone7UP {
                let g = UIImpactFeedbackGenerator(style: .medium)
                g.impactOccurred()
            } else {
                AudioServicesPlaySystemSound(1519)
            }
        }

        let result = zhInput!.shortCutInput(buttonTag: KeyboardKey.currentKeyboardKeyID, isDown: true)
        if let button = KeyboardKey.keyboardButtons[KeyboardKey.currentKeyboardKeyID] {
            for b in button { b.buttonUp() }
        }
        KeyboardKey.currentKeyboardKeyID = 0
        guard !result else { return }

        guard sender.state == .ended,
              !isEmojiBoardOpening,
              !configManager.disableSwipeDownToEmoji
        else { return }
        emojiInputMode()
    }

    private lazy var maskButton: KeyboardKey = {
        let b = KeyboardKey(tag: 666, isOrphan: true)
        return b
    }()

    func swipeUpMode(_ sender: UIPanGestureRecognizer) {
        guard sender.state == .ended,
              !isEmojiBoardOpening,
              !isMoreCandidateViewOpening,
              !isCandidateModifyViewOpening,
              !isEnglishKeyboardOpening
        else { return }
        if configManager.clickVibrate {
            if iphone7UP, keyboardHasFullAccess() {
                let g = UIImpactFeedbackGenerator(style: .medium)
                g.impactOccurred()
            } else {
                AudioServicesPlaySystemSound(1519)
                // Fallback on earlier versions
            }
        }
        if KeyboardKey.currentKeyboardKeyID == 126,
           !configManager.spaceSwipeUpMask,
           engineHasBuffer || configManager.spaceUpThink
        {
            if candidates.count > 1 {
                KeyboardViewController.inputProxy?.didSelectCandidate(1)
            } else {
                KeyboardViewController.inputProxy?.didSelectCandidate(0)
            }
        } else if KeyboardKey.currentKeyboardKeyID == 126, configManager.isCodeTableModeOn, configManager.spaceSwipeUpMask {
            keyboardKeyConfirm(maskButton)
        } else {
            _ = zhInput?.shortCutInput(buttonTag: KeyboardKey.currentKeyboardKeyID)
        }

        if let button = KeyboardKey.keyboardButtons[KeyboardKey.currentKeyboardKeyID] {
            for b in button { b.buttonUp() }
        }
        KeyboardKey.currentKeyboardKeyID = 0
    }

    /// 左右划来移动光标，根据移速度不同，光标的移动速度也变化
    func moveCursorMode(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            if cursorDidMove {
                configManager.setKeyboardNoPattern(false)
                LocalConfigManager.shared.setTempHideHint(false)
                NotificationCenter.default.post(name: .KeyboardModeChanged, object: self, userInfo: nil)
                changeMode()
            }
            cursorDidMove = false
            return
        }
        //        guard abs(sender.translation(in: view).y) < 10 else {return}

        guard abs(sender.translation(in: view).x) > 20 || cursorDidMove else { return }
        let v = Int(sender.velocity(in: view).x)
        recognizerCount += Int(abs(v) / 10)
        //        LogPrint(log:sender.translation(in: view).x)
        guard recognizerCount > 70 else { return }
        recognizerCount = 0
        pendingKey?.cancelTracking(with: nil)
        pendingKey = nil
        TouchLayer.current?.touchCancel()
        if !cursorDidMove, !configManager.keyboardNoPattern {
            if configManager.clickVibrate, iphone7UP {
                impactGenerator?.trigger()
            }
            cursorDidMove = true
            configManager.setKeyboardNoPattern(true)
            LocalConfigManager.shared.setTempHideHint(true)
            changeMode()
            NotificationCenter.default.post(name: .KeyboardModeChanged, object: self, userInfo: nil)
        }

        if sender.velocity(in: view).x < 0 {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: -1)
        } else {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
        }
    }

    func dragMode(_ sender: UIPanGestureRecognizer) {
        if KeyboardKey.currentKeyboardKeyID == shiftKey.tag {
            shiftKey.buttonDown(shiftKey)
        } else if KeyboardKey.currentKeyboardKeyID == puncKey.tag {
            puncKey.buttonDown(puncKey)
            puncKey2?.buttonDown(puncKey)
        }
        guard sender.state != .ended else {
            if let b = punc {
                pendingKey = nil
                keyboardKeyDown(b)
                keyboardKeyUp(b)
                punc = nil
            }

            if KeyboardKey.isPuncDragMode {
                zhInput?.changeBoard(type: .lower)
            }

            puncKey.buttonUp()
            puncKey2?.buttonUp()

            if !CapsLock {
                shiftKey.buttonUp()
            }
            return
        }
        guard sender.numberOfTouches > 0 else { return }
        let location = sender.location(ofTouch: 0, in: sender.view)
        for (keyID, butArr) in KeyboardKey.keyboardButtons where keyID >= 100 {
            for but in butArr where but.point(inside: sender.view!.convert(location, to: but), with: nil) {
                punc?.buttonUp()
                punc?.cancelTouch()

                but.buttonDown()
                punc = but
                return
            }
        }
    }

    var continueDeleteTimer = Timer()
    @IBAction func longPressContinueDelete(_ sender: UILongPressGestureRecognizer) { // 留给emoji
        guard let button = sender.view as? UIButton else { return }
        if button.tag == kDeleteButtonID {
            continueDelete(sender)
        }

        if button.tag == kReturnButtonID {
            softReturn(sender)
        }
    }

    private lazy var b = KeyboardKey(tag: kDeleteButtonID, isOrphan: true)

    @objc func vback() {
        guard okToUse else {
            return
        }
        // 模拟一次 ⌫ 的点击
        keyboardKeyDown(b)
        keyboardKeyUp(b)
        if configManager.clickSound {
            keySoundFeedbackGenerator?.makeSound(for: b.tag)
        }
    }

    @IBOutlet var cleanButton: KeyboardKey! // 退格键，为动作识别委托而引用
    @IBOutlet var VODismissKeyboardButton: KeyboardKey!
    @IBAction func SwipeDownDismissKeyboard(_: Any) {
        isKeyboardUsed = true
        dismissKeyboard()
    }

    @IBOutlet var tmp2T: KeyboardKey!
    @IBOutlet var tmpRe: KeyboardKey!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label4: UILabel!
    @IBOutlet var slider: UISlider!

    @IBAction func changeKeyboardHeight(_ sender: UISlider) {
        let value = sender.value
        label3?.text = String(Int(value))
        label4?.text = String(Int(value))
        //        keyboardAdjustView?.frame = view.frame
        heightConstraint.constant = CGFloat(value)
        configManager.setKeyboardHeight(heightConstraint.constant)
        addConstraintsToKeyboard(customInterface)
        DispatchQueue.main.async {
            let b = UIView()
            self.view.addSubview(b)
            b.removeFromSuperview()
        }
    }

    @IBAction func is2T(_: UIButton) {
        configManager.setS2T(!configManager.s2t)
        UIView.animate(withDuration: 0.08, animations: {
            self.tmp2T.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: {
            if $0 {
                UIView.animate(withDuration: 0.1) {
                    self.tmp2T.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        })
        if configManager.s2t {
            tmp2T.setTitle("临时出繁:开", for: .normal)
        } else {
            tmp2T.setTitle("临时出繁:关", for: .normal)
        }
    }

    @IBAction func closeAdjustView(_: UIButton) {
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "快捷面板已关闭")
        let kView = keyboardAdjustViewVO
        UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: {
            kView!.removeFromSuperview()
        }, completion: { _ in
            self.configManager.setKeyboardHeight(self.heightConstraint.constant)
            //                    self.longPressChangeKeyboardHeight = false
        })
    }

    lazy var keyboardAdjustViewVO: UIView! = {
        UINib(nibName: "KeyboardHeightAdjustVO", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? UIView
    }()

    //    private var longPressChangeKeyboardHeight = false

    @IBAction func VOCleanBuffer(_: KeyboardKey) {
        closeAdjustView(UIButton())
        zhInput?.cleanUp()
    }

    @IBAction func VOOpenEmoji(_: KeyboardKey) {
        closeAdjustView(UIButton())
        if let button = KeyboardKey.keyboardButtons[KeyboardKey.currentKeyboardKeyID] {
            for b in button { b.buttonUp() }
        }
        emojiInputMode()
    }

    // MARK: 所有按下的按钮统一处理

    var pendingKey: KeyboardKey?
    @IBAction func keyboardKeyDown(_ sender: KeyboardKey) {
        if sender == pendingKey { return }

        if (sender.tag == kShiftButtonID) ||
            (sender.tag == kNumberButtonID)
        {
            keyboardKeyConfirm(sender)
            pendingKey = sender
            return
        }

        if let pending = pendingKey, pending.tag != kShiftButtonID, pending.tag != kNumberButtonID {
            keyboardKeyConfirm(pending)
        }

        pendingKey = sender
    }

    @IBAction func keyboardKeyOther(_ sender: KeyboardKey) {
        guard keyboardMode == .lower else {
            return
        }
        guard let pending = pendingKey else { return }
        if sender.tag == pending.tag {
            pendingKey = nil
        } else {
            keyboardKeyUp(pending)
            pendingKey = nil
        }
    }

    private var lastButtonID: KeyboardKeyID = -1
    @IBAction func keyboardKeyUp(_ sender: KeyboardKey) {
        if (sender.tag == kShiftButtonID) ||
            (sender.tag == kNumberButtonID)
        {
            pendingKey = nil
            return
        }
        guard let pending = pendingKey, sender.tag == pending.tag else { return }
        keyboardKeyConfirm(pending)
        pendingKey = nil
    }

    private func keyboardKeyConfirm(_ sender: KeyboardKey) {
//        if configManager.colorfulStyle >= 0 {
//            isKeyboardUsed = true // 如果开启炫彩，就不再频繁响应黑白刷新？
//        }
        guard sender.tag != kEarthButtonID else {
            if #available(iOSApplicationExtension 11.0, *) {
                guard !needsInputModeSwitchKey else { return }
                openEmojiOrMessageBoard()
            }
            return
        }

        //        NotificationCenter.default.post(name: NSNotification.Name.DidTapButton, object: sender)
        zhInput?.keyPress(sender)
        if sender.tag != kShiftButtonID, sender.tag != kNumberButtonID {
            sender.buttonUp()
        }
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.left, .right, .bottom]
    }

    weak var puncKey: KeyboardKey!

    weak var puncKey2: KeyboardKey!

    weak var swipeDownGestureRecognizer: UISwipeGestureRecognizer!

    private var widthCache: CGFloat = 0
    var firstSet = true
    func settingKeyboardHeightAndWidth() {
        guard !view.frame.isEmpty else {
            return
        }
        heightConstraint.constant = configManager.keyboardHeight
        if #available(iOSApplicationExtension 12.0, *),
           deviceName == .iPad,
           view.frame.size.width != UIScreen.main.bounds.width
        {
            // ipad 里的 iPhone 兼容模式
            customInterface.removeFromSuperview()
            customInterface = AlphaButtons(keyboard: self, layout: keyboardLayout)
            self.view.addSubview(customInterface)
            heightConstraint.constant *= 0.8
        }
        if deviceName == .iPad, widthCache > 0, view.frame.size.width != widthCache {
            heightConstraint.constant *= 0.7
        }
        view.addConstraint(heightConstraint) // 添加键盘高度约束
        if widthCache > 0, view.frame.size.width != widthCache {
            view.layoutSubviews()
        }
        if let v = customInterface {
            addConstraintsToKeyboard(v)
        }
        widthCache = view.frame.size.width
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        guard #available(iOSApplicationExtension 12, *) else { return }
        settingKeyboardHeightAndWidth()
        // Add custom view sizing constraints here
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard #available(iOSApplicationExtension 12, *), isX || deviceName == .iPad else { return }
        // 为 iPhone X 及以上全面屏设备进行额外的屏幕宽度检查，以修正横屏宽度问题和兼容模式问题
        if widthCache > 0, view.frame.size.width != widthCache {
            view.layoutSubviews()
            if let v = customInterface {
                addConstraintsToKeyboard(v)
            }
            widthCache = view.frame.size.width
        }
    }

    // MARK: 初始化器

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        KeyboardViewController.inputProxy = self
        MMKV.initialize(rootDir: nil, logLevel: .none)
        configManager.getConfig()
    }

    override func loadView() {
        if deviceName == .iPad {
            view = iPadKeyboard(keyboard: self)
        } else {
            view = Keyboard(keyboard: self)
        }
        if #available(iOSApplicationExtension 12, *) {
        } else {
            view.addConstraint(heightConstraint) // 添加键盘高度约束
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_: Bool) {
        /*
         keyboard layouts:
         0:qwerty26
         1:qwerty27
         2:dvorak26
         */
        needDismissKeyboard = false
        customInterface?.removeFromSuperview()
        if keyboardLayout == .key9 {
            customInterface = NKeyButtons(keyboard: self, layout: keyboardLayout)
        } else if deviceName == .iPad {
            customInterface = iPadAlphaButtons(keyboard: self, layout: keyboardLayout)
        } else {
            customInterface = AlphaButtons(keyboard: self, layout: keyboardLayout)
        }

        //        LogPrint(log: "界面约束添加完成")
        if #available(iOSApplicationExtension 12.0, *) {}
        else if let v = customInterface {
            if !isVoiceOverOn, deviceName == .iPhone, [.default, .done, .send].firstIndex(of: returnKeyType) == nil, firstSet {
                heightConstraint.constant = configManager.keyboardHeight - 42
                addConstraintsToKeyboard(v, full: true)

            } else {
                heightConstraint.constant = configManager.keyboardHeight
                addConstraintsToKeyboard(v)
            }
            widthCache = view.frame.size.width
        }

        view.addSubview(customInterface)
        moveCursorGestureRecognizer.delegate = self

        popView.frame = view.frame
        popView.isHidden = true
        view.addSubview(popView)

        VODismissKeyboardButton?.isHidden = !isVoiceOverOn

        keyboardMode = .lower // 避免shift丢失图标
        CapsLock = false
        isEnMode = false // 英文模式补丁，每次重新初始化

        zhInput = ZhInput(self)
        zhInput?.active()
        zhInput?.changeBoard(type: .lower) // 避免6s 等设备启动后字母错位。

        if deviceName == .iPad, widthCache > 0, view.frame.size.width != widthCache {
            heightConstraint.constant *= 0.7
        }

        // Add custom view sizing constraints here
        // FIXME: 键盘高度到底该怎么调节？
    }

    override func viewDidAppear(_: Bool) {
        isTempInputing = false
        if #available(iOSApplicationExtension 12.0, *) {}
        else if widthCache > 0, view.frame.size.width != widthCache {
            view.layoutSubviews()
            if let v = customInterface { // 用来额外兼容iPhone的兼容模式，不能去掉
                if !isVoiceOverOn, deviceName == .iPhone, [.default, .done, .send].firstIndex(of: returnKeyType) == nil, firstSet {
                    addConstraintsToKeyboard(v, full: true)
                } else {
                    addConstraintsToKeyboard(v)
                }
            }
        }
        if #available(iOSApplicationExtension 13.0, *) {
            let b = UIView()
            self.view.addSubview(b)
            b.removeFromSuperview()
        }

        NotificationCenter.default.post(name: .KeyboardDidPopUp, object: nil)

        DispatchQueue.global(qos: .userInteractive).async {
            self.configObservers()

            if !Device.current.isOneOf([.iPhone4s, .iPhone5, .iPhone5c, .iPhone5s, .iPhone6, .iPhone6Plus, .simulator(.iPhone6s)]),
               Device.current.isPhone
            {
                iphone7UP = true
            }
            Database.shared.cleanCache()
        }

        impactGenerator = KeyFeedbackGenerator()
        keySoundFeedbackGenerator = KeySoundFeedbackGenerator()

        PasteBoard.shared.start()
        ChatEngine.shared.toolBar = toolBar
        DispatchQueue.global().async {
            if self.keyboardHasFullAccess() {
                ChatEngine.shared.login()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.toast(str: "键盘需要开启完全访问权限才能联网")
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if okToUse, !self.engineHasBuffer, returnKeyType != .search {
                self.zhInput?.displaySmartHint()
            }
            if [.decimalPad, .numberPad, .numbersAndPunctuation].contains(self.textDocumentProxy.keyboardTypeSafe) {
                self.openNumberKeyboard()
                self.zhInput?.cleanUp()
            }
        }
        guard let p = Platform.fromClientID(clientID) else {
            return // 仅限支持的平台才能进行隐私聊天
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if isPrivacyModeOn {
                self.openPrivacyMode(atStart: true)
                let recentList = NetLayer.recentUserList(for: p)
                if let u = LocalConfigManager.shared.lastChatTarget, let r = recentList.first, u == r {
                    ChatEngine.shared.setTarget(user: u)
                } else {
                    LocalConfigManager.shared.lastChatTarget = nil
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        zhInput?.deActive()
        ChatEngine.shared.removeTarget()
        super.viewWillDisappear(animated)
    }

    override func willRotate(to _: UIInterfaceOrientation, duration _: TimeInterval) {}

    override func didRotate(from _: UIInterfaceOrientation) {
        dismissKeyboard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        LoginputEngineLib.shared.cleanCache()
        candidateBarController.purge()
        ImageCache.default.clearMemoryCache()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(_: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }

    //    不能使用这个，否则无法监控系统黑白状态切换并实时改变
    //    @available(iOSApplicationExtension 12.0, *)
    //    override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
    //        get {
    //            switch ConfigManager.shared.skinColor {
    //            case kSkinColorDark: return .dark
    //            case kSkinColorWhite: return .light
    //            default: return .unspecified
    //            }
    //        }
    //        set {}
    //    }

    // MARK: 在这里配适系统黑白色调

    override func textDidChange(_: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        let keyboardAppearance = textDocumentProxy.keyboardAppearance ?? .default

        var systemDarkMode = false
        if #available(iOSApplicationExtension 13.0, *) {
            systemDarkMode = traitCollection.userInterfaceStyle == .dark && keyboardAppearance != .light
            // 判断一下键盘颜色如果指定了是白色，那就肯定不是黑色模式，避免系统检测第一次是黑色第二次是白色，导致键盘在不支持黑色模式的app中显示为灰色
        } else {
            // Fallback on earlier versions
        }

        processKeyboardColors(keyboardAppearance: keyboardAppearance, systemDarkMode: systemDarkMode)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        var keyboardAppearance: UIKeyboardAppearance = .default
        var systemDarkMode = false
        if #available(iOSApplicationExtension 13.0, *) {
            guard let p = previousTraitCollection?.userInterfaceStyle else {
                return
            }
            systemDarkMode = p != .dark
            keyboardAppearance = systemDarkMode ? .dark : .default

        } else {
            return
                // Fallback on earlier versions
        }
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = nil
            self.processKeyboardColors(keyboardAppearance: keyboardAppearance, systemDarkMode: systemDarkMode)
        }
    }

    private var isKeyboardUsed = false
    private var statusCache: UIKeyboardAppearance?

    func processKeyboardColors(keyboardAppearance: UIKeyboardAppearance, systemDarkMode: Bool) {
        if statusCache != nil, !engineHasBuffer, !cursorDidMove {
            // 移动光标时不刷新联想，移动完再刷新
            zhInput?.displaySmartHint() // 用户点击发送后重置键盘状态
        }
        guard !isKeyboardUsed else { return } // 如果键盘已经用过，就不要再变化黑白了.

        if statusCache == nil { // 第一次启动记录键盘的颜色
            statusCache = keyboardAppearance
        } else if statusCache == .dark, keyboardAppearance == .default {
            return // 如果键盘是以黑色启动的，就后续忽略 default 颜色
        }

        switch configManager.skinColor {
        case kSkinColorDark where keyboardAppearance != .dark:
            view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            fallthrough
        case kSkinColorDark:
            darkMode = true

        case kSkinColorWhite where keyboardAppearance == .dark || systemDarkMode:
            view.backgroundColor = UIColor(red: 205 / 255.0, green: 209 / 255.0, blue: 214 / 255.0, alpha: 1)
            fallthrough
        case kSkinColorWhite:
            darkMode = false

        case kSkinColorAuto:
            darkMode = keyboardAppearance == .dark || systemDarkMode
        default: break
        }

        sbBlue = UIColor(red: 40 / 255, green: 122 / 255, blue: 1, alpha: 1)
        if configManager.keyGlass {
            whiteColor = UIColor.white.withAlphaComponent(0.2)
            darkColor = UIColor.white.withAlphaComponent(0.1)
        } else if darkMode, !configManager.keyTransparent {
            whiteColor = UIColor.white.withAlphaComponent(0.33)
            darkColor = UIColor.lightGray.withAlphaComponent(0.2)
        } else if !configManager.keyTransparent {
            whiteColor = UIColor.white
            darkColor = UIColor(red: 172 / 255.0, green: 179 / 255.0, blue: 188 / 255.0, alpha: 1)
        } else if configManager.keyTransparent {
            whiteColor = UIColor.clear
            darkColor = UIColor.clear // black.withAlphaComponent(0.1) //黑白如果不一致，炫彩就会功能键变灰
            sbBlue = UIColor.clear
        }
        darkModeLetterColor = UIColor(rgb: ConfigManager.shared.darkLetterColor)
        whiteModeLetterColor = UIColor(rgb: ConfigManager.shared.whiteLetterColor)
        changeMode()
        if configManager.inLineBuffer, engineHasBuffer { return }
        NotificationCenter.default.post(name: Notification.Name.KeyboardModeChanged, object: self, userInfo: nil)
    }

    @IBOutlet var earthKey: KeyboardKey! // 切换输入法的按钮

    //    func appMovedToBackground() {
    //        print("App moved to background!")
    //    }
    //

    private lazy var backWardImage = #imageLiteral(resourceName: "backWard_white")
    private lazy var shiftImage = #imageLiteral(resourceName: "shift_white")
    private lazy var iPadKeyImage = #imageLiteral(resourceName: "key_white")
    private lazy var arrowUpWhiteImage = #imageLiteral(resourceName: "arrow-up_white")
    private lazy var arrowUpBlackImage = #imageLiteral(resourceName: "arrow-up_black")
    private lazy var arrowDownBlackImage = #imageLiteral(resourceName: "arrow-down_black")
    private lazy var arrowDownWhiteImage = #imageLiteral(resourceName: "arrow-down_white")

    weak var ipadDismissButton: KeyboardKey?
    weak var candidateBackground: UIView?
    weak var ipadShortCutButton2: KeyboardKey?

    func changeMode() {
        if configManager.inLineBuffer {
            inputBuffer?.isHidden = true
        }
        if darkMode {
            cleanButton?.tintColor = darkModeLetterColor
            cleanButton?.imageView?.tintColor = darkModeLetterColor
            if keyboardMode != .upper {
                shiftKey?.tintColor = darkModeLetterColor
                shiftKey?.imageView?.tintColor = darkModeLetterColor
            }

            ipadShortCutButton2?.tintColor = darkModeLetterColor
            ipadShortCutButton2?.imageView?.tintColor = darkModeLetterColor
            ipadDismissButton?.tintColor = darkModeLetterColor
            ipadDismissButton?.imageView?.tintColor = darkModeLetterColor
            earthKey?.tintColor = darkModeLetterColor
            earthKey?.imageView?.tintColor = darkModeLetterColor

            let darkColor = UIColor.white.withAlphaComponent(0.2)

            //            self.candidatesCollectionView.backgroundView?.backgroundColor = darkColor
            shadowLine.layer.shadowColor = UIColor.black.cgColor
            moreCandidate.setImage(arrowDownWhiteImage, for: .normal)
            //            candidateRowView?.backgroundColor = darkColor
            inputBuffer?.textColor = UIColor.white

            if #available(iOSApplicationExtension 12, *) {
                candidateBackground?.backgroundColor = UIColor.clear
                candidateBarController.backgroundColor = UIColor.black.withAlphaComponent(0.001)
                moreCandidate.backgroundColor = UIColor.black.withAlphaComponent(0.001)
            } else {
                candidateBackground?.backgroundColor = darkColor
                candidateBarController.backgroundColor = deviceName == .iPad ? UIColor.clear : darkColor
                moreCandidate.backgroundColor = darkColor
            }
            if configManager.keyboardBackgroundColor >= 0 {
                let c = UIColor(rgb: configManager.keyboardBackgroundColor).withAlphaComponent(0.33)
                view.backgroundColor = c
            }
        } else {
            cleanButton?.tintColor = whiteModeLetterColor
            cleanButton?.imageView?.tintColor = whiteModeLetterColor
            if keyboardMode != .upper {
                shiftKey?.tintColor = whiteModeLetterColor
                shiftKey?.imageView?.tintColor = whiteModeLetterColor
            }
            ipadShortCutButton2?.tintColor = whiteModeLetterColor
            ipadShortCutButton2?.tintColor = whiteModeLetterColor
            ipadDismissButton?.tintColor = whiteModeLetterColor
            ipadDismissButton?.imageView?.tintColor = whiteModeLetterColor
            earthKey?.tintColor = whiteModeLetterColor
            earthKey?.imageView?.tintColor = whiteModeLetterColor

            if #available(iOSApplicationExtension 12, *) {
                candidateBackground?.backgroundColor = UIColor.clear
                candidateBarController.backgroundColor = UIColor.white.withAlphaComponent(0.001)
                moreCandidate.backgroundColor = UIColor.white.withAlphaComponent(0.001)
            } else {
                candidateBackground?.backgroundColor = UIColor.white
                candidateBarController?.backgroundColor = UIColor.white
                moreCandidate.backgroundColor = UIColor.white
            }

            shadowLine.layer.shadowColor = UIColor.gray.cgColor
            moreCandidate.setImage(arrowDownBlackImage, for: .normal)
            inputBuffer?.textColor = UIColor.darkText

            if configManager.keyboardBackgroundColor >= 0 {
                let c = UIColor(rgb: configManager.keyboardBackgroundColor).withAlphaComponent(0.8)
                view.backgroundColor = c
            }
        }

        if shiftKey?.title(for: .normal) != "符", keyboardMode != .upper {
            shiftKey?.setImage(#imageLiteral(resourceName: "shift_white"), for: .normal)
            shiftKey?.accessibilityLabel = "shift"
            shiftKey?.accessibilityHint = "轻点三次大写锁定"
            ipadShortCutButton2?.setImage(#imageLiteral(resourceName: "shift_white"), for: .normal)
            ipadShortCutButton2?.accessibilityLabel = "shift"
            ipadShortCutButton2?.accessibilityHint = "轻点三次大写锁定"
        }
        if shiftKey?.title(for: .normal) != "符", keyboardMode == .upper {
            let imgName = CapsLock ? "shift_doubleclick" : "shift_fill"
            shiftKey?.setImage(UIImage(named: imgName), for: .normal)
            shiftKey?.setTitle(nil, for: .normal)
            shiftKey?.accessibilityLabel = "shift"
            shiftKey?.accessibilityHint = "轻点取消大写锁定"
            shiftKey?.layer.backgroundColor = UIColor.white.cgColor
            shiftKey?.tintColor = UIColor.darkText

            ipadShortCutButton2?.setImage(UIImage(named: imgName), for: .normal)
            ipadShortCutButton2?.setTitle(nil, for: .normal)
            ipadShortCutButton2?.accessibilityLabel = "shift"
            ipadShortCutButton2?.accessibilityHint = "轻点取消大写锁定"
            ipadShortCutButton2?.layer.backgroundColor = UIColor.white.cgColor
            ipadShortCutButton2?.tintColor = UIColor.darkText
        }

        if configManager.keyboardNoPattern {
            cleanButton?.setImage(nil, for: .normal)
            //            print(cleanButton)
            shiftKey?.setImage(nil, for: .normal)
            ipadShortCutButton2?.setImage(nil, for: .normal)
            earthKey?.setImage(nil, for: .normal)
            ipadDismissButton?.setImage(nil, for: .normal)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                var i = UIImage(named: "earth_white")
                if #available(iOSApplicationExtension 11.0, *) {
                    if !self.needsInputModeSwitchKey {
                        i = darkMode ? #imageLiteral(resourceName: "altEarth_white") : #imageLiteral(resourceName: "altEarth_black")
                    }
                }

                self.earthKey?.setImage(i, for: .normal)
            }

            cleanButton?.setImage(backWardImage, for: .normal)
            ipadDismissButton?.setImage(iPadKeyImage, for: .normal)
        }

        oneHandButton.alpha = darkMode ? 0.5 : 1

        returnKeyType = textDocumentProxy.returnKeyTypeSafe
    }

    override func accessibilityPerformMagicTap() -> Bool {
        if isMorePuncControllerOpening {
            NotificationCenter.default.post(name: .ScrollToFirstItem, object: nil)
            return true
        }
        if isEmojiBoardOpening {
            emojiBoard?.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            return true
        }
        if candidates.count > 2, configManager.fourCode == 0 {
            candidateBarController.scrollToLeft()
            if let cell = candidateBarController.cellForIndex(at: 0) {
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: cell)
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1) {
                UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "回首选，" + self.candidates[0].table)
            }

            return true
        } else {
            return false
        }
    }

    override func accessibilityPerformEscape() -> Bool {
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "已收起键盘")
        dismissKeyboard()
        return true
    }

    deinit {
        NotificationCenter.default.removeObserver(self) // remove self from notification center
        //        KeyboardKey.keyboardButtons.removeAll()  remove all will cause button unexpectedly break!!
    }

    /**
     为要显示的键盘添加约束

     - author: Aaron
     - date: 16-08-04 05:08:59

     - parameter board: 要显示的键盘，比如中文或者英文键盘
     */
    func addConstraintsToKeyboard(_ board: UIView, full: Bool = false) {
        var size = view.frame.size
        var leftStartValue: CGFloat = 0
        if isX, !isPortrait { // 如果是 iPhone 圆角系列横屏就让键盘窄一点点
            leftStartValue = (size.width - 660) / 2
            size.width = 660
        }
        let p = isPrivacyModeOn && Platform.fromClientID(clientID) != nil
        var offset = deviceName == .iPad ? 55 : 42
        offset += p ? Int(kPrivacyHeight) : 0
        let lineOffset = (board == customInterface || board == numbericBoard) ? 0 : 2
        let num = CGFloat(full ? (p ? Int(kPrivacyHeight) : 0) : offset + lineOffset)
        size.height = heightConstraint.constant - num
        var xValue = CGFloat(0)
        switch LocalConfigManager.shared!.handMode {
        case 1:
            size.width = size.width * CGFloat(configManager.oneHandWidth)
        case 2:
            xValue = size.width * CGFloat(1 - configManager.oneHandWidth)
            size.width = size.width * CGFloat(configManager.oneHandWidth)
        default: break
        }
        board.frame = CGRect(origin: CGPoint(x: leftStartValue + xValue, y: num), size: size)
        updateOneHandOutButton()
    }

    /**
     延迟函数，用来将传入的闭包延迟指定时间再执行
     这里用于延迟执行动画。

     - author: Aaron
     - date: 16-08-04 05:08:54

     - parameter seconds:    要延迟的时间
     - parameter completion: 要延迟执行的代码（闭包）
     */
    func delay(_ seconds: Double, completion: @escaping () -> Void) {
        let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }

    /**
     更新候选列表的显示

     - author: Aaron
     - date: 16-07-28 01:07:57

     - parameter candidates: 候选字词列表
     */
    @IBOutlet var returnKey: KeyboardKey?
    //    weak var alphaReturnKey: KeyboardKey?
    private var candidatesFullCache: CodeTableArray = []
    private var returnTitleColorWhite: UIColor { return ConfigManager.shared.keyboardNoPattern ? UIColor.clear : darkModeLetterColor }
    private var returnTitleColorDark: UIColor { return ConfigManager.shared.keyboardNoPattern ? UIColor.clear : whiteModeLetterColor }

    func updateCandidates(_ candidates: CodeTableArray, loadFullCandidates: Bool = false) {
        self.candidates = candidates
        toolBar.isHidden = !candidates.isEmpty || isEmojiBoardOpening || isTempInputing

        if isMoreCandidateViewOpening, candidates.isEmpty {
            moreCandidateView?.dismiss()
        }
        if isEmojiBoardOpening { return }
        UIView.performWithoutAnimation { // 去掉动画，速度比整体reload要快许多
            if isMoreCandidateViewOpening {
                self.moreCandidateView?.reloadSections([0])
            }
            self.candidateBarController.update()
            self.returnKey?.accessibilityLabel = !self.engineHasBuffer ? nil : "确认"

            if !engineHasBuffer {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
                    self.returnKey?.setTitle(self.returnKey?.title(for: .disabled), for: .normal)
                }

                if returnKeyType != .default, !ConfigManager.shared.keyTransparent, !configManager.keyGlass {
                    self.returnKey?.layer.backgroundColor = sbBlue.cgColor
                    self.returnKey?.setTitleColor(UIColor.white, for: .normal)

                } else if darkMode {
                    self.returnKey?.setTitleColor(self.returnTitleColorWhite, for: .normal)

                } else {
                    self.returnKey?.setTitleColor(self.returnTitleColorDark, for: .highlighted)
                }
            } else {
                if !ConfigManager.shared.keyTransparent, !configManager.keyGlass {
                    returnKey?.layer.backgroundColor = darkColor.cgColor
                }
                let c = darkMode ? returnTitleColorWhite : returnTitleColorDark
                self.returnKey?.setTitleColor(c, for: .normal)
                self.returnKey?.setTitle("确认", for: .normal)
                self.returnKey?.setTitleColor(nil, for: .highlighted)
            }
        }

        if !loadFullCandidates {
            //            self.candidatesCollectionView.scrollToItem(at: IndexPath(item: 0,section: 0), at: .left, animated: false)
            candidateBarController.scrollToLeft()
            if isMoreCandidateViewOpening {
                moreCandidateView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
        }

        if candidates.count > 5, moreCandidate.isHidden == true {
            moreCandidate.isHidden = false
            shadowLine.isHidden = false
            view.layoutSubviews()
        } else if candidates.count <= 5, moreCandidate.isHidden == false, !isMoreCandidateViewOpening {
            moreCandidate.isHidden = true
            shadowLine.isHidden = true
            view.layoutSubviews()
        }
    }

    private var selectedIndex = -1
}

// MARK: - 手势识别委托，用来避开符号按键，退格键以及地球按键

extension KeyboardViewController: UIGestureRecognizerDelegate {
    ///
    ///
    func gestureRecognizer(_: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view is UITableView
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if isMoreCandidateViewOpening || isCandidateModifyViewOpening { return false }
        if touch.view is UITableView { return false }

        if gestureRecognizer is UILongPressGestureRecognizer, let tag = touch.view?.tag {
            if tag == rightHandButtonID || tag == leftHandButtonID { return true }

            guard configManager.longPressSettings else { return false }

            return tag >= 100
        }

        if gestureRecognizer is UIPanGestureRecognizer {
            let location = touch.location(in: candidateRowView)
            guard !candidateRowView.bounds.contains(location) else { return false }
            let tag = touch.view?.tag ?? 0
            let tags: Set<Int> = [1, 4, 5, 6]
            //        let gragButtonTags:Set<Int> = [2,3]
            //        if gragButtonTags.contains(tag!) {gestureRecognizer.cancelsTouchesInView = false}
            return tags.firstIndex(of: tag) == nil
        }

        return false
    }
}

// MARK: - 候选条的协议实现

extension KeyboardViewController: CandidateBarDelegate {
    func didLongPressed(at index: Int) {
        guard !isMoreCandidateViewOpening else { return }
        candidateModifyView?.dismiss()
        let ct = candidates[index]
        CandidateModifyController(candidate: ct, keyboard: self).show()
    }

    func numberOfCandidates() -> Int {
        return candidates.count
    }

    func contentOfCandidate(at index: Int) -> (table: String, code: String, raw: CodeTable) {
        guard zhInput != nil else {
            return (candidates[index].table, "", candidates[index])
        }
        guard !configManager.quanPin || configManager.isCodeTableModeOn else {
            return (candidates[index].table, "", candidates[index])
        }

        let zpinyin = ConfigManager.shared.zFullSpell && zhInput!.inputBuffer.count > 1 && zhInput!.inputBuffer.first == "z" && ConfigManager.shared.isCodeTableModeOn
        let needTmpRevel = zhInput!.inputBuffer.contains(char: "_") || zpinyin
        let ct = candidates[index]
        let word = ct.table
        var code = ""

        if configManager.revealAssist, zhInput!.inputBuffer.count / 2 == ct.table.count {
            code = ct.preAssistedCode
        }

        if needTmpRevel {
            code = ct.code
        }

        if configManager.revealCode, let range = ct.code.range(of: zhInput!.inputBuffer) {
            code = ct.code
            code.removeSubrange(range)
        }

        return (word, code, ct)
    }

    func didSelect(at index: Int) {
        if configManager.clickSound {
            keySoundFeedbackGenerator?.makeSound(for: 100)
        }
        dropSelection()
        KeyboardViewController.inputProxy?.didSelectCandidate(index)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 20 {
            //            updateCandidates([],loadFullCandidates: true)
            guard configManager.spaceConfirmation else { return }
            zhInput?.pleaseGiveMeMore()
        }
    }
}

extension KeyboardViewController: InputProxy {
    var selectedText: String? {
        if #available(iOSApplicationExtension 11.0, *) {
            return self.textDocumentProxy.selectedText
        } else {
            return nil
            // Fallback on earlier versions
        }
    }

    func keyboardHasFullAccess() -> Bool {
        if #available(iOSApplicationExtension 11.0, *) {
            return self.hasFullAccess
        } else {
            return UIDevice.current.identifierForVendor != nil
        }
    }

    /// 如果内部输入源存在，就不要输入给外部了
    override var textDocumentProxy: UITextDocumentProxy {
        return commonInputProxy ?? super.textDocumentProxy
    }

    override func dismissKeyboard() {
        if Thread.isMainThread {
            super.dismissKeyboard()
        } else {
            DispatchQueue.main.async {
                super.dismissKeyboard()
            }
        }
    }

    func nextKeyboard() {
        if Thread.isMainThread {
            super.advanceToNextInputMode()
        } else {
            DispatchQueue.main.async {
                super.advanceToNextInputMode()
            }
        }
    }

    var canConfirmSelection: Bool {
        return selectedIndex != -1
    }

    var documentContextBeforeInput: String? {
        var s: String?
        if Thread.isMainThread {
            s = textDocumentProxy.documentContextBeforeInput
        } else {
            DispatchQueue.main.sync {
                s = textDocumentProxy.documentContextBeforeInput
            }
        }
        return s
    }

    var documentContextAfterInput: String? {
        var s: String?
        if Thread.isMainThread {
            s = textDocumentProxy.documentContextAfterInput
        } else {
            DispatchQueue.main.sync {
                s = textDocumentProxy.documentContextAfterInput
            }
        }
        return s
    }

    func selectNext() {
        returnKey?.setTitle("选定", for: .normal)
        returnKey?.accessibilityLabel = candidates.isEmpty ? nil : "选定"
        candidateBarController.unHighLightCell(at: selectedIndex)
        selectedIndex += 1
        guard selectedIndex < candidates.count else {
            selectedIndex = 0
            candidateBarController.scrollTo(index: selectedIndex, animated: true)
            candidateBarController.highLightCell(at: selectedIndex)
            return
        }
        //        if candidateBarController.cellForIndex(at: selectedIndex+2) == nil {
        candidateBarController.scrollTo(index: selectedIndex, animated: true)
        //        }
        candidateBarController.highLightCell(at: selectedIndex)
    }

    func confirmSelection() {
        guard selectedIndex >= 0 else { return }
        candidateBarController.unHighLightCell(at: selectedIndex)
        didSelectCandidate(selectedIndex)
    }

    func dropSelection() {
        candidateBarController.unHighLightCell(at: selectedIndex)
        selectedIndex = -1
    }

    func deleteBackward() {
        if Thread.isMainThread {
            textDocumentProxy.deleteBackward()
        } else {
            DispatchQueue.main.sync {
                self.textDocumentProxy.deleteBackward()
            }
        }
    }

    func moveCursor(by n: Int) {
        if Thread.isMainThread {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: n)
        } else {
            DispatchQueue.main.sync {
                self.textDocumentProxy.adjustTextPosition(byCharacterOffset: n)
            }
        }
    }

    override func requestSupplementaryLexicon(completion completionHandler: @escaping (UILexicon) -> Swift.Void) {
        DispatchQueue.main.async {
            super.requestSupplementaryLexicon(completion: completionHandler)
        }
    }

    func adjustTextPosition(byCharacterOffset: Int) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.textDocumentProxy.adjustTextPosition(byCharacterOffset: byCharacterOffset)
        }
    }

    func insertTextDirectly(_ s: String) {
        if configManager.inLineBuffer {
            inLineController.insertTextDirectly(s)
        } else {
            textDocumentProxy.insertText(s)
        }
    }

    func insertToApp(_ s: String) {
        super.textDocumentProxy.insertText(s)
    }

    func insertText(str: String) {
        let leftString = textDocumentProxy.documentContextBeforeInput

        if configManager.inLineBuffer {
            inLineController.insertText(str)
        } else {
            if configManager.autoBlank, !isEnMode, !CapsLock, str != "\n",
               let leftChar = leftString?.last,
               let newChar = str.first
            {
                let leftChar = String(leftChar)
                let newChar = String(newChar)

                let enRange = leftChar.range(of: "[a-z|A-Z|0-9]", options: .regularExpression, range: nil, locale: nil)
                let chRange = leftChar.range(of: "[\\u4e00-\\u9fa5]", options: .regularExpression, range: nil, locale: nil)

                let isChinese = newChar.range(of: "[\\u4e00-\\u9fa5]", options: .regularExpression, range: nil, locale: nil) != nil
                let isEnglish = newChar.range(of: "[a-z|A-Z|0-9]", options: .regularExpression, range: nil, locale: nil) != nil

                if enRange != nil && isChinese || chRange != nil && isEnglish {
                    textDocumentProxy.insertText(" ") // 如果开了 inlinebuffer，则空格在inlinebuffer管理器中处理
                }
            }
            textDocumentProxy.insertText(str)
        }
        if !engineHasBuffer {
            if returnKeyType != .default, !configManager.keyTransparent, !configManager.keyGlass {
                returnKey?.layer.backgroundColor = sbBlue.cgColor
                returnKey?.setTitleColor(UIColor.white, for: .normal)
            } else if darkMode {
                returnKey?.setTitleColor(returnTitleColorWhite, for: .normal)

            } else {
                returnKey?.setTitleColor(returnTitleColorDark, for: .highlighted)
            }
        }
        DispatchQueue.global().async {
            guard let s = leftString, !LocalConfigManager.shared.privateMode,
                  let content = str.tokenize().first
            else { return }

            if s.count > 2 {
                Database.shared.updateThinkDB(from: s.subString(from: s.count - 3), to: content)
            } else if s.count > 1 {
                Database.shared.updateThinkDB(from: s.subString(from: s.count - 2), to: content)
            }
        }
    }

    /**
     选择的候选字

     - author: Aaron
     - date: 16-07-28 01:07:28

     - parameter index: 候选字索引位置，从 0 开始，0 也是默认选项
     */

    func didSelectCandidate(_ index: Int) {
        selectedIndex = -1
        if candidates.isEmpty {
            zhInput?.cleanUp()
            return
        }
        let ct = candidates[index]
        var readyToGo = ct.table
        s2tIfNeeded(&readyToGo)

        if ct.from.contains(.auto_comp) {
            for _ in 0 ..< englishModeLeftStr.count {
                deleteBackward()
                usleep(useconds_t(2 * 1000))
            }
            insertTextDirectly(readyToGo + " ")
        } else if ct.from.contains(.english_think) {
            insertTextDirectly(readyToGo + " ")
        } else {
            if !LocalConfigManager.shared.privateMode {
                lastInputedString = readyToGo
            }
            insertText(str: readyToGo)
        }
        DispatchQueue.global(qos: .userInitiated).sync {
            self.zhInput?.candidateSelect(ct, index: index)
        }
    }

    func bufferUpdate(_ text: String) {
        if isMoreCandidateViewOpening {
            zhInput?.pleaseGiveMeMore()
        }
        guard !configManager.inLineBuffer else {
            inLineController.bufferUpdate(text)
            return
        }
        inputBuffer.text = zhInput?.inputBufferWithStyle

        if deviceName == .iPad {
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutSubviews()
            })
        }
    }
}

// MARK: - add Observer

extension KeyboardViewController {
    func configObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(advanceToNextInputMode), name: .AdvanceToNextInputMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(morePuncMode), name: .MorePuncMode, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(emojiInputModeDismiss), name: .EmojiInputModeDismiss, object: nil)
    }
}
