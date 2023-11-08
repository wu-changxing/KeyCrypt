//
//  ContactController.swift
//  keyboard
//
//  Created by Aaron on 7/25/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

var onlineID: Set<Int> = []

class ContactController: UIView, PageViewBasic {
    func beforeShowUp() {
        keyboard.isContactViewOpening = true
        tableView.reloadData()
    }

    func beforeDismiss() {
        onlineID.removeAll()
        timer?.invalidate()
        timer = nil
        keyboard.isContactViewOpening = false
    }

    var recentContacts: [WhoopsUser] = []

    var timer: Timer?
    weak var keyboard: KeyboardViewController!

    let tableView = UITableView(frame: .zero, style: .plain)
    let titleBar = TitleBar(title: "联系人/群", customRightButtonShape: true)

    init(keyboard: KeyboardViewController) {
        super.init(frame: .zero)
        clipsToBounds = true
        self.keyboard = keyboard
        keyboard.contactView = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 65, bottom: 0, right: 0)
        tableView.register(ContactControllerCell.self, forCellReuseIdentifier: "cell")
        backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self

        recentContacts = NetLayer.recentUserList(for: Platform.fromClientID(keyboard.clientID)!)

        addSubview(tableView)

        titleBar.titleOnCenter = false

        let createGroupButton = UIButton()
        createGroupButton.setTitle(" 创建群聊", for: .normal)
        createGroupButton.setTitleColor(darkMode ? .white : kColor5c5c5c, for: .normal)
        createGroupButton.setImage(UIImage(named: "groupImage"), for: .normal)
        createGroupButton.titleLabel?.font = kBold28Font
        createGroupButton.imageView?.tintColor = darkMode ? .white : kColor5c5c5c

        titleBar.rightButton = createGroupButton
        createGroupButton.addTarget(self, action: #selector(createGroupButtonDidTap), for: .touchUpInside)
        startBackgroundChack()
        addSubview(titleBar)

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "")
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        loadContacts() // 如果没好友就拉一下，可能刚邀请了好友这种
    }

    deinit {
        self.timer?.invalidate()
    }

    @objc func refresh() {
        tableView.refreshControl?.beginRefreshing()
        loadContacts()
    }

    func loadContacts() {
        let p = Platform.fromClientID(keyboard.clientID)!

        let group = DispatchGroup()

        var groups: [WhoopsUser] = []
        var contacts: [WhoopsUser] = []

        group.enter()
        NetLayer.getGroupList(for: p) { status, data, _ in
            guard status, let l = data as? [WhoopsUser] else {
                group.leave()
                return
            }
            groups = l
            group.leave()
        }

        group.enter()
        NetLayer.getFriendList(for: p) { status, data, msg in
            guard status, let l = data as? [WhoopsUser] else {
                if msg == "用户登录过期" {
                    DispatchQueue.main.async {
                        UIApplication.fuckApplication().fuckURL(url: URL(string: "whoops://contacts")!)
                    }
                }
                group.leave()
                return
            }
            contacts = l
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard self != nil else { return }
            let globalAllContacts = contacts + groups
            let cur = globalAllContacts.filter { $0.platform == p }
            var new: [WhoopsUser] = []

            for u in self?.recentContacts ?? [] {
                if let index = cur.firstIndex(of: u) {
                    new.append(cur[index])
                }
            }
            new.append(contentsOf: cur)
            new = new.unique
            NetLayer.setRecentUser(list: new, forPlatform: p)
            self?.recentContacts = new
            self?.tableView.reloadData()
            self?.tableView.refreshControl?.endRefreshing()
        }
    }

    @objc func groupCheck() {
        guard let c = recentContacts.first else { return }
        NetLayer.checkOnlineBatch(contacts: recentContacts.filter { $0.userType == kUserTypeSingle }, p: c.platform) { _, d, _ in
            guard let d = d as? [Int] else { return }
            onlineID = Set(d)
            NotificationCenter.default.post(Notification(name: .onlineStatusUpdated))
        }
    }

    func startBackgroundChack() {
        DispatchQueue.main.async {
            if let t = self.timer { t.invalidate() }
            self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.groupCheck), userInfo: nil, repeats: true)
        }
    }

    @objc func createGroupButtonDidTap() {
        if !isPrivacyModeOn {
            keyboard.openPrivacyMode()
        }

        guard isPrivacyModeOn else { return }

        let input = TempInputBar(hint: "群名（建议与微信群一致）", isPasswordField: false)
        input.successCallback = confirmCreateGroup
        keyboard.showKeyboard(tmpInput: input)

        if keyboard.isContactViewOpening { // 避免动画时重复调用
            keyboard.contactView?.dismiss()
        }
    }

    func confirmCreateGroup(name: String) {
        let p = Platform.fromClientID(keyboard.clientID)!
        NetLayer.createGroup(with: name, p: p) { r, m in
            let rs = r ? "成功" : "失败"
            if r {
                NetLayer.getGroupList(for: p) { _, data, m in
                    guard let d = data as? [WhoopsUser] else { return }

                    for g in d where g.name == name && g.memberCount == 1 {
                        NetLayer.setMostRecentUser(g)
                        break
                    }
                    self.keyboard.toast(str: "新群组创建\(rs)！\(m ?? "")")
                    // TODO: create group chat and switch into it
                }
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleBar.frameLayout { $0
            .top.equal(to: 0)
            .left.equal(to: 0)
            .right.equal(to: self.width)
            .height.equal(to: 34)
        }

        tableView.frameLayout { $0
            .top.equal(to: titleBar.bottom)
            .left.equal(to: 0)
            .right.equal(to: self.width)
            .bottom.equal(to: self.height)
        }
    }
}

extension ContactController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return recentContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactControllerCell
        var isChatting = false
        var u = 0
        let user = recentContacts[indexPath.row]

        if let chattingUser = ChatEngine.shared.targetUser, isPrivacyModeOn {
            isChatting = chattingUser == user
        }
        if !isChatting {
            u = ChatEngine.shared.msgHistory.getUnreadMsgCount(for: user.friend_id)
        }

        cell.setContent(user: recentContacts[indexPath.row], isChatting: isChatting, unread: u)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isPrivacyModeOn {
            keyboard.openPrivacyMode()
        } else {
            dismiss()
        }

        ChatEngine.shared.setTarget(user: recentContacts[indexPath.row])
    }
}
