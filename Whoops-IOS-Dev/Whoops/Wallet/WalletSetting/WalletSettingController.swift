//
//  WalletSettingController.swift
//  Whoops
//
//  Created by Aaron on 4/2/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import UIKit

class WalletSettingController: UITableViewController {
    let names = ["修改钱包名", "导出钱包", "红包绑定"]
    var bindingName: String?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
        let user = NetLayer.sessionUser(for: .weChat)!
        for uw in WalletUtil.getWalletList() where uw.getAddress(mode: kAddressModeMain) == user.walletAddress {
            bindingName = uw.name
            break
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        title = "钱包设置"
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        3
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = names[indexPath.row]
        cell.textLabel?.font = kBold28Font
        cell.detailTextLabel?.font = kBasic28Font
        cell.detailTextLabel?.textColor = .gray

        if indexPath.row == 0 {
            cell.detailTextLabel?.text = WalletUtil.getCurrentWallet()!.name
        }
        if indexPath.row == 1 {
            cell.detailTextLabel?.text = ""
        }
        if indexPath.row == 2 {
            cell.detailTextLabel?.text = bindingName
        }

        let image = #imageLiteral(resourceName: "Vector 56")
        let accessory = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        accessory.image = image
        accessory.tintColor = .black
        // set the color here
        cell.accessoryView = accessory
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        50
    }

    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        1
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            let vc = ImportExportSelector()
            vc.isExport = true
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 2 {
            bindingName = nil
            let vc = RedpacketBindingView()
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 0 {
            navigationController?.pushViewController(WalletRenameView(), animated: true)
        }
    }
}
