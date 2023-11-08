//
//  BlackListController.swift
//  Whoops
//
//  Created by Aaron on 8/12/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import SwipeCellKit
import UIKit

class BlackListController: UITableViewController {
    var blacklistedUsers: [WhoopsUser] = []
    weak var contactPage: ContactPageController!

    let noContactImage = UIImageView(image: #imageLiteral(resourceName: "Group 1266"))
    let noContactLabel: UILabel = {
        let l = UILabel()
        l.font = kBasic34Font
        l.text = "黑名单是空的"
        return l
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewDidLoad() {
        title = "黑名单"
        view.backgroundColor = .white
        refreshControl?.beginRefreshing()
        refresh1()
        if #available(iOS 14, *) {
            tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
        noContactLabel.isHidden = true
        noContactImage.isHidden = true
        navigationController?.view.addSubview(noContactLabel)
        navigationController?.view.addSubview(noContactImage)
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noContactImage.pin.center(to: view.anchor.center).marginTop(-100)
        noContactLabel.pin.sizeToFit().below(of: noContactImage, aligned: .center).marginTop(20)
    }

    @IBAction func refresh1() {
        NetLayer.getBlackListBatch { status, data, msg in
            guard status else {
                DispatchQueue.main.async {
                    WhoopsAlertView.badAlert(msg: msg ?? "请重试", vc: self)
                    self.refreshControl?.endRefreshing()
                }
                return
            }
            if let l = data as? [WhoopsUser] {
                self.blacklistedUsers = l
                DispatchQueue.main.async {
                    self.noContactLabel.isHidden = !self.blacklistedUsers.isEmpty
                    self.noContactImage.isHidden = !self.blacklistedUsers.isEmpty
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }

    deinit {
        contactPage.loadContacts()
        settingNavigationBarBlue(controller: navigationController)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return blacklistedUsers.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        70
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! ContactCell
        cell.setContent(user: blacklistedUsers[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
}

extension BlackListController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let action = SwipeAction(style: .default, title: nil) { _, indexPath in

            let alert = WhoopsAlertView(title: "移出黑名单？", detail: "", confirmText: "是", confirmOnly: false)
            alert.confirmCallback = {
                guard $0 else { return }

                tableView.beginUpdates()
                let user = self.blacklistedUsers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
                NetLayer.deleteBlackList(user: user) { r, msg in
                    guard !r else { return } // 如果失败了就回滚，默认成功
                    WhoopsAlertView.badAlert(msg: msg, vc: self.tabBarController!)

                    DispatchQueue.main.async {
                        tableView.beginUpdates()
                        self.blacklistedUsers.insert(user, at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        tableView.endUpdates()
                    }
                }
            }
            alert.overlay(to: self.tabBarController!)
        }
        action.image = #imageLiteral(resourceName: "Group 1264")
        action.backgroundColor = .white
        return [action]
    }

    func tableView(_: UITableView, editActionsOptionsForRowAt _: IndexPath, for _: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .reveal
        options.backgroundColor = UIColor.white
        return options
    }
}
