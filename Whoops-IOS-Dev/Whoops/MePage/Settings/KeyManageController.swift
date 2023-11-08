//
//  KeyManageController.swift
//  Whoops
//
//  Created by Aaron on 7/22/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import UIKit

class KeyManageController: UITableViewController {
    var keys: [String] = []

    init() {
        super.init(style: .grouped)
        title = "聊天密钥"
        tableView.register(KeyCell.self, forCellReuseIdentifier: "cell")
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .white
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewDidLoad() {
        var pairs: [RSAKeyPairManager?] = []
        for p in Platform.allCases {
            pairs.append(RSAKeyPairManager(for: p, withNewPair: false))
        }

        keys = pairs.map { $0?.publicKey.fingerPrint() ?? "---" }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func numberOfSections(in _: UITableView) -> Int {
        3
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return Platform.allCases.count
        }
        if section == 1 {
            return 1
        }
        return 2
    }

    override func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < 2 else { return UIView() }
        let t = UILabel()
        t.text = section == 0 ? "      聊天公钥" : "      聊天私钥"
        t.font = kBold28Font
        t.backgroundColor = UIColor.white
        return t
    }

    override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 2 ? 1 : 20
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 2 ? 50 : 50
    }

    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cases = Platform.allCases
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! KeyCell
            cell.setContent(title: cases[indexPath.row].readableName, fp: keys[indexPath.row], pk: false)
            return cell
        }

        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! KeyCell
            cell.setContent(title: "",
                            fp: RSAKeyPairManager(for: .weChat, withNewPair: false)!.privateKey.fingerPrint(), pk: true)
            return cell
        }

        if indexPath.section == 2, indexPath.row == 0 {
            let cell = KeyCellButton()
            cell.setContent(title: "备份聊天密钥", destructive: false)
            cell.button.addTarget(self, action: #selector(backup), for: .touchUpInside)
            return cell
        }

        let cell = KeyCellButton()
        cell.setContent(title: "吊销聊天密钥", destructive: true)
        cell.button.addTarget(self, action: #selector(revoke), for: .touchUpInside)
        return cell
    }

    @objc func backup() {
        if keys.firstIndex(of: "---") != nil || keys.firstIndex(of: "吊销中...") != nil { return }
        exportKeyPairs(controller: navigationController!)
    }

    @objc func revoke() {
        let alert = WhoopsAlertView(title: "确认吊销聊天密钥？", detail: "确认吊销聊天密钥？该密钥关联的所有联系人、社媒资料、密钥将被永久清除。", confirmText: "是", confirmButtonText: "我知道啦", confirmOnly: false)
        alert.confirmCallback = {
            guard $0 else { return }
            self.navigationController?.loadingWith(string: "吊销中...")

            NetLayer.revokeBatch { ok, msg in
                DispatchQueue.main.async {
                    self.navigationController?.hideLoadingWith(string: "")
                    if ok {
                        let alert = WhoopsAlertView(title: "当前聊天密钥已吊销", detail: "请重新注册。", confirmText: "好", confirmOnly: true)
                        alert.confirmCallback = { _ in
                            let window = UIApplication.shared.delegate!.window!
                            let wel = WelcomeController()
                            let n = UINavigationController(rootViewController: wel)
                            window?.rootViewController = n
                        }
                        alert.overlay(to: self)
                    } else {
                        WhoopsAlertView.badAlert(msg: msg ?? "请重试。", vc: self)
                    }
                }
            }
        }

        alert.overlay(to: navigationController!)
    }
}

private class KeyCellButton: UITableViewCell {
    let button = UIButton(type: .system)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.titleLabel?.font = kBold34Font
        selectionStyle = .none
        contentView.addSubview(button)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.pin.height(40).vCenter().horizontally(contentView.pin.layoutMargins)
    }

    func setContent(title: String, destructive: Bool) {
        if destructive {
            button.layer.borderColor = UIColor(rgb: kButtonBorderColor).cgColor
            button.setTitleColor(.darkText, for: .normal)
        } else {
            button.layer.borderColor = UIColor(rgb: kWhoopsBlue).cgColor
            button.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
            button.setTitleColor(.white, for: .normal)
        }
        button.setTitle(title, for: .normal)
    }
}

private class KeyCell: UITableViewCell {
    let bgView = UIView()
    let cellTitle = UILabel()
    let fingerPrint = UILabel()
    var privateKey: Bool = false
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        bgView.layer.backgroundColor = UIColor.groupTableViewBackground.cgColor
        bgView.layer.cornerRadius = 6

        cellTitle.font = kBasic28Font

        fingerPrint.textColor = UIColor(rgb: 0x8F8F8F)
        fingerPrint.lineBreakMode = .byTruncatingMiddle
        fingerPrint.textAlignment = .right
        fingerPrint.font = kBasic28Font

        contentView.addSubview(bgView)
        contentView.addSubview(cellTitle)
        contentView.addSubview(fingerPrint)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.pin.vertically(5).horizontally(contentView.pin.layoutMargins.left)
        cellTitle.pin.sizeToFit().centerLeft(to: bgView.anchor.centerLeft).marginLeft(10)
        if privateKey {
            fingerPrint.pin.sizeToFit(.width).start(to: bgView.edge.left).end(to: bgView.edge.right).marginLeft(10).marginRight(10).vCenter()
        } else {
            fingerPrint.pin.sizeToFit(.width).start(to: cellTitle.edge.right).end(to: bgView.edge.right).marginLeft(20).marginRight(10).vCenter()
        }
    }

    func setContent(title: String, fp: String, pk: Bool) {
        cellTitle.text = title
        fingerPrint.text = fp
        fingerPrint.textAlignment = pk ? .center : .right
        privateKey = pk
    }
}
