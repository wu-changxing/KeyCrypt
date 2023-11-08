//
// Created by Aaron on 4/4/21.
// Copyright (c) 2021 life.whoops. All rights reserved.
//

import UIKit

class WalletSwitcherController: UITableViewController {
    let wallets = WalletUtil.getWalletList()
    var currentUW = WalletUtil.getCurrentWallet()!
    var user = NetLayer.sessionUser(for: .weChat)!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "切换钱包"
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.register(WalletCell.self, forCellReuseIdentifier: "cell")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        let b = UIButton()
        b.setTitle(" 钱包", for: .normal)
        b.titleLabel?.font = kBold28Font
        b.setImage(#imageLiteral(resourceName: "Group 1073"), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        b.layer.cornerRadius = 6
        b.addTarget(self, action: #selector(addWalletDidTap), for: .touchUpInside)
        b.frame = CGRect(x: 0, y: 0, width: 152 / 2, height: 32)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: b)
    }

    @objc func createWalletView() {
        navigationController?.pushViewController(CreateWalletPage1(), animated: true)
    }

    @objc func importWalletView() {
        let vc = ImportExportSelector()
        vc.isExport = false
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func addWalletDidTap() {
        let a = WhoopsWalletActionSheet()
        a.overlay(to: navigationController!)
        a.buttonImport.addTarget(self, action: #selector(importWalletView), for: .touchUpInside)
        a.buttonCreate.addTarget(self, action: #selector(createWalletView), for: .touchUpInside)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        wallets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WalletCell
        let uw = wallets[indexPath.row]
        cell.selectionStyle = .none
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
        let selectedUW = wallets[indexPath.row]
        WalletUtil.updateWalletInList(currentUW)
        guard selectedUW != currentUW else { return }
        WalletUtil.setCurrentWallet(selectedUW)
        currentUW = selectedUW
        tableView.reloadData()
    }
}
