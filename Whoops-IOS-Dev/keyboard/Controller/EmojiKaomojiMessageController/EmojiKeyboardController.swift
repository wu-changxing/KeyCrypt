//
//  EmojiViewController.swift
//  LoginputKeyboard
//
//  Created by Aaron on 2/1/19.
//  Copyright © 2019 Aaron. All rights reserved.
//

import UIKit

final class EmojiKeyboardController: UIView {
    var collectionView: UICollectionView!
    private var tableView = UITableView()

    private let back: KeyboardKey = { let b = KeyboardKey(tag: 1, isOrphan: true); b.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16); return b }()
    private let lock = KeyboardKey(tag: 1, isOrphan: true)
    private let ret: KeyboardKey = { let b = KeyboardKey(tag: 5, isOrphan: true); b.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16); return b }()
    private let backward = KeyboardKey(tag: 4, isOrphan: true)
    private let buttonView = UIStackView()
    private let longPressContinueDelete = UILongPressGestureRecognizer()
    private let longPressSoftReturn = UILongPressGestureRecognizer()

    var currentClass = "最近"

    let emojiPath = Database.get(localPath: "recentEmoji.plist")
    let kaomojiPath = Database.get(localPath: "recentYan.plist")
    var recentEmoji: [String] = []
    var recentKaomoji: [String] = []

    let kaoClass = ["最近", "开心", "生气", "伤心", "无语", "萌"]
    var emClass = ["最近", "表情", "人物", "自然", "食物", "运动", "旅行", "物体", "符号", "旗帜"]

    var coloredEmojis: [String: Any] = [:]

    var kaomojiHappy: [String] = []
    var kaomojiAngry: [String] = []
    var kaomojiSad: [String] = []
    var kaomojiSilence: [String] = []
    var kaomojiMeng: [String] = []

    var faceCollection: [String] = []

    private lazy var emojiPopView: EmojiPopView = {
        let emojiPopView = EmojiPopView()
        emojiPopView.delegate = self
        return emojiPopView
    }()

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds, !isHidden, alpha > 0 else { return nil }
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            let result = subview.hitTest(subPoint, with: event)
            if result != nil {
                return result
            }
        }
        return nil
    }

    init(keyboard: KeyboardViewController) {
        super.init(frame: .zero)

        clipsToBounds = false
        backgroundColor = UIColor.black.withAlphaComponent(0.001)

        DispatchQueue.global().async {
            let path = Bundle.main.resourceURL?.appendingPathComponent("coloredEmojiList.plist")
            if let s = NSDictionary(contentsOf: path!) as? [String: Any] {
                self.coloredEmojis = s
            }
        }
        if let e = NSArray(contentsOfFile: emojiPath) {
            recentEmoji = e as! [String]
        }

        if #available(iOSApplicationExtension 12.1, *) {
            emClass.insert("12.1", at: 1)
        }
        if #available(iOSApplicationExtension 13.2, *) {
            emClass.insert("13.2", at: 1)
        }
        if #available(iOSApplicationExtension 14.2, *) {
            emClass.insert("14.2", at: 1)
        }
        let emojiLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(emojiLongPressHandle))
        addGestureRecognizer(emojiLongPressGestureRecognizer)

        tableView.separatorStyle = .none
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ClassCell.self, forCellReuseIdentifier: "reuseCell")
        let view1 = UIView()
        //        view.frame = bounds
        let color = darkMode ? UIColor.black.withAlphaComponent(0.001) : UIColor.white
        view1.backgroundColor = color
        tableView.backgroundView = view1
        tableView.backgroundColor = color
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        addSubview(tableView)

        buttonView.alignment = .fill
        buttonView.distribution = .fillEqually
        buttonView.spacing = 10
        buttonView.axis = .horizontal
        buttonView.addArrangedSubview(back)
        buttonView.addArrangedSubview(lock)
        buttonView.addArrangedSubview(backward)
        buttonView.addArrangedSubview(ret)
        addSubview(buttonView)

        back.setTitle("返回", for: .normal)
        back.addTarget(keyboard, action: #selector(keyboard.emojiInputModeDismiss), for: .touchUpInside)
        lock.addTarget(self, action: #selector(lockDidTap(_:)), for: .touchUpInside)

        backward.addTarget(keyboard: keyboard)
        backward.accessibilityLabel = "退格"
        keyboard.cleanButton = backward
        ret.addTarget(keyboard: keyboard)
        keyboard.returnKey = ret

        longPressSoftReturn.addTarget(keyboard, action: #selector(keyboard.softReturn))
        longPressContinueDelete.addTarget(keyboard, action: #selector(keyboard.continueDelete))
        ret.addGestureRecognizer(longPressSoftReturn)
        backward.addGestureRecognizer(longPressContinueDelete)

        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 30, right: 15)
        flow.itemSize = CGSize(width: 25, height: 25)
        flow.minimumInteritemSpacing = 2
        flow.minimumLineSpacing = 4

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flow)
        let view = UIView()
        //        view.frame = bounds
        view.backgroundColor = darkMode ? UIColor.clear : UIColor.white
        collectionView.backgroundView = view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.delaysContentTouches = false

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmCell.self, forCellWithReuseIdentifier: "emCell")
        addSubview(collectionView)

        addSubview(emojiPopView)
        emojiPopView.dismiss()

        NotificationCenter.default.addObserver(self, selector: #selector(scrollToFirstItem), name: NSNotification.Name.ScrollToFirstItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFirstSection), name: NSNotification.Name.ReloadFirstSection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeMode), name: NSNotification.Name.KeyboardModeChanged, object: nil)

        accessibilityViewIsModal = true
    }

    @objc func lockDidTap(_: UIButton) {
        let current = ConfigManager.shared.lockEmoji
        ConfigManager.shared.setLockEmoji(!current)
        lock.accessibilityLabel = ConfigManager.shared.lockEmoji ? "自动返回：关闭" : "自动返回：开启"
        var imageName = ""
        if ConfigManager.shared.lockEmoji {
            imageName = darkMode ? "lock_white" : "lock_black"
        } else {
            imageName = darkMode ? "unlock_white" : "unlock_black"
        }
        lock.setImage(UIImage(named: imageName), for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMoveToSuperview() {
        currentClass = "最近"
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        loadRecentFace()
        update()
    }

    override func layoutSubviews() {
        buttonView.frame = CGRect(x: 10, y: frame.height - 35, width: frame.width - 20, height: 30)
        collectionView.frame = CGRect(x: 60, y: 0, width: frame.width - 60, height: frame.height - 41)
        tableView.frame = CGRect(x: 0, y: 0, width: 60, height: frame.height - 41)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func update() {
        var imageName = ""
        if ConfigManager.shared.lockEmoji {
            imageName = darkMode ? "lock_white" : "lock_black"
        } else {
            imageName = darkMode ? "unlock_white" : "unlock_black"
        }
        lock.setImage(UIImage(named: imageName), for: .normal)
        lock.tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
        lock.accessibilityLabel = ConfigManager.shared.lockEmoji ? "自动返回：关闭" : "自动返回：开启"
        backward.tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
    }

    func setModeTo(_ m: Int) {
        if case 0 ... 1 = m {
            LocalConfigManager.shared!.setEmojiMode(m)
        }
        currentClass = "最近"
        tableView.reloadData()
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }

    @objc func reloadFirstSection() {
        UIView.performWithoutAnimation {
            collectionView.reloadSections(IndexSet(integer: 0))
        }
    }

    @objc func scrollToFirstItem() {
        guard collectionView.visibleCells.count > 0 else { return }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
    }

    @objc func changeMode() {
        collectionView.backgroundView?.backgroundColor = darkMode ? UIColor.clear : UIColor.white
        tableView.backgroundView?.backgroundColor = darkMode ? UIColor.clear : UIColor.white
    }

    @objc func emojiLongPressHandle(sender: UILongPressGestureRecognizer) {
        func longPressLocationInEdge(_ location: CGPoint) -> Bool {
            let edgeRect = collectionView.bounds.inset(by: collectionView.contentInset)
            return edgeRect.contains(location)
        }

        let location = sender.location(in: collectionView)

        guard longPressLocationInEdge(location) else {
            dismissPopView(true)
            return
        }

        guard let indexPath = collectionView.indexPathForItem(at: location), let attr = collectionView.layoutAttributesForItem(at: indexPath), sender.state == .began else {
            return
        }

        if currentClass == "最近" {
            removeRecentFace(indexPath.item)
            let a = UINotificationFeedbackGenerator()
            a.notificationOccurred(.success)

            return
        }

        guard LocalConfigManager.shared.emojiMode == 0 else { return }

        let emoji = faceCollection[indexPath.item]

        guard let emojis = coloredEmojis[emoji] as? [String] else {
            dismissPopView(true)
            return
        }

        let e = Emoji(emojis: emojis)

        emojiPopView.setEmoji(e)

        let cellRect = attr.frame
        let cellFrameInSuperView = collectionView.convert(cellRect, to: self)
        let emojiPopLocation = CGPoint(
            x: cellFrameInSuperView.origin.x - ((TopPartSize.width - BottomPartSize.width) / 2.0) + 5,
            y: cellFrameInSuperView.origin.y - TopPartSize.height
        )
        emojiPopView.move(location: emojiPopLocation, animation: sender.state != .began)
    }

    private func dismissPopView(_: Bool) {
        emojiPopView.dismiss()
        emojiPopView.currentEmoji = ""
    }

    func didSelected(face: String) {
        if ConfigManager.shared.clickSound {
            keySoundFeedbackGenerator?.makeSound(for: 200)
        }
        updateRecentFace(face)
        KeyboardViewController.inputProxy?.insertText(str: face)
        if ConfigManager.shared.lockEmoji { return }
        NotificationCenter.default.post(name: NSNotification.Name.EmojiInputModeDismiss, object: nil)
    }
}

// MARK: - EmojiPopViewDelegate

extension EmojiKeyboardController: EmojiPopViewDelegate {
    internal func emojiPopViewShouldDismiss(emojiPopView: EmojiPopView) {
        let currentEmoji = emojiPopView.currentEmoji
        if !currentEmoji.isEmpty {
            didSelected(face: currentEmoji)
        }
        dismissPopView(true)
    }
}
