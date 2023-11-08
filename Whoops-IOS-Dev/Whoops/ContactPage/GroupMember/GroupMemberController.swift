//
//  GroupMemberController.swift
//  Whoops
//
//  Created by Aaron on 10/19/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import SwipeCellKit
import UIKit

class GroupMemberController: UITableViewController {
    var currentGroup: WhoopsUser!

    var currentMembers: [WhoopsUser] = []

    override func viewDidLoad() {
        title = "群成员"
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.register(GroupMemberCell.self, forCellReuseIdentifier: "contactCell")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        if currentGroup.identity != kIdentityMember {
            let b = UIButton()
            b.setTitle("添加", for: .normal)
            b.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
            b.setTitleColor(.white, for: .normal)
            b.layer.cornerRadius = 6
            b.titleLabel?.font = kBold28Font
            b.addTarget(self, action: #selector(addMember), for: .touchUpInside)
            b.frame = CGRect(x: 0, y: 0, width: 112 / 2, height: 32)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: b)
        }
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.addTarget(self, action: #selector(loadMembers), for: .valueChanged)
        if let l = currentGroup.groupMembersCache {
            currentMembers = l
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            loadMembers()
        }
    }

    @objc func loadMembers() {
        refreshControl?.beginRefreshing()
        currentGroup.loadGroupMembers {
            guard $0 else {
                let alert = UIAlertController(title: "出错了！", message: $1 ?? "请重试", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                self.navigationController?.present(alert, animated: true, completion: nil)
                return
            }
            self.currentMembers = self.currentGroup.groupMembersCache!
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    @objc func addMember() {
        let vc = GroupAddMemberController()
        vc.memberController = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension GroupMemberController {
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return currentMembers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! GroupMemberCell
        cell.selectionStyle = .none
        cell.delegate = self
        let u = currentMembers[indexPath.row]
        cell.setContent(user: u, selection: false)
        if u.identity == kIdentityOwner {
            cell.detailTextLabel?.text = "群主"
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 70
    }
}

extension GroupMemberController: SwipeTableViewCellDelegate {
    func tableView(_: UITableView, editActionsOptionsForRowAt _: IndexPath, for _: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .reveal
        options.backgroundColor = UIColor.white
        return options
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let target = currentMembers[indexPath.row]
        let reportAction = SwipeAction(style: .default, title: nil) { _, indexPath in
            let user = self.currentMembers[indexPath.row]
            let vc = ReportController()
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }

        reportAction.hidesWhenSelected = true
        reportAction.image = #imageLiteral(resourceName: "Group 1327")
        reportAction.backgroundColor = .white

        let deleteAction = SwipeAction(style: .default, title: nil) { _, indexPath in
            let alert = WhoopsAlertView(title: "移除该成员？", detail: "", confirmText: "是", confirmOnly: false)
            alert.overlay(to: self.tabBarController!)
            alert.confirmCallback = {
                guard $0 else { return }
                let user = self.currentMembers[indexPath.row]
                NetLayer.removeMember(group: self.currentGroup, memberToRemove: user) { result, msg in

                    DispatchQueue.main.async {
                        guard result else {
                            WhoopsAlertView.badAlert(msg: msg, vc: self)
                            return
                        }
                        tableView.beginUpdates()
                        self.currentMembers.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .left)
                        tableView.endUpdates()
                    }
                }
            }
        }
        deleteAction.image = #imageLiteral(resourceName: "Group 1260")
        deleteAction.backgroundColor = .white

        switch target.identity {
        case kIdentityOwner: return nil // 群主不能被移除
        case kIdentityAdmin where currentGroup.identity == kIdentityOwner: // 群主可以移除管理员
            return [deleteAction, reportAction]
        case kIdentityMember where currentGroup.identity != kIdentityMember: // 除了成员，都可以移除成员
            return [deleteAction, reportAction]
        default: return [reportAction] // 成员就只能举报成员和管理员
        }
    }
}
