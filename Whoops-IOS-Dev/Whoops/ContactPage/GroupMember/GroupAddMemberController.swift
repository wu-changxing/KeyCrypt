//
//  GroupAddMemberController.swift
//  Whoops
//
//  Created by Aaron on 10/19/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class GroupAddMemberController: UITableViewController {
    let noContactLabel: UILabel = {
        let l = UILabel()
        l.text = "暂无联系人可添加"
        l.textColor = .gray
        l.font = kBasic28Font
        return l
    }()

    weak var memberController: GroupMemberController!

    private var alreadyInside: [WhoopsUser] = []
    private var availableContacts: [WhoopsUser] = []
    private var membersToAdd: Set<WhoopsUser> = []

    func loadContacts() {
        updateFriendList()
    }

    private func updateFriendList() {
        let s = Set(memberController.currentMembers.map { $0.the_id })
        availableContacts = globalAllContacts.filter {
            s.firstIndex(of: $0.friend_id) == nil && $0.userType == kUserTypeSingle
        }
        alreadyInside = globalAllContacts.filter { user in
            s.firstIndex(of: user.friend_id) != nil && user.userType == kUserTypeSingle
        }

        noContactLabel.isHidden = !availableContacts.isEmpty || !alreadyInside.isEmpty
        tableView.reloadData()
    }

    override func viewDidLoad() {
        title = "联系人"
        tableView.allowsMultipleSelection = true
        tableView.allowsSelection = true
        tableView.register(GroupMemberCell.self, forCellReuseIdentifier: "contactCell")
        tableView.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let b = UIButton()
        b.setTitle("保存", for: .normal)
        b.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 6
        b.titleLabel?.font = kBold28Font
        b.addTarget(self, action: #selector(comfirmAddMember), for: .touchUpInside)
        b.frame = CGRect(x: 0, y: 0, width: 112 / 2, height: 32)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: b)

        view.addSubview(noContactLabel)
        loadContacts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        noContactLabel.pin.sizeToFit().center()
    }

    @objc func comfirmAddMember() {
        NetLayer.addMembersToGroup(group: memberController.currentGroup, members: Array(membersToAdd)) { _, _ in
            self.memberController.currentGroup.loadGroupMembers { _, _ in

                self.navigationController?.popViewController(animated: true)
                self.memberController.currentMembers = self.memberController.currentGroup.groupMembersCache!
                self.memberController.tableView.reloadSections([0], with: .automatic)
            }
        }
    }
}

extension GroupAddMemberController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row >= alreadyInside.count else { return }
        let u = availableContacts[indexPath.row]
        membersToAdd.insert(u)
        let cell = tableView.cellForRow(at: indexPath) as! GroupMemberCell
        cell.isSelected = true
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard indexPath.row >= alreadyInside.count else { return }
        let u = availableContacts[indexPath.row]
        membersToAdd.remove(u)
        let cell = tableView.cellForRow(at: indexPath) as! GroupMemberCell
        cell.isSelected = false
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return availableContacts.count + alreadyInside.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as! GroupMemberCell
        if indexPath.row >= alreadyInside.count {
            cell.setContent(user: availableContacts[indexPath.row - alreadyInside.count], selection: true)
            cell.detailTextLabel?.text = ""
        } else {
            cell.setContent(user: alreadyInside[indexPath.row], selection: true)
            cell.detailTextLabel?.text = "已入群"
        }
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 40
    }
}
