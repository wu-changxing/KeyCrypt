//
// Created by Aaron on 4/3/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit

class RedpacketBindingView: UITableViewController {
    let wallets = WalletUtil.getWalletList()
    var user = NetLayer.sessionUser(for: .weChat)!
    let currentUW = WalletUtil.getCurrentWallet()!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "红包绑定"
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.register(WalletCell.self, forCellReuseIdentifier: "cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "帮助", style: .plain, target: self, action: #selector(helpDidTap))
    }

    @objc func helpDidTap() {
        WhoopsAlertView(title: "", detail: "红包绑定的钱包用于 Whoops 隐私群聊中发红包和抢红包等操作，抢到的资金将会自动进入绑定的钱包中。", confirmText: "我知道了", confirmOnly: true).overlay(to: navigationController!)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        wallets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WalletCell
        let uw = wallets[indexPath.row]
        cell.setContent(
            wallet: uw,
            selectedBinding: uw.getAddress(mode: kAddressModeMain) == user.walletAddress,
            isCurrent: uw.getAddress(mode: kAddressModeMain) == currentUW.getAddress(mode: kAddressModeMain)
        )
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        50
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        UIView()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let a = WhoopsAlertView(title: "换绑后因钱包地址变化，之前存在的红包都不能再抢，确认换绑？", detail: "", confirmText: "是", confirmOnly: false)
        a.confirmCallback = { b in
            guard b else { return }
            self.navigationController?.loadingWith(string: "")
            let uw = self.wallets[indexPath.row]
            NetLayer.updateWalletBatch(address: uw.getAddress(mode: kAddressModeMain)) { _, _ in
                NetLayer.userInfoBatch { _, _ in
                    self.user = NetLayer.sessionUser(for: .weChat)!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.navigationController?.hideLoadingWith(string: "")
                    }
                }
            }
        }
        a.overlay(to: navigationController!)
    }
}
