//
//  InviteGroupView.swift
//  keyboard
//
//  Created by Aaron on 10/8/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class InviteGroupView: UIView {
    let titleBar = TitleBar(title: "邀请入群")
    let tableView = UITableView()
    var callback: ((WhoopsUser) -> Void)?

    var groupList: [WhoopsUser] = []

    init() {
        super.init(frame: .zero)
        backgroundColor = darkMode ? .black : .white
        addSubview(titleBar)
        addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ContactControllerCell.self, forCellReuseIdentifier: "cell")
        titleBar.backButton.addTarget(self, action: #selector(goback), for: .touchUpInside)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "")
        tableView.refreshControl?.addTarget(self, action: #selector(loadGroups), for: .valueChanged)
        loadGroups()
    }

    @objc func loadGroups() {
        guard let platform = Platform.fromClientID(KeyboardViewController.inputProxy!.clientID)
        else { return }
        tableView.refreshControl?.beginRefreshing()
        NetLayer.getGroupList(for: platform) {
            guard $0, let d = $1 as? [WhoopsUser] else {
                KeyboardViewController.inputProxy!.toast(str: "网络错误，请重试。\($2 ?? "")")
                return
            }
            self.groupList = d
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
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
            .height.equal(to: 34)
            .top.equal(to: 0)
            .left.equal(to: 0)
            .right.equal(to: width)
        }
        tableView.frameLayout { $0
            .top.equal(to: titleBar.bottom)
            .left.equal(to: 0)
            .right.equal(to: width)
            .bottom.equal(to: height)
        }
    }

    deinit {
        callback = nil
    }

    @objc func goback() {
        UIView.animateSpring {
            self.centerX += self.width
        } completion: {
            guard $0 else { return }
            self.removeFromSuperview()
        }
    }
}

extension InviteGroupView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return groupList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactControllerCell

        cell.setContent(user: groupList[indexPath.row], isChatting: false, unread: 0)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groupList[indexPath.row]
        callback?(group)
    }
}
