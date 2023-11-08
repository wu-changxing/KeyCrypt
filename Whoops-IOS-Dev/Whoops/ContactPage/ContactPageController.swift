//
//  ContactPageController.swift
//  Whoops
//
//  Created by Aaron on 7/14/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//
import MMKVAppExtension
import SwipeCellKit
import UIKit

var globalAllContacts: [WhoopsUser] = []
var onlineID: Set<Int> = []
var groupApplyMsg: [GroupMessageModel] = []

class ContactPageController: UITableViewController {
    var barTitle: UILabel = {
        let t = UILabel()
        t.text = "联系人"
        t.textColor = .white
        t.font = kBasicFont(size2x: 40, semibold: true)
        return t
    }()

    let blueHeader = UIView()
    var availableContacts: [WhoopsUser] = []

    let noContactImage = UIImageView(image: #imageLiteral(resourceName: "noContact"))
    let noContactLabel: UILabel = {
        let l = UILabel()
        l.font = kBasic34Font
        l.text = "还没有联系人"
        return l
    }()

    private var groups: [WhoopsUser] = []
    private var contacts: [WhoopsUser] = []
    let layer0: CALayer = genGradientLayer(isVertical: false)
    var timer: Timer?

    func loadContacts() {
        refreshControl?.beginRefreshing()
        guard !isNotGoodToGo else {
            updateFriendList()
            refreshControl?.endRefreshing()
            return
        }

        let group = DispatchGroup()

        group.enter()
        NetLayer.getGroupListBatch { status, data, _ in
            guard status, let l = data as? [WhoopsUser] else {
                group.leave()
                return
            }
            self.groups = l
            group.leave()
        }

        group.enter()
        NetLayer.getFriendListBatch { status, data, msg in
            guard status, let l = data as? [WhoopsUser] else {
                if msg == "用户登录过期" {
                    DispatchQueue.main.async {
                        let window = UIApplication.shared.delegate!.window!
                        let wel = WelcomeController()
                        let n = UINavigationController(rootViewController: wel)
                        window?.rootViewController = n
                    }
                    for p in Platform.allCases {
                        NetLayer.setRecentUser(list: [], forPlatform: p)
                    }
                    group.leave()
                    return
                }
                WhoopsAlertView.badAlert(msg: msg, vc: self)
                group.leave()
                return
            }
            self.contacts = l
            group.leave()
        }

        group.notify(queue: .main) {
            globalAllContacts = self.contacts + self.groups
            self.updateFriendList()
        }
    }

    private func updateFriendList() {
        availableContacts = globalAllContacts

        DispatchQueue.global().async {
            for p in Platform.allCases {
                let l = NetLayer.recentUserList(for: p)
                let cur = self.availableContacts.filter { $0.platform == p }
                var new: [WhoopsUser] = []

                for u in l {
                    if let index = cur.firstIndex(of: u) {
                        new.append(cur[index])
                    }
                }
                new.append(contentsOf: cur)
                NetLayer.setRecentUser(list: new.unique, forPlatform: p)
            }
        }
        DispatchQueue.main.async {
            self.noContactLabel.isHidden = !self.availableContacts.isEmpty
            self.noContactImage.isHidden = !self.availableContacts.isEmpty
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    override func viewDidLoad() {
        if MMKV.default()?.bool(forKey: "browser_enable") ?? false {
        } else {
            var l = tabBarController!.viewControllers
            l?.remove(at: 1)
            tabBarController!.setViewControllers(l, animated: false)
        }

        navigationController?.navigationBar.addSubview(barTitle)
        barTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barTitle.leftAnchor.constraint(equalTo: navigationController!.navigationBar.leftAnchor, constant: 20),
            barTitle.bottomAnchor.constraint(equalTo: navigationController!.navigationBar.bottomAnchor, constant: -12),
        ])
        barTitle.isUserInteractionEnabled = true
        let g = UILongPressGestureRecognizer(target: self, action: #selector(卐开))
        barTitle.addGestureRecognizer(g)

        navigationController?.view.insertSubview(blueHeader, belowSubview: navigationController!.navigationBar)

        blueHeader.layer.addSublayer(layer0)
        tableView.backgroundColor = .white

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "moreButton"), style: .plain, target: self, action: #selector(moreButtonDidTap))
        moreButton.tintColor = .white

        navigationItem.rightBarButtonItems = [moreButton]
        noContactLabel.isHidden = true
        noContactImage.isHidden = true
        view.addSubview(noContactLabel)
        view.addSubview(noContactImage)
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        NetLayer.checkAllTokensAvailable { r, _ in
            DispatchQueue.main.async {
                if r {
                    self.loadContacts()
                } else {
                    for p in Platform.allCases {
                        NetLayer.setRecentUser(list: [], forPlatform: p)
                    }
                    let window = UIApplication.shared.delegate!.window!
                    let wel = WelcomeController()
                    let n = UINavigationController(rootViewController: wel)
                    window?.rootViewController = n
                }
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBackToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarBlue(controller: navigationController)
        UIView.animateSpring {
            self.barTitle.alpha = 1
        }
    }

    override func viewWillDisappear(_: Bool) {
        UIView.animateSpring {
            self.barTitle.alpha = 0
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    @objc func moreButtonDidTap(_: UIBarButtonItem) {
        let f = navigationController!.navigationBar.frame
        let p = navigationController!.view.convert(CGPoint(x: f.maxX - 100, y: f.maxY - 55), from: navigationController!.navigationBar)
        let m = Menu()
        m.show(on: navigationController!.view, with: p)
        m.button.addTarget(self, action: #selector(gotoBlackList), for: .touchUpInside)
    }

    @objc func 卐开(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        let t = tabBarController!
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dapp")
        var l = t.viewControllers
        guard l?.count == 3 else { return }
        l?.insert(vc, at: 1)
        t.setViewControllers(l, animated: true)
        MMKV.default()?.set(true, forKey: "browser_enable")
        let alert = WhoopsAlertView(title: "成功开启 Whoops 所有功能", detail: "", confirmText: "好", confirmOnly: true)

        alert.overlay(to: t)
    }

    @objc func groupCheck() {
        NetLayer.checkOnlineBatchBatch(allContacts: contacts) { _, d, _ in
            guard let d = d as? [Int] else { return }
            onlineID = Set(d)
            NotificationCenter.default.post(Notification(name: .onlineStatusUpdated))
        }

        guard !(groups.filter { $0.isGroupAdmin }).isEmpty else { return }

        NetLayer.getGroupApplyMessageBatch { _, d, _ in
            guard let s = d as? [GroupMessageModel] else { return }
            groupApplyMsg = s

            DispatchQueue.main.async {
                guard !(s.filter { $0.status == .pending }).isEmpty else { return }
                self.addRedDotAtTabBarItemIndex(index: 1)
            }
        }
    }

    @objc func gotoBlackList() {
        let vc = UIStoryboard(name: "BlackListController", bundle: nil).instantiateInitialViewController() as! BlackListController
        vc.contactPage = self
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        startBackgroundChack()

        super.viewDidAppear(animated)
        if !UserDefaults.standard.bool(forKey: kWelcomeGuidShown) {
            let guidAlert = WelcomeGuidAlert()
            guidAlert.overlay(to: tabBarController!)
            let guid = PrivacyPage()
            present(guid, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: kWelcomeGuidShown)
        }
    }

    override func viewDidLayoutSubviews() {
        blueHeader.pin.top().horizontally().height(view.pin.layoutMargins.top)
        layer0.frame = blueHeader.bounds
        noContactImage.pin.center(to: view.anchor.center).marginTop(-view.pin.layoutMargins.top)
        noContactLabel.pin.sizeToFit().below(of: noContactImage, aligned: .center).marginTop(20)
    }

    @objc func appBackToForeground() {}

    @objc func refresh() {
        loadContacts()
    }
}

extension ContactPageController {
    @objc func stopTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func startBackgroundChack() {
        DispatchQueue.main.async {
            if let t = self.timer { t.invalidate() }
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.groupCheck), userInfo: nil, repeats: true)
        }
    }

    func addRedDotAtTabBarItemIndex(index: Int) {
        for subview in tabBarController!.tabBar.subviews {
            if subview.tag == 1314 {
                subview.removeFromSuperview()
                break
            }
        }

        let RedDotRadius: CGFloat = 4
        let RedDotDiameter = RedDotRadius * 2

        let TopMargin: CGFloat = 3

        let TabBarItemCount = CGFloat(tabBarController!.tabBar.items!.count)

        let HalfItemWidth = view.bounds.width / (TabBarItemCount * 2)

        let xOffset = HalfItemWidth * CGFloat(index * 2 + 1)

        let imageHalfWidth: CGFloat = ((tabBarController!.tabBar.items![index]).selectedImage?.size.width)! / 2

        let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))

        redDot.tag = 1314
        redDot.backgroundColor = UIColor.red
        redDot.layer.cornerRadius = RedDotRadius
        tabBarController?.tabBar.addSubview(redDot)
    }
}

extension ContactPageController {
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ContactDetailController()
        vc.hidesBottomBarWhenPushed = true
        vc.user = availableContacts[indexPath.row]
        vc.contactPage = self
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return availableContacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as? ContactCell
        cell?.setContent(user: availableContacts[indexPath.row])
        cell?.delegate = self
        return cell!
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 10
    }

    func remove(aUser: WhoopsUser) {
        guard let index = globalAllContacts.firstIndex(of: aUser) else { return }
        globalAllContacts.remove(at: index)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.availableContacts.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
            self.tableView.endUpdates()
        }
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 70
    }
}

extension ContactPageController: SwipeTableViewCellDelegate {
    func tableView(_: UITableView, editActionsOptionsForRowAt _: IndexPath, for _: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .reveal
        options.backgroundColor = UIColor.white
        return options
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let groupAdminAction = SwipeAction(style: .default, title: nil) { _, indexPath in
            let alert = WhoopsAlertView(title: "解散该群？", detail: "", confirmText: "是", confirmOnly: false)
            alert.overlay(to: self.tabBarController!)
            alert.confirmCallback = {
                guard $0 else { return }
                let user = self.availableContacts[indexPath.row]
                NetLayer.dismissGroup(group: user) { success, msg in
                    if success {
                        self.remove(aUser: user)
                    } else {
                        WhoopsAlertView.badAlert(msg: msg, vc: self)
                    }
                }
            }
        }
        groupAdminAction.image = #imageLiteral(resourceName: "Group 1260")
        groupAdminAction.backgroundColor = .white

        let groupLeaveAction = SwipeAction(style: .default, title: nil) { _, _ in
            let alert = WhoopsAlertView(title: "退出该群？", detail: "", confirmText: "是", confirmOnly: false)
            alert.overlay(to: self.tabBarController!)
            alert.confirmCallback = {
                guard $0 else { return }
                let user = self.availableContacts[indexPath.row]
                NetLayer.leaveGroup(group: user) { success, msg in
                    if success {
                        self.remove(aUser: user)
                    } else {
                        WhoopsAlertView.badAlert(msg: msg, vc: self)
                    }
                }
            }
        }
        groupLeaveAction.image = #imageLiteral(resourceName: "Group 1264 (1)")
        groupLeaveAction.backgroundColor = .white

        let commentAction = SwipeAction(style: .default, title: nil) { _, indexPath in

            let vc = UserCommentEditController()
            vc.user = self.availableContacts[indexPath.row]
            vc.callback = {
                let c = $0.isEmpty ? nil : $0
                self.availableContacts[indexPath.row].nickName = c
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

        commentAction.hidesWhenSelected = true
        commentAction.image = #imageLiteral(resourceName: "Group 1261")
        commentAction.backgroundColor = .white

        let deleteAction = SwipeAction(style: .default, title: nil) { _, indexPath in
            let alert = WhoopsAlertView(title: "移除该联系人？", detail: "", confirmText: "是", confirmOnly: false)
            alert.overlay(to: self.tabBarController!)
            alert.confirmCallback = {
                guard $0 else { return }
                let user = self.availableContacts[indexPath.row]
                NetLayer.deleteContact(user) { success, msg in
                    if success {
                        self.remove(aUser: user)
                    } else {
                        WhoopsAlertView.badAlert(msg: msg, vc: self)
                    }
                }
            }
        }
        deleteAction.image = #imageLiteral(resourceName: "Group 1260")
        deleteAction.backgroundColor = .white

        let user = availableContacts[indexPath.row]

        guard user.userType == kUserTypeSingle else {
            if user.identity == kIdentityOwner {
                return [groupAdminAction]
            } else {
                return [groupLeaveAction]
            }
        }

        return [deleteAction, commentAction]
    }
}
