//
//  TransferTokenSelector.swift
//  keyboard
//
//  Created by Aaron on 11/25/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import PinLayout
import UIKit

class TransferTokenSelector: UITableView, TransferViewNv {
    var nv: WhoopsNavigationController!
    weak var tranA: TransferViewA!

    func rightButtonSetting(_ sender: UIButton) {
        sender.isHidden = true
    }

    var tokens: [Token] = []
    let CFXAddress = WalletUtil.getAddress()!

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        backgroundColor = darkMode ? .black : .white
        register(WalletTokenCell.self, forCellReuseIdentifier: "cell")
        dataSource = self
        delegate = self
        separatorStyle = .none
        tokens = WalletUtil.getEnabledContract()
    }
}

extension TransferTokenSelector: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return tokens.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WalletTokenCell
        cell.textLabel?.textColor = darkMode ? .white : .darkText
        cell.valueLabel.textColor = darkMode ? .white : .darkText
        if indexPath.row == 0 {
            cell.setContent(token: nil, with: 0, mainAddress: CFXAddress)
        } else {
            cell.setContent(token: tokens[indexPath.row - 1], with: indexPath.row, mainAddress: CFXAddress)
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tranA.token = nil
        } else {
            tranA.token = tokens[indexPath.row - 1]
        }

        tranA.updateContent()
        nv.pop()
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
