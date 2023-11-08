//
//  MyRankList.swift
//  Whoops
//
//  Created by Aaron on 2/11/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class MyRankList: UITableViewController {
    var myList: [WhoopsUser] = []
    override func viewDidLoad() {
        title = "我的拉新"
        tableView.separatorStyle = .none
        tableView.register(MyRankListCell.self, forCellReuseIdentifier: "cell")
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "")
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc func refresh() {
        NetLayer.myInviteRankingList { _, d, _ in
            self.myList = d as? [WhoopsUser] ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return myList.count + 1
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 120 : 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = MyRankListBigCell()
            let u = NetLayer.sessionUser(for: .weChat)!
            u.inviteCount = myList.count
            cell.setContent(user: u)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MyRankListCell
        cell.setContent(user: myList[indexPath.row], isEnd: indexPath.row == myList.count - 1)
        return cell
    }
}
