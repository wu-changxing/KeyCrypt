//
//  AccountSettings.swift
//  Whoops
//
//  Created by Aaron on 3/27/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class AccountSettings: UITableViewController {
    let names = ["闲置账号自动清理", "查看聊天密钥", "关于", "注销"]

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func viewWillAppear(_: Bool) {
        settingNavigationBarWhite(controller: navigationController)
    }

    override func viewDidLoad() {
        title = "账户设置"
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        4
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = names[indexPath.row]
        cell.textLabel?.font = kBold28Font
        cell.textLabel?.textColor = indexPath.row == 3 ? .red : .darkText
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
        if indexPath.row == 0 {
            let vc = AutoDeleteController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 1 {
            let vc = KeyManageController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 2 {
            let vc = AboutPageController()
            navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.row == 3 {
            deleteKey()
        }
    }

    func deleteKey() {
        let v = WhoopsAlertView(title: "确认注销？", detail: "你可通过备份的聊天密钥恢复该账号的所有联系人和平台公钥。", confirmText: "注销", confirmButtonText: "我已备份聊天密钥", confirmOnly: false)
        v.confirmCallback = {
            guard $0 else { return }
            NetLayer.logoutAll()
            RSAKeyPairManager.deleteKeyPairs()
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            let n = UINavigationController(rootViewController: WelcomeController())

            let transtition = CATransition()
            transtition.duration = 0.5
            transtition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            window?.layer.add(transtition, forKey: "animation")
            window?.rootViewController = n
        }
        v.overlay(to: tabBarController!)
    }
}
