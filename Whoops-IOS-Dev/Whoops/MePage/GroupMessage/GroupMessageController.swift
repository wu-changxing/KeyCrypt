//
//  GroupMessageController.swift
//  Whoops
//
//  Created by Aaron on 10/24/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class GroupMessageController: UITableViewController {
    let noContactImage = UIImageView(image: #imageLiteral(resourceName: "Group 1284"))
    let noContactLabel: UILabel = {
        let l = UILabel()
        l.font = kBasic34Font
        l.text = "没消息就是好消息"
        return l
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLoad() {
        title = "消息"
        tableView.register(GroupMsgCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: .onlineStatusUpdated, object: nil)
        noContactLabel.isHidden = !groupApplyMsg.isEmpty
        noContactImage.isHidden = !groupApplyMsg.isEmpty
        navigationController?.view.addSubview(noContactLabel)
        navigationController?.view.addSubview(noContactImage)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noContactImage.pin.center(to: view.anchor.center).marginTop(-100)
        noContactLabel.pin.sizeToFit().below(of: noContactImage, aligned: .center).marginTop(20)
    }

    @objc func updateTableView() {
        DispatchQueue.main.async {
            self.noContactLabel.isHidden = !groupApplyMsg.isEmpty
            self.noContactImage.isHidden = !groupApplyMsg.isEmpty
            self.tableView.reloadSections([0], with: .none)
        }
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 20
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 90
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return groupApplyMsg.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GroupMsgCell
        cell.setContent(groupApplyMsg[indexPath.row])
        return cell
    }
}
