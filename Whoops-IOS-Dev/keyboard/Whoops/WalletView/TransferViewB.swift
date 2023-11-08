//
//  TransferViewB.swift
//  keyboard
//
//  Created by Aaron on 11/23/20.
//  Copyright © 2020 life.whoops. All rights reserved.
//

import ConfluxSDK
import Foundation
import KeychainAccess
import PinLayout
import UIKit

class TransferViewB: UIView, TransferViewNv {
    weak var nv: WhoopsNavigationController!
    func rightButtonSetting(_ sender: UIButton) {
        sender.isHidden = true
    }

    let confirmButton = UIButton()
    let pwdField = CYMTextView()
    let pwdBg = UIView()
    let forgetLabel = UILabel()
    let forgetButton = UIButton()
    let dismissKeyboardButton = UIButton()

    var toUser: WhoopsUser!
    var token: Token!
    var mainAddress: String!
    var gas = 1
    var gasLimit = 21000
    var sendingValue = 0.0
    var currentAvailableBalance = 0.0
    var storageLimit = -1
    var textEncryption = true

    //=====redpacket====
    var rootHash = ""
    var groupMemberCount = 0
    var groupId = 0
    var isRedpacket = false
    var redpacketNumber = 1

    init() {
        super.init(frame: .zero)

        backgroundColor = darkMode ? .black : kColorSysBg
        dismissKeyboardButton.backgroundColor = UIColor.white.withAlphaComponent(0.001)
        dismissKeyboardButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        addSubview(dismissKeyboardButton)

        pwdBg.layer.backgroundColor = darkMode ? UIColor.darkGray.cgColor : UIColor.white.cgColor
        pwdBg.layer.cornerRadius = 6
        pwdBg.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        pwdBg.layer.shadowOpacity = 1
        pwdBg.layer.shadowRadius = 6
        pwdBg.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(pwdBg)

        pwdField.placeholder = "钱包密码"
        pwdField.placeholderColor = darkMode ? .darkGray : .lightGray
        pwdField.isSecureTextEntry = true
        pwdField.textColor = darkMode ? .white : .darkText
        pwdField.backgroundColor = darkMode ? UIColor.darkGray : UIColor.white
        pwdField.font = kBasicFont(size2x: 40)
        pwdField.delegate = self
        addSubview(pwdField)

        confirmButton.layer.cornerRadius = 4
        if #available(iOSApplicationExtension 13.0, *) {
            confirmButton.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        confirmButton.layer.backgroundColor = UIColor(rgb: kWhoopsBlue).cgColor
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.titleLabel?.font = kBasic28Font
        confirmButton.clipsToBounds = true
        confirmButton.addTarget(self, action: #selector(sendTokenDidTap), for: .touchUpInside)
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.5
        addSubview(confirmButton)

        forgetLabel.text = "忘记密码？"
        forgetLabel.font = kBasic28Font
        forgetLabel.textColor = .gray
        addSubview(forgetLabel)

        forgetButton.setTitle("从助记词恢复", for: .normal)
        forgetButton.titleLabel?.font = kBold28Font
        forgetButton.setTitleColor(UIColor(rgb: kWhoopsBlue), for: .normal)
        forgetButton.addTarget(self, action: #selector(forgetPwdDidTap), for: .touchUpInside)
        addSubview(forgetButton)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dismissKeyboardButton.pin.all()
        pwdBg.pin.height(60).horizontally(14).top(10)
        confirmButton.pin.width(68).height(40).centerRight(to: pwdBg.anchor.centerRight).marginRight(10)
        pwdField.pin.height(50).centerLeft(to: pwdBg.anchor.centerLeft).marginLeft(14).right(to: confirmButton.edge.left).marginRight(10)

        forgetLabel.pin.sizeToFit().top(to: pwdBg.edge.bottom).marginTop(30).right(to: pwdBg.edge.hCenter)
        forgetButton.pin.sizeToFit().after(of: forgetLabel, aligned: .center)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        let keychain = Keychain(service: "life.whoops.app", accessGroup: "group.life.whoops.app")
        DispatchQueue.global().async {
            do {
                let password = try keychain
                    .authenticationPrompt("认证以解锁钱包")
                    .get(WalletUtil.getCurrentWallet()!.id)
                DispatchQueue.main.async {
                    self.pwdField.text = password
                    self.textViewDidChange(self.pwdField)
                }
//                    print("password: \(password)")
            } catch {
//                    print(error,11111)
                // Error handling if needed...
            }
        }
    }

    @objc func forgetPwdDidTap() {
        UIApplication.fuckApplication().fuckURL(url: URL(string: "whoops://forget")!)
    }

    @objc func sendTokenDidTap() {
        dismissKeyboard()
        let pwd = pwdField.text!
        sendTokenWithPwd(pwd)
    }

    @objc func dismissKeyboard() {
        pwdField.endEditing(true)
        guard isTempInputing else { return }
        (KeyboardViewController.inputProxy as! KeyboardViewController).hideKeyboardTemp()
    }

    private func sendTransaction(wallet: Wallet, g: Gcfx, rawTransaction: RawTransaction) {
        guard let transactionHash = try? wallet.sign(rawTransaction: rawTransaction) else {
            error(ConfluxError.cryptoError(.failedToSign))
            return
        }

        g.sendRawTransaction(rawTransaction: transactionHash) { r in
            switch r {
            case let .success(hash):
                DispatchQueue.main.async {
                    self.nv.loadingWith(string: "正在交易...")
                }
                DispatchQueue.global(qos: .userInitiated).async { // 这里必须到另一个线程执行，否则gcfx不会回调
                    self.checkStatusOfTransaction(by: hash.id, g: g)
                }

            case let .failure(e):

                self.error(e)
                DispatchQueue.main.async {
                    let a = WhoopsAlertView(title: "转账出错", detail: "出现此错误也可能是 CFX 余额不足无法支付 gas 导致。", confirmText: "好", confirmOnly: true)
                    a.overlay(to: self.nv)
                }
            }
        }
    }

    private func sendToken(wallet: Wallet, nonce: Int, epoch: Int, g: Gcfx) {
        if let t = token {
            let formatSendValue = sendingValue.dripIn(decimals: t.decimals)
            var data: Data

            if isRedpacket {
                data = ConfluxToken.ContractFunctions.redpacket(redpacketAddress: WalletUtil.redpacketAddress, groupId: groupId, amount: formatSendValue, mode: 0, number: redpacketNumber, whiteCount: groupMemberCount, rootHash: rootHash, msg: "").data
            } else {
                data = ConfluxToken.ContractFunctions.transfer(address: toUser.walletAddress, amount: formatSendValue).data
            }

            let rawTransaction = ConfluxSDK.RawTransaction(value: 0, to: t.contract, gasPrice: gas, gasLimit: gasLimit, nonce: nonce, data: data, storageLimit: Drip(storageLimit), epochHeight: Drip(epoch), chainId: g.chainId)
            sendTransaction(wallet: wallet, g: g, rawTransaction: rawTransaction)

        } else {
            var sendValueIntDrip = sendingValue.dripInCFX()
            var data = Data()
            var toAddress = toUser.walletAddress
            if isRedpacket {
                data = ConfluxToken.ContractFunctions.redpacketCFX(mode: 0, groupId: groupId, number: redpacketNumber, whiteCount: groupMemberCount, rootHash: rootHash, msg: "").data
                toAddress = WalletUtil.redpacketAddress
            } else {
                let currentBalanceDrip = currentAvailableBalance.dripInCFX()
                let x = currentBalanceDrip - sendValueIntDrip
                if x < 21000 {
                    sendValueIntDrip = sendValueIntDrip - 21000 + x
                }
            }
            let rawTransaction = RawTransaction(value: sendValueIntDrip, to: toAddress, gasPrice: gas, gasLimit: gasLimit, nonce: nonce, data: data, storageLimit: Drip(storageLimit), epochHeight: Drip(epoch), chainId: g.chainId)

            sendTransaction(wallet: wallet, g: g, rawTransaction: rawTransaction)
        }
    }

    private func sendTokenWithPwd(_ pwd: String) {
        pwdField.endEditing(true)

        guard let wallet = WalletUtil.getWalletObj(pwd: pwd) else {
            let d = WhoopsAlertView(title: "密码错误", detail: "如忘记密码，请重新导入钱包以重置密码。", confirmText: "好", confirmOnly: true)
            d.overlay(to: nv)
            return
        }

        nv.loadingWith(string: "处理中...")
        let g = WalletUtil.getGcfx()

        g.getNextNonce(of: mainAddress) { r in
            switch r {
            case let .success(n):
                g.getEpochNumber { r in
                    switch r {
                    case let .success(e):

                        self.sendToken(wallet: wallet, nonce: n, epoch: e, g: g)

                    case let .failure(e):
                        self.error(e)
                    }
                }
            case let .failure(e):
                self.error(e)
            }
        }
    }

    private func error(_ e: ConfluxError) {
        var eStr = ""
        switch e {
        case let .requestError(e1):
            eStr = e1.localizedDescription
        case let .responseError(e2):
            switch e2 {
            case let .connectionError(ee):
                eStr = ee.localizedDescription
            case let .unexpected(ee):
                eStr = ee.localizedDescription
            default:
                eStr = e2.localizedDescription
            }
        default:
            eStr = e.localizedDescription
        }
        DispatchQueue.main.async {
            KeyboardViewController.inputProxy?.toast(str: eStr)
            self.nv.hideLoadingWith(string: "")
        }
    }

    private func checkStatusOfTransaction(by hash: String, g: Gcfx) {
        var status = -1
        repeat {
            if isRedpacket { break } // 如果是红包，就不用等交易生效了

            sleep(1)
            let group = DispatchGroup()
            group.enter()
            g.getTransactionStatus(by: hash) { r in
                switch r {
                case let .success(n):
                    status = n
                case .failure:
                    break
                }
                group.leave()
            }
            _ = group.wait(timeout: .now() + 10)

        } while status < 0

        let successStr = isRedpacket ? "红包已发送" : "转账成功"
        let failStr = isRedpacket ? "发红包失败" : "转账失败"
        let s = status == 0 || isRedpacket ? successStr : failStr
        DispatchQueue.main.async {
            self.nv.hideLoadingWith(string: s)

            if status != 0, !self.isRedpacket {
                let a = WhoopsAlertView(title: failStr, detail: "请跳转 ConfluxScan 查看交易详情。", confirmText: "跳转", confirmOnly: false)
                a.confirmCallback = {
                    guard $0 else {
                        self.nv.dismiss()
                        return
                    }
                    UIApplication.fuckApplication().fuckURL(url: URL(string: "https://www.confluxscan.io/transaction/\(hash)")!)
                }
                a.overlay(to: self.nv)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    ChatEngine.shared.setTarget(user: self.toUser)
                    if self.isRedpacket {
                        ChatEngine.shared.sendRedPack(value: self.sendingValue, count: self.redpacketNumber, hash: hash, token: self.token, textEncrypt: self.textEncryption, rootHash: self.rootHash)
                    } else {
                        ChatEngine.shared.sendTransfer(value: self.sendingValue, hash: hash, token: self.token, textEncrypt: self.textEncryption)
                    }

                    self.nv.dismiss()
                }
                // 转账成功！
            }
        }
    }
}

extension TransferViewB: CYMTextViewDelegate {
    func textViewDidBeginEditing(_: UITextView) {
        (KeyboardViewController.inputProxy as! KeyboardViewController).showKeyboard(tmpInput: nil)
    }

    func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            dismissKeyboard()
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count < 8 {
            confirmButton.alpha = 0.5
            confirmButton.isEnabled = false
        } else {
            confirmButton.alpha = 1
            confirmButton.isEnabled = true
        }
    }
}
