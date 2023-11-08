//
//  PuncController.swift
//  LoginputKeyboard
//
//  Created by Aaron on 11/30/18.
//  Copyright © 2018 Aaron. All rights reserved.
//

import UIKit

final class PuncController: UIVisualEffectView {
    let backButton = KeyboardKey(tag: 1, isOrphan: true)
    let lockButton = KeyboardKey(tag: 1, isOrphan: true)
    let deleteButton = KeyboardKey(tag: 4, isOrphan: true)
    let returnButton = KeyboardKey(tag: 5, isOrphan: true)

    let classTableView = UITableView()
    var puncCollectionView: UICollectionView!

    let recentPath = Database.get(localPath: "recentPunc.plist")
    var currentClass = "最近"
    var recentPunc: [String] = []
    var puncDict: NSMutableDictionary!
    var puncCollection: [String] = []
    let puncClasses = ["最近", "中文", "英文", "小字", "数学", "序号", "注音", "箭头", "制表", "平假", "片假", "字母", "性别",
                       "盲文", "光学", "几何", "单位", "下标", "上标", "时间", "日期", "偏旁", "圈字", "货币"]

    init() {
        let keyboard = KeyboardViewController.inputProxy as! KeyboardViewController
        let effect = UIBlurEffect(style: darkMode ? .dark : .light)

        super.init(effect: effect)
        loadPunc()

        backButton.setTitle("返回", for: .normal)
        backButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        backButton.addTarget(self, action: #selector(dismissPunc), for: .touchUpInside)
        backButton.accessibilityTraits.insert(.button)

        lockButton.accessibilityTraits.insert(.button)
        lockButton.accessibilityLabel = "自动返回"
        updateLockButton()
        lockButton.addTarget(self, action: #selector(lockButtonDidTap), for: .touchUpInside)

        deleteButton.addTarget(keyboard: keyboard)
        deleteButton.accessibilityTraits.insert(.button)
        deleteButton.accessibilityLabel = "退格"
        deleteButton.accessibilityHint = "长按以连续删除"
        let gr = UILongPressGestureRecognizer(target: keyboard, action: #selector(keyboard.continueDelete))
        deleteButton.addGestureRecognizer(gr)

        returnButton.addTarget(keyboard: keyboard)
        returnButton.accessibilityTraits.insert(.button)
        returnButton.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        let gr1 = UILongPressGestureRecognizer(target: keyboard, action: #selector(keyboard.softReturn))
        returnButton.addGestureRecognizer(gr1)

        contentView.addSubview(backButton)
        contentView.addSubview(lockButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(returnButton)

//        let view = UIView()
//        view.backgroundColor = UIColor.clear
//        classTableView.backgroundView = view
        classTableView.backgroundColor = UIColor.clear
        classTableView.showsVerticalScrollIndicator = false
        classTableView.delegate = self
        classTableView.dataSource = self
        classTableView.register(ClassCell.self, forCellReuseIdentifier: "reuseCell")
        classTableView.separatorInset = UIEdgeInsets.zero
        classTableView.layoutMargins = UIEdgeInsets.zero
        classTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
        contentView.addSubview(classTableView)

        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.sectionInset = UIEdgeInsets(top: 15, left: 20, bottom: 30, right: 20)
        puncCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flow)
        puncCollectionView.dataSource = self
        puncCollectionView.delegate = self
        puncCollectionView.backgroundColor = UIColor.clear
        puncCollectionView.delaysContentTouches = false
        let gr2 = UILongPressGestureRecognizer(target: self, action: #selector(removeRecentPunc))
        puncCollectionView.addGestureRecognizer(gr2)
        puncCollectionView.register(PuncCell.self, forCellWithReuseIdentifier: "emCell")
        contentView.addSubview(puncCollectionView)

        NotificationCenter.default.addObserver(self, selector: #selector(modeChange), name: .KeyboardModeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate), name: .DidRotate, object: nil)

        accessibilityViewIsModal = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        backButton.frameLayout { $0
            .width.equal(to: buttonWidth)
            .height.equal(to: buttonHeight)
            .left.equal(to: buttonInset)
            .bottom.equal(to: height).offset(-5)
        }
        lockButton.frameLayout { $0
            .width.equal(to: buttonWidth)
            .height.equal(to: buttonHeight)
            .left.equal(to: backButton.right).offset(buttonInset)
            .bottom.equal(to: height).offset(-5)
        }
        deleteButton.frameLayout { $0
            .width.equal(to: buttonWidth)
            .height.equal(to: buttonHeight)
            .left.equal(to: lockButton.right).offset(buttonInset)
            .bottom.equal(to: height).offset(-5)
        }
        returnButton.frameLayout { $0
            .width.equal(to: buttonWidth)
            .height.equal(to: buttonHeight)
            .left.equal(to: deleteButton.right).offset(buttonInset)
            .bottom.equal(to: height).offset(-5)
        }

        classTableView.frameLayout { $0
            .width.equal(to: tableViewWidth)
            .top.equal(to: 0)
            .left.equal(to: 0)
            .bottom.equal(to: backButton.top).offset(-5)
        }
        puncCollectionView.frameLayout { $0
            .left.equal(to: classTableView.right)
            .top.equal(to: 0)
            .right.equal(to: width)
            .bottom.equal(to: classTableView.bottom)
        }
    }

    @objc func didRotate() {
        UIView.animateSpring(animations: {
            self.alpha = 0
        }, completion: { _ in
            (KeyboardViewController.inputProxy as! KeyboardViewController).addConstraintsToKeyboard(self, full: true)
            UIView.animateSpring { self.alpha = 1 }
        })
    }

    func updateLockButton() {
        let lock = ConfigManager.shared.lockPunc
        var imageName = ""
        if lock { imageName = darkMode ? "lock_white" : "lock_black" }
        else { imageName = darkMode ? "unlock_white" : "unlock_black" }
        if lock {
            lockButton.accessibilityTraits.remove(.selected)
        } else {
            lockButton.accessibilityTraits.insert(.selected)
        }
        if ConfigManager.shared.keyboardNoPattern {
            lockButton.setImage(nil, for: .normal)
        } else {
            lockButton.tintColor = darkMode ? darkModeLetterColor : whiteModeLetterColor
            lockButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }

    @objc func lockButtonDidTap(_: UIButton) {
        let lock = ConfigManager.shared.lockPunc
        ConfigManager.shared.setLockPunc(!lock)
        updateLockButton()
    }

    @objc func dismissPunc() {
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "符号面板已关闭")
        (KeyboardViewController.inputProxy as! KeyboardViewController).isMorePuncControllerOpening = false
        UIView.animateSpring(animations: {
            self.alpha = 0
        }, completion: { [weak self] b in
            guard b else { return }
            self?.removeFromSuperview()
        })
    }

    @objc func modeChange() {
        updateLockButton()

        if ConfigManager.shared.keyboardNoPattern {
            deleteButton.setImage(nil, for: .normal)
        } else {
            let backImage = darkMode ? UIImage(named: "backWard_white") : UIImage(named: "backWard_black")
            deleteButton.setImage(backImage, for: .normal)
        }
        UIView.animateSpring {
            if LocalConfigManager.shared.tempHideHint {
                self.classTableView.alpha = 0
                self.puncCollectionView.alpha = 0
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.classTableView.alpha = 1
                    self.puncCollectionView.alpha = 1
                }
            }
        }
    }

    func reloadFirstSection() {
        UIView.performWithoutAnimation {
            puncCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }

    func scrollToFirstItem() {
        guard puncCollectionView.visibleCells.count > 0 else { return }
        puncCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
    }
}

extension PuncController {
    var buttonInset: CGFloat {
        return deviceName == .iPad ? 20 : 10
    }

    var tableViewWidth: CGFloat {
        return deviceName == .iPad ? 80 : 60
    }

    var buttonHeight: CGFloat {
        return deviceName == .iPad ? 50 : 30
    }

    var buttonWidth: CGFloat {
        return (width - (buttonInset * 5)) / 4
    }
}

extension PuncController {
    func loadPunc() {
        let path = Bundle.main.resourceURL?.appendingPathComponent("punc.plist")
        puncDict = NSMutableDictionary(contentsOf: path!)
        if let recentPunc = NSArray(contentsOfFile: recentPath) {
            puncDict.setObject(recentPunc, forKey: "最近" as NSCopying)
        } else {
            puncDict.setObject(NSArray(), forKey: "最近" as NSCopying)
        }
        updateCurrentPuncList(forClass: "最近")
    }

    func updateRecentPunc(_ punc: String) {
        let recentPuncList = puncDict.mutableArrayValue(forKey: "最近")
        recentPuncList.remove(punc)
        recentPuncList.insert(punc, at: 0)
        recentPuncList.write(toFile: recentPath, atomically: true)
    }

    func updateCurrentPuncList(forClass c: String) {
        puncCollection = (puncDict[c] as? [String]) ?? []
    }

    @objc func removeRecentPunc(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        let location = sender.location(in: puncCollectionView)
        guard currentClass == "最近",
              let index = puncCollectionView.indexPathForItem(at: location),
              let cell = puncCollectionView.cellForItem(at: index) as? PuncCell
        else { return }

        let punc = cell.getContentText()
        let recentPuncList = puncDict.mutableArrayValue(forKey: "最近")
        recentPuncList.remove(punc)
        recentPuncList.write(toFile: recentPath, atomically: true)
        updateCurrentPuncList(forClass: "最近")
        cell.layer.backgroundColor = UIColor.clear.cgColor
        puncCollectionView.deleteItems(at: [index])
        let a = UINotificationFeedbackGenerator()
        a.notificationOccurred(.success)
    }
}

extension PuncController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // ——————>  CollectionView 的数据源
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.alpha == 1 else { return }
        if ConfigManager.shared.clickSound {
            keySoundFeedbackGenerator?.makeSound(for: 200)
        }
        let face = puncCollection[indexPath.item]
        updateRecentPunc(face)
        KeyboardViewController.inputProxy?.insertText(str: face)
        if !ConfigManager.shared.lockPunc { dismissPunc() }
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return puncCollection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emCell", for: indexPath)
        (cell as! EmCellProtocol).setContent(puncCollection[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)!
        if ConfigManager.shared.firstColor {
            let color = UIColor(rgb: ConfigManager.shared.firstColorValue)
            cell.layer.backgroundColor = color.withAlphaComponent(0.5).cgColor
        } else {
            if darkMode {
                cell.layer.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
            } else {
                cell.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            }
        }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        cell.layer.backgroundColor = UIColor.clear.cgColor
    }
}

extension PuncController: UITableViewDataSource, UITableViewDelegate {
    // ——————>  tableview 的数据源
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return puncClasses.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.alpha == 1 else { return }
        currentClass = puncClasses[indexPath.row]

        updateCurrentPuncList(forClass: currentClass)
        reloadFirstSection()
        if !puncCollection.isEmpty {
            scrollToFirstItem()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell") as! ClassCell
        cell.displayText(puncClasses[indexPath.row])
        return cell
    }
}
