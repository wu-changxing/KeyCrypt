//
//  TransferFriendList.swift
//  keyboard
//
//  Created by Aaron on 11/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class TransferFriendList: UITableView, TransferViewNv {
    weak var nv: WhoopsNavigationController!
    weak var tranA: TransferViewA!

    lazy var noContentLabel: UILabel = {
        let l = UILabel()
        l.text = "你还没有\(self.isRedpacket ? "加入群组" : "添加好友")，无法\(self.isRedpacket ? "发红包" : "转账")。"
        l.font = kBasic28Font
        l.textColor = darkMode ? .lightGray : .darkGray
        return l
    }()

    var userList: [WhoopsUser] = []
    var isRedpacket: Bool {
        tranA.isRedpacket
    }

    func rightButtonSetting(_ sender: UIButton) {
        sender.isHidden = true
    }

    func viewDidPoped(_: UIButton) {
        if tranA.toUser == nil {
            tranA.isHidden = true
            nv.dismiss()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard userList.isEmpty else { return }
        noContentLabel.pin.sizeToFit().center(to: anchor.center).marginBottom(40)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = darkMode ? .black : kColorSysBg
        register(ContactControllerCell.self, forCellReuseIdentifier: "cell")
        separatorStyle = .none
        dataSource = self
        delegate = self

        let usertype = isRedpacket ? kUserTypeGroup : kUserTypeSingle

        let k = KeyboardViewController.inputProxy as? KeyboardViewController
        if let id = k?.clientID, let p = Platform.fromClientID(id) {
            userList = NetLayer.recentUserList(for: p).filter {
                $0.userType == usertype
            }
        }

        if userList.isEmpty {
            addSubview(noContentLabel)
            bringSubviewToFront(noContentLabel)
        }
    }
}

extension TransferFriendList: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return userList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactControllerCell
        cell.setContent(user: userList[indexPath.row], isChatting: false, unread: 0)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        tranA.toUser = userList[indexPath.row]
        tranA.updateContent()
        nv.pop()
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
