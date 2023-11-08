//
//  ImportSelector.swift
//  Whoops
//
//  Created by Aaron on 3/15/21.
//  Copyright © 2021 life.whoops. All rights reserved.
//

import ConfluxSDK
import KeychainAccess
import PinLayout
import UIKit

class ImportExportSelector: UITableViewController {
    var isExport = false
    var isRecover = false

    let importSelectionList = [
        "导入私钥",
        "导入 Keystore",
        "导入助记词",
    ]

    var exportSelectionList: [String] = {
        if WalletUtil.hasWords() {
            return [
                "查看私钥",
                "导出 Keystore",
                "查看助记词",
            ]
        } else {
            return [
                "查看私钥",
                "导出 Keystore",
            ]
        }
    }()

    override func viewDidLoad() {
        title = isExport ? "导出钱包" : "导入钱包"
        tableView.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }

    func exportKeystore(pk: String, pwd: String) {
        tabBarController?.loadingWith(string: "加密中...")

        DispatchQueue.global().async {
            guard let pkData = Data(hexString: pk),
                  let s = try? Keystore(privateKey: pkData, passphrase: pwd)
            else {
                DispatchQueue.main.async {
                    self.tabBarController?.hideLoadingWith(string: "密码错误")
                }
                return
            }
            let path = get(localPath: "wallet-keystore")
            let encoder = JSONEncoder()
            let d = try? encoder.encode(s)
            try! d?.write(to: URL(fileURLWithPath: path))
            DispatchQueue.main.async {
                self.tabBarController?.hideLoadingWith(string: "完成！")
                let picker = UIDocumentPickerViewController(url: URL(fileURLWithPath: path), in: .exportToService)
                self.present(picker, animated: true, completion: { self.navigationController?.popViewController(animated: true) })
            }
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        60
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        isExport ? exportSelectionList.count : importSelectionList.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = isExport ? exportSelectionList[indexPath.row] : importSelectionList[indexPath.row]
        let image = #imageLiteral(resourceName: "Vector 56")
        let accessory = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        accessory.image = image
        accessory.tintColor = .black
        // set the color here
        cell.accessoryView = accessory
        cell.textLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        return cell
    }

    func export(with pwd: String, indexPath: IndexPath) {
        guard let wallet = WalletUtil.getWalletObj(pwd: pwd) else {
            let a = WhoopsAlertView(title: "密码错误", detail: "请重试。", confirmText: "好", confirmOnly: true)
            a.overlay(to: tabBarController!)
            return
        }
        switch indexPath.row {
        case 0:
            let page = PrivateKeyViewer()
            page.privateKey = wallet.privateKey().hexString.uppercased()
            navigationController?.pushViewController(page, animated: true)
        case 1:
            let a = NewPwdAlertView(title: "为该 Keystore 设置密码", placeholder: "密码")
            a.overlay(to: navigationController!)
            a.confirmCallback = { b, s in
                guard b else { return }
                self.exportKeystore(pk: wallet.privateKey().hexString, pwd: s)
            }

        case 2:
            let page = WordsViewer()
            page.words = WalletUtil.getWords(pwd: pwd)!.components(separatedBy: " ")
            navigationController?.pushViewController(page, animated: true)
        default: tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isExport {
            let keychain = Keychain(service: "life.whoops.app", accessGroup: "group.life.whoops.app")
            DispatchQueue.global().async {
                do {
                    let password = try keychain
                        .authenticationPrompt("认证以解锁钱包")
                        .get(WalletUtil.getCurrentWallet()!.id)
                    guard let p = password else { throw Status.invalidData }
                    DispatchQueue.main.async {
                        self.export(with: p, indexPath: indexPath)
                    }
                    //                    print("password: \(password)")
                } catch _ {
                    DispatchQueue.main.async {
                        let a = PwdAlertView(title: "输入钱包密码", placeholder: "密码", showRestore: true)
                        a.confirmCallback = { confirm, pwd in
                            guard confirm else { return }
                            self.export(with: pwd, indexPath: indexPath)
                        }
                        a.forgetCallback = {
                            let vc = ImportExportSelector()
                            vc.isExport = false
                            vc.isRecover = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        a.overlay(to: self.tabBarController!)
                    }
                }
            }

        } else {
            switch indexPath.row {
            case 0:
                let page = ImportPage1()
                page.isRecover = isRecover
                page.isWords = false
                navigationController?.pushViewController(page, animated: true)
            case 1:
                let documentTypes = ["public.content",
                                     "public.data",
                                     "public.text",
                                     "public.source-code"]

                let document = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
                document.delegate = self // UIDocumentPickerDelegate
                present(document, animated: true, completion: nil)
            case 2:
                let page = ImportPage1()
                page.isRecover = isRecover
                page.isWords = true
                navigationController?.pushViewController(page, animated: true)
            default: tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

extension ImportExportSelector: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        controller.dismiss(animated: true) {
            self.tabBarController?.loadingWith(string: "解密中...")

            DispatchQueue.global().async {
                guard let k = try? Keystore.keystore(url: url) else {
                    DispatchQueue.main.async {
                        self.tabBarController?.hideLoadingWith(string: "")
                        let a = WhoopsAlertView(title: "解析错误", detail: "请重新选择 Keystore。", confirmText: "好", confirmOnly: true)
                        a.overlay(to: self.tabBarController!)
                    }

                    return
                }
                DispatchQueue.main.async {
                    let a = PwdAlertView(title: "输入 Keystore 密码", placeholder: "Keystore 密码", showRestore: false)
                    a.confirmCallback = { c, pwd in
                        guard c else {
                            self.tabBarController?.hideLoadingWith(string: "")
                            return
                        }
                        DispatchQueue.global().async {
                            guard let pk = try? k.privateKey(passphrase: pwd) else {
                                DispatchQueue.main.async {
                                    self.tabBarController?.hideLoadingWith(string: "")
                                    let a = WhoopsAlertView(title: "密码错误", detail: "请重试。", confirmText: "好", confirmOnly: true)
                                    a.overlay(to: self.tabBarController!)
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                self.tabBarController?.hideLoadingWith(string: "完成！")
                                let page = ImportPage2()
                                page.isRecover = self.isRecover
                                page.privateKey = pk.raw.hexString
                                self.navigationController?.pushViewController(page, animated: true)
                            }
                        }
                    }
                    a.overlay(to: self.tabBarController!)
                }
            }
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
