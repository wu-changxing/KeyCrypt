//
//  RankingList.swift
//  Whoops
//
//  Created by Aaron on 2/11/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class RankingList: UITableViewController {
    var userList: [WhoopsUser] = []
    var meCount = 9999
    var meList: [WhoopsUser] = []
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLoad() {
        title = "拉新榜"
        tableView.separatorStyle = .none
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        view.backgroundColor = .white
        tableView.register(RankingListCell.self, forCellReuseIdentifier: "cell")
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        refresh()
    }

    @objc func refresh() {
        NetLayer.inviteRankingList { r, d, _ in
            guard r else { return }
            self.userList = d as? [WhoopsUser] ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
        NetLayer.myInviteRankingList { r, d, _ in
            guard r else { return }
            self.meList = d as? [WhoopsUser] ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension RankingList {
    override func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 0 else {
            return UIView()
        }

        return RankFooterView()
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 10
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return userList.count > 100 ? 100 : userList.count
    }

    override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20 : 1
    }

    override func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        return UIView()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        guard let u = NetLayer.sessionUser(for: .weChat) else { return 1 }
        return userList.contains(u) ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RankingListCell
        if indexPath.section == 0, let u = NetLayer.sessionUser(for: .weChat) {
            let index = u.selfRanking
            cell.setContent(user: u, index: index)
            return cell
        }

        let u = userList[indexPath.row]
        cell.setContent(user: u, index: indexPath.row + 1)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = MyRankList()
        vc.myList = meList
        navigationController?.pushViewController(vc, animated: true)
    }
}
